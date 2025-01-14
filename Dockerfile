FROM ubuntu:latest

LABEL name="remote-container-toolkit" \
      vendor="self" \
      version="0.2" \
      release="1" \
	  maintainer="Arif A" \
      summary="CLI Toolkit" \
      description="Ubuntu instance with IBM Cloud, OpenShift, Kubectl, Helm and other needed tools. For use with Visual Studio Code remote container."

USER root

ARG DEBIAN_FRONTEND=noninteractive
ARG gid=1001
ARG group=demo
ARG uid=1001
ARG user=demo

RUN apt-get update -y && \
	apt-get install -y --no-install-recommends sudo dnsutils wget vim gettext iputils-ping mlocate git curl openssl zip unzip jq openjdk-8-jdk && \
	updatedb && \
	apt-get clean all -y && \
	rm -rf /var/lib/apt/lists/* && \
#	curl -sL https://ibm.biz/idt-installer | bash && \
	curl -fsSL https://clis.cloud.ibm.com/install/linux | sh && \
	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
	chmod 700 get_helm.sh && \
	bash ./get_helm.sh && \
#	curl -sLo /tmp/oc.tar.gz https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/oc/4.6/linux/oc.tar.gz && \
	curl -sLo /tmp/oc.tar.gz https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/oc/latest/linux/oc.tar.gz && \
	tar xzvf /tmp/oc.tar.gz -C /usr/local/bin/ && \
	rm -rf /tmp/oc.tar.gz && \
	ibmcloud plugin install container-service -r 'IBM Cloud' && \
	groupadd -g ${gid} ${group} && useradd -u ${uid} -g ${group} -ms /bin/sh ${user} && \
	usermod -aG sudo ${user} && \
	chgrp -R 0 /home/demo && \
    chown -R 1001:0 /home/demo && \
    chmod -R g=u /home/demo && \
    sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^#includedir.*/## **Removed the include directive** ##"/g' && \
    echo "demo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /home/demo    
USER 1001

ENTRYPOINT ["/bin/bash", "-ce", "tail -f /dev/null"]
