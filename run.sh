#!/bin/bash

# Compile code
make

# Check if the compilation was successful
if [ $? -eq 0 ]; then
    echo "Compilation successful."
else
    echo "Compilation failed. Exiting script."
    exit 1
fi

# Copy the image file to the SD card
cp /home/mvelasqu/usp/3ma/labproc/testes/final/out/teste.img /media/mvelasqu/644E-159C/teste.img

# Check if the copy was successful
if [ $? -eq 0 ]; then
    echo "Copy successful: teste.img has been copied to the SD card."
else
    echo "Copy failed. Please check the SD card and try again."
    exit 1
fi
