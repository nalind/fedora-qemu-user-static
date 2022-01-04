#!/bin/bash
set -e
check() {
	if ! test -w /proc/sys/fs/binfmt_misc/register; then
		# kernel facility not already available; hope it's a module that we can force to be loaded
		mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc || true
	fi
	if ! test -w /proc/sys/fs/binfmt_misc/register; then
		# kernel facility still not available; hope it's a module that we could force to be loaded
		echo No /proc/sys/fs/binfmt_misc/register in container.  Please \`modprobe binfmt_misc\` and run with --privileged.
		exit 1
	fi
}
register() {
	for binfmt in /usr/lib/binfmt.d/* ; do
		name=$(cut -f2 -d: ${binfmt})
		binary=$(cut -f7 -d: ${binfmt})
		echo -n "${name}: "
		if test -r /proc/sys/fs/binfmt_misc/${name} ; then
			# clear previous registration
			echo -n -1 > /proc/sys/fs/binfmt_misc/${name} 
		fi
		if test -n "${BINDIR}" ; then
			# optionally copy this binary to a volume
			install -v "${binary}" "${BINDIR}/"
			if test -n "${CHCON}" ; then
				# optionally try to relabel the binary in the volume
				chcon -v ${CHCON} "${BINDIR}/${binary##*/}" || :
			fi
		fi
		sed "s#/usr/bin#${BINDIR:-/usr/bin}#g" ${binfmt} > /proc/sys/fs/binfmt_misc/register && echo ok
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
