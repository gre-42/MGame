#!/bin/bash -eux

cd "$(dirname "${BASH_SOURCE[0]}")"

for f in *.svg; do convert -background none -geometry 256x256 -density 288 $f ${f%%.svg}.png; done
