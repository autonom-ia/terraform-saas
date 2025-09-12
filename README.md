# Autonom.ia RDS Terraform Configuration

Este projeto contém a configuração Terraform para criar um banco de dados PostgreSQL RDS na AWS que pode ser acessado pela internet.

## Pré-requisitos

- Terraform 1.0.0 ou superior
- AWS CLI configurado com credenciais de acesso
- Acesso à AWS com permissões para criar recursos RDS

## Estrutura do Projeto

- `main.tf` - Configuração principal do Terraform
- `variables.tf` - Definição das variáveis utilizadas
- `terraform.tfvars` - Valores das variáveis (incluindo senhas)

## Recursos Criados

- Grupo de segurança para o RDS
- Grupo de sub-redes para o RDS
- Instância RDS PostgreSQL

## Configuração

Antes de aplicar esta configuração, edite o arquivo `terraform.tfvars` para definir uma senha segura para o banco de dados:

```hcl
database_password = "SuaSenhaSeguraAqui"
```

## Uso

Para inicializar o Terraform:

```bash
cd /Users/robertomartins/Workspace/autonom.ia/terraform
terraform init
```

Para verificar o plano de execução:

```bash
terraform plan
```

Para aplicar a configuração:

```bash
terraform apply
```

## Conexão ao Banco de Dados

Após a criação do banco de dados, você pode se conectar a ele usando o endpoint fornecido na saída do Terraform:

```bash
psql -h <db_endpoint> -U autonomia_admin -d autonomia_db
```

## Segurança

- O banco de dados está configurado para ser acessível pela internet (publicly_accessible = true)
- O grupo de segurança permite tráfego na porta 5432 de qualquer IP (0.0.0.0/0)
- Em um ambiente de produção, considere restringir o acesso a IPs específicos

## Limpeza

Para destruir os recursos criados:

```bash
terraform destroy
```
