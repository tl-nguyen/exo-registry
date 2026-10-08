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

autopilot=$(pin class autopilot)
builder=$(pin class builder)
lead=$(pin class lead)
qa=$(pin class qa)
reviewer=$(pin class reviewer)
scout=$(pin class scout)
default_crew=$(pin crew default-crew)

cat > index.json <<EOF
{"v":1,"packages":{"class/autopilot":{"1":{"path":"exo-factory/packages/class/autopilot-1.tar.gz","sha256":"$autopilot","code_bearing":false}},"class/builder":{"1":{"path":"exo-factory/packages/class/builder-1.tar.gz","sha256":"$builder","code_bearing":false}},"class/lead":{"1":{"path":"exo-factory/packages/class/lead-1.tar.gz","sha256":"$lead","code_bearing":false}},"class/qa":{"1":{"path":"exo-factory/packages/class/qa-1.tar.gz","sha256":"$qa","code_bearing":false}},"class/reviewer":{"1":{"path":"exo-factory/packages/class/reviewer-1.tar.gz","sha256":"$reviewer","code_bearing":false}},"class/scout":{"1":{"path":"exo-factory/packages/class/scout-1.tar.gz","sha256":"$scout","code_bearing":false}},"crew/default-crew":{"1":{"path":"exo-factory/packages/crew/default-crew-1.tar.gz","sha256":"$default_crew","code_bearing":false}}}}
EOF
