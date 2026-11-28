resource "kubernetes_service" "redis_cluster_leaders" {
  metadata {
    name      = "redis-cluster-leaders"
    namespace = var.namespace
    labels = {
      app                           = "redis-cluster-leader"
      redis_setup_type              = "cluster"
      role                          = "leader"
      "app.kubernetes.io/name"      = "redis"
      "app.kubernetes.io/component" = "platform"
      "app.kubernetes.io/part-of"   = "ctfpilot"
      "ctfpilot.com/component"      = "platform"
    }
  }

  spec {
    selector = {
      app              = "redis-cluster-leader"
      redis_setup_type = "cluster"
      role             = "leader"
    }
    port {
      name        = "redis-client"
      port        = 6379
      target_port = 6379
      protocol    = "TCP"
    }
    # type = "NodePort"
  }
}

resource "kubernetes_service" "redis_cluster_followers" {
  metadata {
    name      = "redis-cluster-followers"
    namespace = var.namespace
    labels = {
      app                           = "redis-cluster-follower"
      redis_setup_type              = "cluster"
      role                          = "follower"
      "app.kubernetes.io/name"      = "redis"
      "app.kubernetes.io/component" = "platform"
      "app.kubernetes.io/part-of"   = "ctfpilot"
      "ctfpilot.com/component"      = "platform"
    }
  }

  spec {
    selector = {
      app              = "redis-cluster-follower"
      redis_setup_type = "cluster"
      role             = "follower"
    }
    port {
      name        = "redis-client"
      port        = 6379
      target_port = 6379
      protocol    = "TCP"
    }
    # type = "NodePort"
  }
}
