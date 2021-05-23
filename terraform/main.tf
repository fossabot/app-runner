provider "aws" {
  region = "us-east-1"
}

resource "aws_apprunner_connection" "github" {
  connection_name = "github"
  provider_type   = "GITHUB"
}

resource "aws_apprunner_auto_scaling_configuration_version" "scaling" {
  auto_scaling_configuration_name = "scaling"
  max_concurrency                 = 100
  max_size                        = 10
  min_size                        = 1
}

resource "aws_apprunner_service" "service" {
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.scaling.arn

  service_name = "app-runner"

  source_configuration {
    authentication_configuration {
      connection_arn = aws_apprunner_connection.github.arn
    }

    code_repository {
      code_configuration {
        configuration_source = "API"

        code_configuration_values {
          runtime       = "python3"
          build_command = "pip install -r requirements.txt"
          start_command = "python app.py"
          port          = "8000"
        }
      }

      repository_url = "https://github.com/brunosantosnet/app-runner"

      source_code_version {
        type  = "BRANCH"
        value = "main"
      }

    }
  }
}
