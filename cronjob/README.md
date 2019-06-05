# Cronjobs no GKE

Primeiro faça a conexão com o cluster desejado:

`gcloud container clusters get-credentials [NAME_CLUSTER]`

Em seguida é só criar as cronjobs executando o seguinte comando:

`kubectl apply -f [ARQUIVO.YAML]`

Substitua o nome [ARQUIVO.YAML] pelo nome do arquivo desejado.

Referência:
- [CronJobs](https://cloud.google.com/kubernetes-engine/docs/how-to/cronjobs?hl=pt-br "CronJobs")