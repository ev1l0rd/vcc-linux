#!/bin/bash
# Video Channels Creator - Linux Edition
# Original version by [Rinnegatamante](http://rinnegatamante.it)
function usage() {
# shellcheck disable=SC2086
cat <<EOF
	Usage: $(basename $0) [-cf] [-d [FILE]| -t [-l FILE [-r FILE]]] [-u UNIQUEID] [-n TITLE] [-b BANNER] [-i ICON] [-a AUDIO] [-g AUTHOR] [-q QUALITY] [-p FRAMERATE] [-h]

Can also be called without arguments. Script will go interactive for any missing arguments. All arguments are optional.

Run man ./docs/manpage or $(basename $0) -h for individual option coverage.

EOF
}

#getopts parsing
while getopts ":cfhd:tl:r:u:n:b:i:a:q:p:g:" opt; do
	case $opt in
	c)
		compression=1
		;;
	f)
		FORCED=1
		;;
	h)
		man './docs/manpage'
		;;
	d)
		VIDFILESET=1
		threedeevid=2
		videoname=$OPTARG
		;;
	t)
		VIDFILESET=1
		threedeevid=1
		;;
	l)
		threedeeleft=$OPTARG
		;;
	r)
		threedeeright=$OPTARG
		;;
	u)
		uniqueid=$OPTARG
		;;
	n)
		videotitle=$OPTARG
		;;
	i)
		cicon=$OPTARG
		;;
	b)
		ciabanner=$OPTARG
		;;
	a)
		ciaudio=$OPTARG
		;;
	q)
		quality=$OPTARG
		;;
	p)
		framerate=$OPTARG
		;;
	g)
		videoauthor=$OPTARG
		;;
	esac
done

#Thank stackoverflow again. http://stackoverflow.com/a/2210386/4666756
if [[ -n $quality ]]; then

	if [[ $quality =~ ^[0-9]+$ ]]; then
		echo "Quality is a positive integer"
	else
		echo "Quality is not a positive integer. Exiting"
		exit 1
	fi
fi

if [[ -n $framerate ]]; then
	if [[ $framerate =~ ^[0-9]+$ ]]; then
		echo "Framerate is a positive integer"
	else
		echo "Framerate is not a positive integer. Exiting"
		exit 1
	fi
fi

if [[ -n $VIDFILESET ]]; then
	if [[ -z $threedeeleft || -z $threedeeright ]]; then
		echo "3D video flag given, but no left and/or right video specified. Exiting"
		exit 1
	fi
fi

if [ -z "$FORCED" ]; then
# Command line checking. See http://stackoverflow.com/a/677212/4666756 for details.
command -v ffmpeg >/dev/null 2>&1 || { echo -e "\e[1;31mFFMpeg is not installed or it is not added to your PATH."; echo -e "Install FFMpeg or add it to your PATH, then rerun this script.\e[0m"; exit 1; }
command -v jpegtran >/dev/null 2>&1 || { echo -e "\e[1;33mjpegtran is not installed or it is not added to your PATH."; echo "jpegtran is required for video compression."; echo "jpegtran is in the libjpeg-turbo-progs package on Ubuntu systems."; echo -e "If it is not, you can get it from here and compile it yourself: http://jpegclub.org/jpegtran/ . \e[0m";}
command -v bannertool >/dev/null 2>&1 || { echo -e "\e[1;31mBannertool is not installed or it is not added to your PATH."; echo "Bannertool is required for VCC."; echo "Bannertool can be obtained here: https://github.com/Steveice10/bannertool/releases \e[0m";}
command -v 3dstool >/dev/null 2>&1 || { echo -e "\e[1;313dstool is not installed or it is not added to your PATH."; echo "3dstool is required for VCC."; echo -e "Install 3dstool or add it to your PATH, then rerun this script. 3dstool can be obtained from here: https://github.com/dnasdw/3dstool/releases \e[0m"; exit 1; }
command -v makerom >/dev/null 2>&1 || { echo -e "\e[1;31makerom is not installed or it is not added to your PATH."; echo "makerom is required for VCC."; echo -e "Install makerom or add it to your PATH, then rerun this script. 3dstool can be obtained from here: https://github.com/profi200/Project_CTR/releases \e[0m"; exit 1; }

echo "Command line appears to be correct. Continuing."
else
	echo "Skipping commandline checks."
fi

# Get previous UniqueID - Note, this is currently stored in a serparate file, cuz I'm lazy.
initialuniqueid=$(cat "linuxstuffs/uniq")

# Convert a 3D video?
if [ -z "$VIDFILESET" ]; then
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
else
	echo "Video Files already set"
fi

# Asking other questions
if [ -z "$framerate" ]; then
	read -rp "Insert video framerate: " framerate
else
	echo "Framerate set to $framerate."
fi

if [ -z "$quality" ]; then
	read -rp "Insert video quality (From 1 to 32, lower = better quality, higher = better filesize): " quality
else
	echo "Quality set to $quality"
fi

if [ -z "$compression" ]; then
	read -rp "Do you want to apply extra compression (slow process and slight filesize reducing)? (1 = Yes, 2 = No): " compression
else
	echo "Compression set to true."
fi

if [ -z "$uniqueid" ]; then
	read -rp "Insert cia Unique ID [0-9, A-F] (Example: 0xAAAAAA): " uniqueid
else
	echo "UniqueID set to $uniqueid."
fi

if [ -z "$ciabanner" ]; then
	read -rp "Insert banner image (Example: banner.jpg): " ciabanner
else
	echo "Banner image set to $ciabanner"
fi

if [ -z "$ciaudio" ]; then
	read -rp "Insert banner audio: (Example: audio.wav): " ciaudio
else
	echo "Banner audio set to $ciaudio"
fi

if [ -z "$cicon" ]; then
	read -rp "Insert icon image: (Example: icon.png): " cicon
else
	echo "Icon image set to $cicon"
fi

if [ -z "$videotitle" ]; then
	read -rp "Insert video title: " videotitle
else
	echo "Video title set to $videotitle"
fi

if [ -z "$videoauthor" ]; then
	read -rp "Insert video author: " videoauthor
else
	echo "Video author set to $videoauthor"
fi

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

# We start by generating the romfs for usage in makerom
echo "Creating romfs file..."
3dstool -cvtf romfs tmp/romfs.bin --romfs-dir romfs
if [ $? != 0 ];then 
	echo "An error occured in bannertool, conversion aborted."
	echo "The JPGV file has been backupped as saved.jpgv, use the build_jpgv.bat script to use this file instead of re-creating it."
	mv romfs/video.jpgv saved.jpgv
	exit 1
fi 

# Now we make a cia out of it
sed -i "s/$initialuniqueid/$uniqueid/g" "linuxstuffs/cia_workaround.rsf"
echo "$uniqueid" > "linuxstuffs/uniq"
echo "Generating CIA..."
makerom -f cia -o my_video.cia -elf "linuxstuffs/lpp-3ds.elf" -rsf "linuxstuffs/cia_workaround.rsf" -icon "tmp/icon.bin" -banner "tmp/banner.bin" -exefslogo -target t -romfs "tmp/romfs.bin"
if [ $? != 0 ];then 
	echo "An error occured in makerom, conversion aborted."
	echo "The JPGV file has been backupped as saved.jpgv, use the build_jpgv.bat script to use this file instead of re-creating it."
	mv romfs/video.jpgv saved.jpgv
	exit 1
fi 

# Removing temporary files
echo "Removing temporary files..."
rm -rf "tmp/*"
rm -rf "romfs/video.jpgv"
echo "Video converted succesfully!"
exit 0
