set -e

brew install hub
ls ./

# find ${HOMEBREW_REPOSITORY}/Cellar/${f} -name "${f}.rb" >> version.txt
# RELEASE_TAG=$(grep -Po "(\d+\.)+(\d+\.)+\d" version.txt | head -n 1)
# RELEASE_TAG=$(grep -Po "(\d+\.)+(\d+\.)+\d" ${HOMEBREW_REPOSITORY}/Library/Taps/${TRAVIS_REPO_SLUG}/Formula/${f}.rb | head -n 1)

hub release delete "${RELEASE_TAG}"

# tag_name="v${1}"

asset_dir="./bottles"
assets=()
for f in "$asset_dir"/*; do [ -f "${f}" ] && assets+=(-a "${f}"); done

hub release create "${assets[@]}" -m "Release ${RELEASE_TAG}" "${RELEASE_TAG}"
