ARG FEDORARELEASE=36
FROM registry.fedoraproject.org/fedora-minimal:${FEDORARELEASE}
RUN microdnf -y distro-sync && microdnf -y install --setopt install_weak_deps=0 qemu-user-static /usr/bin/mount /usr/bin/chcon && microdnf clean all
COPY LICENSE entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
ARG IMAGE=ghcr.io/nalind/fedora-qemu-user-static
ENV IMAGE=${IMAGE}
ARG SOURCE=https://github.com/nalind/fedora-qemu-user-static
LABEL org.opencontainers.image.source=${SOURCE}
LABEL org.opencontainers.image.description="When run with privileges, registers Fedora's qemu-user-static package's interpreters with the host's binfmt_misc kernel module."
