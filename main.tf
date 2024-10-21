locals {
    iam_prefix = "ROLES"

    common_roles = [
        format("%s/run.serviceAgent", lower(local.iam_prefix)),
        format("%s/logging.viewer", lower(local.iam_prefix)),
        format("%s/iam.serviceAccountTokenCreator", lower(local.iam_prefix)),
        format("%s/serviceusage.serviceUsageConsumer", lower(local.iam_prefix)),
    ]
    firebase_roles = [
        format("%s/firebase.admin", lower(local.iam_prefix)),
    ]
    
    admin_roles = [
        format("${lower(local.iam_prefix)}/artifactregistry.admin"),
        format("${lower(local.iam_prefix)}/run.admin"),
        format("${lower(local.iam_prefix)}/cloudfunctions.admin"),
    ]
    external_roles = jsondecode(file("${path.module}/roles.json"))

    ci_cd_roles = distinct(concat(
        local.common_roles,
        local.firebase_roles,
        local.admin_roles,
        local.external_roles
    ))
    is_firebase_admin = contains(local.ci_cd_roles, format("%s/firebase.admin", lower(local.iam_prefix)))

}

resource "google_service_account" "service_account" {
  account_id   = var.service_account_id
  display_name= var.service_account_id
  description = "Service Account for Pipeline"
}

resource "google_project_iam_member" "iam_member_role" {
  project = var.project_id
  count   = length(local.ci_cd_roles)
  role    = local.ci_cd_roles[count.index]
  member  = "serviceAccount:${google_service_account.service_account.email}"
}
