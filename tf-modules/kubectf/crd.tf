resource "kubernetes_manifest" "crd" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind       = "CustomResourceDefinition"
    metadata = {
      name = "instanced-challenges.kube-ctf.${var.org_name}"
    }
    spec = {
      group = "kube-ctf.${var.org_name}"
      names = {

        plural   = "instanced-challenges"
        singular = "isolated-challenge"
        kind     = "IsolatedChallenge"
        shortNames = [
          "isolated-challenge"
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
