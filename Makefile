centos-7:
	docker build --pull . -f centos7.Dockerfile -t boot-centos7

ubuntu-16.04:
	docker build --pull  . -f ubuntu1604.Dockerfile -t boot-ubuntu1604

ubuntu-18.04:
	docker build --pull  . -f ubuntu1804.Dockerfile -t boot-ubuntu1804

img-builder:
	docker build --pull  . -f img-builder.Dockerfile -t img-builder

test:
	mkdir -p images
	docker rm boot-centos7 || true
	docker create --name boot-centos7 boot-centos7
	docker export -o images/centos7.tar boot-centos7
	gzip -f images/centos7.tar
	aws s3 cp images/centos7.tar.gz s3://test.boot-image.vmware.dev/centos7.tar.gz
	packer build packer.json
	#docker run -it -v $(PWD)/images:/images:Z -v $(PWD)/test.sh:/root/test.sh:Z --privileged img-builder /root/test.sh

packer:
	packer build packer.json

push:
	./push.sh
