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
test -z "${total}" && xread "Total tracks in album: " total
test -z "${date}" && xread "Date: " date
test -z "${genre}" && xread "Genre: " genre

temp="$(mktemp)"
cp -f "${file}" "${temp}"
ffmpeg \
	-i "${temp}" \
	-map 0 -y -codec copy \
	-metadata title="${title}" \
	-metadata album="${album}" \
	-metadata artist="${artist}" \
	-metadata track="${track}${total:+/"${total}"}" \
	${date:+-metadata date="${date}"} \
	${genre:+-metadata genre="${genre}"} \
	${comment:+-metadata comment="${comment}"} "${file}"
rm -f ${temp}
