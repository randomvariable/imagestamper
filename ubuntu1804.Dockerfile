FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y apt-utils

# Packages marked as "Required", as pulled by debootstrap
RUN apt-get install -y \
  base-files \
  base-passwd \
  bash \
  bsdutils \
  cloud-init \
  coreutils \
  dash \
  debconf \
  debianutils \
  diffutils \
  dpkg \
  e2fsprogs \
  fdisk \
  findutils \
  gcc-8-base \
  grep \
  gzip \
  hostname \
  ifupdown \
  init-system-helpers \
  libacl1 \
  libattr1 \
  libaudit-common \
  libaudit1 \
  libblkid1 \
  libbz2-1.0 \
  libc-bin \
  libc6 \
  libcap-ng0 \
  libcom-err2 \
  libdb5.3 \
  libdebconfclient0 \
  libext2fs2 \
  libfdisk1 \
  libgcc1 \
  libgcrypt20 \
  libgpg-error0 \
  liblz4-1 \
  liblzma5 \
  libmount1 \
  libncurses5 \
  libncursesw5 \
  libpam-modules \
  libpam-modules-bin \
  libpam-runtime \
  libpam0g \
  libpcre3 \
  libprocps6 \
  libseccomp2 \
  libselinux1 \
  libsemanage-common \
  libsemanage1 \
  libsepol1 \
  libsmartcols1 \
  libss2 \
  libsystemd0 \
  libtinfo5 \
  libudev1 \
  libuuid1 \
  libzstd1 \
  login \
  lsb-base \
  mawk \
  mount \
  ncurses-base \
  ncurses-bin \
  netplan.io \
  nplan \
  passwd \
  perl-base \
  procps \
  sed \
  sensible-utils \
  sysvinit-utils \
  tar \
  util-linux \
  xfsprogs \
  xfsdump \
  zlib1g

COPY /files/common/etc/sysctl.d/fs.file-max.conf /etc/sysctl.d/fs.file-max.conf
COPY /files/common/etc/sysctl.d/fs.inotify.max_user_watches.conf /etc/sysctl.d/fs.inotify.max_user_watches.conf
COPY /files/common/etc/sysctl.d/net.bridge.bridge-nf-call-ip6tables.conf /etc/sysctl.d/net.bridge.bridge-nf-call-ip6tables.conf
COPY /files/common/etc/sysctl.d/net.bridge.bridge-nf-call-iptables.conf /etc/sysctl.d/net.bridge.bridge-nf-call-iptables.conf
COPY /files/common/etc/sysctl.d/net.core.default_qdisc.conf /etc/sysctl.d/net.core.default_qdisc.conf
COPY /files/common/etc/sysctl.d/net.ipv4.ip_forward.conf /etc/sysctl.d/net.ipv4.ip_forward.conf
COPY /files/common/etc/sysctl.d/net.ipv4.tcp_congestion_control.conf /etc/sysctl.d/net.ipv4.tcp_congestion_control.conf

RUN apt-get install -y \
  awscli \
  linux-aws \
  euca2ools

RUN systemctl enable fstrim.timer
