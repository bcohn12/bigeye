---
layout: page
title: Installation
---


## Installing R:


All *R* code that is available has only been tested on Terminal/Command Prompt. Installation guides for required packages
based on platform are provided below

### Windows:

1. Download R for windows from [here](https://cran.r-project.org/bin/windows/base/)
2. Record the installation location: e.g. C:\Program Files\R\R-3.3.2
3. If the installation is done in C:\ make sure to run command prompt in administrative mode
4. Add the path to x64 (e.g: C:\Program Files\R\R-3.3.2\bin\x64) to the path/environment variable

### Mac OS X:

1. Download R for Mac OS X for 10.9 of higher [here](https://cran.r-project.org/bin/macosx/R-3.3.2.pkg) or from the terminal: 

<pre>
$ sudo port install R 
</pre>

2. Installation on Mac's requires extra tools, [fortran](https://cran.r-project.org/bin/macosx/tools/gfortran-4.2.3.pkg) and [tcltk](https://cran.r-project.org/bin/macosx/tools/tcltk-8.5.5-x11.pkg). Once downloads are complete, install R then fortran then tcltk

The easiest way to make sure everything is installed properly is to install through [*brew*](http://www.howtogeek.com/211541/homebrew-for-os-x-easily-installs-desktop-apps-and-terminal-utilities/)


<pre>
$ brew tap homebrew/science
$ brew install Caskroom/cask/xquartz
$ brew install r
</pre>

After *R* is installed [download](https://github.com/maciverlab/bigeye/blob/master/data/paleo/installer.R) the required packages by running 


<pre>
$ Rscript installer.R --cwd
</pre>

## Required packages in MATLAB and requirements:


Curve fitting and Image Processing toobloxes are required to implement the code without errors.

Before running any individual file run [bigeye_startup](https://github.com/maciverlab/bigeye/blob/master/bigeye_startup.m) to link all the directories. 
