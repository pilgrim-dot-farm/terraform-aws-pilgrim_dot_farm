module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "7.6.1"

  cluster_name               = "${var.instance_name}-ecs"
  cluster_capacity_providers = ["FARGATE"]

  create_security_group                  = false
  cloudwatch_log_group_retention_in_days = 7

  services = var.ecs_container_image == null ? {} : {
    app = {
      name                     = "${var.instance_name}-app"
      launch_type              = "FARGATE"
      requires_compatibilities = ["FARGATE"]
      platform_version         = "1.4.0"
      cpu                      = 1024 # 2x min
      memory                   = 2048 # 2x min
      desired_count            = var.ecs_count
      enable_autoscaling       = false
      enable_execute_command   = false

      health_check_grace_period_seconds = 60
      deployment_circuit_breaker = {
        enable   = true
        rollback = true
      }

      runtime_platform = {
        cpu_architecture        = "ARM64"
        operating_system_family = "LINUX"
      }

      subnet_ids            = local.private_subnet_ids
      create_security_group = false
      security_group_ids    = local.front_end_sg_ids

      # ECS registers and deregisters task IPs as tasks start and stop.
      load_balancer = {
        app = {
          target_group_arn = aws_lb_target_group.pg.arn
          container_name   = "app"
          container_port   = var.ecs_container_port
        }
      }

      container_definitions = {
        app = {
          image     = var.ecs_container_image
          essential = true

          # Bump the release to redeploy an image published under the same tag.
          dockerLabels = {
            release = var.ecs_release
          }

          portMappings = [{
            name          = "http"
            containerPort = var.ecs_container_port
            protocol      = "tcp"
          }]

          healthCheck = {
            command = [
              "CMD", "python", "-c",
              "import sys, urllib.request; r = urllib.request.urlopen('http://127.0.0.1:${var.ecs_container_port}/api/health', timeout=3); sys.exit(0 if r.status == 200 else 1)",
            ]
            interval    = 15
            timeout     = 3
            retries     = 3
            startPeriod = 20
          }

          environment = [
            for name, value in local.app_environment : {
              name  = name
              value = value
            }
          ]

          cloudwatch_log_group_retention_in_days = 7
        }
      }

      iam_role_arn = local.pg_role_arn

      # The application reads its database and Stripe secrets at runtime.
      # The execution role needs no secret access: there are no `secrets:` entries.
      tasks_iam_role_statements = [
        {
          actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
          resources = [local.db_secret_arn, local.stripe_secret_arn]
        }
      ]

      task_exec_secret_arns    = []
      task_exec_ssm_param_arns = []
    }
  }

  tags = {
    Name = "${var.instance_name}-ecs"
  }

  # Wait for both the ALB association and private-subnet egress before starting tasks.
  depends_on = [
    aws_lb_listener.https,
    aws_route_table_association.private,
    aws_secretsmanager_secret_version.stripe,
  ]
}
