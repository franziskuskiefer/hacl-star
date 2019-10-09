#!/usr/bin/env bash
set -e

# Look for config.json file
FILE=".docker/build/config.json"
if [[ ! -f $FILE ]]; then
   echo "File $FILE does not exist."
fi

# In case you want to build windows, change agentOS here to windows-nt if OSTYPE is not working
agentOS=linux
if [[ "$OSTYPE" == "cygwin" ]]; then
    agentOS=linux #windows-nt
fi

DOCKERCOMMAND=$(jq -c -r ".DockerCommand" "$FILE")
DOCKERSTYLE=$(jq -c -r ".DockerStyle" "$FILE")

DOCKERFILE=$(jq -c -r ".DockerFile" "$FILE")
DOCKERFILE=$( echo ${DOCKERFILE} | sed "s/{agentOS}/${agentOS}/g" )

# Copy dockerfile to root
cp $DOCKERFILE ./Dockerfile

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
    COMMITURL=$(jq -c -r ".GithubCommitUrl" "$FILE")/$REQUESTEDCOMMITID
    LINE="$( git ls-remote ${COMMITURL%"/commit/master"} HEAD)"
    FULLCOMMITID="$( echo ${LINE} | cut -f1 )"
    COMMITID=${FULLCOMMITID:0:12}
else
    COMMITID=$REQUESTEDCOMMITID
fi


# create fake files ssh key, commitinfofilename.json, etc
echo "fake" > id_rsa
echo "fake" > commitinfofilename.json

# build container
$DOCKERCOMMAND build --file Dockerfile --build-arg BUILDLOGFILE="buildlogfile.txt" --build-arg MAXTHREADS="8" --build-arg BUILDTARGET="$BUILDTARGET" --build-arg BRANCHNAME="$LOCALBRANCHNAME" --build-arg COMMITID="$COMMITID" --build-arg DOCKERHUBPROJECT="projecteverest/" --tag "$PROJECTNAME:local" .

# run docker container if this is a build
if [[ "$DOCKERSTYLE" == "run" ]]; then
    $DOCKERCOMMAND run --rm -ti "$PROJECTNAME:local"
fi

# delete fake files
rm -f id_rsa
rm -f commitinfofilename.json

rm -f build.sh
rm -f build_helper.sh
rm -f id_rsa
rm -f commitinfofilename.json

# Remove dep files.
for f in $DEPFILES; do rm -f $(basename $f); done

# delete dockerfile
rm -f Dockerfile
