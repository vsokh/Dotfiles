#!/usr/bin/env bash

ar1=$(fd . "$1")
ar2=$(fd . "$2")
for a in $ar1; do
	for b in $ar2; do
		if grep "$a" "$b" > /dev/null; then
			echo "DIFF: $a && $b"
			diff "$a" "$b";
		fi
	done
done

