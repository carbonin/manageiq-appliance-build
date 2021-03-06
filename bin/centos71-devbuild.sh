#
# Kick off a CentOS 7.1 development build
#
# repo:      abellotti/manageiq.git
# branch:    centos71
# fileshare: true
#

CUR_BUILD="`virsh list | sed '1,2d'`"
if [ -n "${CUR_BUILD}" ]
then
  echo "Current ImageFactory Build ongoing, cannot kick-off CentOS 7.1 build"
  exit 1
fi

LOG_DIR=/build/logs
mkdir -p ${LOG_DIR}

DATE_STAMP=`date +"%Y%m%d_%T"`
LOG_FILE="${LOG_DIR}/centos71_devbuild_${DATE_STAMP}.log"

BUILD_OPTIONS="--type nightly --reference centos71"
if [ "${1}" = "-B" ]
then
  shift
  if [ -z "#{1}" ]
  then
    echo "Must specify the repo to use for the ManageIQ config and kickstart files"
    exit 1
  fi
  BUILD_OPTIONS="$BUILD_OPTIONS -B ${1}"
  shift
else
  BUILD_OPTIONS="$BUILD_OPTIONS -B http://github.com/abellotti/manageiq-appliance-build.git"
fi

if [ "${1}" = "--fileshare" -o "${1}" = "--no-fileshare" -o "${1}" = "--local" ]
then
  BUILD_OPTIONS="$BUILD_OPTIONS ${1}"
  shift
fi

if [ "${1}" = "--fg" ]
then
  echo "CentOS 7.1 Dev Build kicked off, Log being saved in ${LOG_FILE} ..."

  time ruby /build/scripts/vmbuild.rb $BUILD_OPTIONS 2>&1 | tee ${LOG_FILE}
else
  nohup time ruby /build/scripts/vmbuild.rb $BUILD_OPTIONS >${LOG_FILE} 2>&1 &

  echo "CentOS 7.1 Dev Build kicked off, Log @ ${LOG_FILE} ..."
fi
