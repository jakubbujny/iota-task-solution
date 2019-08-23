
resource "null_resource" "config-map-aws-auth" {
  provisioner "local-exec" {
    command = "echo \"${local.config-map-aws-auth}\" > config-map-aws-auth.yml && KUBECONFIG=kubeconfig.yml kubectl apply -f config-map-aws-auth.yml"
  }
  provisioner "local-exec" {
    command = "KUBECONFIG=kubeconfig.yml kubectl delete -f config-map-aws-auth.yml && rm config-map-aws-auth.yml"
    when = "destroy"
  }
  depends_on = ["null_resource.kubeconfig"]
}


resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "echo \"${local.kubeconfig}\" > kubeconfig.yml"
  }
  provisioner "local-exec" {
    command = "rm kubeconfig.yml"
    when = "destroy"
  }
}





