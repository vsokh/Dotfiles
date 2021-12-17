#!/usr/bin/env bash

function compile
{
    g++ -std=c++17 -O2 -o "${1%.*}" "$1" -g -Wall -fsanitize=address;
}

function run
{
    compile "$1" && ./"${1%.*}" & fg;
}
