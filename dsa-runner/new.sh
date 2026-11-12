#!/bin/sh
# Usage: ./new.sh <ProblemName>
# Creates <ProblemName>.java from Template.java and an empty tests/<ProblemName>.txt
cd "$(dirname "$0")" || exit 1

name="${1%.java}"
if [ -z "$name" ]; then
  echo "Usage: ./new.sh <ProblemName>"
  exit 2
fi
if ! printf '%s' "$name" | grep -Eq '^[A-Za-z_][A-Za-z0-9_]*$'; then
  echo "Error: '$name' is not a valid Java class name (letters, digits, _; no leading digit)"
  exit 2
fi
if [ -e "$name.java" ] || [ -e "tests/$name.txt" ]; then
  echo "Error: $name.java or tests/$name.txt already exists"
  exit 2
fi

mkdir -p tests
sed "s/Template/$name/g" Template.java > "$name.java"
cat > "tests/$name.txt" <<'EOF'
# One line per solve() parameter, in order, then one line with the expected answer.
# Separate test cases with a blank line. Lines starting with # are ignored.

EOF

echo "Created $name.java and tests/$name.txt"
echo "Run with: ./run.sh $name"
