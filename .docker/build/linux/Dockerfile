# base hacl build container

# Define on fstar-version.json what FStar base container image
# hacl build should use.
# By default it always look for the latest FStar container available
# In case you would like to reference a specific commit,
# replace latest with the commit id from github using 12 characters.
#
# This is the base image for both docker builds.
ARG DOCKERHUBPROJECT
ARG COMMITID
FROM ${DOCKERHUBPROJECT}fstar-linux:${COMMITID}

ARG BUILDLOGFILE
ARG MAXTHREADS
ARG BUILDTARGET
ARG BRANCHNAME

# Do some cleanup
RUN rm -f build.sh & \
    rm -f build_helper.sh & \
    rm -f buildlogfile.txt & \
    rm -f log_no_replay.html & \
    rm -f log_worst.html & \
    rm -f orange_status.txt & \
    rm -f result.txt & \
    rm -f status.txt & \
    rm -f commitinfofilename.json

COPY --chown=everest build.sh ${MYHOME}/build.sh
RUN chmod +x build.sh
COPY --chown=everest build_helper.sh ${MYHOME}/build_helper.sh
RUN chmod +x build_helper.sh

ENV BUILDTARGET ${BUILDTARGET}
ENV BUILDLOGFILE ${BUILDLOGFILE}
ENV MAXTHREADS ${MAXTHREADS}
ENV BRANCHNAME ${BRANCHNAME}

ENTRYPOINT ./build_helper.sh ${BUILDTARGET} ${BUILDLOGFILE} ${MAXTHREADS} ${BRANCHNAME}
