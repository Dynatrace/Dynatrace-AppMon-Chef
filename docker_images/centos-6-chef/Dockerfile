FROM centos:6
RUN yum update -y
RUN yum install -y sudo openssh-server openssh-clients which curl
RUN yum install -y net-tools tar
RUN curl -L https://www.opscode.com/chef/install.sh | sudo bash
