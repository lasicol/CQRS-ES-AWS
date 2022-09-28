resource "aws_opensearch_domain" "product_search" {
  domain_name           = "product-search"
  engine_version = "OpenSearch_1.3"

  cluster_config {
    instance_type = "t3.small.search"
  }
  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
  tags = {
    Domain = "product-search"
  }
  access_policies = <<POLICY
    {
    "Version": "2012-10-17",
    "Statement": [
                {
        "Action": "es:*",
        "Principal": {
            "AWS": [
                "${aws_iam_role.RoleProductReadModel.arn}"
            ]
        },
        "Effect": "Allow",
        "Resource": "arn:aws:es:us-east-1:890769921003:domain/product-search/*"
        },
        {
        "Action": "es:*",
        "Principal": "*",
        "Effect": "Allow",
        "Resource": "arn:aws:es:us-east-1:890769921003:domain/product-search/*",
      "Condition": {
        "IpAddress": {"aws:SourceIp": ["80.94.27.51/32"]}
      }
        }
    ]
    }
  POLICY
}