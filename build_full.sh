#!/bin/bash
# Video Channels Creator - Linux Edition
# Original version by [Rinnegatamante](http://rinnegatamante.it)

# Command line checking. See http://stackoverflow.com/a/677212/4666756 for details.
command -v ffmpeg >/dev/null 2>&1 || { echo -e "\e[1;31mFFMpeg is not installed or it is not added to your PATH."; echo -e "Install FFMpeg or add it to your PATH, then rerun this script.\e[0m"; exit 1; }
command -v jpegtran >/dev/null 2>&1 || { echo -e "\e[1;33mjpegtran is not installed or it is not added to your PATH."; echo "jpegtran is required for video compression."; echo "jpegtran is in the libjpeg-turbo package on most systems."; echo -e "If it is not, you can get it from here and compile it yourself: http://jpegclub.org/jpegtran/ . \e[0m";}
command -v bannertool >/dev/null 2>&1 || { echo -e "\e[1;31mBannertool is not installed or it is not added to your PATH."; echo "Bannertool is required for VCC."; echo "Bannertool is installed with DevKitPro."; echo -e "To install DevKitPro, please follow the instructions at: http://wiki.gbatemp.net/wiki/3DS_Homebrew_Development#Linux_.2F_Mac_OSX \e[0m";}
# Convert a 3D video?
read -rp "Convert a 3D video? (1 = Yes, 2 = No) " threedeevid

case $threedeevid in
	1)
	touch romfs/three.txt
	read -rp "Insert left channel video name (Example: left.mp4): " threedeeleft
	read -rp "Insert right channel video name (Example: right.mp4): " threedeeright
	;;
	2)
	read -rp "Insert video name (Example: video.mp4): " videoname
	;;
esac

# Asking other questions
read -rp "Insert video framerate: " framerate
read -rp "Insert video quality (From 1 to 32, lower = better quality, higher = better filesize): " quality
read -rp "Do you want to apply extra compression (slow process and slight filesize reducing)? (1 = Yes, 2 = No): " compression
read -rp "Insert cia Unique ID [0-9, A-F] (Example: AAAAAA): " uniqueid
read -rp "Insert banner image (Example: banner.jpg): " ciabanner
read -rp "Insert banner audio: (Example: audio.wav): " ciaudio
read -rp "Insert icon image: (Example: icon.png): " cicon
read -rp "Insert video title: " videotitle
read -rp "Insert video author: " videoauthor

# Converting video to JPGV format
case $threedeevid in
	1)
	ffmpeg -i "../files/$threedeeleft" -r "$framerate" -qscale:v "$quality" -vf "transpose=1" -s 240x400 "temp_left/output%%1d.jpg"
	if [ $? != 0 ]; then
		echo "An error occured in FFMpeg, conversion aborted."
		exit 1
	fi 	
	ffmpeg -i "../files/$threedeeright" -r "$framerate" -qscale:v "$quality" -vf "transpose=1" -s 240x400 "temp_right/output%%1d.jpg"
	if [ $? != 0 ];then 
		echo "An error occured in FFMpeg, conversion aborted."
		exit 1
	fi 
	;;
	2)
	ffmpeg -i "../files/$videoname" -r "$framerate" -qscale:v "$quality" -vf "transpose=1" -s 240x400 "temp/output%%1d.jpg"
	if [ $? != 0 ]; then
		echo "An error occured in FFMpeg, conversion aborted."
		exit 1
	fi 
	;;
esac

# Video compression
if [[ "1" == "$compression" ]]; then
	if [[ $threedeevid == 1 ]]; then
		echo "Starting left video optimization through jpegtran, please wait..."
		# Left side compression
		for leftrawjpgs in temp_left/*
		do
			jpegtran -optimize -outfile "$leftrawjpgs" "$leftrawjpgs"
		done
		# Right side compression
		for rightrawjpgs in temp_right/*
		do
			jpegtran -optimize -outfile "$rightrawjpgs" "$rightrawjpgs"
		done
	fi
	if [[ $threedeevid == 2 ]]; then
		echo "Starting video optimization through jpegtran, please wait..."
		for rawjpgs in temp/*
		do
			jpegtran -optimize -outfile "$rawjpgs" "$rawjpgs"
		done 
	fi
fi

# Audio extraction
echo "Starting audio extraction through ffmpeg, please wait..."
if [[ "1" == "$threedeevid" ]]; then
	ffmpeg -i "../files/$threedeeleft" -acodec: libvorbis -ac 2 -ar 24000 -vn temp/audio.ogg
fi

if [[ "2" == "$threedeevid" ]]; then
	ffmpeg -i "../files/$videoname" -acodec: libvorbis -ac 2 -ar 24000 -vn temp/audio.ogg
fi

# Creating JPGV file

# We start with checking if the encoder is already compiled, and if not, we compile it. This is better because that way, it will always work, regardless of architecture.
if [ ! -f "linuxstuffs/jpgv_encoder_2d" ]; then
	exec linuxstuffs/vid2jpgvsauce/build.sh
fi

if [ ! -f "linuxstuffs/jpgv_encoder_3d" ]; then
	exec linuxstuffs/vid2jpgvsauce/build.sh
fi

# Now to actually create the jpgv
if [[ "1" == "$threedeevid" ]]; then
	exec linuxstuffs/jpgv_encoder_3d "$quality"
fi

if [[ "2" == "$threedeevid" ]]; then
	exec linuxstuffs/jpgv_encoder_2d "$quality"
fi

echo "Deleting temp files..."
rm -rf temp/* temp_left/* temp_right/*

mv output.jpgv romfs/video.jpgv

# Makerom prepping
echo "Creating icon and banner files..."
bannertool makebanner -i "files/$ciabanner" -a "files/$ciaudio" -o "tmp/banner.bin"
if [ $? != 0 ];then 
	echo "An error occured in bannertool, conversion aborted."
	echo "The JPGV file has been backupped as saved.jpgv, use the build_jpgv.bat script to use this file instead of re-creating it."
	mv romfs/video.jpgv saved.jpgv
	exit 1
fi 

bannertool makesmdh -s "$videotitle" -l "$videotitle" -p "$videoauthor" -i "files/$cicon" -o "tmp/icon.bin"
if [ $? != 0 ];then 
	echo "An error occured in bannertool, conversion aborted."
	echo "The JPGV file has been backupped as saved.jpgv, use the build_jpgv.bat script to use this file instead of re-creating it."
	mv romfs/video.jpgv saved.jpgv
	exit 1
fi 
