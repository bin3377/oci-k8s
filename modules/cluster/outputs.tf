output "cluster_id" {
  description = "the id of kubernetes cluster created"
  value = oci_containerengine_cluster.this.id
}
