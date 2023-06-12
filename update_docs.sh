#!/bin/bash

DIR_THIS="nimcatapi"
DIR_ORIGIN=$(pwd)
DIR_PRF=~/Coding/GitHub/nirokay.github.io
DIR_OUT=$DIR_PRF/nim-docs
DIR_DOC=$DIR_ORIGIN/docs

# Generate docs:
nim doc --project --index:off --outdir:"$DIR_DOC" "$DIR_THIS.nim"

# Check dirs:
[ ! -d "$DIR_PRF" ] && echo "Destination dir was not found" && exit 1
[ ! -d "$DIR_DOC" ] && echo "Docs did not create successfully" && exit 1

# cd into dir:
[ ! -d $DIR_OUT ] && mkdir "$DIR_OUT"
[ ! -d $DIR_OUT/$DIR_THIS ] && mkdir "$DIR_OUT/$DIR_THIS"
cd "$DIR_OUT/$DIR_THIS" || exit 1

# Pull hcanges and copy files:
git pull
cp -r "$DIR_DOC"/* "$DIR_OUT/$DIR_THIS"

git add .
git commit -m "Updated docs on $(date)"

# cd back:
cd "$DIR_ORIGIN" || exit 1
