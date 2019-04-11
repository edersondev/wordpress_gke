# Instruções de configuração WordPress no Google Cloud Kubernetes Engine

#### Antes de começar:

1. Visite a página [Kubernetes Engine](https://console.cloud.google.com/projectselector/kubernetes?_ga=2.10000118.-233317994.1545753588&_gac=1.262810110.1553747665.CjwKCAjwm-fkBRBBEiwA966fZFdwwzgOtBs9nOo2XXZJqf_mUXwM6lUesyORfZKYWi3ItzoH1MvT7xoCry4QAvD_BwE "Kubernetes Engine") no console da plataforma Google Cloud.
2. Crie ou selecione um projeto.
3. Aguarde a API e os serviços relacionados estarem ativados. Isso pode levar vários minutos.
4. Verifique se o faturamento foi ativado para o projeto.
[Saiba como ativar o faturamento](https://cloud.google.com/billing/docs/how-to/modify-project "Saiba como ativar o faturamento")
5. Ter acesso ao Cloud shell
6. Configure a região padrão:

`gcloud config set compute/zone southamerica-east1-a`

### Passo 1: Criar um Clusters

O primeiro passo é criar um cluster GKE para hospedar seus contêineres do site. Depois de criar o cluster na plataforma, execute o seguinte comando no google shell:

`gcloud container clusters get-credentials [NAME_CLUSTER]`

### Passo 2: Criar volumes permanentes e reivindicações de volumes permanentes

Para criar o armazenamento necessário para o site, o primeiro passo é criar as reivindicações de volumes permanentes.

Você usará o arquivo [wordpress-volumeclaim.yaml](https://github.com/edersondev/wordpress_gke/raw/master/wordpress-volumeclaim.yaml "wordpress-volumeclaim.yaml") para criar a reivindicação de volumes permanentes necessários para as implementações.

Baixe o arquivo yaml para dentro do Cloud Shell, se preferir crie uma pasta para guardar o arquivo, use o seguinte comando para baixar:
`wget https://github.com/edersondev/wordpress_gke/raw/master/wordpress-volumeclaim.yaml`

Execute o comando para criar o volume:
`kubectl apply -f wordpress-volumeclaim.yaml`

Execute o seguinte comando para verificar se as reivindicações estão vinculadas.
`kubectl get pvc`

### Passo 3: Criação Instância Cloud SQL

1. Acesse a página "Instâncias" do Cloud SQL no Console do Google Cloud Platform. 
[ACESSAR A PÁGINA INSTÂNCIAS DO CLOUD SQL](https://console.cloud.google.com/sql/instances "ACESSAR A PÁGINA INSTÂNCIAS DO CLOUD SQL")
2. Clique em Criar instância.
3. Selecione MySQL e clique em Avançar.
4. Clique em Escolher segunda geração.
5. Digite um nome.
6. Não inclua informações confidenciais ou de identificação pessoal no nome da sua instância. Elas são visíveis externamente.
7. Não é necessário incluir o código do projeto no nome da instância. Isso é feito automaticamente quando apropriado, como nos arquivos de registros, por exemplo.
8. Digite a senha do usuário root.
9. Configure a região para a instância.
10. Coloque a instância na mesma região que os recursos que a acessam. Na maioria dos casos, você não precisa especificar uma zona.
11. Crie o banco de dados da sua aplicação

### Passo 4: Como conectar a partir do GKE

#### IntroduçãoIntrodução

Para acessar uma instância do Cloud SQL a partir de um aplicativo em execução no Kubernetes Engine, use a imagem Docker do Cloud SQL Proxy. O Cloud SQL Proxy é adicionado ao seu pod usando o padrão de contêiner "arquivo secundário". Dessa forma, o contêiner de proxy está no mesmo conjunto que seu aplicativo, permitindo que o aplicativo se conecte ao proxy usando o localhost e aumentando a segurança e o desempenho.

#### 4.1: Criar uma conta de serviço

Para usar o proxy, é necessário ter uma conta de serviço com os devidos privilégios para a instância do Cloud SQL.
1. Acesse a página Contas de serviço do console do Google Cloud Platform.
[Acessar página Contas de serviço](https://console.cloud.google.com/iam-admin/serviceaccounts/?_ga=2.9566326.-233317994.1545753588&_gac=1.196169566.1554077875.CjwKCAjwm-fkBRBBEiwA966fZFdwwzgOtBs9nOo2XXZJqf_mUXwM6lUesyORfZKYWi3ItzoH1MvT7xoCry4QAvD_BwE "Acessar página Contas de serviço")
2. Se necessário, selecione o projeto que contém a instância do Cloud SQL.
3. Clique em Criar conta de serviço.
4. Na caixa de diálogo "Criar conta de serviço", forneça um nome descritivo para a conta.
5. Em Papel, selecione um dos seguintes papéis:
 - Cloud SQL > Cliente do Cloud SQL
 - Cloud SQL > Editor do Cloud SQL
 - Cloud SQL > Administrador do Cloud SQL
6. Altere o código da conta de serviço com um valor exclusivo que você reconhecerá para que possa facilmente encontrar essa conta de serviço mais tarde, se necessário.
7. Clique em Fornecer uma nova chave privada.
8. O tipo de chave padrão é JSON, que é o valor correto a ser usado.
9. Clique em Criar.
10. O arquivo da chave privada é transferido para sua máquina. Você pode movê-lo para outro local. Mantenha-o seguro.

Você fornecerá a localização desse arquivo de chave mais adiante, quando criar as chaves secretas, como PROXY_KEY_FILE_PATH.

#### 4.2: Criar o usuário do banco de dados

Se necessário, crie um usuário do MySQL que seu aplicativo usará para acessar seu banco de dados:

`gcloud sql users create [DBUSER] --host=% --instance=[INSTANCE_NAME] --password=[PASSWORD]`

### 4.3: Solicitar o nome da conexão da instância

O nome da conexão da instância identifica a instância do Cloud SQL no Google Cloud Platform. Você pode encontrá-lo no console do Google Cloud Platform ou usando a ferramenta de linha de comando gcloud:

`gcloud sql instances describe [INSTANCE_NAME]`

Guarde a informação do parâmetro connectionName.

Você fornecerá esse valor posteriormente como INSTANCE_CONNECTION_NAME.

### 4.4: Criar as chaves secretas

Você precisa de duas chaves secretas para permitir que seu aplicativo do GKE acesse os dados em sua instância do Cloud SQL:
- a chave secreta cloudsql-instance-credentials que contém a conta de serviço
- a chave secreta cloudsql-db-credentials que fornece a conta de usuário e a senha do proxy

Para criar essas chaves secretas:

1. Crie a chave secreta cloudsql-instance-credentials usando o arquivo de chave que você baixou anteriormente:

`kubectl create secret generic cloudsql-instance-credentials --from-file=credentials.json=[PROXY_KEY_FILE_PATH]`

2. Crie a chave secreta cloudsql-db-credentials usando o nome e a senha do usuário do banco de dados que você criou anteriormente:

`kubectl create secret generic cloudsql-db-credentials --from-literal=username=[DBUSER] --from-literal=password=[PASSWORD]`

### 4.5: Deploy WordPress

O próximo passo é fazer o deploy do container Wordpress no cluster. O arquivo de reivindicação para o deploy de uma instância Wordpress.
[wordpress.yaml](https://github.com/edersondev/wordpress_gke/raw/master/wordpress.yaml "wordpress.yaml")

Do arquivo yaml alterar somente as strings “<DB_NAME>” com o nome do banco criado na instância e  "<INSTANCE_CONNECTION_NAME>" pelo nome solicitado no item 4.3.

Para fazer o deploy rode o comando abaixo:

`kubectl create -f wordpress.yaml`

Para atualizações no arquivo execute o seguinte comando:

`kubectl apply -f wordpress.yaml`

Verifique se o Pod está em execução. Pode levar alguns minutos para que o Pod faça a transição para o status de execução, já que anexar o disco permanente ao nó de cálculo leva um tempo:

`kubectl get pod -l app=wordpress`

### 4.6: Expor o serviço

Na etapa anterior, você implantou um contêiner do WordPress que não está acessível de fora do cluster, pois não tem um endereço IP externo.

Para expor seu aplicativo WordPress ao tráfego da Internet usando um balanceador de carga (sujeito a cobrança), você precisa de um Serviço com o tipo: LoadBalancer.

O arquivo [wordpress-service.yaml](https://github.com/edersondev/wordpress_gke/raw/master/wordpress-service.yaml "wordpress-service.yaml") contém o reivindicação deste Serviço.

Para fazer o deploy do serviço rode o comando abaixo:

`kubectl create -f wordpress-service.yaml`

A implantação(deploy) dessa reivindicação criará um balanceador de carga, o que pode levar alguns minutos. Execute o seguinte comando para descobrir o endereço IP externo site:

`kubectl get svc -l app=wordpress`

Saída esperada:

    NAME        CLUSTER-IP      EXTERNAL-IP    PORT(S)        AGE
    wordpress   10.51.243.233   203.0.113.3    80:32418/TCP   1m

Na saída acima, a coluna EXTERNAL-IP mostrará o endereço IP público criado para o site.

### Referências
- [Using Persistent Disks with WordPress and MySQL](https://cloud.google.com/kubernetes-engine/docs/tutorials/persistent-disk#set-defaults-for-the-gcloud-command-line-tool "Using Persistent Disks with WordPress and MySQL")
- [kubernetes-engine-samples](https://github.com/GoogleCloudPlatform/kubernetes-engine-samples "kubernetes-engine-samples")
- [Como conectar a partir do GKE](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine "Como conectar a partir do GKE")
- [Como criar instâncias Cloud SQL](https://cloud.google.com/sql/docs/mysql/create-instance "Como criar instâncias Cloud SQL")
