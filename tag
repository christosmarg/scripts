#!/bin/sh

usage()
{
	echo "usage: ${0##*/} [-a artist] [-A album_title] [-c comment]" 1>&2
	echo "	[-d year] [-g genre] [-n trackno] [-N totalno]" 1>&2
	echo "	[-t song_title] file" 1>&2
	exit 1
}

while getopts "a:t:A:n:N:d:g:c:" arg; do
case "${arg}" in
	a) artist="${OPTARG}" ;;
	t) title="${OPTARG}" ;;
	A) album="${OPTARG}" ;;
	n) track="${OPTARG}" ;;
	N) total="${OPTARG}" ;;
	d) date="${OPTARG}" ;;
	g) genre="${OPTARG}" ;;
	c) comment="${OPTARG}" ;;
	*) usage ;;
esac
done
shift $((OPTIND - 1))

file="${1}"
test ! -f "${file}" && echo "${0##*/}: file not found: ${file}" && usage

test -z "${title}" && read -erp "Title: " title
test -z "${artist}" && read -erp "Artist: " artist
test -z "${album}" && read -erp "Album: " album
test -z "${track}" && read -erp "Track number: " track
test -z "${total}" && read -erp "Total tracks in album: " total
test -z "${date}" && read -erp "Date: " date
test -z "${genre}" && read -erp "Genre: " genre

temp="$(mktemp)"
cp -f "${file}" "${temp}"
ffmpeg \
	-i "${temp}" \
	-nostdin \
	-map 0 -y -c copy \
	-metadata title="${title}" \
	-metadata album="${album}" \
	-metadata artist="${artist}" \
	-metadata track="${track}${total:+/"${total}"}" \
	${date:+-metadata date="${date}"} \
	${genre:+-metadata genre="${genre}"} \
	${comment:+-metadata comment="${comment}"} \
	"${file}"
rm -f ${temp}
