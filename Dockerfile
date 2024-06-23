FROM ubuntu:24.04

# Use bash as the default shell
SHELL ["/bin/bash", "-c"]

WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake net-tools htop vim-nox python3-dev\
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

RUN apt install apt-transport-https dirmngr gnupg2 -y
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb https://download.mono-project.com/repo/ubuntu vs-bionic main" | tee /etc/apt/sources.list.d/mono-official-vs.list
RUN apt update
RUN apt install mono-complete monodevelop -y
RUN apt install golang-go nodejs npm default-jdk default-jre -y
RUN cd /root/.vim/plugged/YouCompleteMe/;python3 install.py --all --force-sudo

COPY .tmux.conf /root/.tmux.conf
COPY .gitconfig /root/.gitconfig

COPY .bashrc /root/.bashrc.tmp
RUN curl -o /usr/share/doc/fzf/examples/key-bindings.bash https://raw.githubusercontent.com/junegunn/fzf/0.44.1/shell/key-bindings.bash
RUN cat /root/.bashrc.tmp >> /root/.bashrc
RUN rm /root/.bashrc.tmp
