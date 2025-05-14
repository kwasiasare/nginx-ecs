AWS ECS Nginx Hello Demo
A containerized web application deployment using AWS ECS (Elastic Container Service) with Fargate launch type, demonstrating cloud-native containerization and load balancing capabilities.
Architecture Overview
This project demonstrates a highly available, containerized nginx hello application deployed on AWS ECS using Fargate. The architecture includes:
* ECS Cluster: Nginx-demo-cluster with enhanced container insights
* Service: nginxdemos-hello-service-jll8io9u running on Fargate
* Load Balancer: Application Load Balancer (nginx-hello-elb) for high availability
* Networking: Multi-AZ deployment across 2 availability zones
* Security: Configured security groups with port 80 access
Key Features
* Serverless Container Hosting: Uses AWS Fargate for serverless container execution
* High Availability: Deployed across multiple availability zones
* Load Balancing: Application Load Balancer for traffic distribution
* Auto-Scaling: Configured with capacity providers (FARGATE, FARGATE_SPOT)
* Enhanced Monitoring: Container Insights enabled for comprehensive metrics
* Deployment Safety: Circuit breaker and automatic rollback enabled
Infrastructure Components
CloudFormation Templates
1. ecs-infra.yaml: Sets up the ECS cluster infrastructure
    * ECS Cluster with enhanced container insights
    * Security groups
    * Launch template (for EC2 capacity if needed)
    * Auto Scaling Group (currently set to 0 instances)
    * Capacity providers configuration
2. ecs-cfl.yaml: Deploys the ECS service and load balancer
    * ECS Service running on Fargate
    * Application Load Balancer
    * Target Group and Listener
    * Security group for the ALB
Resource Details
* VPC: vpc-0e94afce11ca4687d
* Subnets:
    * subnet-0af0286d2048d7d45
    * subnet-08c891646465fb2a7
* Task Definition: nginxdemos-hello:3
* Container Port: 80
Deployment Configuration
Service Configuration
* Launch Type: FARGATE
* Desired Count: 1
* Network Mode: awsvpc with public IP assignment
* Platform Version: LATEST
Deployment Strategy
* Circuit Breaker: Enabled
* Automatic Rollback: Enabled
* Maximum Percent: 200%
* Minimum Healthy Percent: 100%
Security Configuration
* Ingress Rules:
    * TCP port 80 from 0.0.0.0/0
    * TCP port 80 from ::/0 (IPv6)
Getting Started
Prerequisites
* AWS Account with appropriate permissions
* AWS CLI configured
* CloudFormation access
Deployment Steps
1. Deploy the infrastructure stack: aws cloudformation create-stack \
2.   --stack-name nginx-demo-infra \
3.   --template-body file://ecs-infra.yaml \
4.   --capabilities CAPABILITY_IAM
5. 
6. Deploy the service stack: aws cloudformation create-stack \
7.   --stack-name nginx-demo-service \
8.   --template-body file://ecs-cfl.yaml \
9.   --capabilities CAPABILITY_IAM
10. 
11. Access the application:
    * Get the ALB DNS name from the CloudFormation outputs
    * Navigate to http://<alb-dns-name> in your browser
Monitoring and Maintenance
Container Insights
The cluster has enhanced Container Insights enabled, providing:
* Task and service metrics
* Resource utilization
* Performance monitoring
Health Checks
The Application Load Balancer performs health checks on:
* Path: /
* Protocol: HTTP
* Port: 80
Scaling
The infrastructure is prepared for auto-scaling with:
* Auto Scaling Group (0-5 instances)
* Multiple capacity providers (FARGATE, FARGATE_SPOT)
Cost Optimization
* Fargate Spot: The cluster is configured to support FARGATE_SPOT for cost-effective workloads
* Right-sizing: Currently running 1 task, easily scalable based on demand
* No EC2 instances: Pure serverless approach with Fargate
Security Considerations
* Security groups restrict traffic to necessary ports only
* Tasks run in isolated network environments (awsvpc mode)
* IAM roles follow least privilege principle
Troubleshooting
Common Issues
1. Task fails to start: Check task definition and container image
2. Health check failures: Verify the application is responding on port 80
3. Cannot access application: Check security group rules and ALB configuration
Useful Commands
# View cluster status
aws ecs describe-clusters --clusters Nginx-demo-cluster

# View service status
aws ecs describe-services --cluster Nginx-demo-cluster --services nginxdemos-hello-service-jll8io9u

# View running tasks
aws ecs list-tasks --cluster Nginx-demo-cluster --service-name nginxdemos-hello-service-jll8io9u
Clean Up
To remove all resources:
# Delete the service stack first
aws cloudformation delete-stack --stack-name nginx-demo-service

# Wait for deletion to complete, then delete infrastructure
aws cloudformation delete-stack --stack-name nginx-demo-infra
License

