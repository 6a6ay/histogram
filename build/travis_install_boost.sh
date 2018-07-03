BOOST_VERSION=1.65.0
if [[ -z "${TRAVIS_BUILD_DIR}" ]]; then
  TRAVIS_BUILD_DIR=/tmp
fi
PYVER=$(python -c 'import sys; sys.stdout.write("%i"%sys.version_info.major)')
BOOST_DIR=${TRAVIS_BUILD_DIR}/deps/boost-${BOOST_VERSION}-py${PYVER}
echo "Boost: ${BOOST_DIR}"
mkdir -p ${BOOST_DIR}
BOOSTRAP_PATCH_REGEX="s|\( *using python.*\);|\1: $(python get_python_include.py) ;|"
echo $BOOSTRAP_PATCH_REGEX
if [[ -z "$(ls -A ${BOOST_DIR})" ]]; then
  BOOST_URL="http://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/boost_${BOOST_VERSION//\./_}.tar.gz"
  { wget --quiet -O - ${BOOST_URL} | tar --strip-components=1 -xz -C ${BOOST_DIR}; } || exit 1
  (cd ${BOOST_DIR} && ./bootstrap.sh && \
   sed -i "${BOOSTRAP_PATCH_REGEX}" project-config.jam && \
   cat project-config.jam && \
   ./b2 install --prefix=${BOOST_DIR} --with-serialization --with-iostreams --with-python | grep -v -e common\.copy -e common\.mkdir)
fi
ls ${BOOST_DIR}/lib | grep libboost
