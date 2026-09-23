#!/bin/sh
# Builds a small site with this image, to check it can still generate one.
#
# A UI bundle the image cannot read makes Antora exit 0 without writing any page and without an error
# (Node 24.17 never finished reading a compressed zip entry of 64 KiB or more), so check the output.
set -e
IMAGE=${1:-antora:test}
BUNDLE=${UI_BUNDLE_URL:-https://github.com/vshn/antora-ui-default/releases/latest/download/ui-bundle.zip}
cd "$(dirname "$0")/.."
rm -rf test/out
# Antora reads content from a git repository, so commit the fixture into one inside the container
docker run --rm -v "$PWD":/antora -w /antora --entrypoint /bin/sh "$IMAGE" -c "
  set -e
  cp -r test/fixture /tmp/fixture-content
  cd /tmp/fixture-content
  git init -q && git add . && git -c user.name=ci -c user.email=ci@example.org commit -q -m fixture
  cd /antora
  antora --fetch --ui-bundle-url '$BUNDLE' test/playbook.yml"

page=test/out/fixture/index.html
fail () { echo "FAIL: $1"; exit 1; }
[ -f "$page" ] || fail "$IMAGE generated no page (bundle: $BUNDLE)"
grep -q '_/css/site.css' "$page" || fail "$page does not use the UI bundle"
grep -q 'admonitionblock note' "$page" || fail "$page is missing the admonition"
grep -q 'class="fa icon-note"' "$page" || fail "$page is missing the admonition icon element"
grep -q 'kroki' "$page" || fail "$page is missing the diagram, so the kroki extension did not run"
[ -f test/out/_/css/site.css ] || fail "the UI was not written to test/out/_"
echo "OK: $IMAGE built $page with $BUNDLE"
