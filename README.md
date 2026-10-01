# Scalable Web Application Using ALB and Auto Scaling

## 1. Project Title

**Scalable Web Application Using Application Load Balancer and Auto
Scaling**

## 2. Objective

The objective of this project is to deploy a scalable web application on
AWS that can handle increasing traffic by distributing requests across
multiple EC2 instances.

The project also demonstrates high availability and automatic recovery
when an EC2 instance becomes unavailable.

------------------------------------------------------------------------

## 3. AWS Services Used

  -----------------------------------------------------------------------
  AWS Service                         Purpose
  ----------------------------------- -----------------------------------
  Amazon EC2                          Hosts the Apache web application

  Application Load Balancer (ALB)     Distributes incoming HTTP traffic

  Target Group                        Registers EC2 instances and
                                      performs health checks

  Auto Scaling Group (ASG)            Automatically manages EC2 instance
                                      capacity

  Launch Template                     Defines the configuration for new
                                      EC2 instances

  Amazon Machine Image (AMI)          Provides the base image for EC2
                                      instances

  Amazon CloudWatch                   Monitors CPU utilization and Auto
                                      Scaling activity

  Security Groups                     Controls inbound and outbound
                                      network access
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 4. Architecture Diagram

``` text
                         User / Browser
                              |
                              | HTTP :80
                              v
                          Internet
                              |
                              v
                 +-------------------------+
                 | Application Load        |
                 | Balancer (ALB)          |
                 +-------------------------+
                              |
                              v
                 +-------------------------+
                 | Target Group            |
                 | Health Checks            |
                 +-------------------------+
                              |
                    +---------+---------+
                    |                   |
                    v                   v
             +-------------+      +-------------+
             | EC2         |      | EC2         |
             | Instance 1  |      | Instance 2  |
             | Apache      |      | Apache      |
             +-------------+      +-------------+
                    \                   /
                     \                 /
                      +---------------+
                      | Auto Scaling  |
                      | Group         |
                      +---------------+
                              ^
                              |
                    CPU-based scaling
                              |
                              v
                       CloudWatch
```

### Request Flow

1.  The user opens the web application through a browser.
2.  The request reaches the internet-facing Application Load Balancer.
3.  The ALB forwards the request to a healthy EC2 instance through the
    Target Group.
4.  The EC2 instance runs the Apache web server and returns the webpage.
5.  CloudWatch monitors instance metrics such as CPU utilization.
6.  The Auto Scaling Group launches or terminates EC2 instances
    according to the configured scaling policy.

------------------------------------------------------------------------

## 5. Source Code

### Web Application

The application is a simple HTML webpage hosted by Apache on the EC2
instances.

Example structure:

``` text
ALB-ASG-WebServer/
├── index.html
├── user-data.sh
├── README.md
└── screenshots/
```

### `index.html`

``` html
<!DOCTYPE html>
<html>
<head>
    <title>ALB Auto Scaling Demo</title>
</head>
<body>

    <h1>🚀 Scalable Web Application</h1>
    <h2>Amazon EC2 + ALB + Auto Scaling</h2>

    <p>Web Server is running successfully!</p>

    <p><b>Hostname:</b> YOUR_HOSTNAME</p>
    <p><b>Instance ID:</b> YOUR_INSTANCE_ID</p>

</body>
</html>
```

Replace the placeholder values with the actual values if the application
uses static values. If your final Launch Template uses dynamic metadata,
document the exact final User Data script used in your AWS
configuration.

------------------------------------------------------------------------

## 6. Implementation Steps

### Step 1: Create EC2 Instance

An Amazon Linux 2023 EC2 instance was launched using the `t3.micro`
instance type.

Apache HTTP Server was installed and configured:

``` bash
sudo dnf install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
```

The web application was placed in:

``` text
/var/www/html/
```

------------------------------------------------------------------------

### Step 2: Configure Security Group

A security group was configured for the EC2 web servers.

The security configuration was designed so that web traffic can reach
the application through the Load Balancer, while administrative SSH
access is restricted.

------------------------------------------------------------------------

### Step 3: Create AMI

An Amazon Machine Image named:

``` text
ALB-ASG-WebServer-AMI
```

was created from the configured EC2 web server.

The AMI is used as the base image for new Auto Scaling instances.

------------------------------------------------------------------------

### Step 4: Create Launch Template

Launch Template:

``` text
ALB-ASG-WebServer-Template
```

was created with:

-   Amazon Linux 2023 AMI
-   `t3.micro`
-   `alb-asg-key`
-   EC2 security group
-   8 GiB gp3 root volume

The final configuration used Launch Template Version 2.

------------------------------------------------------------------------

### Step 5: Create Target Group

Target Group:

``` text
ALB-ASG-WebServer-TG
```

Configuration:

-   Target type: Instance
-   Protocol: HTTP
-   Port: 80
-   Health check path: `/`
-   Health check protocol: HTTP

The Target Group checks whether the EC2 web servers are healthy before
sending traffic to them.

------------------------------------------------------------------------

### Step 6: Create Application Load Balancer

An internet-facing Application Load Balancer was created in the selected
VPC and multiple Availability Zones.

The HTTP listener on port 80 forwards traffic to:

``` text
ALB-ASG-WebServer-TG
```

------------------------------------------------------------------------

### Step 7: Create Auto Scaling Group

Auto Scaling Group:

``` text
ALB-ASG-WebServer-ASG
```

Configuration used during the project:

``` text
Minimum capacity: 1
Desired capacity: 2
Maximum capacity: 3
```

The Auto Scaling Group was connected to the Target Group.

------------------------------------------------------------------------

### Step 8: Configure Auto Scaling Policy

A target tracking policy was configured:

``` text
Policy: CPU-Target-50
Target CPU utilization: 50%
```

CloudWatch metrics are used by the scaling policy to determine when
additional capacity is required.

------------------------------------------------------------------------

## 7. Project Demonstration

### Traffic Distribution

The ALB distributes incoming requests among healthy EC2 instances.

Refreshing the ALB URL demonstrated that requests could be served by
different instances.

### Automatic Scale-Out

CPU load was generated on the EC2 instances to test Auto Scaling.

The Auto Scaling Group increased the desired capacity from:

``` text
2 → 3
```

A new EC2 instance was launched automatically.

### Failure Recovery

One Auto Scaling managed EC2 instance was terminated as a resilience
test.

The Auto Scaling Group detected the reduced capacity and launched a
replacement instance.

The Target Group then returned to a healthy state after the replacement
instance passed its health checks.

------------------------------------------------------------------------

## 8. Security Configuration

Security was implemented using separate Security Groups for the ALB and
EC2 instances.

### ALB Security Group

-   HTTP port 80 allowed from the Internet for the public web
    application.

### EC2 Security Group

-   Web traffic is restricted to traffic from the ALB security group.
-   SSH access is restricted to an appropriate administrative source.

This prevents direct public access to the EC2 web servers through HTTP.

------------------------------------------------------------------------

## 9. Monitoring

Amazon CloudWatch was used to monitor the Auto Scaling environment.

The dashboard included metrics such as:

-   CPU Utilization
-   Group Desired Capacity
-   Group In-Service Instances
-   Group Total Instances
-   Group Maximum Size

CloudWatch also supported the CPU-based Auto Scaling policy and helped
verify scaling activity.

------------------------------------------------------------------------

## 10. Screenshots

The following screenshots demonstrate the important parts of the
project:

1.  **EC2 Instances** -- Shows the EC2 instances used by the
    application.
2.  **Running Web Application** -- Shows the application accessed
    through the ALB.
3.  **Launch Template** -- Shows the configuration used to launch new
    instances.
4.  **Application Load Balancer** -- Shows the ALB configuration.
5.  **Target Group** -- Shows healthy EC2 targets and health checks.
6.  **Auto Scaling Group** -- Shows minimum, desired, and maximum
    capacity.
7.  **Auto Scaling Policy** -- Shows the CPU target tracking policy.
8.  **Scale-Out Activity** -- Shows capacity changing from 2 to 3
    instances.
9.  **Instance Replacement** -- Shows automatic replacement after an
    instance failure.
10. **CloudWatch Dashboard** -- Shows monitoring metrics.

------------------------------------------------------------------------

## 11. Key Learnings

Through this project, I learned:

-   How to launch and configure EC2 instances.
-   How to deploy an Apache web server.
-   How to create and use an AMI.
-   How Launch Templates work.
-   How an Application Load Balancer distributes traffic.
-   How Target Groups perform health checks.
-   How Auto Scaling automatically manages EC2 capacity.
-   How CloudWatch monitors AWS resources.
-   How Security Groups control network access.
-   How AWS provides automatic recovery when an instance becomes
    unavailable.
-   How to test scalability and fault tolerance in a cloud environment.

------------------------------------------------------------------------

## 12. Production Improvements

For a production environment, I would improve the architecture by:

-   Using HTTPS with an SSL/TLS certificate.
-   Placing EC2 application servers in private subnets.
-   Using least-privilege IAM permissions.
-   Adding more CloudWatch alarms and notifications.
-   Using multiple Availability Zones for higher availability.
-   Using Infrastructure as Code such as Terraform or CloudFormation.
-   Implementing CI/CD for automated deployments.
-   Using Route 53 with a custom domain name.
-   Adding a managed database such as Amazon RDS when persistent
    application data is required.

------------------------------------------------------------------------

## 13. Conclusion

This project demonstrates how AWS services can be combined to build a
scalable and fault-tolerant web application.

The Application Load Balancer distributes traffic, the Auto Scaling
Group manages EC2 capacity, the Target Group performs health checks, and
CloudWatch provides monitoring and scaling metrics.

The project was tested for traffic distribution, automatic scale-out,
and EC2 instance failure recovery.
