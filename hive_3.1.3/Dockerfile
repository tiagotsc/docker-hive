FROM centos:7
ENV container docker

# Remover alguns arquivos para ativar o systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

RUN yum clean all && \
    yum update -y && yum install -y \
    python3 \
    rsync \
    net-tools \
    vim \
    nano \
    sudo \
    sshpass \
    wget \
    make \
    unzip \
    tomcat \
    tomcat-webapps \
    tomcat-admin-webapps \
    yum install -y autoconf automake libtool \
    yum install -y gcc gcc-c++ cmake \
    yum install -y zlib-devel \
    yum install -y openssl-devel \
    yum install -y snappy snappy-devel \
    yum install -y bzip2 bzip2-devel \
    yum -y install openssh-server openssh-clients initscripts

#########  CENTOS 7 - INSTALAÇÃO MYSQL - INÍCIO ######### 

# Baixa pacotes de configuração do MySql
# Veja sempre no link abaixo a versão mais atual e substitua esse link no passo a passo
# https://dev.mysql.com/downloads/repo/yum/
# Baixe a versão do Red Hat Enterprise Linux 7 / Oracle Linux 7
RUN curl -sSLO https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm

# Opcional, verifique se o md5 corresponde ao presente lá no site download o MySql
# md5sum mysql80-community-release-el7-7.noarch.rpm

# Adicione o repositório MySql
RUN sudo rpm -Uvh mysql80-community-release-el7-7.noarch.rpm
# Instale o MySql
RUN sudo yum install mysql-server -y
# Inicie o serviço
#RUN sudo systemctl start mysqld
# Remove o arquivo rpm
RUN rm -f mysql80-community-release-el7-7.noarch.rpm

#########  CENTOS 7 - INSTALAÇÃO MYSQL - FIM ######### 

# Cria grupo hadoop
RUN groupadd hadoop
# Cria usuário para a instalação do Hadoop e define a senha
RUN useradd -m hduser && echo "hduser:hduser" | chpasswd
# Adiciona o usuário criado ao grupo padrão wheel do super usuário do CentOS
RUN usermod -aG wheel hduser
# Adiciona usuário ao grupo hadoop
RUN usermod -aG hadoop hduser
# Transforma o usuário criado em um super usuário
RUN echo "hduser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Apache TOMCAT - Adicionando usuário ADM para parte administrativa
ADD ./config-files/tomcat-users.xml /usr/share/tomcat/conf/
RUN sudo chown root:tomcat /usr/share/tomcat/conf/tomcat-users.xml && sudo chmod 644 /usr/share/tomcat/conf/tomcat-users.xml
# Ativar Apache TOMCAT: sudo systemctl start tomcat
# Acessar painel gerencial TOMCAT: http://IP_SUA_VM:8080/
# Logue no painel com o usuário e senha do arquivo tomcat-users.xml

# Muda o usuário
USER hduser

# Usuário de trabalho
ENV HDFS_NAMENODE_USER=hduser
ENV HDFS_DATANODE_USER=hduser
ENV HDFS_SECONDARYNAMENODE_USER=hduser
ENV YARN_RESOURCEMANAGER_USER=hduser
ENV YARN_NODEMANAGER_USER=hduser

######### JAVA JDK 1.8 (BINÁRIOS E VARIÁVEIS DE AMBIENTE) - INÍCIO #########

# Copia os binários do JDK
ADD ./binarios/jdk /home/hduser/jdk

# Variáveis de ambiente JDK
ENV JAVA_HOME=/home/hduser/jdk
ENV PATH=$PATH:$JAVA_HOME:$JAVA_HOME/bin

# Variáveis de ambiente
RUN echo "PATH=$PATH:$JAVA_HOME/bin" >> ~/.bash_profile

######### JAVA JDK 1.8 (BINÁRIOS E VARIÁVEIS DE AMBIENTE) - FIM #########

######### HADOOP 3.3.5 (BINÁRIOS E VARIÁVEIS DE AMBIENTE) - INÍCIO #########

# Copia os binários do Hadoop
ADD ./binarios/hadoop /home/hduser/hadoop

# Variáveis de ambiente do Hadoop
ENV HADOOP_HOME=/home/hduser/hadoop
ENV PATH=$PATH:$HADOOP_HOME
ENV PATH=$PATH:$HADOOP_HOME/bin
ENV PATH=$PATH:$HADOOP_HOME/sbin

ENV HADOOP_MAPRED_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_HOME=$HADOOP_HOME
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV YARN_HOME=$HADOOP_HOME
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

# Config libs
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
ENV HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"

# Variáveis de ambiente
RUN echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bash_profile
RUN echo "PATH=$PATH:$HADOOP_HOME/sbin" >> ~/.bash_profile

# Copia os arquivos de configuração
ADD ./config-files/core-site.xml $HADOOP_HOME/etc/hadoop/
ADD ./config-files/yarn-site.xml $HADOOP_HOME/etc/hadoop/
ADD ./config-files/mapred-site.xml $HADOOP_HOME/etc/hadoop/

######### HADOOP 3.3.5 (BINÁRIOS E VARIÁVEIS DE AMBIENTE) - FIM #########

######### HIVE 3.1.3 (BINÁRIOS E VARIÁVEIS DE AMBIENTE) - INÍCIO #########

# Copia os binários do HIVE
ADD ./binarios/hive /home/hduser/hive

# Variáveis de ambiente do HIVE
ENV HIVE_HOME=/home/hduser/hive
ENV PATH=$PATH:$HIVE_HOME
ENV PATH=$PATH:$HIVE_HOME/bin
ENV CLASSPATH=$CLASSPATH:$HADOOP_HOME/lib/*:.
ENV CLASSPATH=$CLASSPATH:$HIVE_HOME/lib/*:.

# Copia os arquivos de configuração
ADD ./config-files/hive-site.xml $HIVE_HOME/conf

# Baixa conector Java MySql
# Se o link mudar, verifique o novo e substitua nos passos abaixo
# Verifique no site https://dev.mysql.com/downloads/connector/j/
# Selecione plataforma independente e baixe
RUN sudo wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.0.33.zip
RUN sudo unzip mysql-connector-j-8.0.33.zip
RUN sudo cp mysql-connector-j-8.0.33/mysql-connector-j-8.0.33.jar /home/hduser/hive/lib/
RUN sudo rm -Rf mysql-connector-j-8.0.33*

######### HIVE 3.1.3 (BINÁRIOS E VARIÁVEIS DE AMBIENTE) - FIM #########

######### TEZ 0.10.2 (BINÁRIOS E VARIÁVEIS DE AMBIENTE) - INÍCIO #########

# Copia os binários do HIVE
ADD ./binarios/tez /home/hduser/tez

# Variáveis de ambiente do TEZ
ENV TEZ_HOME=/home/hduser/tez
ENV TEZ_CONF_DIR=$TEZ_HOME/conf
ENV TEZ_JARS=$TEZ_HOME/*:$TEZ_HOME/lib/*
ENV HADOOP_CLASSPATH=$TEZ_CONF_DIR:$TEZ_JARS/*:$TEZ_JARS/lib/*
ENV CLASSPATH=$CLASSPATH:$TEZ_CONF_DIR:$TEZ_JARS/*:$TEZ_JARS/lib/*

# Copia os arquivos de configuração
ADD ./config-files/tez-site.xml $TEZ_HOME/conf

# Removendo arquivos
RUN sudo rm -f $TEZ_HOME/lib/hadoop-hdfs-client*.jar
RUN sudo rm -f $TEZ_HOME/lib/hadoop-mapreduce-client-common*.jar
RUN sudo rm -f $TEZ_HOME/lib/hadoop-mapreduce-client-core*.jar
RUN sudo rm -f $TEZ_HOME/lib/hadoop-yarn-server-timeline-pluginstorage*.jar

#  Adicionando novos arquivos
RUN sudo cp $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-common*.jar $TEZ_HOME/lib/
RUN sudo cp $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-core*.jar $TEZ_HOME/lib/
RUN sudo cp $HADOOP_HOME/share/hadoop/hdfs/hadoop-hdfs-client-*.jar $TEZ_HOME/lib/
RUN sudo cp $HADOOP_HOME/share/hadoop/yarn/hadoop-yarn-server-timeline-pluginstorage*.jar $TEZ_HOME/lib/

######### TEZ 0.10.2 (BINÁRIOS E VARIÁVEIS DE AMBIENTE) - FIM #########

######### TEZ UI 0.10.2 (BINÁRIOS E VARIÁVEIS DE AMBIENTE) - INÍCIO #########
# Link pode mudar com o tempo, se mudar olhar no site abaixo
# https://tez.apache.org/releases/index.html
RUN sudo wget https://repository.apache.org/content/repositories/releases/org/apache/tez/tez-ui/0.10.2/tez-ui-0.10.2.war
RUN sudo mkdir tez-ui && sudo mv tez-ui-0.10.2.war tez-ui
RUN cd tez-ui && sudo /home/hduser/jdk/bin/jar -xvf tez-ui-0.10.2.war && sudo rm -f tez-ui-0.10.2.war
RUN sudo mv tez-ui /var/lib/tomcat/webapps/

# Adiciona arquivo virtual host para aplicação Tez UI
ADD ./config-files/configs.js /var/lib/tomcat/webapps/tez-ui/config/
RUN sudo chown tomcat:tomcat /var/lib/tomcat/webapps/tez-ui/ -R && sudo chown 644 /var/lib/tomcat/webapps/tez-ui/config/configs.js

######### TEZ UI 0.10.2 (BINÁRIOS E VARIÁVEIS DE AMBIENTE) - FIM #########

# Adiciona scripts
COPY script.sh /home/hduser
RUN sudo chmod +x /home/hduser/script.sh
# Executa script
RUN /bin/bash -c '/home/hduser/script.sh'

# Portas que poderão ser usadas
EXPOSE 10002 8080 9999 8188

# # Volta para usuário root, pois alguns processos são iniciados através dele
USER root
# setup new root password
RUN echo root:root | chpasswd

# Muda configuração do sistema
RUN echo '* soft nofile 102400' >> /etc/security/limits.conf
RUN echo '* hard nofile 409600' >> /etc/security/limits.conf
RUN echo 'session    required     /lib64/security/pam_limits.so' >> /etc/pam.d/login

# Instalação openssl version 1.1.1 (É utilizado pelo Yarn e MapReduce)
RUN wget https://www.openssl.org/source/openssl-1.1.1h.tar.gz 
RUN tar -zxf openssl-1.1.1h.tar.gz
RUN cd openssl-1.1.1h && ./config && make && make install
RUN ln -s /usr/local/lib64/libssl.so.1.1 /usr/lib64/libssl.so.1.1
RUN ln -s /usr/local/lib64/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
RUN rm -Rf openssl-1.1.1h
RUN rm -f openssl-1.1.1h.tar.gz
# Teste openssl 1.1.1 com comando: openssl version

CMD ["/usr/sbin/init"]

