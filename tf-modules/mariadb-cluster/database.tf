resource "kubernetes_manifest" "maxscale" {
  manifest = {
    apiVersion = "k8s.mariadb.com/v1alpha1"
    kind       = "MaxScale"

    metadata = {
      name      = var.cluster_name
      namespace = var.namespace
    }

    spec = {

      mariaDbRef = {
        name = var.cluster_name
      }

      kubernetesService = {
        type = "ClusterIP"
      }

      guiKubernetesService = {
        type = "ClusterIP"
      }

      metrics = {
        enabled = true
      }
    }
  }
}

resource "kubernetes_manifest" "mariadb-cluster" {
  manifest = {
    apiVersion = "k8s.mariadb.com/v1alpha1"
    kind       = "MariaDB"

    metadata = {
      name      = var.cluster_name
      namespace = var.namespace
    }

    spec = {
      storage = {
        size = "5Gi"

        # # Use cluster longhorn storage class
        # storageClassName = "longhorn"
      }

      replicas = 3

      maxScaleRef = {
        name = kubernetes_manifest.maxscale.manifest.metadata.name
      }

      galera = {
        enabled = true
        primary = {
          podIndex          = 0
          automaticFailover = true
        }

        sst                = "mariabackup"
        availableWhenDonor = false
        galeraLibPath      = "/usr/lib/galera/libgalera_smm.so"
        replicaThreads     = 4

        agent = {
          image = "docker-registry3.mariadb.com/mariadb-operator/mariadb-operator:${var.mariadb_version}"
          port  = 5555
          kubernetesAuth = {
            enabled = true
          }
          gracefulShutdownTimeout = "1s"
        }


        recovery = {
          enabled                    = true
          minClusterSize             = 1
          forceClusterBootstrapInPod = "${var.cluster_name}-0"
          clusterMonitorInterval     = "10s"
          clusterHealthyTimeout      = "30s"
          clusterBootstrapTimeout    = "10m0s"
          podRecoveryTimeout         = "5m0s"
          podSyncTimeout             = "5m0s"

          job = {
            metadata = {
              labels = {
                "sidecar.istio.io/inject" = "false"
              }
            }
            resources = {
              requests = {
                cpu    = "50m"
                memory = "128Mi"
              }
              limits = {
                cpu    = "500m"
                memory = "512Mi"
              }
            }
          }
        }

        initContainer = {
          image = "docker-registry3.mariadb.com/mariadb-operator/mariadb-operator:${var.mariadb_version}"
        }

        initJob = {
          metadata = {
            labels = {
              "sidecar.istio.io/inject" = "false"
            }
          }
          resources = {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }

        config = {
          volumeClaimTemplate = {
            # storageClassName = "longhorn"
            resources = {
              requests = {
                storage = "2Gi"
              }
            }
            accessModes = [
              "ReadWriteOnce"
            ]
          }
        }
      }

      service = {
        type = "ClusterIP"
      }

      connection = {
        secretName = "${var.cluster_name}-conn"
        secretTemplate = {
          key = "dsn"
        }
      }

      primaryService = {
        type = "ClusterIP"
      }

      primaryConnection = {
        secretName = "${var.cluster_name}-conn-primary"
        secretTemplate = {
          key = "dsn"
        }
      }

      secondaryService = {
        type = "ClusterIP"
      }

      secondaryConnection = {
        secretName = "${var.cluster_name}-conn-secondary"
        secretTemplate = {
          key = "dsn"
        }
      }

      affinity = {
        antiAffinityEnabled = true
      }

      tolerations = [
        {
          key      = "k8s.mariadb.com/ha"
          operator = "Exists"
          effect   = "NoSchedule"
        }
      ]

      podDisruptionBudget = {
        maxUnavailable = "66%"
      }

      updateStrategy = {
        autoUpdateDataPlane = true
        type                = "RollingUpdate"
        rollingUpdate = {
          maxUnavailable = 1
        }
      }

      priorityClassName = "system-node-critical"

      myCnf = <<EOF
        [mariadb]
        bind-address=*
        default_storage_engine=InnoDB
        binlog_format=row
        innodb_autoinc_lock_mode=2
        max_allowed_packet=256M
		    wsrep_retry_autocommit=5
      EOF

      timeZone = "+2:00"

      resources = {
        requests = {
          cpu    = "25m"
          memory = "416Mi"
        }
        limits = {
          cpu    = "1500m"
          memory = "2Gi"
        }
      }

      livenessProbe = {
        initialDelaySeconds = 20
        periodSeconds       = 5
        timeoutSeconds      = 5
      }

      readinessProbe = {
        initialDelaySeconds = 20
        periodSeconds       = 5
        timeoutSeconds      = 5
      }

      metrics = {
        enabled = true
      }

      suspend = false
    }
  }

  depends_on = [
    kubernetes_secret_v1.mariadb-cluster
  ]
}
