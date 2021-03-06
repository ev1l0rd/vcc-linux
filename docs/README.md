vcc-linux(1) -- Converts videos to JPGV, then packs them up in CIA to be played on the NINTENDO 3DS
==========================

## SYNOPSIS
`build_full.sh` [-cf] [-d [FILE]| -t [-l FILE [-r FILE]]] [-u UNIQUEID] [-n TITLE] [-b BANNER] [-i ICON] [-a AUDIO] [-g AUTHOR] [-q QUALITY] [-p FRAMERATE] [-h]

## DESCRIPTION
Bash script to convert videos to JPGV format. Converted videos are then build in the CIA format, which can be installed on a Nintendo 3DS with the proper CFW or played with citra. Has good error handling and sanity checks. Can be automated with options.

## OPTIONS
* `-c`:
Adds compression to the video. Requires jpegtran to be installed. If not specified, this will be asked during execution.
* `-f`:
Skips command line checking. Generally not recommended.
* `-d` <var>FILE</var>:
Mutually exclusive with `-t`. Specifies a 2D video to be converted.
* `-t`:
Mutually exclusive with `-d`. Tells the script you want to convert a 3D video.
* `-l` <var>FILE</var>: 
Requires `-r` and `-t` to also be specified. The left video of a 3D video.
* `-r` <var>FILE</var>:
Requires `-l` and `-t` to also be specified. The right video of a 3D video.
* `-u` <var>UNIQUEID</var>:
Specifies the <var>UNIQUEID</var> for the resulting CIA. UNIQUEID must be 8 characters long and is given in this format: _0xYYYYYY_, where _0x_ is literal and Y can be _[0-9, A-F]_.
* `-n` <var>TITLE</var>:
Specifies the title for the resulting CIA. The title is used for listing the CIA in the System Settings, as well as visible at the biggest Home Menu zoom.
* `-b` <var>BANNER</var>:
Specifies the banner image. Banner image must be in the PNG format and be 256x128px. The banner is visible when launching the CIA from the Home Menu.
* `-i` <var>ICON</var>:
Specifies the icon. The icon must be in the PNG format and be 48x48px. The icon is visible on the Home Menu and in the System Settings.
* `-a` <var>AUDIO</var>:
Specifies the audio file. The audio file must be in the .wav format and can be up to 3 seconds long.
* `-g` <var>AUTHOR</var>:
Specifies the author/publisher. The author/publisher is visible in the System Settings when selecting the installed CIA, as well as visible at the biggest Home Menu zoom.
* `-q` <var>QUALITY</var>:
Specifies the quality of the resulting video. Must be a valid integer between _[1-32]_.
* `-p` <var>FRAMERATE</var>:
Specifes the amount of frames per second of the resulting video. Must be a valid integer. Too many frames per second will result in duplicate frames and slowdown on the 3DS. Too few frames per second will result in dropped frames, but may work better on older systems. `ffmpeg -i` can be used on the video file to determine the correct value.
* `-h`:
Displays this manual file.

## AUTHOR
Written by Valentijn "ev1l0rd" Vermeij. Original idea and Windows version by Rinnegatamante.

This program uses utilities by The FFmpeg developers, the Independent JPEG Group, the FSF, Steveice10, dnasdw, profi200 and Rinnegatamante. With the exception of Rinnegatamante's jpgv converter, of which the source is included and compiled at runtime, no utilities are included in the source code.

## COPYRIGHT
The jpgv converter does not have any license attached to it, but the repository the original converter is in is under the GPL v3.0, so I'm assuming the jpgv converter is under the GPL v3.0 as well.

The rest of the repository is under the following license:

    vcc-linux Copyright (C) 2017 Valentijn "ev1l0rd" Vermeij

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.



[SYNOPSIS]: #SYNOPSIS "SYNOPSIS"
[DESCRIPTION]: #DESCRIPTION "DESCRIPTION"
[OPTIONS]: #OPTIONS "OPTIONS"
[AUTHOR]: #AUTHOR "AUTHOR"
[COPYRIGHT]: #COPYRIGHT "COPYRIGHT"


[vcc-linux(1)]: manpage.html
