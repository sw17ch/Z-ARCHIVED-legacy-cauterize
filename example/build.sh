#!/bin/sh

rm -rf doc_cauterize_output
../bin/cauterize generate doc doc_cauterize_output

rm -rf c_cauterize_output
../bin/cauterize generate c c_cauterize_output

CFLAGS="-Wall -Werror -Wextra"
INCLUDES="-Ic_cauterize_output"


gcc $CFLAGS $INCLUDES c_cauterize_output/cauterize.c -c -o c_cauterize_output/cauterize.o
gcc $CFLAGS $INCLUDES c_cauterize_output/example_project.c -c -o c_cauterize_output/example_project.o

rm -rf cs_cauterize_output
../bin/cauterize generate cs cs_cauterize_output

dmcs cs_cauterize_output/*.cs -target:library -out:cs_cauterize_output/example_project.dll

