#!/bin/bash

TEMPOFILE="/tmp/.tempFileConvertedfile_"

if [ -z "$1" ] && [ -z "$2" ]; then
	echo -e -n "\n\nplease provide the filename to convert, then the new filename\n\nUsage : $0 <dos file> <unix file>\n\n\n" && exit 1
else
	tr -d "\r" < "$1" > ${TEMPOFILE}$$ &&\
	cp ${TEMPOFILE}$$ "$2" && echo -e -n "\nConversion \e[92m[DONE]\e[0m\n" || echo -e -n "\nConversion : \e[91m[FAILED]\e[0m\n"
fi

rm -Rf "${TEMPOFILE}*"

exit 0


