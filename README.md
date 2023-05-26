
# Qt5.15 Development Container

Stuff in this directory creates the Qt5.15 development image that is available on the docker hub as gregabram/qt5.   If you are running docker, you *should* be able to simply 

**docker run -it gregabram/qt5** 

to get a prompt at a container that you can use to develop Qt5.15 apps.   If you use **apptainer** you *should* be able to run:

**apptainer pull docker://gregabram/qt5**

**apptainer run qt5_latest.sif**

The remainder of this document relates how I created this image.

## The Base image ##

I separated the creation of a base image from the build/install of Qt5.  In the **base** subdir there is a Dockerfile that creates a Ubuntu image with a bunch of X11 etc. packages.

**cd base**

**docker build -t {name}/qt-base .**

**docker push {name}/qt-base**

## The Qt5 dev image

I built the Qt5 development environment by installing Qt5 into the qt5-base image.

### Failed Compile/Build Approach

Dockerfile.compile builds an image containing Qt5.15.9 by compiling from source and installing inside the Dockerfile.   Worked fine on LS6 and my Rocky9 workstation, but not on Stampede2 or Frontera.   No idea why.   Those two run CentOS7, whike the others are CentOS8 or Rocky9.

### Success using Qt's Online Installer

Instead, I built an image by running the gregabram/qt5-base and installing using the Qt online installer, then tarring up the istallation.  The Dockerfile herein then copies that tar file and untars it in the right place.  Here's how I built the tar file.

First, going to need to have a shared directory so that, once the Qt install is done, I can tar the important bits back to the host.   


I used the build-run.sh script to start a gregabram/qt5-base, which is ubuntu:20.04 with all sorts of X stuff installed.  It links the HERE/local dir found here to /local in the container.   It also sets up the necessities to connect the container to an X11 server on the host, so make sure you have eg. XQuartz running and xhost +.  

First downoad the ***linux*** Qt5 online installer to the shared local directory.  You can get it from https://www.qt.io/download-qt-installer.  Remember - we are installing it inside a Linux container.   

Now we run the container.

**cd qt5**

**sh build.sh**

From the container prompt, I ran the Qt online installer.  You can download one; I've included one in /local/qti.run.  This is an executable - just run:

**./qti.run**.

This *should* start the Qt installer GUI on the host.   I then put in my Qt credentials and installed Qt5.15.2.  When that finished I tarred the installation to the shared local directory:

**cd /opt**

**tar cf /local/Qt.tgz Qt/5.15.2/gcc_64**

This bundles just the development environment - includes and libs, primarily.   

Then I built the development image itself.  First, if you created your own base image, change the Dockerfile to reference your base image.  Then:

**docker build -t {name}/qt5 .**

This copies the tar file, cd's to /opt, and untars it.

I then pushed gregabram/qt5:

**docker push {name}/qt5**

## Use on HPC systems

Using the TAP portal, I started a desktop job on S2.   In a xterm I:

**module purge**

**module load tacc-apptainer**

I went to \$WORK/qt5 and pulled the container (if qt5_latest.sif is there I removed it).  If you built and pushed your own image, change *gregabram* to *{name}* in the following.

**apptainer pull docker://gregabram/qt5  **

And ran it: 

**apptainer run qt5_latest.sif**

From that prompt I first added the Qt5 bins to my PATH env variable:

**export PATH=/opt/Qt5/5.15.2/gcc_64:\$PATH**

I had previously copied the qt3d example to \$WORK/qt5.  I cd'd to examples/qt3d/wave.
If there is a build subdir I removed its contents; otherwise I created it. Then:

**cd build**

**qmake ../wave.pro**

**make**

**./wave**

and up it came!   Subsequently, since the wave build was in the host file system, I could (in the host xterm):

**apptainer run qt5_latest.sif examples/qt3d/wave/build/wave**

## Extending the image

I've included the **emacs** directory as a example of how one might extend the qt5 image with other stuff necessary to build an end-user application using Qt5.  In that directory there is a Dockerfile that begins with **gregabram/qt5**, then uses apt-get to install emacs.   Again, if you built your own, change the FROM line to reference your own qt5 image.

If you enter that directory and run:

**docker build -t {name}/qt5-emacs .**

It will build an image with both Qt5.15 and emacs.   If you have an accessible X server running, you can change **run.sh** to reference your new image and run:

**sh run.sh**

and get an emacs window up. 
