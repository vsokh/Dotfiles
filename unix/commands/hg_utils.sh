#!/bin/bash

function close_branch
{
    hg up -C "$1"
    if [ "$?" -eq 0 ]; then
        echo "$1 is up"
    else
        echo "branch is not found, please recheck your argument"
        return 1;
    fi

    hg commit --close-branch -m "Close $1 branch"
    echo "$1 is closed"

    hg up -C default
    echo "default is up"
}

function merge_branch
{
    hg pull && hg up -C default
    echo "default is up"

    hg merge "$1"
    echo "default was merged with $1"

    hg commit -m "Merge with $1"
}
