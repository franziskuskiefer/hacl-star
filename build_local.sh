#!/usr/bin/env bash
set -e

# Look for config.json file
FILE=${1:-".docker/build/config.json"}
if [[ ! -f $FILE ]]; then
   echo "File $FILE does not exist."
fi

# In case you want to build windows, change agentOS here to windows-nt if OSTYPE is not working
agentOS=linux
if [[ "$OSTYPE" == "cygwin" ]]; then
    agentOS=linux #windows-nt
fi

BASEIMAGE="hacl-base"

MAXTHREADS=$(jq -c -r ".MaxThreads" "$FILE")

DOCKERCOMMAND=$(jq -c -r ".DockerCommand" "$FILE")
DOCKERSTYLE=$(jq -c -r ".DockerStyle" "$FILE")

DOCKERFILE=$(jq -c -r ".DockerFile" "$FILE")
DOCKERFILE=$( echo ${DOCKERFILE} | sed "s/{agentOS}/${agentOS}/g" )
DOCKERFILEPERSIST=$(jq -c -r ".DockerFilePersist" "$FILE")
DOCKERFILEPERSIST=$( echo ${DOCKERFILEPERSIST} | sed "s/{agentOS}/${agentOS}/g" )

# Copy dependencies
DEPFILES=$(jq -c -r ".DependencyFiles[]" "$FILE")
cp -r $DEPFILES .

PROJECTNAME=$(jq -c -r ".ProjectName" "$FILE" | awk '{print tolower($0)}')
BUILDTARGET=$(jq -c -r ".CIBuildTarget" "$FILE")
LOCALBRANCHNAME=$(git branch | grep \* | cut -d ' ' -f2)

#Find commit id.
REQUESTEDBRANCHNAME=$(jq -c -r ".BranchName" "$FILE")
REQUESTEDCOMMITID=$(jq -c -r ".BaseContainerImageTagOrCommitId" "$FILE")
COMMITURL=$(jq -c -r ".GithubCommitUrl" "$FILE")/$REQUESTEDBRANCHNAME

if [[ "$REQUESTEDCOMMITID" == "latest" ]]; then
    LINE="$( git ls-remote https://github.com/FStarLang/FStar HEAD)"
    FULLCOMMITID="$( echo ${LINE} | cut -f1 )"
    COMMITID=${FULLCOMMITID:0:12}
else
    COMMITID=$REQUESTEDCOMMITID
fi

# create fake files ssh key, commitinfofilename.json, etc
echo "fake" > id_rsa
echo "fake" > commitinfofilename.json

# clean any container running with the name we want to use
$DOCKERCOMMAND stop "$BASEIMAGE-run" || true
$DOCKERCOMMAND rm "$BASEIMAGE-run" || true

# build base container
$DOCKERCOMMAND build --file ${DOCKERFILE} \
    --build-arg BUILDLOGFILE="buildlogfile.txt" \
    --build-arg MAXTHREADS="$MAXTHREADS" --build-arg BUILDTARGET="$BUILDTARGET" \
    --build-arg BRANCHNAME="$LOCALBRANCHNAME" --build-arg COMMITID="$COMMITID" \
    --build-arg DOCKERHUBPROJECT="projecteverest/" --tag "$BASEIMAGE:wip" .

# run docker container and build
$DOCKERCOMMAND run -v $PWD:/home/everest/hacl-star --name "$BASEIMAGE-run" -ti "$BASEIMAGE:wip"

# commit the docker image with build environment (not build artifacts) and clean-up
$DOCKERCOMMAND commit "$BASEIMAGE-run" "$BASEIMAGE"
$DOCKERCOMMAND stop "$BASEIMAGE-run"
$DOCKERCOMMAND rm "$BASEIMAGE-run"
$DOCKERCOMMAND rmi "$BASEIMAGE:wip"

# build persisting container
$DOCKERCOMMAND build --build-arg BASEIMAGE="$BASEIMAGE" \
    --file ${DOCKERFILEPERSIST} --tag "$PROJECTNAME:local" .

# delete temporary build files
rm -f build.sh
rm -f build_helper.sh
rm -f hacl-ci

# delete fake files
rm -f id_rsa
rm -f commitinfofilename.json

# Remove dep files.
for f in $DEPFILES; do rm -f $(basename $f); done
