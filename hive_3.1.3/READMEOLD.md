﻿## Docker - Integrando o Hive no cluster Hadoop

Será adicionado o Hive que é o **DW** no **HDFS** do Hadoop.
Com ele será possível interagir com os dados semi-estruturados e estruturados do seu cluster usando usando SQL e através dele é possível até montar um Data Warehouse sobre o Data Lake, ou seja, é possível ter um Data Warehouse sobre uma infraestrutura Big Data.

### Requisitos mínimos

Ter um cluster Hadoop ativo e funcional.

### Siga as etapas

1 - Baixe o Hive

- Hive 3.1.3

  https://dlcdn.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz

```bash
# Baixa o Hive
https://dlcdn.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
# Descompacta os arquivos
tar -xvf apache-hive-3.1.3-bin.tar.gz
# Mova para seguinte caminho renomeando a pasta para hive
mv apache-hive-3.1.3-bin hive/binarios/hive
```

### Os passos abaixo devem ser executados apenas na pasta hive

1 - Entre na pasta **hive** e crie o arquivo **Dockerfile**, sem extensão.

```bash
# Entrar na pasta hive
cd ~/projeto/hive/
# Cria o arquivo Dockerfile
touch Dockerfile
```

Esse arquivo conterá todos os recursos e configurações necessárias que nossa imagem Hadoop Namenode precisará.

2 - Adicione o seguinte conteúdo no arquivo **Dockerfile** e salve.

https://github.com/tiagotsc/docker-hadoop/blob/19c425b95d4f350ed8e61f1cadd64ee1934f2b35/hadoop_3.3.5/namenode/Dockerfile#L1-L146

3 - Na pasta onde tem o **Dockerfile**, crie o arquivo **script.sh** e adicione o conteúdo:

https://github.com/tiagotsc/docker-hadoop/blob/19c425b95d4f350ed8e61f1cadd64ee1934f2b35/hadoop_3.3.5/namenode/script.sh#L1-L5

Esse arquivo fará o ajuste de privilégios na nossa imagem.

4 - Na pasta **config-files**, que foi criada anteriormente, adicione os arquivos que estão presentes na pasta **namenode/config-files** desse repositório.

Esses arquivos possuem as configurações necessárias para o cluster Hadoop.

5 - Agora já podemos construir a imagem, estando na pasta **namenode** que contém o arquivo **Dockerfile**, execute:

```bash
# Constrói a imagem
docker build . -t hadoop_namenode:3.3.5
```

6 - Imagem criada, já é possível subir o container, execute:

```bash
docker run -dit --net hadoop_dl_net --hostname namenode1 --name namenode1 -p 9870:9870 -p 50030:50030 -p 8020:8020 -p 8088:8088 --privileged hadoop_namenode:3.3.5 /usr/sbin/init
```

7 - Inicie o Namenode, que pode ser de 2 formas:

Fique a vontade para escolher uma das duas opções.

- Entrando no container
  
  ```bash
  # Entre no container usando o usuário hduser
  docker exec -u hduser -it namenode1 /bin/bash

  # Dentro do container, formate o NameNode (somente na primeira execução)
  hdfs namenode -format

  # Dentro do container, inicie o serviço do Namenode
  hdfs --daemon start namenode

  # Dentro do container, inicie o serviço do Yarn Resource Manager
  yarn --daemon start resourcemanager
  ```

- Via Docker de fora do container

  ```bash
  # Formatar o NameNode (somente na primeira execução)
  docker exec -u hduser namenode1 hdfs namenode -format

  # Inicie o serviço do Namenode
  docker exec -u hduser namenode1 hdfs --daemon start namenode

  # Inicie o serviço do Yarn Resource Manager
  docker exec -u hduser namenode1 yarn --daemon start resourcemanager
  ```
8 - Agora é só acessar o painel gerencial do Hadoop e do Yarn

- Se o seu Docker estiver rodando direito no seu SO host, acesse:
  
  Para hadoop: 
  http://localhost:9870

  Para Yarn:
  http://localhost:8088/cluster

- Se seu Docker estiver rodando de forma isolada em alguma VM, lembrando que é necessário liberar a porta no firewall, acesse:

  Para hadoop:
  http://IP_SUA_VM:9870

  Para Yarn: http://IP_SUA_VM:8088/cluster

E você verá a seguinte tela:

Para Hadoop
![App Screenshot](../hadoop_3.3.5/images/img4.png)

Para Yarn
![App Screenshot](../hadoop_3.3.5/images/img6.png)

#### Enviando a imagem Hadoop Namenode para o DockerHub

````bash
# Logue no Docker
docker login

# Depois que tiver construído localmente sua imagem, crie a tag apontando para a imagem criada
docker image tag hadoop_namenode:3.3.5 SEU_USUARIO_DOCKER/hadoop_namenode:3.3.5

# Envie a imagem
docker image push SEU_USUARIO_DOCKER/hadoop_namenode:3.3.5
````

Nó Namenode e Yarn Resource Manager está tudo ok! Vamos agora para o nó Datanode.

### Os passos abaixo devem ser executados apenas na pasta **datanode** criada anteriormente

1 - Entre na pasta **datanode** e crie o arquivo **Dockerfile**, sem extensão.

```bash
# Entrar na pasta datanode
cd ~/projeto/datanode/
# Cria o arquivo Dockerfile
touch Dockerfile
```

Esse arquivo conterá todos os recursos e configurações necessárias que nossa imagem Hadoop Datanode precisará.

2 - Adicione o seguinte conteúdo no arquivo **Dockerfile** e salve.

https://github.com/tiagotsc/docker-hadoop/blob/19c425b95d4f350ed8e61f1cadd64ee1934f2b35/hadoop_3.3.5/datanode/Dockerfile#L1-L144

3 - Na pasta onde tem o **Dockerfile**, crie o arquivo **script.sh** e adicione o conteúdo:

https://github.com/tiagotsc/docker-hadoop/blob/19c425b95d4f350ed8e61f1cadd64ee1934f2b35/hadoop_3.3.5/datanode/script.sh#L1-L5

Esse arquivo fará o ajuste de privilégios na nossa imagem.

4 - Na pasta **config-files**, que foi criada anteriormente, adicione os arquivos que estão presentes na pasta **datanode/config-files** desse repositório.

Esses arquivos possuem as configurações necessárias para o cluster Hadoop.

5 - Agora já podemos construir a imagem, estando na pasta **datanode** que contém o arquivo **Dockerfile**, execute:

```bash
# Constrói a imagem
docker build . -t hadoop_datanode:3.3.5
```

6 - Imagem criada, já é possível subir o container **datanode1**, execute:

```bash
docker run -dit --net hadoop_dl_net --hostname datanode1 --name datanode1 -p 9864:9864 -p 8042:8042 --privileged hadoop_datanode:3.3.5 /usr/sbin/init
```

7 - Antes de iniciar o serviço do **Datanode** e **Yarn node manager**, é preciso copia a chave pública SSH do **Namenode** para o **Datanode**, que pode ser de 2 formas:

- Entrando no container **namenode1** e depois no container **datanode1**

  ````bash
  # Entre no container namenode1
  docker exec -u hduser -it namenode1 /bin/bash

  # Dentro do container namenode1, faça cópia da chave passando a senha (hduser) do usuário hduser no comando (Não recomendado)
  sshpass -p hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@datanode1

  # OU

  # Dentro do container namenode1, armazene a senha do usuário em um arquivo (arquivo.txt), faça a cópia da chave passando o caminho do arquivo(Recomendado)
  sshpass -f arquivo.txt ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@datanode1

  # Saia do container namenode1 e entre no do datanode1
  docker exec -u hduser -it datanode1 /bin/bash

  # Dentro do container datanode, já com a chave ssh adicionada, é só subir o serviço datanode
  hdfs --daemon start datanode

  # Dentro do container datanode, já com a chave ssh adicionada, é só subir o serviço Yarn node manager
  yarn --daemon start nodemanager

  ````

- Vi Docker de fora do container

  ````bash
  # Faça cópia da chave passando a senha (hduser) do usuário hduser para o container datanode (Não recomendado)
  docker exec -u hduser namenode1 sshpass -p hduser ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@datanode1

  # OU

  # Recupere e armazene a chave em uma variável
  CHAVE=$(docker exec -u hduser namenode1 cat /home/hduser/.ssh/authorized_keys)

  # Envie a chave armazenada na variável para o container
  docker exec -u hduser -i datanode1 bash -c "echo \"$CHAVE\" > /home/hduser/.ssh/authorized_keys"

  # Depois de colocar a chave no datanode, suba o serviço do datanode
  docker exec -u hduser datanode1 hdfs --daemon start datanode

  # Depois de colocar a chave no datanode, suba o serviço do Yarn node manager
  docker exec -u hduser datanode1 yarn --daemon start nodemanager
  ````

8 - Executando uma das 2 opções da etapa anterior, no navegador, você dando um refresh na tela e clicando no link **Datanodes**, você deve ver o datanode que acabou de adicionar rodando:

http://IP_SUA_VM:9870

![App Screenshot](images/img5.png)

E na tela do Yarn, você dando um refresh, você já deve ver um **Active Node**.

http://IP_SUA_VM:8088/cluster

![App Screenshot](images/img7.png)

Seu cluster Hadoop já está funcionando! Se quiser pode adicionar mais datanodes no seu cluster a qualquer momento.

#### Enviando a imagem Hadoop Datanode para o DockerHub

````bash
# Logue no Docker
docker login

# Depois que tiver construído localmente sua imagem, crie a tag apontando para a imagem criada
docker image tag hadoop_datanode:3.3.5 SEU_USUARIO_DOCKER/hadoop_datanode:3.3.5

# Envie a imagem
docker image push SEU_USUARIO_DOCKER/hadoop_datanode:3.3.5
````

#### Concluiu todo o passo a passo e desejava remover os recursos criados, execute os comandos abaixo:

````bash
docker container rm -f datanode1
docker image rm hadoop_datanode:3.3.5
docker container rm -f namenode1
docker image rm hadoop_namenode:3.3.5
docker image rm SEU_USUARIO_DOCKER/hadoop_namenode:3.3.5
docker image rm SEU_USUARIO_DOCKER/hadoop_datanode:3.3.5
docker network rm hadoop_dl_net
````

### Alguns comandos úteis

```bash
##### VAGRANT - é preciso estar na pasta que contém o Vagrantfile #####

# Liga VM, ou cria, caso ainda não exista
vagrant up

# Desliga a VM
vagrant halt

# Reiniciar a VM
vagrant reload

# Destrói a VM, mas pergunta antes
vagrant destroy

# Destrói a VM sem perguntar
vagrant destroy -f

##### HADOOP NAMENODE - Pode ser executado: #####
# Dentro do container (docker exec -u hduser -it namenode1 /bin/bash)
# OU 
# via Docker (docker exec -u hduser namenode1 COMANDO_AQUI)

# Formata o Namenode
hdfs namenode -format

# Inicia o Namenode
hdfs --daemon start namenode

# Para o Namenode
hdfs --daemon stop namenode

# Inicia todo o cluster Hadoop, Namenode + Datanodes associados
$HADOOP_HOME/sbin/start-dfs.sh

# Parar todo o cluster Hadoop, Namenode + Datanodes associados
$HADOOP_HOME/sbin/stop-dfs.sh

# Iniciar Yarn Resource Manager
yarn --daemon start resourcemanager

# Parar Yarn Resource Manager
yarn --daemon stop resourcemanager

# Inicia todo o cluster Yarn, Resource Manager + Node Manager
$HADOOP_HOME/sbin/start-yarn.sh

# Parar todo o cluster Yarn, Resource Manager + Node Manager
$HADOOP_HOME/sbin/stop-yarn.sh

# Listar jobs Yarn
yarn application -list

# Matar job Yarn
yarn application -kill ID_APLICACAO

# Ver log de job Yarn
yarn logs -applicationId ID_APLICACAO

# Listar os Node Manager Yarn
yarn node -list

##### HADOOP DATANODE - Pode ser executado: #####
# Dentro do container (docker exec -u hduser -it datanode1 /bin/bash)
# OU 
# via Docker (docker exec -u hduser datanode1 COMANDO)

# Inicia o Datanode
hdfs --daemon start datanode

# Para o Datanode
hdfs --daemon stop datanode

# Inicia o Yarn Node Manager 
yarn --daemon start nodemanager

# Para o Yarn Node Manager 
yarn --daemon stop nodemanager

##### DOCKER #####

# Listar redes
docker network ls

# Listar containers parados e em execução
docker container ls -a

# Listar imagens
docker image ls

# Se quiser parar os containers criados
docker container stop namenode1 datanode1

# Se quiser iniciar os containers que já tinham sido criados em algum momento, caso estejam parados
docker container start namenode1 datanode1

# Se quiser remover os containers
docker container rm -f namenode1 datanode1

# Se quiser remover as imagens criada
docker image rm hadoop_namenode:3.3.5 hadoop_datanode:3.3.5

# Criar container a partir da imagem remota, caso tenha enviado para o DockerHub
# Namenode
docker run -dit --net hadoop_dl_net --hostname namenode1 --name namenode1 -p 9870:9870 -p 50030:50030 -p 8020:8020 --privileged SEU_USUARIO_DOCKER/hadoop_namenode:3.3.5 /usr/sbin/init
# Datanode
docker run -dit --net hadoop_dl_net --hostname datanode1 --name datanode1 --privileged tiagotsc/hadoop_datanode:3.3.5 /usr/sbin/init

# Puxar só a imagem remota, caso tenha enviado para o DockerHub
# Namenode
docker pull SEU_USUARIO_DOCKER/hadoop_namenode:3.3.5
# Datanode
docker pull SEU_USUARIO_DOCKER/hadoop_datanode:3.3.5

# Remove localmente imagem obtida do DockerHub
# Namenode
docker image rm SEU_USUARIO_DOCKER/hadoop_namenode:3.3.5
# Datanode
docker image rm SEU_USUARIO_DOCKER/hadoop_datanode:3.3.5

# Ficou sem espaço no seu ambiente Docker
# Cuidado! esse comando apaga vários recursos criados pelo Docker, só é recomendado em ambientes puramente de testes
docker system prune --all --force
```

Todo o tutorial aplicado aqui, já se encontra pronto para uso nesse repositório, se você tiver em seu SO o **Vagrant** e **VirtualBox**, basta clonar, subir o ambiente, baixar os binários e seguir os passos de construção das imagens e consequentemente containers.

O passo a passo foi desenvolvido encima do **Vagrant 2.3.3** e **VirtualBox 7.0.6**.

#### Documentação oficial do Vagrant

https://developer.hashicorp.com/vagrant/docs

#### Documentação oficial Docker
https://docs.docker.com/

#### Documentação oficial Hadoop 3.3.5
https://hadoop.apache.org/docs/r3.3.5/

## 🔗 Links
[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/tiago-s-costa)
