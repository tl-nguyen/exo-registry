#!/bin/sh
set -eu

LC_ALL=C
TZ=UTC
export LC_ALL TZ

root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$root"

mkdir -p packages/class packages/crew

package() {
  category=$1
  name=$2
  output="packages/$category/$name-1.tar.gz"

  tar --sort=name --mtime='@0' --owner=0 --group=0 --numeric-owner \
    -C "src/$category/$name" -cf - . | gzip -n > "$output"
}

for name in autopilot builder lead qa reviewer scout; do
  package class "$name"
done
package crew default-crew

pin() {
  sha256sum "packages/$1/$2-1.tar.gz" | cut -d ' ' -f 1
}

# Keep index policy aligned with client: only declarative package files are data.
# Any unreadable or unknown source file is code-bearing.
code_bearing() {
  source="src/$1/$2"
  # Package source paths are controlled repository names (no whitespace).
  for file in $(find "$source" -type f | LC_ALL=C sort); do
    relative=${file#"$source/"}
    name=${relative##*/}
    if [ -x "$file" ] || case "/$relative/" in */hooks/*|*/settings/*) true ;; *) false ;; esac; then
      printf '%s\n' true
      return
    fi
    case "$name" in
      class.yaml|crew.yaml|*.md) continue ;;
      *.yaml|*.json)
        case "/$relative/" in */guidance/*|*/skills/*|*/docs/*) continue ;; esac
        ;;
    esac
    printf '%s\n' true
    return
  done
  # A declared hook/settings pool is executable policy unless explicitly empty.
  if [ "$1" = class ] && grep -Eq '^[[:space:]]*(hooks|settings):[[:space:]]*[^[:space:]#].*$' "$source/class.yaml"; then
    if ! grep -Eq '^[[:space:]]*(hooks|settings):[[:space:]]*(\[\]|null|\{\})[[:space:]]*$' "$source/class.yaml"; then
      printf '%s\n' true
      return
    fi
  fi
  printf '%s\n' false
}

autopilot=$(pin class autopilot)
builder=$(pin class builder)
lead=$(pin class lead)
qa=$(pin class qa)
reviewer=$(pin class reviewer)
scout=$(pin class scout)
default_crew=$(pin crew default-crew)
autopilot_code=$(code_bearing class autopilot)
builder_code=$(code_bearing class builder)
lead_code=$(code_bearing class lead)
qa_code=$(code_bearing class qa)
reviewer_code=$(code_bearing class reviewer)
scout_code=$(code_bearing class scout)
default_crew_code=$(code_bearing crew default-crew)

cat > index.json <<EOF
{"v":1,"packages":{"class/autopilot":{"1":{"path":"exo-factory/packages/class/autopilot-1.tar.gz","sha256":"$autopilot","code_bearing":$autopilot_code}},"class/builder":{"1":{"path":"exo-factory/packages/class/builder-1.tar.gz","sha256":"$builder","code_bearing":$builder_code}},"class/lead":{"1":{"path":"exo-factory/packages/class/lead-1.tar.gz","sha256":"$lead","code_bearing":$lead_code}},"class/qa":{"1":{"path":"exo-factory/packages/class/qa-1.tar.gz","sha256":"$qa","code_bearing":$qa_code}},"class/reviewer":{"1":{"path":"exo-factory/packages/class/reviewer-1.tar.gz","sha256":"$reviewer","code_bearing":$reviewer_code}},"class/scout":{"1":{"path":"exo-factory/packages/class/scout-1.tar.gz","sha256":"$scout","code_bearing":$scout_code}},"crew/default-crew":{"1":{"path":"exo-factory/packages/crew/default-crew-1.tar.gz","sha256":"$default_crew","code_bearing":$default_crew_code}}}}
EOF
