#!/bin/sh

rm -rf doc_cauterize_output
../bin/cauterize generate doc doc_cauterize_output

rm -rf c_cauterize_output
../bin/cauterize generate c c_cauterize_output

CFLAGS="-Wall -Werror -Wextra"
INCLUDES="-Ic_cauterize_output -Ic_example_support"
DEFINES="-DUSE_CAUTERIZE_CONFIG_HEADER"

gcc $CFLAGS $INCLUDES $DEFINES c_example_support/example_project_config.c \
                               c_example_support/empty_main.c \
                               c_cauterize_output/cauterize.c \
                               c_cauterize_output/example_project.c \
                               -o c_cauterize_output/example_project

rm -rf cs_cauterize_output
../bin/cauterize generate cs cs_cauterize_output

dmcs cs_cauterize_output/*.cs -target:library -out:cs_cauterize_output/example_project.dll

rm -rf ruby_cauterize_output
../bin/cauterize generate ruby ruby_cauterize_output
