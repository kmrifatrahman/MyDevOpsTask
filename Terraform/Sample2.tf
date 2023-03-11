# Define variables
variable "aws_region" {
  default = "us-east-2"
}

variable "github_owner" {
  default = "kmrifatrahman"
}

variable "github_repo" {
  default = "MyWeb"
}

variable "github_branch" {
  default = "main"
}

variable "github_oauth_token" {
  default = "YOUR_GITHUB_OAUTH_TOKEN"
}

variable "fargate_task_name" {
  default = "FargateTaskDemo"
}

variable "input_bucket_name" {
  default = "inputbucket01780919098"
}

variable "output_bucket_name" {
  default = "outputbucket01780919098"
}

variable "ProjectName_Dev" {
  default = "MyDevBuildProject"
}

variable "ProjectName_QA" {
  default = "MyQABuildProject"
}

variable "ProjectName_Test" {
  default = "MyTestBuildProject"
}

variable "ProjectName_Prod" {
  default = "MyProdBuildProject"
}

variable "clusterName" {
  default = "DemoCluster"
}
variable "clusterServiceName" {
  default = "myDemoService"
}



# Create S3 buckets
resource "aws_s3_bucket" "input_bucket" {
  bucket = var.input_bucket_name
}

resource "aws_s3_bucket" "output_bucket_1" {
  bucket = "${var.output_bucket_name}1"
}

resource "aws_s3_bucket" "output_bucket_2" {
  bucket = "${var.output_bucket_name}2"
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.output_bucket_name}3"
}

# Create IAM roles
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to IAM roles
resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.codebuild_role.name
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSageMakerServiceCatalogProductsCodePipelineServiceRolePolicy"
  role       = aws_iam_role.codepipeline_role.name
}

# Create CodeBuild project
resource "aws_codebuild_project" "my_project" {
  name = "my_project"

  service_role = aws_iam_role.codebuild_role.arn
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:4.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/${var.github_owner}/${var.github_repo}"
    buildspec       = "buildspec.yml"
    git_clone_depth = 1
    report_build_status = true
  }

  artifacts {
    type = "S3"
    location = aws_s3_bucket.artifacts.bucket
    name = "build-output.zip"
  }
}

# Create CodePipeline
resource "aws_codepipeline" "my_pipeline" {
  name = "my_pipeline"
  role_arn  = "arn:aws:iam::860632841866:role/StackPipeline-MyPipelineRole-1H4AHQPY68NM0"

  artifact_store {
    location = var.aws_region
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "Github"
      version          = "2"
      output_artifacts = ["source_output"]
      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = var.github_oauth_token
      }
    }
  }

  stage {
    name = "Dev"

    action {
      name            = "Dev"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version          = "1"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = var.ProjectName_Dev
      }
    }
  }


  stage {
    name = "QA"

    action {
      name            = "QA"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version          = "1"
      input_artifacts = ["build_output"]
      output_artifacts = ["managed_output"]
      configuration = {
        ProjectName = var.ProjectName_Dev
      }
    }
  }

  stage {
    name = "Test"

    action {
      name            = "Test"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version          = "1"
      input_artifacts = ["managed_output"]
      configuration = {
        ClusterName = var.clusterName
        ServiceName = var.clusterServiceName
        FileName   = "imagedefinitions.json"
        Environment = "EcsAll"
      }
    }
  }
}




# Create CodeBuild projects
resource "aws_codebuild_project" "my_Buildproject" {
  name        = "my_Buildproject"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "S3"
    location = aws_s3_bucket.artifacts.bucket
    name = "build_output"
    packaging = "ZIP"
  }

  source {
    type = "S3"
    location = aws_s3_bucket.input_bucket.bucket
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    type         = "LINUX_CONTAINER"
    image        = "aws/codebuild/standard:5.0"
  }

  cache {
    type = "LOCAL"
    modes = ["LOCAL_SOURCE_CACHE", "LOCAL_DOCKER_LAYER_CACHE", "LOCAL_CUSTOM_CACHE"]
  }

  logs_config {
    cloudwatch_logs {
      group_name = "my_project_logs"
      stream_name = "my_project_stream"
    }
  }

  build_timeout = 60
}

resource "aws_codebuild_project" "my_test_project" {
  name        = "my_test_project"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "S3"
    location = aws_s3_bucket.artifacts.bucket
    name = "test_output"
    packaging = "ZIP"
  }

  source {
    type = "S3"
    location = aws_s3_bucket.input_bucket.bucket
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    type         = "LINUX_CONTAINER"
    image        = "aws/codebuild/standard:5.0"
  }

  cache {
    type = "LOCAL"
    modes = ["LOCAL_SOURCE_CACHE", "LOCAL_DOCKER_LAYER_CACHE", "LOCAL_CUSTOM_CACHE"]
  }

  logs_config {
    cloudwatch_logs {
      group_name = "my_test_project_logs"
      stream_name = "my_test_project_stream"
    }
  }

  build_timeout = 60
}

# Create CodeDeploy application and deployment group
resource "aws_codedeploy_app" "my_app" {
  name = "my_app"
}
resource "aws_sns_topic" "my_topic" {
  name = "hulu007k"
}

resource "aws_codedeploy_deployment_group" "my_deployment_group" {
    deployment_group_name = "my-deployment-group"
    deployment_config_name = "CodeDeployDefault.OneAtATime"
    service_role_arn      = "arn:aws:iam::860632841866:role/service-role"
    app_name              = aws_codedeploy_app.my_app.name

  auto_rollback_configuration {
    enabled = true
    events = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "STOP_DEPLOYMENT"
    }
  }

  ecs_service {
    cluster_name = "my_cluster"
    service_name = var.fargate_task_name
  }

  load_balancer_info {
    target_group_info {
      name = "my_target_group"
    }
  }

  trigger_configuration {
    trigger_events      = ["DeploymentStart", "DeploymentSuccess"]
    trigger_name        = "my_trigger"
    trigger_target_arn  = aws_sns_topic.my_topic.arn
  }
}
