#!/usr/bin/env bash

compile()
{
    g++ -std=c++17 -O2 -o "${1%.*}" "$1" -g -Wall -fsanitize=address;
}

run()
{
    compile "$1" && ./"${1%.*}" & fg;
}
