#!/bin/sh
# Usage: ./run.sh <ProblemName> [testNumber]
cd "$(dirname "$0")" || exit 1

name="${1%.java}"
if [ -z "$name" ]; then
  echo "Usage: ./run.sh <ProblemName> [testNumber]"
  exit 2
fi
if [ ! -f "$name.java" ]; then
  echo "Error: $name.java not found"
  exit 2
fi

mkdir -p out
javac -parameters -d out TestRunner.java "$name.java" || exit 1
java -cp out ${2:+-Dtest=$2} "$name"
