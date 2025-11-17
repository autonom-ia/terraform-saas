# 📋 Comandos Terraform - Guia Rápido

## ⚠️ IMPORTANTE: Sempre use o arquivo correto!

O `terraform.tfvars` padrão está configurado para **STAGING**. Sempre especifique o arquivo correto para cada ambiente.

## 🚀 Comandos para PRODUÇÃO

### Plan (verificar mudanças)
```bash
export AWS_PROFILE=autonomia
terraform workspace select prod
source load-env.sh prod
terraform plan -var-file=terraform.tfvars.prod
```

### Apply (aplicar mudanças)
```bash
export AWS_PROFILE=autonomia
terraform workspace select prod
source load-env.sh prod
terraform apply -var-file=terraform.tfvars.prod
```

### Plan apenas RDS e SSM (mais rápido)
```bash
export AWS_PROFILE=autonomia
terraform workspace select prod
source load-env.sh prod
terraform plan \
  -var-file=terraform.tfvars.prod \
  -target=aws_db_instance.main \
  -target=aws_db_subnet_group.main \
  -target=aws_ssm_parameter.db_host \
  -target=aws_ssm_parameter.db_port \
  -target=aws_ssm_parameter.db_name \
  -target=aws_ssm_parameter.db_user \
  -target=aws_ssm_parameter.db_password \
  -target=aws_ssm_parameter.db_ssl_enabled
```

## 🧪 Comandos para STAGING

### Plan (verificar mudanças)
```bash
export AWS_PROFILE=autonomia
terraform workspace select staging
source load-env.sh staging
terraform plan
```

### Apply (aplicar mudanças)
```bash
export AWS_PROFILE=autonomia
terraform workspace select staging
source load-env.sh staging
terraform apply
```

## 🔍 Verificar Workspace Atual

```bash
terraform workspace show
```

## 📝 Aliases Úteis (adicionar ao .zshrc)

```bash
# Produção
alias tf-plan-prod='export AWS_PROFILE=autonomia && terraform workspace select prod && source load-env.sh prod && terraform plan -var-file=terraform.tfvars.prod'
alias tf-apply-prod='export AWS_PROFILE=autonomia && terraform workspace select prod && source load-env.sh prod && terraform apply -var-file=terraform.tfvars.prod'

# Staging
alias tf-plan-staging='export AWS_PROFILE=autonomia && terraform workspace select staging && source load-env.sh staging && terraform plan'
alias tf-apply-staging='export AWS_PROFILE=autonomia && terraform workspace select staging && source load-env.sh staging && terraform apply'
```

## ⚠️ Erros Comuns

### Erro: "No value for required variable"
**Causa**: Não carregou as variáveis do `.env`
**Solução**: Execute `source load-env.sh [prod|staging]` antes

### Erro: Plan mostra destruição de recursos de prod
**Causa**: Usou `terraform.tfvars` (staging) no workspace prod
**Solução**: Use `-var-file=terraform.tfvars.prod` no workspace prod

### Erro: "Resource will be replaced"
**Causa**: Configuração diferente entre state e código
**Solução**: Verifique se está usando o arquivo `.tfvars` correto

## ✅ Checklist Antes de Apply

- [ ] Workspace correto selecionado (`terraform workspace show`)
- [ ] Variáveis carregadas (`source load-env.sh [prod|staging]`)
- [ ] Arquivo `.tfvars` correto (`-var-file=terraform.tfvars.prod` para prod)
- [ ] Plan revisado e sem mudanças indesejadas
- [ ] Backup do state (se necessário)

