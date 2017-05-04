#!/bin/bash
# Requires ronn to be installed.

ronn --roff --html --markdown --manual="VCC-Linux" --organization="ev1l0rd" --style="toc" manpage.ronn
cp manpage.1.markdown README.md
