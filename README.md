# Stack Services

Este repositório contém a infraestrutura como código (IaC) para gerenciar múltiplos serviços utilizando Terragrunt, OpenTofu/Terraform e módulos reutilizáveis. O objetivo é facilitar a automação, versionamento e provisionamento de recursos em provedores como Cloudflare, Google Workspace e Vault.

## Estrutura do Repositório

```
stack-services/
├── README.md                # Este arquivo
├── root.hcl                 # Configuração raiz do Terragrunt
├── live/                    # Ambientes e instâncias reais
│   ├── cloudflare/
│   │   ├── fabioluciano.dev/
│   │   │   └── terragrunt.hcl
│   │   ├── integr8.me/
│   │   └── naoimporta.com/
│   ├── google-workspace/
│   │   └── terragrunt.hcl
│   └── vault/
│       └── terragrunt.hcl
└── modules/                 # Módulos reutilizáveis para cada serviço
    ├── cloudflare/
    │   ├── main.tf
    │   ├── provider.tf
    │   └── variable.tf
    ├── google-workspace/
    │   ├── main.tf
    │   ├── provider.tf
    │   └── variables.tf
    └── vault/
        ├── main.tf
        ├── provider.tf
        └── variable.tf
```

## Como rodar os scripts

### Pré-requisitos
- [direnv](https://direnv.net/) para carregar variáveis de ambiente automaticamente
- [Terragrunt](https://terragrunt.gruntwork.io/)
- [OpenTofu](https://opentofu.org/) (ou Terraform)
- Credenciais e variáveis de ambiente configuradas no arquivo `.envrc`

### Passos para uso local

1. **Carregue as variáveis de ambiente:**
   ```sh
   direnv allow
   ```
2. **Inicialize o ambiente:**
   ```sh
   terragrunt run-all init
   ```
3. **Planeje e aplique as mudanças:**
   ```sh
   terragrunt run-all plan
   terragrunt run-all apply
   ```

### Execução via GitHub Actions
O repositório já possui um workflow em `.github/workflows/terragrunt.yaml` que executa os comandos de plan e apply automaticamente em pull requests e merges na branch `main`.

## Observações
- Os módulos em `modules/` são reutilizáveis e parametrizáveis.
- Os ambientes reais ficam em `live/` e cada subpasta representa um domínio, serviço ou ambiente distinto.
- O backend remoto é configurado via Terragrunt para armazenar o estado em um bucket S3/R2.
