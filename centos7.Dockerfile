FROM centos:7

RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
COPY /files/centos7/etc/yum.conf /etc/yum.conf
RUN yum update -y

# Based on `yum groupinstall base`
RUN yum -y install \
  audit \
  basesystem \
  bash \
  biosdevname \
  btrfs-progs \
  cloud-init \
  coreutils \
  cronie \
  curl \
  dhclient \
  dracut-config-generic \
  dracut-config-rescue \
  dracut-fips-aesni \
  e2fsprogs \
  efibootmgr \
  filesystem \
  firewalld \
  glibc \
  grub2-tools \
  grub2-efi \
  grub2-efi-x64-modules \
  grub2-pc \
  grub2-pc-modules  \
  hostname \
  initscripts \
  iproute \
  iprutils \
  irqbalance \
  kbd \
  kernel-tools \
  kexec-tools \
  less \
  libseccomp \
  libsysfs \
  linux-firmware \
  lshw \
  man-db \
  microcode_ctl \
  ncurses \
  NetworkManager \
  openssh-clients \
  openssh-keycat \
  openssh-server \
  parted \
  plymouth \
  polycoreutils \
  postfix \
  procps-ng \
  rng-tools \
  rootfiles \
  rpm \
  rsyslog \
  selinux-policy-targeted \
  setup \
  sg3_utils \
  sg3_utils-libs \
  shadow-utils \
  shim \
  sudo \
  systemd \
  tar \
  tuned \
  util-linux \
  vim-minimal \
  xfsprogs \
  yum

RUN systemctl enable rngd
RUN systemctl enable fstrim.timer

COPY /files/common/etc/sysctl.d/fs.file-max.conf /etc/sysctl.d/fs.file-max.conf
COPY /files/common/etc/sysctl.d/fs.inotify.max_user_watches.conf /etc/sysctl.d/fs.inotify.max_user_watches.conf
COPY /files/common/etc/sysctl.d/net.bridge.bridge-nf-call-ip6tables.conf /etc/sysctl.d/net.bridge.bridge-nf-call-ip6tables.conf
COPY /files/common/etc/sysctl.d/net.bridge.bridge-nf-call-iptables.conf /etc/sysctl.d/net.bridge.bridge-nf-call-iptables.conf
COPY /files/common/etc/sysctl.d/net.core.default_qdisc.conf /etc/sysctl.d/net.core.default_qdisc.conf
COPY /files/common/etc/sysctl.d/net.ipv4.ip_forward.conf /etc/sysctl.d/net.ipv4.ip_forward.conf

COPY /files/centos7/etc/sysconfig/clock /etc/sysconfig/clock
COPY /files/centos7/etc/sysconfig/firstboot /etc/sysconfig/firstboot
COPY /files/centos7/etc/sysconfig/grub /etc/sysconfig/grub

COPY /files/common/etc/fstab /etc/fstab

COPY /files/aws/centos7/etc/cloud/cloud.cfg /etc/cloud/cloud.cfg

RUN rm -rf /var/lib/yum /var/log/yum.* /var/cache/yum
