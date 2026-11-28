resource "kubernetes_manifest" "crd" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind       = "CustomResourceDefinition"
    metadata = {
      name = "instanced-challenges.kube-ctf.${var.org_name}"

      labels = {
        "app.kubernetes.io/name"      = "kube-ctf"
        "app.kubernetes.io/component" = "challenges"
        "app.kubernetes.io/part-of"   = "ctfpilot"
        "ctfpilot.com/component"      = "challenges"
      }
    }
    spec = {
      group = "kube-ctf.${var.org_name}"
      names = {

        plural   = "instanced-challenges"
        singular = "instanced-challenge"
        kind     = "InstancedChallenge"
        shortNames = [
          "instanced-challenge"
        ]
      }
      versions = [
        {
          name    = "v1"
          served  = true
          storage = true
          schema = {
            openAPIV3Schema = {
              type = "object"
              properties = {
                spec = {
                  type = "object"
                  properties = {
                    expires = {
                      type = "integer"
                    }
                    available_at = {
                      type = "integer"
                    }
                    type = {
                      type = "string"
                    }
                    template = {
                      type = "string"
                      type = "string"
                    }
                  }
                }
              }
            }
          }
        }
      ]
      scope = "Cluster"
    }
  }
}
