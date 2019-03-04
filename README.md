# Imagestamper

Experiments in building AMIs in Docker

## What this does

The following generate Docker images that are minimal, bootable root file
systems:

``` shell
make centos-7 # Tested
make ubuntu-16.04 # Not tested
make ubuntu-18.04 # Not tested
```

`make test` copies this to an S3 bucket right now (hard-coded), but could
push it into a Docker registry.

Finally `make packer` starts an EC2 instance, downloads and unpacks the CentOS 7
tar, and writes its contents to a newly formatted EBS volume, and installs
Grub - you will need to replace the subnet_id and region parameters as
appropriate.

### Discarded ideas

LinuxKit writes out an initrd and bootsector, and that's all it needs to boot.
Differs quite significantly from traditional distros that want
standard  partitions to install Grub in. This requires privileged access, so
some steps must be run as sudo.

In addition, in contrast to syslinux+initrd in linuxkit, we want a full disk
image. Even if the image is sparse, uploading to object storage ignores this.

It's therefore quicker to do the final cloud provider build on a host on that
cloud provider where it pulls down the docker image, formats a volume and
un-tars the image.

See [centos7.Dockerfile](centos7.Dockerfile), [test.sh](test.sh) and
[packer.json](packer.json) to understand the process.

Importing snapshots, such as done by LinuxKit, also has some odd properties
on [AWS](https://docs.aws.amazon.com/vm-import/latest/userguide/vmie_prereqs.html#limitations-image).

The virtual disk based systems, where these are hosted on LANs, won't need this,
and the image can be stamped out locally without virtualisation.vv

## Questions

### Layering

How to DRY this up for various OS, and also have some layer separation. Probably
want something like this:

* containerd layer
* docker layer
* kubelet/kubeadm layer
* Golden layer for CentOS 7/8, Ubuntu 16.04/18.04, Photon
* Per cloud-provider HWE layer for each Distro
* Additional customisations

Final image examples:

CentOS7-AWS-ContainerD-Kubernetes_1.13:

* Docker:
  * CentOS 7
  * CentOS 7 AWS HWE
  * Common containerd
  * Common kubelet
  * SELinux compat layer
* Image:
  * BIOS boot

CentOS7-Azure-Docker-Kubernetes_1.13:

* Docker:
  * CentOS 7
  * CentOS 7 Azure HWE
  * Common docker
  * Common kubelet
  * SELinux compat layer
* Image:
  * EFI boot

### Have a layer per package?

This is what LinuxKit does, but is a burden for us to do outside of each
distro's community.

### Other TODOs

* Build Kubernetes layers
* Stamp image names / tags / drop a manifest with Docker image IDs
* Make these not shell scripts
* Un-hardcode everything

### Windows (out-of-scope)

Windows support will be different, and Dockerised equivalents may not be
found for any of the following:

* Start with Windows Server 2019 WIM (this is a Windows equivalent of a tarball)
* Boot Windows PE with secondary volume
* Write out WIM to secondary volume
* Enable Windows Containers offline
* Copy required kubelet, containerd equivalents over to new FS
* Add customisations to OOBE XML manifest
* Apply Windows Updates offline
* Apply offline drivers for cloud providers
* Write out boot manager
