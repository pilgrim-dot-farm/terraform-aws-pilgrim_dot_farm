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
          portMappings = [{
            name          = "http"
            containerPort = var.ecs_container_port
            protocol      = "tcp"
          }]

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
  ]
}
