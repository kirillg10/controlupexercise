module "network" {
  source               = "../network"
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  depends_id           = ""
}

module "ecs_instances" {
  source = "../ecs_instances"

  environment             = var.environment
  cluster                 = var.cluster
  instance_group          = var.instance_group
  private_subnet_ids      = module.network.private_subnet_ids
  aws_ami                 = var.ecs_aws_ami
  instance_type           = var.instance_type
  max_size                = var.max_size
  min_size                = var.min_size
  desired_capacity        = var.desired_capacity
  vpc_id                  = module.network.vpc_id
  iam_instance_profile_id = aws_iam_instance_profile.ecs.id
  key_name                = var.key_name
  load_balancers          = var.load_balancers
  depends_id              = module.network.depends_id
  custom_userdata         = var.custom_userdata
  cloudwatch_prefix       = var.cloudwatch_prefix
}

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster
}

resource "aws_ecs_task_definition" "service" {
  family = "service"
  container_definitions = file("${path.module}/td-nginx.json")
}

resource "aws_ecs_service" "hello-world" {
  name            = "hello-world"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  iam_role        = aws_iam_role.ecs_service.arn


  load_balancer {
    target_group_arn = module.alb.default_alb_target_group_arn
    container_name   = "hello-world"
    container_port   = 8080
  }

  depends_on = ["module.alb"]

}