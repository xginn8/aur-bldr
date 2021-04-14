FROM archlinux:base-devel-20210131.0.14634
RUN sed -i -e '/IgnorePkg *=/s/^.*$/IgnorePkg = coreutils/' /etc/pacman.conf
RUN pacman --needed --noconfirm -Syuq && yes | pacman -Sccq
#FROM archlinux:latest
#RUN pacman -Syu --noconfirm && pacman -S --noconfirm sudo base-devel git pacman-contrib reflector zsh namcap jq
RUN pacman -S --noconfirm sudo base-devel git pacman-contrib reflector zsh namcap jq
COPY mkosi.postinst /home/root/postinstall.sh
COPY mkosi.skeleton/ /
RUN chmod +x /home/root/postinstall.sh && /home/root/postinstall.sh
COPY build.sh pkg-gitignore /home/bldr/
RUN rm -rf /var/cache/pacman/pkg/* /tmp/yay*

USER bldr
CMD ["/bin/zsh","-x", "/home/bldr/build.sh"]
