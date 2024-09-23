 
**PRIMEIROS PASSOS:** 

*Instalação Terraform:*
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli 

*Instalação AWS CLI:*
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

*Configuração CLI para subir os arquivos Terraform:* 

aws configure
AWS Access Key ID [None]: <sua-access-key-id>
AWS Secret Access Key [None]: <sua-secret-access-key>
Default region name [None]: us-east-1
Default output format [None]: json

*Configurar acesso ao cluster:* 
aws eks --region us-east-1 update-kubeconfig --name descomplica_k8s


**1. Backend em Kubernetes**

   Para iniciar attravés de um módulo uma vpc especifica para o projeto é criada para que o projeto tenha configuração especificas e também subnets isso se encontra no arquivo vpc.tf. Para ter mais visibilidade e entendimento da cada item criado o cluster foi criado também através de um módulo no arquivo eks.tf. E dentro desse arquivo também está subindo os itens relacionados ao cluster:
    -Configuração para acesso ao cluster
    -Namespace 
    -Cronjob

**2. Frontend com S3 e CloudFront** 
 
   Para expor o forntend um arquivo especifico para essa parte foi criada com nome fronten.tf. Nesse arquivo temos a criação de um bucket com as configurações de política para acesso e também os CloudFront relacionando o acesso via bucket.  

**3. Bancos de Dados Postgres RDS**
   Para criação do banco um arquivo separado também foi configurado com os grupos de segurança para o banco, subnets e todas as configurações necessárias para garantir maior segurança dos dados.  

**4. Observabilidade**

   Para monitoração há um arquivo chamado prometheus.tf onde o helm desse serviço é configurado para que possa ser puxadas as metricas e assim visualizadas via Grafana. Para visualização após a subida da estrutura é necessário expor o serviço criado acessando pelo link local :
      - kubectl get svc -A
      - kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
      - http://localhost:3000 
  
**5. CI/CD**
    A constraução da pipeline foi realizada para subir via GitHub Actions, uma pasta .github está criada na pasta do projeto contendo o arquivo yaml com os steps de teste, build e deploy.  

**PONTOS DE MELHORIA:**
 - Criar arquivo de variável
 - Criar bucket S3 para armazenar os estados do terraform (terraform.tfstate)
 - Melhorar pipeline
 - Subir itens de monitoração junto com todos os outros recursos de infraesturura

**REFERÊNCIAS UTILIZADAS:**
https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
https://dev.to/chinmay13/aws-networking-with-terraform-deploying-a-cloudfront-distribution-for-s3-static-website-2jbf
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cron_job
https://medium.com/itautech/hands-on-automatiza%C3%A7%C3%A3o-de-pipelines-de-entrega-com-github-actions-1e6a0864f6ce
https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/namespace.html 