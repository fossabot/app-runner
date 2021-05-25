provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "myrepo" {
  name = "myrepo"

  image_scanning_configuration {
    scan_on_push = true
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sh ~/codes/poc/app-runner/removeimages.sh"
  }

}

resource "null_resource" "myimage" {

  provisioner "local-exec" {
    command = "sh ~/codes/poc/app-runner/deploy.sh"
    #aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 882456490456.dkr.ecr.us-east-1.amazonaws.com && docker build -t myrepo /home/bruno.santos/codes/poc/app-runner/. && docker tag myrepo:latest 882456490456.dkr.ecr.us-east-1.amazonaws.com/myrepo:latest && docker push 882456490456.dkr.ecr.us-east-1.amazonaws.com/myrepo:latest"
  }
}

resource "aws_apprunner_service" "apprunner" {
    service_name                   = "apprunner"

    health_check_configuration {
        healthy_threshold   = 1
        interval            = 10
        path                = "/"
        protocol            = "TCP"
        timeout             = 5
        unhealthy_threshold = 5
    }

    source_configuration {
        auto_deployments_enabled = false

        authentication_configuration {
            access_role_arn = "arn:aws:iam::882456490456:role/service-role/AppRunnerECRAccessRole"
        }

        image_repository {
            image_identifier      = "882456490456.dkr.ecr.us-east-1.amazonaws.com/myrepo:latest"
            image_repository_type = "ECR"

            image_configuration {
                port                          = "8000"
                runtime_environment_variables = {}
            }
        }
    }
}

/*
resource "aws_apprunner_service" "myapp" {
  service_name = "myapp"

  source_configuration {
    image_repository {
      image_configuration {
        port = "8000"
      }
      image_identifier      = "882456490456.dkr.ecr.us-east-1.amazonaws.com/myrepo:latest"
      image_repository_type = "ECR"
    }
  }

  depends_on = [
    null_resource.myimage,
  ]
}
*/

/*
output "ecr_arn" {
  value = aws_ecrpublic_repository.myrepo.arn
}

output "ecr_repository" {
  value = aws_ecrpublic_repository.myrepo.repository_uri
}

output "ecr_registry" {
  value = aws_ecrpublic_repository.myrepo.registry_id
}

output "ecr_id" {
  value = aws_ecrpublic_repository.myrepo.id
}
*/
