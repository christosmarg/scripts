#!/bin/sh

usage()
{
	echo "usage: ${0##*/} [-a artist] [-A album_title] [-c comment]" 1>&2
	echo "	[-d year] [-g genre] [-n trackno] [-N totalno]" 1>&2
	echo "	[-t song_title] file" 1>&2
	exit 1
}

xread()
{
        printf "%s" "${1}" && read -r ${2}
}

while getopts "a:t:A:n:N:d:g:c:f:" arg; do
case "${arg}" in
	a) artist="${OPTARG}" ;;
	t) title="${OPTARG}" ;;
	A) album="${OPTARG}" ;;
	n) track="${OPTARG}" ;;
	N) total="${OPTARG}" ;;
	d) date="${OPTARG}" ;;
	g) genre="${OPTARG}" ;;
	c) comment="${OPTARG}" ;;
	f) file="${OPTARG}" ;;
	*) usage ;;
esac
done
shift $((OPTIND - 1))

file="${1}"
test ! -f "${file}" && echo "${0##*/}: file not found" && usage

test -z "${title}" && xread "Title: " title
test -z "${artist}" && xread "Artist: " artist
test -z "${album}" && xread "Album: " album
test -z "${track}" && xread "Track number: " track

info="Title=${title}
Artist=${artist}
Album=${album}
Track=${track}
Total=${total}
Date=${date}
Genre=${genre}
Comment=${comment}"

echo "${info}"

case "${file}" in
	*.ogg)	echo "${info}" | vorbiscomment -w "${file}" ;;
	*.opus)	echo "${info}" | opustags -i -S "${file}" ;;
	*.mp3)	eyeD3 -Q --remove-all \
			-a "${artist}" \
			-A "${album}" \
			-t "${title}" \
			-n "${track}" \
			-N "${total}" \
			-Y "${date}" \
			"${file}" ;;
	*)	echo "${0##*/}: file type not implemented yet" ;;
esac
