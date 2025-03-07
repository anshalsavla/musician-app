resource "aws_ecr_repository" "musician_app" {
  name                 = "musician-app"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}


module "music-app-build" {
    source = "github.com/anshalsavla/terraform-aws-webapp-nodejs/modules"
    app_name = "musician-build"
    repo = "anshalsavla/musician-app"
    buildspec = "buildspec-build.yml"
    compute_type = "BUILD_LAMBDA_4GB"
    image = "aws/codebuild/amazonlinux-x86_64-lambda-standard:nodejs18"
    environment_type = "LINUX_LAMBDA_CONTAINER"
    filter_group= [ 
        {
            type = "EVENT"
            pattern = "PUSH"
        },
        {
            type = "HEAD_REF"
            pattern = "refs/heads/master"
        }
    ]
  
    build_timeout = "5"
    environment_variables = [{
        "name" = "ECR_REPOSITORY_NAME"
        "value" = "${aws_ecr_repository.musician_app.name}"
    }]
}

resource "aws_iam_role_policy" "ecr_policy" {
  name   = "musician-build-ecr-policy"
  role   = module.music-app-build.role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

module "music-app-test" {
    source = "github.com/anshalsavla/terraform-aws-webapp-nodejs/modules"
    app_name = "musician-test"
    repo = "anshalsavla/musician-app"
    buildspec = "buildspec-test.yml"
    compute_type = "BUILD_LAMBDA_4GB"
    image = "aws/codebuild/amazonlinux-x86_64-lambda-standard:nodejs18"
    environment_type = "LINUX_LAMBDA_CONTAINER"
    filter_group= [ 
        {
            type = "EVENT"
            pattern = "PULL_REQUEST_CREATED,PULL_REQUEST_UPDATED, PULL_REQUEST_REOPENED"
        },
        {
            type = "BASE_REF"
            pattern = "master"
        }
    ]
  
    build_timeout = "5"
}
