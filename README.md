# Italian Blockchain Services Infrastructure (IBSI)


### Contenuto

1. [Descrizione](https://github.com/innovazione-posteitaliane/ibsi/#descrizione)
2. [Prerequisiti](https://github.com/innovazione-posteitaliane/ibsi/#prerequisiti)
3. [Bootstrap](https://github.com/innovazione-posteitaliane/ibsi/#bootstrap)
4. [Generazione materiale crittografico](https://github.com/innovazione-posteitaliane/ibsi/wiki/Content/_edit#generazione-materiale-crittografico)
5. [Bootnode](https://github.com/innovazione-posteitaliane/ibsi/#sostituzione-della-lista-dei-bootnode-nel-file-template-configtoml)
6. [Impostazione della chiave](https://github.com/innovazione-posteitaliane/ibsi/#impostazioni-delle-chiavi)
7. [Generazione del file di genesi]( https://github.com/innovazione-posteitaliane/ibsi/#generazione-del-file-di-genesis)
8. [Compilazione dello smartcontract](https://github.com/innovazione-posteitaliane/ibsi/#compilazione-dello-smart-contract)
9. [Start blockchain permissionless](https://github.com/innovazione-posteitaliane/ibsi/#start-della-blockchain-in-modalit%C3%A0-permissionless)
10. [Install smart contract](https://github.com/innovazione-posteitaliane/ibsi/#install-smart-contract)
11. [Start blockchain permissioning](https://github.com/innovazione-posteitaliane/ibsi/#start-della-blockchain-in-modalit%C3%A0-permissioning)
12. [Start dapp]( https://github.com/innovazione-posteitaliane/ibsi/#start-dapp)
13. [Aggiunta di un ulteriore nodo]( https://github.com/innovazione-posteitaliane/ibsi/#aggiunta-di-un-ulteriore-nodo)






### Descrizione

Lo scopo del presente progetto è quello di fornire un pacchetto d’istallazione di una blockchain besu in modalità permissioning per mezzo di un tool di deploy ansible.
 
La guida di riferimento utilizzata e’ disponibile al seguente link [https://besu.hyperledger.org/en/stable/](https://besu.hyperledger.org/en/stable/)

### Prerequisiti

* docker
* docker-compose
* python3

sono inoltre necessari i seguenti pacchetti python:

* docker 5.0.0
* docker-compose 1.29.2
* docker-pycreds 0.4.0
* dockerpty 0.4.1

### Bootstrap

Di seguito vengono descritte le operazioni necessarie alla creazione e lo start della blockchain. La rete sara’ configurata con algoritmo di consenso IBFT2 e  modalità onchain permissioning che consentira’ a tutti i nodi di leggere le whitelist di nodi autorizzati all’accesso e di utenze amministrative da un'unica fonte, la blockchain.
Il boostrap dell'infrastruttura e' stato predisposto per startare una blockchain con 4 nodi validatori.



Nella directory ansible-bootstrap, contenente il file Dockerfile lanciamo il comando per la creazione dell’immagine ansible-besu

`docker build --no-cache -t ansible-besu .`

### Generazione materiale crittografico

L’identificazione delle varie  entità partecipanti  alla  blockchain avviene tramite una serie di operazioni crittografiche basate su chiavi asimmetriche e algoritmi di hashing. Per ogni nodo dovranno essere generate le chiavi asimmetriche, con le quali ottenere l’enode che consentira’ il dialogo con gli altri nodi della blockchain e il  nodeAddress, utile per la promozione al ruolo di validatore. 

Configurare i parametri `p2p_host` e `p2p_port` nei file ansible-bootstrap/ansible-config/vars/node*.yml.


| parametro | descrizione |
| :---: | :---: |
| p2p_host | ip della macchina  | 
| p2p_port | porta http/udp per il disvovery del nodo  | 
| besu_version | versione besu utilizzata  | 
| container_name | nome del container docker | 
| rpc_port | porta rpc per l'utilizzo delle besu api | 
| ws_port | porta http per l'utilizzo delle web socket  | 
| metrics_port | porta per la condivisione delle metriche del nodo  | 
| alethio_server_url | ip:porta del server alethio | 
| alethio_account_email | account di registrazione al server alethio | 
| alethio_client_node_name | nome di registrazione al server alethio  | 
| node_key | chiave privata del nodo  | 
| permissions_nodes_contract_enabled | parametro di gestione del permissioning  | 
| permissions_accounts_contract_enabled | parametro di gestione del permissioning  | 


ed eseguire il comando seguente



     docker run --rm --name ansible-besu-deployer -v $PWD:/var/besu/scripts ansible-besu ansible-playbook -v ansible-config/bootstrap.yml -i ansible-config/inventory.yml --tags="loadvar,downloadbesu,unzipbesu,crypto"

L'esecuzione del comando precedente crea tutte le informazioni necessarie per la caratterizzazione delle blockchain all'interno delle cartella
 ansible-bootstrap/deploy/cryptofiles
 



### sostituzione della lista dei bootnode nel file template config.toml

Con gli enode dei nodi generati al passo precedente si puo' procedere alla valorizzazione dei bootnode all'interno del file config.toml 


    docker run --rm --name ansible-besu-deployer -v $PWD:/var/besu/scripts ansible-besu ansible-playbook -v ansible-config/bootstrap.yml -i ansible-config/inventory.yml --tags="bootnodes" --limit=node1
    
    
### impostazioni delle chiavi

Eseguire la seguente istruzione per i 4 nodi e impostare i relativi valori nella property `node_key` di ansible-bootstrap/ansible-config/vars/node*.yml

    KEY=$(cat deploy/cryptofiles/node*/key)
    echo $KEY




### generazione del file di genesis


    docker run --rm --name ansible-besu-deployer -v $PWD:/var/besu/scripts ansible-besu ansible-playbook -v ansible-config/genesisfile.yml --tags="generate"


### start della blockchain in modalità permissionless

dopo aver configurato opportunamente gli indirizzi dei nodi `node1`,`node2`,`node3` e `node4`  

    docker run --rm --name ansible-besu-deployer -v $PWD:/var/besu/scripts --add-host "node1:127.0.0.1" --add-host "node2:127.0.0.1" --add-host "node3:127.0.0.1" --add-host "node4:127.0.0.1"  ansible-besu ansible-playbook -v ansible-config/bootstrap.yml -i ansible-config/inventory.yml

### compilazione dello smart contract

Utilizzando lo smart contract [https://github.com/ConsenSys/permissioning-smart-contracts](https://github.com/ConsenSys/permissioning-smart-contracts) abbiamo apportato alcune modifiche cambiando la logica del permissioning. 

![https://i.postimg.cc/WzHFBDK4/transazioni.png](https://i.postimg.cc/WzHFBDK4/transazioni.png)

sarà quindi necessario ricompilarlo attraverso la seguente istruzione:


    docker run --rm --name ansible-besu-deployer -v $PWD:/var/besu/scripts ansible-besu ansible-playbook -v ansible-config/smart-contract.yml --tags="compile"
    
### install smart contract
    docker run --rm --name ansible-besu-deployer -v $PWD:/var/besu/scripts ansible-besu ansible-playbook -v ansible-config/smart-contract.yml --tags="install"

### start della blockchain in modalità permissioning

dopo aver configurato opportunamente l'indirizzo del nodo `node1`

    docker run --rm --name ansible-besu-deployer -v $PWD:/var/besu/scripts --add-host "node1:127.0.0.1" ansible-besu ansible-playbook -v ansible-config/bootstrap.yml -i ansible-config/inventory.yml --tags="loadvar,config,start" --limit="node1" -e '{"permissions_nodes_contract_enabled":"true","permissions_accounts_contract_enabled":"true"}

### start dapp
dopo aver configurato opportunamente l'indirizzo del nodo `node1`

    docker run --rm --name ansible-besu-deployer -v $PWD:/var/besu/scripts --add-host "node1:127.0.0.1" ansible-besu ansible-playbook -v ansible-config/playbook-dapp.yml -i ansible-config/inventory-dapp.yml

### aggiunta di un ulteriore nodo
I passi precedenti descrivono le operazioni necessarie allo startup della blockchain con quattro nodi validatori, di seguito descriviamo la procedura per l'aggiunta di ulteriori nodi.

la directory di riferimento del repository e' : ansible-add-node

I passi di generazione e configurazione sono uguali a quelli eseguiti precedentemente.

Generato il materiale crittografico bignognerà censirlo in blockchain. Questa operazione viene effettuale manualmente attraverso la dapp come illustrato nell'immagine sotto.


![https://i.postimg.cc/52BFSZwS/dapp1.png](https://i.postimg.cc/52BFSZwS/dapp1.png)


Registrato l'enode in blockchain l'ultima operazione da fare e' quella di startare il nodo, della directory ansible-addnode dopo aver impostato le variabili HOST_NAME e HOST_IP 

eseguire 

    HOST_NAME=node
    HOST_IP=111.111.222.222
    docker run --rm --name ansible-besu-deployer -v $PWD:/var/besu/scripts --add-host $HOST_NAME":"$HOST_IP ansible-besu ansible-playbook -v ansible-config/other/playbook.yml -i ansible-config/other/inventory.yml







 
