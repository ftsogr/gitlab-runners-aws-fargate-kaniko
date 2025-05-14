# terraform.tfvars

fargate_cluster                       = "ftso-cluster"
fargate_region                        = "us-west-2"
fargate_subnet         = "subnet-xxxxxxxx"
fargate_security_group = "sg-xxxxxxxx"
project                               = "ftso"
ecsTaskExecutionRoleArn               = "arn:aws:iam::demo:role/ecsTaskExecutionRole"
java_fargate_task_definition          = "java-task-def"
java_runner_image                     = "demo.dkr.ecr.us-west-2.amazonaws.com/java-runner:latest"
java_fargate_cpu                      = "1024"
java_fargate_memory                   = "2048"