docker run -v `pwd`/local:/local -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=host.docker.internal:0 -it gregabram/qt5 /bin/bash
