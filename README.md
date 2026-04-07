# Stack Services

Infraestrutura como código (IaC) para gerenciar domínios e serviços DNS no Cloudflare utilizando **Terragrunt v1** e **OpenTofu**.

## Domínios Gerenciados

| Domínio | GitHub Pages | Fastmail | Redirects | Email Routing |
|---------|:---:|:---:|:---:|:---:|
| `fabioluciano.com` | ✓ | ✓ | cv → resume | — |
| `fabioluciano.dev` | — | ✓ | → fabioluciano.com | — |
| `naoimporta.com` | — | ✓ | → fabioluciano.com | — |
| `integr8.me` | ✓ | ✓ | — | — |
| `beniciosilva.com` | ✓ | — | — | ✓ |

## Estrutura do Repositório

```
stack-services/
├── root.hcl                          # Configuração raiz (remote state no R2)
├── live/
│   └── cloudflare/
│       ├── beniciosilva.com/
│       ├── fabioluciano.com/
│       ├── fabioluciano.dev/
│       ├── integr8.me/
│       └── naoimporta.com/
└── modules/
    └── cloudflare/
        ├── main.tf                   # Root module (zona + submodules)
        ├── provider.tf               # Provider Cloudflare ~> 5
        ├── variable.tf               # Variáveis do módulo
        ├── dns/
        │   ├── main.tf               # DNS records, SRV, redirect rulesets
        │   ├── locals.tf             # Construção dos maps de records
        │   └── variable.tf
        └── mail/
            ├── main.tf               # Email routing (MX, SPF, DKIM, rules)
            └── variable.tf
```

## Pré-requisitos

- [Terragrunt](https://docs.terragrunt.com/) v1.0+
- [OpenTofu](https://opentofu.org/)
- [direnv](https://direnv.net/)
- Variáveis de ambiente no `.envrc`:
  - `CLOUDFLARE_API_TOKEN` — Token da API Cloudflare
  - `CLOUDFLARE_R2_ACCESS_KEY` / `CLOUDFLARE_R2_SECRET_KEY` / `CLOUDFLARE_R2_ENDPOINT` — Backend S3 no R2

## Uso

```sh
# Carregar variáveis de ambiente
direnv allow

# Planejar todas as unidades
terragrunt stack run plan

# Aplicar todas as unidades
terragrunt stack run apply

# Planejar um domínio específico
cd live/cloudflare/fabioluciano.com
terragrunt plan
```
