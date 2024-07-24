#!/bin/bash

EXE="$FUZZ_ASAN_DIR/$FUZZ_PROG $FUZZ_ARGS"
echo fuzzing $EXE
AFL_USE_ASAN=1 AFL_AUTORESUME=1 afl-fuzz -i corpus/ -o out/ -- $EXE
