FROM registry.fedoraproject.org/fedora
RUN dnf -y install qemu-user-static && dnf clean all
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
ARG IMAGE=fedora-qemu-user-static
ENV IMAGE=${IMAGE}
