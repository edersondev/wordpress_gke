# Teste distribuido usando Google Cloud Kubernetes

Para criar o cluster do Locust execute o seguinte comando:

`sh create_cluster.sh <IP_DOMINIO>`

O paramêtro pode ser um número IP ou o nome de um domínio. Aguarde a criação do cluster e ao terminar acesse o menu Serviços e clique no IP na porta 8089.

Depois que terminou os testes você pode apagar o cluster com o seguinte comando:

`sh delete_cluster.sh`