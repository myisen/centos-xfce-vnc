# This Dockerfile is used to build an headles vnc image based on Centos

FROM centos:7.5.1804

MAINTAINER Marc Schweikert "schweikertm@udev.local"

ENV DISPLAY=:1 \
    VNC_PORT=5901

EXPOSE $VNC_PORT

### Envrionment config
ENV HOME=/headless \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    DATADIR=/data \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024 \
    VNC_PW=password \
    VNC_VIEW_ONLY=false
WORKDIR $HOME

### setup repositories
COPY src/repos/*.repo /etc/yum.repos.d/
COPY src/repos/RPM-GPG-KEY* /etc/pki/rpm-gpg/
RUN  rpm --import /etc/pki/rpm-gpg/*

### update OS
RUN yum-config-manager --save --setopt gpgcheck=0 main && \
    yum makecache fast && \
    yum -y upgrade && \
    yum clean all && \
    rm -fr /var/cache/yum

# generate our locale (appears to be an upstream bug)
RUN localedef -i en_US -f UTF-8 en_US.UTF-8

### Install core tools to make the rest easier
RUN yum makecache fast && \
    yum -y install man-db info deltarpm && \
    yum clean all && \
    rm -fr /var/cache/yum

### Install some common tools
RUN yum makecache fast && \
    yum -y install vim sudo wget which net-tools bzip2 unzip mlocate screen rsync && \
    yum clean all && \
    rm -fr /var/cache/yum

### Install git
RUN yum makecache fast && \
    yum -y install git2u-gitk git2u-gui tig && \
    yum clean all && \
    rm -fr /var/cache/yum

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN yum makecache fast && \
    yum -y install tigervnc-server && \
    yum clean all && \
    rm -fr /var/cache/yum

### Install firefox and chrome browser
RUN yum makecache fast && \
    yum -y install firefox && \
    yum clean all && \
    rm -fr /var/cache/yum

### Install xfce UI
RUN yum makecache fast && \
    yum -y -x gnome-keyring --skip-broken install Thunar xfce4-panel xfce4-session xfce4-settings xfconf xfdesktop xfwm4 NetworkManager-gnome gdm leafpad openssh-askpass orage polkit-gnome thunar-archive-plugin thunar-volman tumbler xfce4-appfinder xfce4-icon-theme xfce4-power-manager xfce4-pulseaudio-plugin xfce4-session-engines xfce4-terminal xfwm4-theme-nodoka xfwm4-themes pinentry-gtk && \
    yum -y remove *\power\* \*screensaver\* && \
    yum clean all && \
    rm -fr /var/cache/yum && \
    rm /etc/xdg/autostart/xfce-polkit* && \
    /bin/dbus-uuidgen > /etc/machine-id

### configure startup
RUN yum makecache fast && \
    yum -y install nss_wrapper gettext && \
    yum clean all && \
    rm -fr /var/cache/yum

### deliver files
COPY src/xfce/ $HOME/
COPY src/xfce/bashrc $HOME/.bashrc
COPY src/scripts $STARTUPDIR

### perstent files
RUN mkdir $DATADIR
VOLUME $DATADIR

### set root password
RUN echo "root" | passwd --stdin root

### create user account for headless
RUN groupadd --gid 54321 headless && \
    useradd --gid 54321 --uid 54321 --shell /bin/bash --home /headless headless && \
    usermod -aG wheel headless && \
    echo "headless" | passwd --stdin headless

### restore permissions
RUN for var in $STARTUPDIR $HOME $DATADIR; do \
    find "$var"/ -name '*.sh' -exec chmod $verbose a+x {} +; \
    chown -cR headless: $var; \
    done

USER headless

CMD ["/bin/bash"]
