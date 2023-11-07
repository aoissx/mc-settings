#!/bin/bash

# gitignoreで無視されているファイルを表示
ignored_files=$(git ls-files --others --ignored --exclude-standard)

# 無視されているファイルを一つずつ削除
for file in $ignored_files
do
    rm -rf $file
done