#!/bin/bash

# 定义变量
SRC_DIR="src"
PACKAGE_JSON="package.json"
OUTPUT_DIR="output"
FINAL_NAME="new_sprite_with_preset_canvas.aseprite-extension"

# 检查并创建 output 文件夹
mkdir -p "$OUTPUT_DIR"

# 检查 src 文件夹和 package.json 文件是否存在
if [ ! -d "$SRC_DIR" ]; then
    echo "ERROR: src folder does not exist."
    exit 1
fi

if [ ! -f "$PACKAGE_JSON" ]; then
    echo "ERROR: package.json does not exist."
    exit 1
fi

# 清空 output 文件夹
echo "cleaning output folder..."
rm -rf "$OUTPUT_DIR"/*

# 压缩 package.json 和 src 文件夹的内容，直接输出到 output 文件夹并命名为 .aseprite-extension
echo "压缩 package.json 和 src 文件夹的内容..."
zip -r "$OUTPUT_DIR/$FINAL_NAME" "$PACKAGE_JSON" "$SRC_DIR" > /dev/null
if [ $? -ne 0 ]; then
    echo "ERROR: zip failed."
    exit 1
fi

echo  success to create %$FINAL_NAME% in %$OUTPUT_DIR%
