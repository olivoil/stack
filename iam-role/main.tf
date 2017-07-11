variable "name" {
  description = "The name of the stack to use in security groups"
}

variable "environment" {
  description = "The name of the environment for this stack"
}

resource "aws_iam_role" "default_lambda_role" {
  name = "lambda-role-${var.name}-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eni" {
  role       = "${aws_iam_role.default_lambda_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "default_lambda_function_role_policy" {
  name = "lambda-function-role-policy-${var.name}-${var.environment}"
  role = "${aws_iam_role.default_lambda_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Action": [
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:DeleteItem",
        "dynamodb:DescribeLimits",
        "dynamodb:DescribeReservedCapacity",
        "dynamodb:DescribeReservedCapacityOfferings",
        "dynamodb:DescribeStream",
        "dynamodb:DescribeTable",
        "dynamodb:DescribeTimeToLive",
        "dynamodb:GetItem",
        "dynamodb:GetRecords",
        "dynamodb:GetShardIterator",
        "dynamodb:ListStreams",
        "dynamodb:ListTables	*",
        "dynamodb:ListTagsOfResource",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:TagResource",
        "dynamodb:UpdateItem",
        "dynamodb:UpdateTimeToLive",
        "dynamodb:UntagResource"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:dynamodb:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "default_api_gateway_role" {
  name = "api-gateway-role-${var.name}-${var.environment}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": ["apigateway.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "default_apigateway_role_policy" {
  name = "api-gateway-role-policy-${var.name}-${var.environment}"
  role = "${aws_iam_role.default_api_gateway_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "lambda:InvokeFunction"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "default_ecs_role" {
  name = "ecs-role-${var.name}-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "default_ecs_service_role_policy" {
  name = "ecs-service-role-policy-${var.name}-${var.environment}"
  role = "${aws_iam_role.default_ecs_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "default_ecs_instance_role_policy" {
  name = "ecs-instance-role-policy-${var.name}-${var.environment}"
  role = "${aws_iam_role.default_ecs_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecs:StartTask",
        "autoscaling:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "default_ecs" {
  name  = "ecs-instance-profile-${var.name}-${var.environment}"
  path  = "/"
  role  = "${aws_iam_role.default_ecs_role.name}"
}

output "default_lambda_role_id" {
  value = "${aws_iam_role.default_lambda_role.id}"
}

output "default_lambda_role_arn" {
  value = "${aws_iam_role.default_lambda_role.arn}"
}

output "default_api_gateway_role_id" {
  value = "${aws_iam_role.default_api_gateway_role.id}"
}

output "default_api_gateway_role_arn" {
  value = "${aws_iam_role.default_api_gateway_role.arn}"
}

output "default_ecs_role_id" {
  value = "${aws_iam_role.default_ecs_role.id}"
}

output "default_ecs_role_arn" {
  value = "${aws_iam_role.default_ecs_role.arn}"
}

output "profile" {
  value = "${aws_iam_instance_profile.default_ecs.id}"
}
