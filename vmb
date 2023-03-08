#!/bin/sh

# TODO virtio-blk
# TODO is grub complete?

cpu="2"
mem="2G"
disk="disk.img"
tap="tap0"
uefifile="/usr/local/share/uefi-firmware/BHYVE_UEFI.fd"

usage()
{
	echo "usage: ${0##*/} start [-Duv] [-c cpu] [-C com] [-d disksiz]" 1>&2
	echo "               [-g grub_bootdrv] [-G grub_bootdir] [-i img]" 1>&2
	echo "               [-m mem] [-t tap] vmname" 1>&2
	echo "       ${0##*/} stop [-t tap] vmname" 1>&2
	echo "       -D: pause at first instruction and wait for gdb" 1>&2
	echo "       -u: run in uefi mode" 1>&2
	echo "       -v: wait until the vnc client has started" 1>&2
	exit 1
}

err()
{
	echo "${0##*/}: ${@}" 1>&2
	exit 1
}

vmb_start()
{
	while getopts "c:C:d:Dg:G:i:m:t:uv" arg; do
	case "${arg}" in
		c) cpu="${OPTARG}" ;;
		C) com="${OPTARG}" ;;
		d) disksiz="${OPTARG}" ;;
		D) dbgw="w" ;;
		g) grubdrv="${OPTARG}" ;;
		G) grubdir="${OPTARG}" ;;
		i) img="${OPTARG}" ;;
		m) mem="${OPTARG}" ;;
		t) tap="${OPTARG}" ;;
		u) uefi="-l bootrom,${uefifile}" ;;
		v) vncwait=",wait" ;;
		*) usage ;;
	esac
	done
	shift $((OPTIND - 1))

	name="${1}"
	test -z "${name}" && usage

	if [ -n "${uefi}" ]; then
		test ! -f ${uefifile} && \
		err "uefi file \"${uefifile}\" not found." \
		"Install $(pkg search uefi-edk2 | awk '{print $1}')"
	fi

	if [ -n "${grubdrv}" ] || [ -n "${grubdir}" ]; then
		test ! "$(pkg info | awk '{print $1}' | grep grub2-bhyve)" &&
		err "grub driver not found." \
		"Install $(pkg search grub2-bhyve | awk '{print $1}')"
	fi

	ifconfig "${tap}" up || exit 1

	test -n "${disksiz}" && truncate -s "${disksiz}" ${disk}

	if [ -n "${grubdrv}" ]; then
		echo "(hd0) disk.img" > device.map
		${img:+(cd0) ${img}} >> device.map
		grub-bhyve \
			-m device.map \
			-r ${grubdrv} \
			${grubdir:+-d ${grubdir}} \
			-M ${mem} \
			${name}
	fi

	bhyve \
		-wHAP \
		-c ${cpu} \
		-m ${mem} \
		-s 0,hostbridge \
		${img:+-s 3,ahci-cd,${img}} \
		-s 4,ahci-hd,${disk} \
		-s 5,virtio-net,${tap} \
		-s 29,fbuf,tcp=0.0.0.0:5900${vncwait} \
		-s 30,xhci,tablet \
		-s 31,lpc \
		-G ${dbgw}1234 \
		${com:+-l com1,${com}} \
		${uefi:+${uefi}} \
		${name}
}

vmb_stop()
{
	while getopts "t:" arg; do
	case "${arg}" in
		t) tap="${OPTARG}" ;;
		*) usage ;;
	esac
	done
	shift $((OPTIND - 1))

	name="${1}"
	test -z "${name}" && usage

	ifconfig ${tap} down
	bhyvectl --force-poweroff --vm=${name}
	bhyvectl --destroy --vm=${name}
}

cmd="${1}"
shift 1
case "${cmd}" in
	start) vmb_start $@ ;;
	stop) vmb_stop $@ ;;
	*) usage ;;
esac
