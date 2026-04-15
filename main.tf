
##########
# Cilium #
##########

# The below CiliumClusterwideNetworkPolicy resource is a split yaml doc to create a pair of global policies to replicate
# the default behaviour of Calico in the Cloud Platform:
#
# - Deny all egress to the IMDS IP (169.254.169.254) from non-system namespaces.
# - Allow all other pod/namespace egress to the internet

data "kubectl_path_documents" "policies" {
  pattern = "${path.module}/manifests/*.yaml"
}

resource "kubectl_manifest" "cilium_clusterwide_policies" {
  for_each  = data.kubectl_path_documents.policies.manifests
  yaml_body = each.value

  depends_on = [
    helm_release.cilium
  ]
}

resource "kubernetes_namespace_v1" "cilium" {
  metadata {
    name = "cilium"

    labels = {
      "component"                          = "cilium"
      "pod-security.kubernetes.io/enforce" = "privileged"
    }

    annotations = {
      "container-platform.service.justice.gov.uk/application"   = "cilium"
      "container-platform.service.justice.gov.uk/business-unit" = "OCTO"
      "container-platform.service.justice.gov.uk/owner"         = "Container Platform: platforms@digital.justice.gov.uk"
      "container-platform.service.justice.gov.uk/service-area"  = "Hosting"
      "container-platform.service.justice.gov.uk/is-production" = "true"
      "container-platform.service.justice.gov.uk/source-code"   = "https://github.com/ministryofjustice/modernisation-platform-environments/tree/main/terraform/environments/cloud-platform"
    }
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "helm_release" "cilium" {
  name       = "cilium"
  chart      = "cilium"
  repository = "https://helm.cilium.io/"
  namespace  = "cilium"
  timeout    = 300
  version    = "1.18.4"
  skip_crds  = true

  set = [
    {
      name  = "cni.chainingMode"
      value = "aws-cni"
    },
    {
      name  = "cni.exclusive"
      value = "false"
    },
    {
      name  = "enableIPv4Masquerade"
      value = "false"
    },
    {
      name  = "routingMode"
      value = "native"
    }
  ]

  depends_on = [
    kubernetes_namespace_v1.cilium
  ]
}
