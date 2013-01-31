#!/bin/sh

rm -rf cauterize_output
../bin/cauterize generate c cauterize_output

CFLAGS="-Wall -Werror -Wextra"
INCLUDES="-Icauterize_output"


gcc $CFLAGS $INCLUDES cauterize_output/cauterize.c -c -o cauterize_output/cauterize.o
gcc $CFLAGS $INCLUDES cauterize_output/example_project.c -c -o cauterize_output/example_project.o
