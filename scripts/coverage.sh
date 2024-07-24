#!/bin/bash

PROJECT_DIR=$FUZZ_DIR

# Check if $1 is null
if [ -z "$1" ]; then
  echo "Error: Input directory is missing. Please provide an input directory as an argument."
  exit 1
fi

INPUT_DIR=$1
TMP_DIR=$PROJECT_DIR/tmp_dir
OUTPUT_DIR=$PROJECT_DIR/coverage/${INPUT_DIR/\//\_}
OUTPUT_DIR=${OUTPUT_DIR::-1}
EXE=$FUZZ_COV_DIR/$FUZZ_PROG
echo $EXE $ARGS
run() { $EXE $1;}

echo "Making covrege for $INPUT_DIR"

# Create output directory if it doesn't exist
rm -rf $OUTPUT_DIR
rm -rf $TMP_DIR
mkdir $OUTPUT_DIR
mkdir $TMP_DIR


# Function to run fuzzing with coverage instrumentation
run_one_file() {
  local file="$1"
  local filename=$(basename "$file" .pdf)
  local profile_file="$TMP_DIR/$filename.profraw"
  LLVM_PROFILE_FILE="$profile_file" "$EXE" ${FUZZ_ARGS/\@\@/$file}
}

# Iterate through files in the input directory
for file in "$INPUT_DIR"/*; do
  run_one_file $file
done


# Merge coverage data into a single file
llvm-profdata merge -sparse $TMP_DIR/*.profraw -o "$OUTPUT_DIR/coverage.profdata"

# Generate coverage report in HTML format
llvm-cov show "$EXE" -instr-profile="$OUTPUT_DIR/coverage.profdata" --format="html" -o "$OUTPUT_DIR"

# Optionally, generate a detailed coverage report
# llvm-cov show -instr-profile="$temp_dir/coverage.profdata" "$FUZZ_EXE" > "$temp_dir/coverage_details.txt"

rm -rf $TMP_DIR

echo "Coverage reports generated in $OUTPUT_DIR"
