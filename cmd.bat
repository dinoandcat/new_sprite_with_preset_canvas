@echo off

:: 定义变量
set SRC_DIR=src
set PACKAGE_JSON=package.json
set OUTPUT_DIR=output
set FINAL_NAME=new_sprite_with_preset_canvas.aseprite-extension

:: 创建输出目录（如果不存在）
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
) else (
    echo clear output folder...
    del /q "%OUTPUT_DIR%\*" 2>nul
    if errorlevel 1 (
        echo  ERROR: Clear output folder failed.
        exit /b 1
    )
)

:: 检查 src 文件夹和 package.json 文件是否存在
if not exist "%SRC_DIR%" (
    echo  ERROR: src folder does not exist.
    exit /b 1
)

if not exist "%PACKAGE_JSON%" (
    echo   ERROR: package.json does not exist.
    exit /b 1
)

:: 使用 7-Zip 压缩 package.json 和 src 文件夹的内容，输出为 .aseprite-extension 文件
echo zip package.json and src folder's contents...
7z a -tzip "%OUTPUT_DIR%\%FINAL_NAME%" "%PACKAGE_JSON%" "%SRC_DIR%\*" >nul
if errorlevel 1 (
    echo ERROR: Zip failed.
    exit /b 1
)

echo success to create %FINAL_NAME% in %OUTPUT_DIR% 

exit /b 0
