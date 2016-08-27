#!/bin/bash
echo "Compiling 2D encoder"
gcc -o jpgv_encoder_2d main_m.c
echo "Compiling 3D encoder"
gcc -o jpgv_encoder_3d main_s.c
echo "Moving files to linuxstuffs"
mv jpgv_encoder_2d ../
mv jpgv_encoder_3d ../
echo "Finished"
