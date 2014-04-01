#!/bin/bash
#
# Automatically create tarball and submit it to launchpad.
#

# Produce package for all currently supported releases as well as the upcoming
# release.
# See <http://en.wikipedia.org/wiki/List_of_Ubuntu_releases#Version_timeline>.

submit() {
  # Usage
  #
  PACKAGE_BASENAME=$1
  # The resubmission tag is used when several submission need to be made with
  # the same VERSION. Use a positive integer here.
  RESUBMISSION=$2
  GIT_DIR=$3
  DEBIAN_DIR=$4
  UBUNTU_RELEASES=$5
  PPAS=$6
  VERSION_GETTER=$7

  # Set SSH agent variables.
  eval $(cat $HOME/.ssh/agent/info)

  # Retrieve the directory of this script, cf.
  # http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
  BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  cd $GIT_DIR || return 1
  echo "Fetching updates..."
  git pull > /dev/null || return 1
  echo "done."

  SUBMIT_ID=$(git rev-parse HEAD)

  # File to store the HEAD command of the last push.
  ID_FILE="${HOME}/.${PACKAGE_BASENAME}-submit-unstable"

  # Check if there was an update.
  # TODO remove ID_FILE, test the next line
  if [ -f "${ID_FILE}" -a "$(cat "${ID_FILE}")" = "${SUBMIT_ID}" ]; then
    echo "Latest version already submitted to launchpad."
    return 0
  fi

  # Create a version number of the form 4.3.1.2~20121123.
  PACKAGE_VERSION=$($VERSION_GETTER)
  VERSION="${PACKAGE_VERSION}~$(date +%Y%m%d)"

  # Create the tarball.
  TARBALL_PATH="/tmp/${PACKAGE_BASENAME}.tar.gz"
  PREFIX="${PACKAGE_BASENAME}-${VERSION}"
  echo "Creating new archive ${TARBALL_NAME}..."
  rm -f "${TARBALL_PATH}" || return 1
  # Append the "/" to $PREFIX, otherwise this may be interpreted as an
  # ordinary filename-prefix.
  git archive master --prefix="${PREFIX}/" --format=tar.gz --output="${TARBALL_PATH}" || return 1
  echo "done."

  for PPA in ${PPAS[@]}
  do
    for UBUNTU_RELEASE in ${UBUNTU_RELEASES[@]}
    do
      DEB_DIR="/tmp/${PACKAGE_BASENAME}/deb/${UBUNTU_RELEASE}/"
      if [ -d "${DEB_DIR}" ]; then
          # clean DEB_DIR
          rm -rf ${DEB_DIR}/* || return 1
      else
          mkdir -p "${DEB_DIR}" || return 1
      fi
      TARBALL_NAME="${PACKAGE_BASENAME}_${VERSION}.orig.tar.gz"
      cp "${TARBALL_PATH}" "${DEB_DIR}/${TARBALL_NAME}" || return 1
      cd "${DEB_DIR}" || return 1
      tar xf "${TARBALL_NAME}" || return 1
      # Copy over the debian folder.
      cp -r "${BASEDIR}/$DEBIAN_DIR/" \
         "${PREFIX}/debian" || return 1

      # Use the `-` as a separator (instead of `~` as it's often used) to make
      # sure that ${UBUNTU_RELEASE}x isn't part of the name. This makes it
      # possible to increment `x` and have launchpad recognize it as a new
      # version.
      FULL_VERSION="${VERSION}-${UBUNTU_RELEASE}${RESUBMISSION}"

      # Override changelog.
      echo "${PACKAGE_BASENAME} (1:${FULL_VERSION}) ${UBUNTU_RELEASE}; urgency=low

  * Initial release

 -- Nico Schlömer <nico.schloemer@gmail.com>  $(date "+%a, %d %b %Y %T %z")" \
      > "${PREFIX}/debian/changelog" || return 1

      # Build the data.
      cd "${PREFIX}" || return 1
      # The actual workhorse:
      debuild -p${BASEDIR}/mygpg -S || return 1
      # Submit to launchpad.
      cd ..
      dput ppa:${PPA} "${PACKAGE_BASENAME}_${FULL_VERSION}_source.changes" || return  1
    done
  done

  # Store which revision we're pushing so we don't do it twice.
  echo "${SUBMIT_ID}" > "${ID_FILE}"

  return 0
}
