#!/bin/bash
set -e
check() {
	if ! test -w /proc/sys/fs/binfmt_misc/register; then
		mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc || true
	fi
	if ! test -w /proc/sys/fs/binfmt_misc/register; then
		echo No /proc/sys/fs/binfmt_misc/register in container.  Please \`modprobe binfmt_misc\` and run with --privileged.
		exit 1
	fi
}
register() {
	for binfmt in /usr/lib/binfmt.d/* ; do
		name=$(cut -f2 -d: ${binfmt})
		echo -n "${name}: "
		if test -r /proc/sys/fs/binfmt_misc/${name} ; then
			echo -n -1 > /proc/sys/fs/binfmt_misc/${name} 
		fi
		cat ${binfmt} > /proc/sys/fs/binfmt_misc/register && echo ok
	done
}
unregister() {
	for binfmt in /usr/lib/binfmt.d/* ; do
		name=$(cut -f2 -d: ${binfmt})
		echo -n "${name}: "
		echo -n -1 > /proc/sys/fs/binfmt_misc/${name} && echo ok
	done
}

IMAGE=${IMAGE:-IMAGE}
runtime='$RUNTIME'
if test -f /run/.containerenv; then
	runtime=podman
elif test -f /.dockerenv; then
	runtime=docker
fi

case "$1" in
	register)
		check && register
		;;
	unregister)
		check && unregister
		;;
	*)
		check
		echo "usage: ${runtime} run --rm --privileged ${IMAGE} register | unregister"
		;;
esac
