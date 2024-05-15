#!/bin/bash
LR_PKG_PATH="packages/lakka/libretro_cores"
RA_PKG_PATH="packages/lakka/retroarch_base"
PACKAGES_ALL=""
PACKAGES_EX=" citra "
PACKAGES_UP=""
ALL_FILES=""

if [ -f config/functions ] ; then
  source config/functions
else
  echo "Cannot find 'config/functions'."
  exit 1
fi

# print usage of this script
usage()
{
  echo ""
  echo "$0 <--all [--exclude list] | --used [--exclude list] | --packages list>"
  echo ""
  echo "Updates PKG_VERSION in package.mk of libretro and RetroArch packages to latest."
  echo ""
  echo "Parameters:"
  echo " -a --all                 Update libretro and RetroArch packages"
  echo " -c --cores               Update libretro packages shipped"
  echo " -r --retroarch           Update RetroArch packages"
  echo " -p list --packages list  Update only listed libretro / RetroArch packages"
  echo " -e list --exclude list   Provide list of packages to exclude from update"
  echo ""
}

# get list of all libretro packages in the path
get_lr_packages()
{
  for p in $(cd $LR_PKG_PATH && ls -d */) ; do
    PACKAGES_ALL+=" ${p//\//} "
  done
}

# get list of all retroarch packages in the path
get_ra_packages()
{
  for p in $(cd $RA_PKG_PATH && ls -d */) ; do
    PACKAGES_ALL+=" ${p//\//} "
  done
}

# check if packages to exclude are actual packages
get_ex_packages()
{
  x="$1"
  shift
  v="$@"
  [ "$v" = "" ] && { echo "Error: You must provide name(s) of package(s) to exclude after $x" ; exit 1 ; }
  for a in $v ; do
    if [ -f $LR_PKG_PATH/$a/package.mk -o -f $RA_PKG_PATH/$a/package.mk ] ; then
      PACKAGES_EX+=" $a "
    else
      echo "Warning: $a is not a libretro package."
    fi
  done
  [ "$PACKAGES_EX" = "" ] && { echo "No valid packages to exclude given! Aborting." ; exit 1 ; }
}

# check if packages to update are actual libretro or retroarch packages
get_single_packages()
{
  x="$1"
  shift
  v="$@"
  [ "$v" = "" ] && { echo "Error: You must provide name(s) of package(s) after $x" ; exit 1 ; }
  for a in $v ; do
    if [ -f $LR_PKG_PATH/$a/package.mk -o -f $RA_PKG_PATH/$a/package.mk ] ; then
      PACKAGES_ALL+=" $a "
    else
      echo "Warning: $a is not a libretro / RetroArch package - skipping."
    fi
  done
  [ "$PACKAGES_ALL" = "" ] && { echo "No valid packages given! Aborting." ; exit 1 ; }
}

# check any dependencies for updated cores
check_lr_deps()
{
  # check if easyrpg was updated - needs also update of package liblcf
  if listcontains "$PACKAGES_UP" "easyrpg" ; then
    print_color CLR_INFO "Dependency check:"
    echo " easyrpg updated - update also liblcf!"
  fi
}

# print text $2 in color $1 - original function from config/functions
print_color()
{
  local clr_name="$1" clr_text="$2" clr_actual
  local black red green yellow blue magenta cyan white endcolor
  local boldblack boldred boldgreen boldyellow boldblue boldmagenta boldcyan boldwhite

  [ -z "${clr_name}" ] && return 0

  black="\e[0;30m"
  boldblack="\e[1;30m"
  red="\e[0;31m"
  boldred="\e[1;31m"
  green="\e[0;32m"
  boldgreen="\e[1;32m"
  yellow="\e[0;33m"
  boldyellow="\e[1;33m"
  blue="\e[0;34m"
  boldblue="\e[1;34m"
  magenta="\e[0;35m"
  boldmagenta="\e[1;35m"
  cyan="\e[0;36m"
  boldcyan="\e[1;36m"
  white="\e[0;37m"
  boldwhite="\e[1;37m"
  endcolor="\e[0m"

  # $clr_name can be a color variable (boldgreen etc.) or a
  # "standard" color determined by an indirect name (CLR_ERROR etc.)
  #
  # If ${!clr_name} doesn't exist then assume it's a standard color.
  # If ${!clr_name} does exist then check it's not a custom color mapping.
  # Custom color mappings can be configured in options files.
  #
  clr_actual="${!clr_name}"

  if [ -n "${clr_actual}" ]; then
    clr_actual="${!clr_actual}"
  else
    case "${clr_name}" in
      CLR_ERROR)        clr_actual="${boldred}";;
      CLR_WARNING)      clr_actual="${boldred}";;
      CLR_WARNING_DIM)  clr_actual="${red}";;

      CLR_APPLY_PATCH)  clr_actual="${boldgreen}";;
      CLR_AUTORECONF)   clr_actual="${boldmagenta}";;
      CLR_BUILD)        clr_actual="${boldyellow}";;
      CLR_TOOLCHAIN)    clr_actual="${boldmagenta}";;
      CLR_CLEAN)        clr_actual="${boldred}";;
      CLR_FIXCONFIG)    clr_actual="${boldyellow}";;
      CLR_GET)          clr_actual="${boldcyan}";;
      CLR_INFO)         clr_actual="${boldgreen}";;
      CLR_INSTALL)      clr_actual="${boldgreen}";;
      CLR_PATCH_DESC)   clr_actual="${boldwhite}";;
      CLR_TARGET)       clr_actual="${boldwhite}";;
      CLR_UNPACK)       clr_actual="${boldcyan}";;
      CLR_AUTOREMOVE)   clr_actual="${boldblue}";;

      CLR_ENDCOLOR)     clr_actual="${endcolor}";;

      *)                clr_actual="${endcolor}";;
    esac
  fi

  if [ $# -eq 2 ]; then
    echo -en "${clr_actual}${clr_text}${endcolor}"
  else
    echo -en "${clr_actual}"
  fi
}

# return 0 if $2 in space-separated list $1, otherwise return 1 - original function from config/functions
listcontains() {
  if [ -n "$1" -a -n "$2" ]; then
    [[ ${1} =~ (^|[[:space:]])${2}($|[[:space:]]) ]] && return 0 || return 1
  else
    return 1
  fi
}

[ "$1" = "" ] && { usage ; exit ; }

case $1 in
  -a | --all )
    s=$1
    shift
    if [ "$1" != "" ] ; then
      case $1 in
        -e | --exclude )
          get_ex_packages $@
          ;;
        * )
          echo "Error: After $s use only --exclude (-e) to exclude some packages."
          exit 1
          ;;
      esac
    fi
    # Get list of all libretro and RetroArch packages
    get_lr_packages
    get_ra_packages
    ;;

  -r | --retroarch )
    s=$1
    shift
    if [ "$1" != "" ] ; then
      case $1 in
        -e | --exclude )
          get_ex_packages $@
          ;;
        * )
          echo "Error: After $s use only --exclude (-e) to exclude some packages."
          exit 1
          ;;
      esac
    fi
    # Get list of all RetroArch packages
    get_ra_packages
    ;;

  -c | --cores )
    s=$1
    shift
    if [ "$1" != "" ] ; then
      case $1 in
        -e | --exclude )
          get_ex_packages $@
          ;;
        * )
          echo "Error: After $s use only --exclude (-e) to exclude some packages."
          exit 1
          ;;
      esac
    fi
    # Get list of all libretro packages
    get_lr_packages
    ;;

  -p | --packages )
    get_single_packages $@
    ;;

  -e | --exclude )
    usage
    echo "Use $1 after -a/--all, -c/--cores or -r/--retroarch"
    exit 1
    ;;

  * )
    usage
    echo "Unknown parameter: $1"
    exit 1
    ;;
esac

if [ "$PACKAGES_EX" != "" ] ; then
  for a in $PACKAGES_EX ; do
    PACKAGES_ALL="${PACKAGES_ALL// $a /}"
  done
fi

[ -z "$(echo $PACKAGES_ALL)" ] && { echo "No packages to udpate." ; exit 1 ; }

echo "Checking following packages: $(echo $PACKAGES_ALL)"

# Initialize counter of updated packages
declare -i i=0

# Check if we have package.mk for all package names
for p in $PACKAGES_ALL
do
  f1=$LR_PKG_PATH/$p/package.mk
  f2=$RA_PKG_PATH/$p/package.mk

  if [ -f "$f1" ] ; then
    ALL_FILES+="$f1 "
  elif [ -f "$f2" ] ; then
    ALL_FILES+="$f2 "
  else
    echo "Neither '$f1' nor '$f2' found! Will be skipped."
    continue
  fi
done

# Check for updates
for f in $ALL_FILES ; do
  PKG_VERSION=`cat $f | sed -En "s/^PKG_VERSION=\"(.*)\"/\1/p"`
  PKG_SITE=`cat $f | sed -En "s/^PKG_SITE=\"(.*)\"/\1/p"`
  PKG_NAME=`cat $f | sed -En "s/^PKG_NAME=\"(.*)\"/\1/p"`
  PKG_GIT_CLONE_BRANCH=`cat $f | sed -En "s/^PKG_GIT_CLONE_BRANCH=\"(.*)\"/\1/p"`
  PKG_LR_UPDATE_TAG=`cat $f | sed -En "s/^PKG_LR_UPDATE_TAG=\"(.*)\"/\1/p"`
  PKG_LR_UPDATE_TAG_MASK=`cat $f | sed -En "s/^PKG_LR_UPDATE_TAG_MASK=\"(.*)\"/\1/p"`

  # Skip packages without PKG_VERSION or PKG_SITE
  if [ -z "$PKG_VERSION" ] || [ -z "$PKG_SITE" ] ; then
    echo "$f: does not have PKG_VERSION or PKG_SITE"
    echo "PKG_VERSION: $PKG_VERSION"
    echo "PKG_SITE: $PKG_SITE"
    echo "Skipping update."
    continue
  fi

  # Skip packages that have both - PKG_GIT_CLONE_BRANCH and PKG_LR_UPDATE_TAG - set
  if [ -n "$PKG_GIT_CLONE_BRANCH" -a "$PKG_LR_UPDATE_TAG" = "yes" ]; then
    echo "$f: WARNING: both PKG_GIT_CLONE_BRANCH and PKG_LR_UPDATE_TAG are set! Please use only one! Skipping update."
    continue
  fi

  UPDATE_INFO=""

  if [ -n "$PKG_GIT_CLONE_BRANCH" ]; then
    GIT_HEAD="heads/$PKG_GIT_CLONE_BRANCH"
    UPDATE_INFO="(branch $PKG_GIT_CLONE_BRANCH)"
  else
    GIT_HEAD="HEAD"
  fi

  if [ "$PKG_LR_UPDATE_TAG" = "yes" ]; then
    if [ -n "${PKG_LR_UPDATE_TAG_MASK}" ]; then
      TAG=`git ls-remote --tags $PKG_SITE "${PKG_LR_UPDATE_TAG_MASK}" 2>/dev/null | cut --delimiter='/' --fields=3 | cut --delimiter='^' --fields=1 | sort --version-sort | tail --lines=1`
    else
      TAG=`git ls-remote --tags $PKG_SITE 2>/dev/null | cut --delimiter='/' --fields=3 | cut --delimiter='^' --fields=1 | sort --version-sort | tail --lines=1`
    fi
    UPS_VERSION=`git ls-remote --tags $PKG_SITE 2>/dev/null | grep refs/tags/$TAG | tail --lines=1 | awk '{ print $1; }'`
    UPDATE_INFO="(latest tag - $TAG)"
  else
    UPS_VERSION=`git ls-remote $PKG_SITE 2>/dev/null | grep ${GIT_HEAD}$ | awk '{ print $1; }'`
  fi

  if [ "$UPS_VERSION" = "$PKG_VERSION" ]; then
    echo "$PKG_NAME is up to date ($UPS_VERSION) $UPDATE_INFO"
  elif [ "$UPS_VERSION" = "" ]; then
    echo "$PKG_NAME does not use git - nothing changed"
  else
    i+=1
    PACKAGES_UP+=" $PKG_NAME"
    echo "$PKG_NAME updated from $PKG_VERSION to $UPS_VERSION $UPDATE_INFO"
    sed -i "s/$PKG_VERSION/$UPS_VERSION/" $f
  fi

done

# Print update summary
if [ $i -eq 0 ]; then
  echo "No packages updated."
else
  check_lr_deps
  echo "$i package(s) updated:"
  echo $PACKAGES_UP
fi
