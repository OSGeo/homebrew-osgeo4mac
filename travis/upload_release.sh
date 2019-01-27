set -e

cd ${TRAVIS_BUILD_DIR}
echo "Check build dir: ${TRAVIS_BUILD_DIR}"

ls ./

cd bottles

for f in ${CHANGED_FORMULAE}; do

  # command-line tool to use with GitHub
  brew install hub
  ls ./

  # use ggprep instead of gprep
  brew install grep
  # find ${HOMEBREW_PREFIX}/Cellar/${f} -name "${f}.rb" >> version.txt
  # RELEASE_TAG=$(ggrep -Po "(\d+\.)+(\d+\.)+\d" version.txt | head -n 1)
  RELEASE_TAG=$(ggrep -Po "(\d+\.)+(\d+\.)+\d" ${HOMEBREW_REPOSITORY}/Library/Taps/${TRAVIS_REPO_SLUG}/Formula/${f}.rb | head -n 1)
  echo "Release Tag: ${RELEASE_TAG}"

  hub release delete "${RELEASE_TAG}"

  # tag_name="v${1}"

  asset_dir="."
  assets=()
  for b in "$asset_dir"/*; do [ -f "${b}" ] && assets+=(-a "${b}"); done

  hub release create "${assets[@]}" -m "Release ${RELEASE_TAG}" "${RELEASE_TAG}"

done
