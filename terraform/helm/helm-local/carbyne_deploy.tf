data "aws_sqs_queue" "sqs_queue" {
  name = var.model_sqs_name
}

resource "helm_release" "carbyne-helm" {
  name             = "carbyne"
  chart            = "./helm/helm-local/helm-carbyne"
  namespace        = "sqs-consumer"
  create_namespace = true

  values = [templatefile("${path.module}/template.yaml", {
    aws_region    = var.model_aws_region
    sql_queue_url = data.aws_sqs_queue.sqs_queue.url
  })]
}
