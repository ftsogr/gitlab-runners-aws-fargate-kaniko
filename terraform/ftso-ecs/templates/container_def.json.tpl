[
    {
        "name": "ci-coordinator",
        "image": "${runner_image}",
        "cpu": ${fargate_cpu},
        "memory": ${fargate_memory},
        "portMappings": [
            {
                "name": "ci-coordinator-80-tcp",
                "containerPort": 80,
                "hostPort": 80,
                "protocol": "tcp",
                "appProtocol": "http"
            },
            {
                "name": "ci-coordinator-22-tcp",
                "containerPort": 22,
                "hostPort": 22,
                "protocol": "tcp"
            },
            {
                "name": "ci-coordinator-443-tcp",
                "containerPort": 443,
                "hostPort": 443,
                "protocol": "tcp",
                "appProtocol": "http"
            }
        ],
        "essential": true,
        "environment": [],
        "environmentFiles": [],
        "mountPoints": [],
        "volumesFrom": [],
        "ulimits": [],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-create-group": "true",
                "awslogs-group": "/ecs/${project}/logs",
                "awslogs-region": "${fargate_region}",
                "awslogs-stream-prefix": "${fargate_task_definition}"
            },
            "secretOptions": []
        },
        "systemControls": []
    }
]
