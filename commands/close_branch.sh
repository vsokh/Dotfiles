#!/bin/bash

hg up -C $1
if [ $? -eq 0 ]; then
    echo "$1 is up"
else
    echo "branch is not found, please recheck your argument"
    exit 1
fi

hg commit --close-branch -m "Close $1 branch"
echo "$1 is closed"

hg up -C default
echo "default is up"
