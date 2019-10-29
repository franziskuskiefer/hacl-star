# hacl build container
# This container only copies the local hacl-star folder into the image

ARG BASEIMAGE
FROM ${BASEIMAGE}

# Copy source files (Note that hacl-star is part of the image already)
COPY --chown=everest / ${MYHOME}/hacl-star/

# Remove ssh identities.
RUN rm -f ${MYHOME}/.ssh/id_rsa

# Reset entrypoint
ENTRYPOINT /bin/bash
