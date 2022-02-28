#!/bin/bash

python3 -m crumbs.sdm \
      --points occurrences.shp \
      --variables dem \
      --background 200 \
      --times $(seq -s ',' 19 1 20) \
      --margin 2.0 \
      --cleanup \
      --output suitability.tif

python3 -m crumbs.animate suitability.tif \
      --output suitability.gif