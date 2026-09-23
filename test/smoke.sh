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
# run as the calling user, so the generated files are not owned by root in the workspace
docker run --rm -v "$PWD":/antora -w /antora -u "$(id -u):$(id -g)" -e HOME=/tmp \
  --entrypoint /bin/sh "$IMAGE" -c "
  set -e
  cp -r test/fixture /tmp/fixture-content
  cd /tmp/fixture-content
  git init -q && git add . && git -c user.name=ci -c user.email=ci@example.org commit -q -m fixture
  cd /antora
  antora --fetch --ui-bundle-url '$BUNDLE' test/playbook.yml"

page=test/out/fixture/index.html
fail () { echo "FAIL: $1"; exit 1; }

# the site was generated and uses the UI bundle
[ -f "$page" ] || fail "$IMAGE generated no page (bundle: $BUNDLE)"
[ -f test/out/_/css/site.css ] || fail "the UI was not written to test/out/_"
grep -q '_/css/site.css' "$page" || fail "$page does not use the UI bundle"
grep -q 'admonitionblock note' "$page" || fail "$page is missing the admonition"
grep -q 'class="fa icon-note"' "$page" || fail "$page is missing the admonition icon element"

# asciidoctor-kroki turned both diagram blocks into images and fetched them from the kroki server
images=$(grep -c '<img src="_images/[^"]*\.svg"' "$page" || true)
[ "$images" -ge 2 ] || fail "$page has $images kroki diagram images, expected 2 (kroki extension did not run)"
svgs=$(find test/out/fixture/_images -name '*.svg' | wc -l | tr -d ' ')
[ "$svgs" -ge 2 ] || fail "$svgs diagrams were fetched into _images, expected 2"
for svg in test/out/fixture/_images/*.svg; do
  grep -q '<svg' "$svg" || fail "$svg is not an SVG, so the kroki server response was not stored"
done
grep -q 'fetched-diagram' "$page" || fail "$page is missing the named diagram target"

echo "OK: $IMAGE built $page with $BUNDLE ($images diagrams)"
