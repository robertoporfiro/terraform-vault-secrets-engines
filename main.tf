resource "vault_mount" "ssh" {
  count = contains(var.secrets_engines, "ssh") ? 1 : 0
  path  = "ssh"
  type  = "ssh"

  default_lease_ttl_seconds = var.default_lease
  max_lease_ttl_seconds     = var.max_lease

  seal_wrap               = var.seal_wrap
  local                   = var.local_mount
  external_entropy_access = var.external_entropy_access

  description = "The ssh secrets engine is mounted at the ssh/ path"
}

resource "vault_mount" "db" {
  count = contains(var.secrets_engines, "db") ? 1 : 0
  path  = "db"
  type  = "db"

  default_lease_ttl_seconds = var.default_lease
  max_lease_ttl_seconds     = var.max_lease

  seal_wrap               = var.seal_wrap
  local                   = var.local_mount
  external_entropy_access = var.external_entropy_access

  description = "The ${element(var.secrets_engines, count.index)} secrets engine is mounted at the /${element(var.secrets_engines, count.index)} path"
}

resource "vault_mount" "transit" {
  count = contains(var.secrets_engines, "transit") ? 1 : 0
  path  = "transit"
  type  = "transit"

  default_lease_ttl_seconds = var.default_lease
  max_lease_ttl_seconds     = var.max_lease

  seal_wrap               = var.seal_wrap
  local                   = var.local_mount
  external_entropy_access = var.external_entropy_access

  description = "The ${element(var.secrets_engines, count.index)} secrets engine is mounted at the /${element(var.secrets_engines, count.index)} path"
}

resource "vault_aws_secret_backend" "aws_backend" {
  count = contains(var.secrets_engines, "aws") ? 1 : 0

  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region

  default_lease_ttl_seconds = var.aws_default_lease
  max_lease_ttl_seconds     = var.aws_max_lease
}

resource "vault_aws_secret_backend_role" "aws_backend_role" {
  count = contains(var.secrets_engines, "aws") ? 1 : 0
  name  = var.aws_backend_role_name

  backend         = vault_aws_secret_backend.aws_backend[count.index].path
  credential_type = var.aws_backend_role_cred_type

  role_arns       = var.aws_role_arns
  policy_arns     = var.aws_policy_arns
  policy_document = var.aws_policy_document
  iam_groups      = var.aws_iam_groups

  default_sts_ttl = var.aws_sts_default_ttl
  max_sts_ttl     = var.aws_sts_max_ttl
}

resource "vault_azure_secret_backend" "azure_secret_backend" {
  count = contains(var.secrets_engines, "azure") ? 1 : 0
  path  = "azure"

  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id

  client_id     = var.azure_client_id
  client_secret = var.azure_client_secret
  environment   = var.azure_environment
}

resource "vault_azure_secret_backend_role" "azure_secret_backend_role" {
  count = contains(var.secrets_engines, "azure") ? 1 : 0
  role  = var.azure_secret_backend_role_name

  backend = vault_azure_secret_backend.azure_secret_backend[count.index].path
  max_ttl = var.azure_secret_backend_max_ttl
  ttl     = var.azure_secret_backend_ttl

  azure_roles {
    role_name = var.azure_role
    scope     = local.azure_role_scope
  }

  application_object_id = var.azure_app_id
}
