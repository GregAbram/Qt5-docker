FROM gregabram/qt5-base

COPY local/Qt.tgz Qt.tgz
RUN cd /opt && tar xf /Qt.tgz
RUN rm /Qt.tgz

RUN apt-get install -y patchelf 
