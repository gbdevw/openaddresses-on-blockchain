# Lab: Openaddresses on blockchain

For this lab, you will setup a local ethereum node and blockchain using Ganache.
You will then start a local notebook server and use a notebook which will guide you
through the lab.

## Setup lab

### Start blockchain node and notebook server

```bash
docker network create openaddresses-net
docker run --network openaddresses-net --name ethnode --detach --publish 8545:8545 trufflesuite/ganache-cli:latest --accounts 10 
docker run --network openaddresses-net -itd -p 8080:8888 -v ~/.aws:/root/.aws:ro -e DISABLE_SSL=true --name notebook amazon/aws-glue-libs:glue_libs_3.0.0_image_01 /home/glue_user/jupyter/jupyter_start.sh
```

### Import data

```bash
docker exec -ti notebook mkdir /home/glue_user/workspace/data
docker cp data/openaddress-bebru.zip notebook:/home/glue_user/workspace/data/openaddress-bebru.zip
docker exec -ti notebook unzip data/openaddress-bebru.zip
```

### Import smart contract code & lab notebook:

```bash
docker cp addresses.sol notebook:/home/glue_user/workspace/jupyter_workspace/addresses.sol
docker cp openaddresses.ipynb notebook:/home/glue_user/workspace/jupyter_workspace/openaddresses.ipynb
```

### Install Python dependencies

```bash
docker exec -ti notebook pip install web3 requests py-solc-x
docker exec -ti notebook pip install -U "web3[tester]"
```

## Time to play

Connect to the notebook server using your Web browser. The URL should look like this (except host, depending on your configuration) :
http://localhost:8080/lab

You will see on the left that there is already a notebook ready to be used (openaddress.ipynb). Open the notebook to continue the lab.

## Clean up

```bash
docker stop ethnode
docker rm ethnode
docker stop notebook
docker rm notebook
docker network rm openaddresses-net
```