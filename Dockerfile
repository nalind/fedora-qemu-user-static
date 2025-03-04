ARG FEDORARELEASE=41
FROM registry.fedoraproject.org/fedora:${FEDORARELEASE}
RUN dnf -y distro-sync && dnf -y install --setopt install_weak_deps=0 qemu-user-static /usr/bin/mount /usr/bin/chcon && dnf clean all
COPY LICENSE entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
ARG IMAGE=ghcr.io/nalind/fedora-qemu-user-static
ENV IMAGE=${IMAGE}
ARG SOURCE=https://github.com/nalind/fedora-qemu-user-static
LABEL org.opencontainers.image.source=${SOURCE}
LABEL org.opencontainers.image.description="When run with privileges, registers Fedora's qemu-user-static package's interpreters with the host's binfmt_misc kernel module."
