#!/usr/bin/env bash
set -euo pipefail

required=(site/index.html site/error.html site/assets/styles.css site/assets/app.js)
for file in "${required[@]}"; do
  test -s "$file" || { echo "Missing or empty: $file" >&2; exit 1; }
done

grep -q 'assets/styles.css' site/index.html
grep -q 'assets/app.js' site/index.html
grep -q '<meta name="viewport"' site/index.html
grep -q '<title>' site/index.html
echo "Static site checks passed."

