FROM archlinux:latest

RUN pacman -Syu --noconfirm && pacman -S --noconfirm vim sudo base-devel git yajl asp go pacman-contrib reflector zsh namcap
COPY mkosi.postinst /home/root/postinstall.sh
COPY mkosi.skeleton/ /
RUN chmod +x /home/root/postinstall.sh && /home/root/postinstall.sh
COPY build.sh /home/bldr/build.sh

USER bldr
CMD ["/bin/zsh","-x", "/home/bldr/build.sh"]
