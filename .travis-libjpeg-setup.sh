#!/bin/sh
wget "http://www.ijg.org/files/jpegsrc.v9b.tar.gz" -O /tmp/libjpeg.tar.gz
tar -xzvf /tmp/libjpeg.tar.gz
cd jpeg-9b/ && ./configure --prefix=$HOME && make && make install

