# controlupexercise

what is created:

VPC with a /16 ip address range and an internet gateway
We are choosing a region and a number of availability zones we want to use. For high-availability we need at least two
In every availability zone we are creating a private and a public subnet with a /24 ip address range
Public subnet convention is 10.x.0.x and 10.x.1.x etc..
Private subnet convention is 10.x.50.x and 10.x.51.x etc..
In the public subnet we place a NAT gateway and the LoadBalancer
The private subnets are used in the autoscale group which places instances in them
We create an ECS cluster where the instances connect to


How to run:

terraform apply -input=false -var-file=ecs.tfvars 
