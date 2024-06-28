FROM ubuntu:24.04

# Use bash as the default shell
SHELL ["/bin/bash", "-c"]

WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake clang net-tools htop vim-nox python3-dev wget\
    xfce4 xfce4-goodies tightvncserver tigervnc-standalone-server dbus-x11 xfonts-base \
    vim tmux ranger neofetch curl git fzf\
    python3 python-is-python3 python3-pip python3-venv

EXPOSE 5902

RUN mkdir /root/.vnc \
    && echo "000000" | vncpasswd -f > /root/.vnc/passwd \
    && chmod 600 /root/.vnc/passwd

RUN touch /root/.Xauthority

COPY .vimrc /root/.vimrc
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

RUN vim -es -u ~/.vimrc -i NONE -c "PlugInstall" -c "qa"

RUN apt install dirmngr gnupg apt-transport-https ca-certificates software-properties-common -y
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN apt-add-repository 'deb https://download.mono-project.com/repo/ubuntu stable-focal main'
RUN apt update -y
RUN apt install mono-complete -y
RUN wget https://golang.org/dl/go1.22.4.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.22.4.linux-amd64.tar.gz
RUN ls /usr/local/go/bin
RUN export PATH=$PATH:/usr/local/go/bin; go version
RUN apt install nodejs npm default-jdk default-jre -y
RUN cd /root/.vim/plugged/YouCompleteMe/;export PATH=$PATH:/usr/local/go/bin;python3 install.py --all --force-sudo

COPY .tmux.conf /root/.tmux.conf
COPY .gitconfig /root/.gitconfig

COPY .bashrc /root/.bashrc.tmp
RUN curl -o /usr/share/doc/fzf/examples/key-bindings.bash https://raw.githubusercontent.com/junegunn/fzf/0.44.1/shell/key-bindings.bash
RUN cat /root/.bashrc.tmp >> /root/.bashrc
RUN rm /root/.bashrc.tmp
