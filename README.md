fedora-qemu-user-static
=======================

Borrowing heavily from the
[docker.io/multiarch/qemu-user-static](https://hub.docker.com/r/multiarch/qemu-user-static)
and [tonistiigi/binfmt](https://hub.docker.com/r/tonistiigi/binfmt)
images and
references at https://dbhi.github.io/qus/, this image is based on Fedora with
its qemu-user-static package installed.  There are many variations on this
theme, and this is one more.

If your Linux distribution includes a `qemu-user-static` package, I
enthusiastically recommend
that you install it instead of attempting to use this image.  On Fedora, at
least, the packaging does all of the right things automatically, and updates
for the package are also provided by the distribution.

For everyone else, when run using the `--privileged` flag using docker or
podman (as root), its entry point script will register the static qemu binaries
that it includes with the `binfmt_misc` module in the host's kernel.  The
registration is done using the flags that instruct the kernel to load the
emulator binary immediately, so the fact that they're in a container that will
be removed immediately after is not an issue.

TL;DR
=====

To turn on emulation:
```
  docker run --rm --privileged ghcr.io/nalind/fedora-qemu-user-static register
  sudo podman run --rm --privileged ghcr.io/nalind/fedora-qemu-user-static register
  podman machine ssh sudo podman run --rm --privileged ghcr.io/nalind/fedora-qemu-user-static register
```

To turn off emulation:
```
  docker run --rm --privileged ghcr.io/nalind/fedora-qemu-user-static unregister
  sudo podman run --rm --privileged ghcr.io/nalind/fedora-qemu-user-static unregister
  podman machine ssh sudo podman run --rm --privileged ghcr.io/nalind/fedora-qemu-user-static unregister
```

SELinux
=======

SELinux policy would normally not allow binaries in one container to access
binaries in another container, so an additional workaround is required.

A workaround that has worked for me is to copy the interpreters to a mounted
volume, relabel them, and register them from there.  SELinux policy will then
allow them to run binaries in containers.

To turn on emulation using that workaround:
```
  docker run --rm --privileged -v $(sudo mktemp -d -p /run -t qemu-user-static-XXXXXX):/usr/local/bin -e BINDIR=/usr/local/bin -e CHCON="-t bin_t" ghcr.io/nalind/fedora-qemu-user-static register
  sudo podman run --rm --privileged -v /usr/local/bin -e BINDIR=/usr/local/bin -e CHCON="-t bin_t" ghcr.io/nalind/fedora-qemu-user-static register
  podman machine ssh sudo podman run --rm --privileged -v /usr/local/bin -e BINDIR=/usr/local/bin -e 'CHCON="-t bin_t"' ghcr.io/nalind/fedora-qemu-user-static register
```

To turn off emulation:
```
  docker run --rm --privileged ghcr.io/nalind/fedora-qemu-user-static unregister
  sudo podman run --rm --privileged ghcr.io/nalind/fedora-qemu-user-static unregister
  podman machine ssh sudo podman run --rm --privileged ghcr.io/nalind/fedora-qemu-user-static unregister
```

We're heavily dependent on the quality of the emulation.  It should go without
saying, but if something breaks, you get to keep all of the pieces.
