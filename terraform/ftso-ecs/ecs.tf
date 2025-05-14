data "template_file" "java_container_def" {
  template = file("./templates/container_def.json.tpl")

  vars = {
    project                 = var.project
    runner_image            = var.java_runner_image
    fargate_cpu             = var.java_fargate_cpu
    fargate_memory          = var.java_fargate_memory
    fargate_region          = var.fargate_region
    fargate_task_definition = var.java_fargate_task_definition
  }
}


resource "aws_ecs_cluster" "project_cluster" {
  name = var.fargate_cluster

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.log_group.name
      }
    }
  }

  tags = {
    Name           = var.fargate_cluster
    "user.type"    = "ecs-cluster"
    "user.project" = var.project
  }
}

resource "aws_ecs_cluster_capacity_providers" "project_cluster_cp" {
  cluster_name = aws_ecs_cluster.project_cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}


resource "aws_ecs_task_definition" "java_project_task_def" {
  family                   = var.java_fargate_task_definition
  container_definitions    = data.template_file.java_container_def.rendered
  task_role_arn            = var.ecsTaskExecutionRoleArn
  execution_role_arn       = var.ecsTaskExecutionRoleArn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.java_fargate_cpu
  memory                   = var.java_fargate_memory

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  tags = {
    Name           = "${var.project}-task"
    "user.type"    = "ecs-task-def"
    "user.project" = var.project
    "TaskType"     = "java"
  }
}