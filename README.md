fedora-qemu-user-static
=======================

Borrowing heavily from the
[docker.io/multiarch/qemu-user-static](https://hub.docker.com/r/multiarch/qemu-user-static)
image and
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
```

To turn off emulation:
```
  docker run --rm --privileged ghcr.io/nalind/fedora-qemu-user-static unregister
  sudo podman run --rm --privileged ghcr.io/nalind/fedora-qemu-user-static unregister
```

Known Limitations
=================

Attempting to use emulators from one container to run binaries in another
container is a case of letting one container mess with another.  If your system
is using SELinux in enforcing mode, this is almost certainly going to not be
allowed.  It _can_ work if the container which needs to be run under emulation
is started without SELinux confinement using the `--security-opt label=disable`
option, but it's a tradeoff that's best avoided if possible.

We're heavily dependent on the quality of the emulation.  It should go without
saying, but if something breaks, you get to keep all of the pieces.
