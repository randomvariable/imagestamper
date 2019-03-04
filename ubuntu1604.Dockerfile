FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y apt-utils

# Packages marked as "Required", as pulled by debootstrap
RUN apt-get install -y \
  apt-transport-https \
  ca-certificates \
  cloud-init \
  cloud-initramfs-growroot \
  adduser \
  debconf \
  e2fslibs \
  gcc-6-base \
  init-system-helpers \
  initscripts \
  insserv \
  libacl1 \
  libapparmor1 \
  libattr1 \
  libaudit-common \
  libaudit1 \
  libblkid1 \
  libbz2-1.0 \
  libc6 \
  libcap2 \
  libcap2-bin \
  libcomerr2 \
  libcryptsetup4 \
  libdb5.3 \
  libdebconfclient0 \
  libdevmapper1.02.1 \
  libfdisk1 \
  libgcc1 \
  libgcrypt20 \
  libgpg-error0 \
  libkmod2 \
  liblzma5 \
  libmount1 \
  libncurses5 \
  libncursesw5 \
  libpam-modules \
  libpam-modules-bin \
  libpam-runtime \
  libpam0g \
  libpcre3 \
  libprocps4 \
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
  libustr-1.0-1 \
  libuuid1 \
  locales \
  lsb-base \
  makedev \
  mawk \
  multiarch-support \
  passwd \
  procps \
  rng-tools \
  sensible-utils \
  ssh \
  systemd \
  systemd-sysv \
  sysv-rc \
  sysvinit-utils \
  tzdata \
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
  linux-aws-hwe \
  awscli \
  euca2ools

