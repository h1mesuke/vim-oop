#!/bin/sh
#=============================================================================
# vim-oop
# Simple OOP Layer for Vim script
#
# File    : bin/bundle.sh
# Author  : h1mesuke
# Updated : 2012-01-13
# Version : 0.2.3
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

NAME=bundle.sh
USAGE="$NAME [options] PLUGIN_DIR"
VERSION=0.0.1

print_help() {
  cat 1>&2 << EOF

  $NAME - Bundle the vim-oop to a Vim's plugin.

  Usage:
    $USAGE

  Options:
    -c                Bundle Class  only.
    -m                Bundle Module only.

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

WHAT=BOTH   # BOTH | CLASS | MODULE
OPT=

# Parse command-line options.
if [ "$OPTIND" = 1 ]; then
  while getopts cmhv OPT; do
    case $OPT in
      c)
        WHAT=CLASS
        ;;
      m)
        WHAT=MODULE
        ;;
      h | \?)
        print_help
        status=0
        if [ $OPT != "h" ]; then
          status=1
        fi
        exit $status
        ;;
      v)
        print_version
        exit 0
        ;;
    esac
  done
  shift `expr $OPTIND - 1`
else
  echo "$NAME: getopts is not available." 1>&2
  exit 1
fi

if [ $# -ne 1 -o ! -d "$1" ]; then
  print_usage
  exit 1
fi

src_dir=$(dirname $(cd $(dirname $0) && pwd))/autoload
#=> path/to/bundle/oop/autoload

plugin=$(basename $1)
dst_dir="$1/autoload/$plugin"
#=> path/to/bundle/plugin/autoload/plugin

mkdir -p "$dst_dir/oop"

bundle_copy() {
  src=$1
  dst=$2

  echo
  echo "SRC: $src"

  cat "$src" | awk -v plugin=$plugin '

    /oop#/ {
      gsub(/oop#/, plugin "#oop#", $0)
    }

    { print $0 }

  ' > "$dst"

  echo "DST: $dst"
}

# autoload/oop.vim
bundle_copy "$src_dir/oop.vim" "$dst_dir/oop.vim"

# autoload/oop/class.vim
if [ WHAT != MODULE ]; then
  bundle_copy "$src_dir/oop/class.vim" "$dst_dir/oop/class.vim"
fi
# autoload/oop/module.vim
if [ WHAT != CLASS ]; then
  bundle_copy "$src_dir/oop/module.vim" "$dst_dir/oop/module.vim"
fi

echo
echo "Done."
