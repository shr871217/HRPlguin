#!/bin/sh

#  find.sh
#  XToDo
#
#  Created by Travis on 13-11-28.
#  Copyright (c) 2013年 Plumn LLC. All rights reserved.

KEYWORDS="#if"

find "$1" \( -name "*.h" -or -name "*.m" \) -print0 | xargs -0 egrep --with-filename --line-number --only-matching $KEYWORDS | perl -p -e "s/($KEYWORDS)/:\$1/"
