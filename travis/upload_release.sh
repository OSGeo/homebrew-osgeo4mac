set -e

brew install hub
ls ./

RELEASE_TAG=$(echo "${TRAVIS_BRANCH}" | sed -nE 's/(^[@a-z0-9\.\-]+-[0-9\._]+)#(macos-)?bottle$/\1/p')
echo "Release Tag: ${RELEASE_TAG}"
# tag_name="v${1}"
asset_dir="./bottles"
assets=()
for f in "$asset_dir"/*; do [ -f "${f}" ] && assets+=(-a "${f}"); done

hub release create "${assets[@]}" -m "Release ${RELEASE_TAG}" "${RELEASE_TAG}"
