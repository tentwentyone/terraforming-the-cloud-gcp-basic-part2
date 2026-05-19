# terraforming the cloud - part 2

![Terraforming the cloud architecture][tfc-arch]

## Temas abordados neste modulo

* Criação de [modulos de Terraform](https://www.terraform.io/docs/language/modules/syntax.html)
* Criação de [cluster GKE](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster)
* Criação de [zonas de DNS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone)
* Utilização de diferentes providers ([kubectl provider](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs))
* [Templates de ficheiros](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file)

**Tempo estimado**: Cerca de 2 horas

**Pré requsitos**: Antes de começares, é necessário verificares algumas coisas:

Certifica-te que tens a `google-cloud-shell` devidamente autorizada correndo este comando:

```bash
gcloud config set project tto-workshops-lab-848993 && gcloud config set accessibility/screen_reader false
```

De seguida, clica no botão **Start** para começares.

## 0. terraform `init`

Neste projeto temos que preparar um prefixo que identifique unicamente os recursos que vão ser criados, por forma a evitar colisões.

* No ficheiro <walkthrough-editor-select-line filePath="terraform.tfvars" startLine="2" endLine="2" startCharacterOffset="0" endCharacterOffset="200">terraform.tfvars</walkthrough-editor-select-line> é necessário definir um prefixo, no seguinte formato: `user_prefix = "<valor>"`

Inicializar:

```bash
terraform init
```

💡Para evitar que o terraform peça o nome do projeto a cada `plan`, podemos definir o nome do projeto por defeito:

* Abrir o ficheiro <walkthrough-editor-select-line filePath="terraform.tfvars" startLine="1" endLine="1" startCharacterOffset="0" endCharacterOffset="200">terraform.tfvars</walkthrough-editor-select-line>.
* Descomentar a linha `project_id` e adicionar o id do projeto que aparece a amarelo na linha de comandos.

💡Notem que a variavel `user_prefix` tem uma validação declarada no ficheiro <walkthrough-editor-select-line filePath="variables.tf" startLine="30" endLine="38" startCharacterOffset="0" endCharacterOffset="200">variables.tf</walkthrough-editor-select-line>. Caso estejam a ter um erro, é preciso garantir queo nome escolhido cumpre com as regras de validação.

> *[from docs:](https://developer.hashicorp.com/terraform/language/values/variables#custom-validation-rules) You can specify custom validation rules for a particular variable by adding a validation block within the corresponding variable block. The example below checks whether the AMI ID has the correct syntax.*

---

Planear:

```bash
terraform plan -out plan.tfplan
```

---

Aplicar:

```bash
terraform apply plan.tfplan
```

## 1. Criar VPC e Subnet

* No ficheiro <walkthrough-editor-open-file filePath="vpc.tf">vpc.tf</walkthrough-editor-open-file> encontram-se as definições da VPC e respetiva subnet a usar

👉 <walkthrough-editor-select-line filePath="vpc.tf" startLine="4" endLine="50" startCharacterOffset="0" endCharacterOffset="200">Descomentar as seguintes resources</walkthrough-editor-select-line>:

* <walkthrough-editor-select-line filePath="vpc.tf" startLine="4" endLine="9" startCharacterOffset="0" endCharacterOffset="200">`resource "google_compute_network" "default"`</walkthrough-editor-select-line>
* <walkthrough-editor-select-line filePath="vpc.tf" startLine="11" endLine="32" startCharacterOffset="0" endCharacterOffset="200">`resource "google_compute_subnetwork" "gke"`</walkthrough-editor-select-line>
* <walkthrough-editor-select-line filePath="vpc.tf" startLine="34" endLine="39" startCharacterOffset="0" endCharacterOffset="200">`resource "google_compute_router" "default"`</walkthrough-editor-select-line>
* <walkthrough-editor-select-line filePath="vpc.tf" startLine="41" endLine="48" startCharacterOffset="0" endCharacterOffset="200">`resource "google_compute_router_nat" "default"`</walkthrough-editor-select-line>

<sub>💡ProTip: `CTRL+K+U` é o atalho para descomentar em bloco</sub>

**Why**: Tanto o `router` como o `nat` são recursos necessários para permitir que o cluster GKE possa aceder à internet para fazer download das imagens dos containers que vamos usar.

Executar o `plan` & `apply`:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

---

Validar the a VPC foi criada:

```bash
gcloud compute networks list | grep $(terraform output -raw my_identifier)
```

Validar que a subnet foi criada:

```bash
gcloud compute networks subnets list | grep "$(terraform output -raw my_identifier)"
```

## 2. Modules & GKE

Neste capitulo iremos abordar a utilização de [terraform modules](https://www.terraform.io/docs/language/modules/syntax.html) para instanciar o GKE.

### 2.1 Introdução aos modulos

Exemplo demonstrativo da organização de modulos no slide 12 da apresentação.

> *[from docs:](https://www.terraform.io/docs/language/modules/syntax.html) A module is a container for multiple resources that are used together.*
>
> *Every Terraform configuration has at least one module, known as its root module, which consists of the resources defined in the .tf files in the main working directory.*
>
> *A module can call other modules, which lets you include the child module's resources into the configuration in a concise way. Modules can also be called multiple times, either within the same configuration or in separate configurations, allowing resource configurations to be packaged and re-used.*

### 2.2 GKE module

Agora que temos os pre-requisitos instalados, iremos entao proceder à primeira aplicação de um [terraform module](https://www.terraform.io/docs/language/modules/syntax.html) para aprovisionar um cluster GKE.

* No ficheiro <walkthrough-editor-select-line filePath="gke.tf" startLine="1" endLine="15" startCharacterOffset="0" endCharacterOffset="200">./gke.tf</walkthrough-editor-select-line> encontra-se a invocação do module
* Por cada module é preciso fazer `terraform init`

👉 No ficheiro <walkthrough-editor-select-line filePath="gke.tf" startLine="1" endLine="15" startCharacterOffset="0" endCharacterOffset="200">./gke.tf</walkthrough-editor-select-line>, descomentar as seguintes resources:

* `module "gke"`
* `output "gke_name"`
* `output "gke_location"`

Primeiro temos que executar `terraform init` para inicializar o modulo:

```bash
terraform init
```

Executar o `plan` & `apply`:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

<sub>⏰ Notem que a criação de um cluster GKE pode levar até **10 minutos**...</sub>

Podemos verificar que o nosso cluster foi corretamente criado através do comando:

```bash
gcloud container clusters list --project $(terraform output -raw project_id) | grep $(terraform output -raw my_identifier)
```

*Também é possivel verificar o estado do cluster pela GUI [aqui](https://console.cloud.google.com/kubernetes/list).*

### 2.3 Aceder ao cluster

O acesso a um GKE, tal como qualquer outro cluster de Kubernetes, é feito a partir da cli `kubectl`. Para podermos executar comandos `kubectl` precisamos primeiro de garantir que temos uma configuração válida para aceder ao nosso cluster.

Usar o comando `gcloud` para construir um `KUBECONFIG` válido para aceder ao cluster:

```bash
export KUBECONFIG=$(pwd)/kubeconfig.yaml && gcloud container clusters get-credentials $(terraform output -raw gke_name) --zone $(terraform output -raw gke_location) --project $(terraform output -raw project_id)
```

Verificar o acesso ao cluster:

```bash
kubectl get nodes
```

### 2.4. Vamos por workloads a correr

Nesta secção abordar a utilização de um provider ([kubectl provider](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs)) para instanciar (via terraform) todos os workloads que vão correr no nosso cluster.

Trata-se de um provider da comunidade que tal como o nome indica, facilita a utilização de terraform para orquestrar ficheiros `yaml`.

> *[from docs:](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs) This provider is the best way of managing Kubernetes resources in Terraform, by allowing you to use the thing Kubernetes loves best - yaml!*

👉 Para habilitar o modulo, temos que ir ao ficheiro <walkthrough-editor-open-file filePath="k8s.hipster.tf">`./k8s.hipster.tf`</walkthrough-editor-open-file> e descomentar o seguinte modulo:

* <walkthrough-editor-select-line filePath="k8s.hipster.tf" startLine="2" endLine="13" startCharacterOffset="0" endCharacterOffset="200">`module "hipster"`</walkthrough-editor-select-line>
* ⛔ **não** descomentar a linha <walkthrough-editor-select-line filePath="k8s.hipster.tf" startLine="7" endLine="7" startCharacterOffset="0" endCharacterOffset="200">`fqdn`</walkthrough-editor-select-line>; será habilitado mais a frente ⛔

💡Os microserviços utilizados nesta demo, encontram-se [neste registry](https://console.cloud.google.com/gcr/images/google-samples/global/microservices-demo) e o respetivo código [neste repositório de github](https://github.com/GoogleCloudPlatform/microservices-demo/tree/main).

Executar `terraform init` para inicializar o modulo:

```bash
terraform init
```

Executar o `plan` & `apply`:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

<sub>⏰ Após o `apply`, pode demorar uns minutos a acabar o comando pois o terraform espera que os pods estejam em `Running` state.</sub>

Podemos verificar que os pods foram corretamente instanciados:

```bash
kubectl get pods -n hipster-demo
```

Também podemos constatar que o cluster-autoscaler teve que aprovisionar mais *nodes* para acautelar o demand 😃🚀

```bash
kubectl get nodes
```

### 2.5. Testar a nossa aplicação

Para testar e validar a nossa aplicação antes de a colocar em "produção", podemos tirar partido da capacidade de fazer `port-forward`.

Para iniciar um `port-forward` no porto `8080`:

```bash
kubectl port-forward -n hipster-demo service/frontend 8080:80
```

* Após este passo, basta testar a aplicação no port-foward que foi estabelecido no seguinte url: <http://localhost:8080>
* Se estiverem a usar a Google CloudShell podem clicar em <walkthrough-web-preview-icon></walkthrough-web-preview-icon> `Preview on Port 8080` no canto superior direito

## 3. DNS & HTTPS

Conseguimos validar que os workloads estao a funcionar.

* O próximo passo será expor a partir dos ingresses e respectivos load-balancers do GKE
* Para isso precisamos de um DNS para HTTP/HTTPS
* Caso queiramos usar HTTPS vamos também precisar de um certificado SSL

### 3.1 Criar a zona de DNS

No ficheiro <walkthrough-editor-open-file filePath="dns.tf">`./dns.tf`</walkthrough-editor-open-file> encontra-se a definição do modulo.

👉 Para habilitar o modulo <walkthrough-editor-select-line filePath="dns.tf" startLine="1" endLine="10" startCharacterOffset="0" endCharacterOffset="200">`./dns.tf`</walkthrough-editor-select-line> precisamos de descomentar as seguintes resources:

* <walkthrough-editor-select-line filePath="dns.tf" startLine="1" endLine="6" startCharacterOffset="0" endCharacterOffset="200">`module "dns"`</walkthrough-editor-select-line>
* <walkthrough-editor-select-line filePath="dns.tf" startLine="8" endLine="10" startCharacterOffset="0" endCharacterOffset="200">`output "fqdn"`</walkthrough-editor-select-line>

Executar `terraform init` para inicializar o modulo:

```bash
terraform init
```

Executar o `plan` & `apply`:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

Podemos verificar que a nossa zona de DNS foi corretamente criada através do seguinte comando:

```bash
gcloud dns managed-zones list --project $(terraform output -raw project_id) | grep $(terraform output -raw my_identifier)
```

### 3.2 Habilitar o `external-dns`

O `external-dns` é a *cola* entre o Kubernetes e o DNS.

> *[from docs:](https://github.com/kubernetes-sigs/external-dns) ExternalDNS synchronizes exposed Kubernetes Services and Ingresses with DNS providers.*

No ficheiro  é necessário passar o fqdn devolvido pelo modulo de dns.

👉 Descomentar o modulo <walkthrough-editor-select-line filePath="k8s.external-dns.tf" startLine="1" endLine="11" startCharacterOffset="0" endCharacterOffset="200">`external_dns`</walkthrough-editor-select-line> no ficheiro <walkthrough-editor-open-file filePath="k8s.external-dns.tf">`./k8s.external-dns.tf`</walkthrough-editor-open-file>:

* <walkthrough-editor-select-line filePath="k8s.external-dns.tf" startLine="1" endLine="5" startCharacterOffset="0" endCharacterOffset="200">`module "external_dns"`</walkthrough-editor-select-line>
* <walkthrough-editor-select-line filePath="k8s.external-dns.tf" startLine="7" endLine="11" startCharacterOffset="0" endCharacterOffset="200">`output "fqdn"`</walkthrough-editor-select-line>

Na diretória `./modules/external-dns` encontra-se a implementação do modulo `external-dns` que permite atualizar os registos DNS automaticamente.

Executar o `init` pois estamos a introduzir um novo modulo:

```bash
terraform init
```

Executar o `plan` & `apply`:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

Podemos verificar a criação do `external-dns` pelo seguinte comando:

```bash
kubectl get pods -n external-dns
```

Podemos também investigar os logs emitidos pelo deployment:

```bash
kubectl logs -n external-dns -l app=external-dns --follow
```

### 3.3 Criar um ponto de entrada (ingress) para o site

> *[from docs:](https://kubernetes.io/docs/concepts/services-networking/ingress/) Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.*

A criação do `ingress` será o culminar das últimas operações que efectuamos (DNS + HTTPS).

* Só será possivel aceder ao nosso site via internet se o expormos a partir de um ingress;
* A criação do ingress irá despoletar a criação de um balanceador com um IP público bem como a geração de um certificado gerido pela Google;
* Após a atribuição do IP, o `external-dns` irá atualizar o DNS com o respetivo IP;
* Uma vez criado o registo no DNS, o GCE irá aprovisionar o certificado automaticamente;
* ⏰ Todo o processo pode levar até cerca de **10 minutos** a acontecer;

👉 No ficheiro <walkthrough-editor-select-line filePath="k8s.hipster.tf" startLine="7" endLine="8" startCharacterOffset="0" endCharacterOffset="200">`./k8s.hipster.tf`</walkthrough-editor-select-line> iremos descomentar a secção **3.3** onde iremos modificar o comportamento do modulo da seguinte forma:

1. Atribuir o `fqdn` dado pelo modulo de `dns`  á variável `fqdn`; o `fqdn` representa o domínio onde vai ser criado o host declarado pelo `ingress`.

   * <walkthrough-editor-select-line filePath="k8s.hipster.tf" startLine="7" endLine="7" startCharacterOffset="0" endCharacterOffset="200">`fqdn = module.dns.fqdn`</walkthrough-editor-select-line>

2. Ativar a criação dos manifestos de ingress através da variável boleana `ingress_enabled`.

   * <walkthrough-editor-select-line filePath="k8s.hipster.tf" startLine="8" endLine="8" startCharacterOffset="0" endCharacterOffset="200">`ingress_enabled = true`</walkthrough-editor-select-line>

Executar o `plan` & `apply`:

```bash
terraform plan -out plan.tfplan
```

```bash
terraform apply plan.tfplan
```

Podemos verificar a criação do `ingress` e a respetiva atribuição de IP a partir dos seguintes comandos:

```bash
kubectl get ingress -n hipster-demo
```

```bash
kubectl describe ingress -n hipster-demo hipster-ingress
```

Também podemos verificar a atuação do `external-dns` assim que o ingress ganhou um IP:

```bash
kubectl logs -f -n external-dns -l app=external-dns
```

Ou então podemos verificar os registos no Cloud DNS:

```bash
gcloud dns record-sets list --zone $(terraform output -raw my_identifier)-dns --project $(terraform output -raw project_id)
```

> 🚀 Infelizmente, devido ao tempo que a Google demora a gerar os certificados, o site só estará disponível quando o certificado for gerado e a *chain* estiver devidamente validada. Este processo leva cerca de **10 minutos** ⏰😡

Podemos verificar o estado do mesmo usando o seguinte comando:

```bash
kubectl describe managedcertificates -n hipster-demo hipster
```

## 4. wrap-up & destroy

Por fim, podemos destruir tudo de uma só vez.

⏰ Notem que devido à quantidade de recursos envolvidos, a operação de destroy pode demorar entre **10 a 20 minutos**.

```bash
terraform destroy
```

🔚🏁 Chegámos ao fim 🏁🔚

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

<!-- markdownlint-disable-file MD013 -->
<!-- markdownlint-disable-file MD033 -->

 [//]: # (*****************************)
 [//]: # (INSERT IMAGE REFERENCES BELOW)
 [//]: # (*****************************)

[tfc-arch]: https://github.com/tentwentyone/terraforming-the-cloud-gcp-basic-part2/raw/main/images/terraforming-the-cloud.png "Terraforming the cloud architecture"
