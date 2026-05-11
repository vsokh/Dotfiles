#!/usr/bin/env bash

# Finds files by a word given in the 1st argument and replaces it by a word given in 2nd argument.
sub()
{
    local from=$1;
    local to=$2;

    fd "$from" --exec sh -c 'x={}; mv -v "$x" $(echo $x | sed 's/"$from"/"$to"/g')' \;
}
