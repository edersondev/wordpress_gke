from locust import HttpLocust, TaskSet, task

class MyTaskSet(TaskSet):

    @task
    def todasnoticias(self):
        self.client.get("/todas-noticias/")

    @task
    def governo(self):
        self.client.get("/governo/")

    @task
    def congresso(self):
        self.client.get("/congresso/")

    @task
    def economia(self):
        self.client.get("/economia/")

    @task
    def justica(self):
        self.client.get("/justica/")

    @task
    def login(self):
        self.client.get("/login/")

    @task
    def pesquisasopiniao(self):
        self.client.get("/pesquisas-de-opiniao/")

    @task
    def politicosbrasil(self):
        self.client.get("/politicos-do-brasil/")

    @task
    def analise(self):
        self.client.get("/analise/")

    @task
    def opiniao(self):
        self.client.get("/opiniao/")

    @task
    def conteudopatrocinado(self):
        self.client.get("/conteudo-patrocinado/")

    @task
    def internacional(self):
        self.client.get("/internacional/")

    @task
    def midia(self):
        self.client.get("/midia/")

    @task
    def tecnologia(self):
        self.client.get("/tecnologia/")

    @task
    def nieman(self):
        self.client.get("/nieman/")

    @task
    def infograficos(self):
        self.client.get("/infograficos/")

    @task
    def datapoder360(self):
        self.client.get("/datapoder360/")

    @task
    def paradisepapers(self):
        self.client.get("/paradise-papers/")

class MyLocust(HttpLocust):
    task_set = MyTaskSet
    min_wait = 5000
    max_wait = 15000