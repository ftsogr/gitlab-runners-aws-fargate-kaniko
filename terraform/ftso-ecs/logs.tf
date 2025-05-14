resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/${var.project}/logs"
  retention_in_days = 7

  tags = {
    Name = "${var.project}-ecs-log-group"
  }
}
