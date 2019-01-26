set -e

brew install hub
ls ./

# tag_name="v${1}"
asset_dir="./bottles"
assets=()
for f in "$asset_dir"/*; do [ -f "${f}" ] && assets+=(-a "${f}"); done

hub release create "${assets[@]}" -m "Release ${RELEASE_TAG}" "${RELEASE_TAG}"
