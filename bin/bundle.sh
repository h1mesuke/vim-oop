#!/bin/bash
#=============================================================================
# vim-oop
# OOP Support for Vim script
#
# File    : bin/bundle.sh
# Author  : h1mesuke <himesuke+vim@gmail.com>
# Updated : 2012-01-19
# Version : 0.2.4
# License : MIT license {{{
#
#   Permission is hereby granted, free of charge, to any person obtaining
#   a copy of this software and associated documentation files (the
#   "Software"), to deal in the Software without restriction, including
#   without limitation the rights to use, copy, modify, merge, publish,
#   distribute, sublicense, and/or sell copies of the Software, and to
#   permit persons to whom the Software is furnished to do so, subject to
#   the following conditions:
#
#   The above copyright notice and this permission notice shall be included
#   in all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
#   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# }}}
#=============================================================================

set -o errexit
set -o nounset

NAME=bundle.sh
USAGE="$NAME [options] PLUGIN_DIR"
VERSION=0.0.2

print_help() {
  cat 1>&2 << EOF

  $NAME - Bundle the vim-oop to a Vim's plugin.

  Usage:
    $USAGE

  Options:
    -c                Bundle Class  only, or skip Module.
    -m                Bundle Module only, or skip Class.
    -a                Bundle Assertions.

    -h                Print this help.
    -v                Print the version of this program.
EOF
}

print_usage() {
  echo "Usage: $USAGE" 1>&2
}

print_version() {
  echo "$NAME $VERSION" 1>&2
}

GREP_FLAGS='--color=auto --line-number'
BUNDLE_CLASS=TRUE
BUNDLE_MODULE=TRUE
BUNDLE_ASSERT=FALSE
OPT=

# Parse command-line options.
if [ "$OPTIND" = 1 ]; then
  while getopts cmahv OPT; do
    case $OPT in
      c)  BUNDLE_MODULE=FALSE   ;;
      m)  BUNDLE_CLASS=FALSE    ;;
      a)  BUNDLE_ASSERT=TRUE    ;;
      h)  print_help;    exit 0 ;;
      v)  print_version; exit 0 ;;
      \?) print_help;    exit 1 ;;
    esac
  done
  shift $(($OPTIND - 1))
else
  echo "$NAME: getopts is not available." 1>&2
  exit 1
fi

if [ $# -ne 1 ] || [ ! -d "$1" ]; then
  print_usage
  exit 1
fi

SRC_DIR=$(dirname $(cd $(dirname $0) && pwd))/autoload
#=> path/to/oop/autoload

PLUGIN=$(basename $1)
DST_DIR="$1/autoload/$PLUGIN"
#=> path/to/PLUGIN/autoload/PLUGIN

mkdir -p "$DST_DIR/oop"

bundle_copy() {
  local src=$1 dst=$2
  echo
  echo "SRC: $src"
  echo "DST: $dst"
  <"$src" awk -v plugin=$PLUGIN '
    /oop#/ { gsub(/oop#/, plugin "#oop#", $0) }
    { print }
  ' | tee "$dst" | grep $GREP_FLAGS "$PLUGIN#oop#"
}

# autoload/oop.vim
bundle_copy "$SRC_DIR/oop.vim" "$DST_DIR/oop.vim"

# autoload/oop/class.vim
if [ $BUNDLE_CLASS = TRUE ]; then
  bundle_copy "$SRC_DIR/oop/class.vim" "$DST_DIR/oop/class.vim"
fi
# autoload/oop/module.vim
if [ $BUNDLE_MODULE = TRUE ]; then
  bundle_copy "$SRC_DIR/oop/module.vim" "$DST_DIR/oop/module.vim"
fi
# autoload/oop/assertions.vim
if [ $BUNDLE_ASSERT = TRUE ]; then
  bundle_copy "$SRC_DIR/oop/assertions.vim" "$DST_DIR/oop/assertions.vim"
fi

echo
echo "Done."
