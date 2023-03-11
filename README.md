# Part 1: Setup an AWS four (4) stages CI/CD pipeline using AWS Cloudformation. The stages (e.g Dev,QA,UAT,Prod) should have manual approvals.

# DevOpsTask_TakeHomeTest

First Of All
We will need an s3 bucket to store artifacts and that should have necessary permissions. I have created required resources first in my test account.
Required IAM role and users are listed below:
# Role:
1. AWSServiceRoleForECS:	Role to enable Amazon ECS to manage your cluster.
2. AWSServiceRoleForElasticLoadBalancing:   Allows ELB to call AWS services on your behalf
3. CodeBuild :  Allows CodeBuild to call AWS services on your behalf. (This is a custom policy)
4. StackPipeline-MyPipelineRole-1H4AHQPY68NM0:  This should have the permission to start:codeBuild (This is also a custom policy)

# User:
A user should be assigned with the above role assigned within. I have created a user with those specific role name DevOps.

# S3:
In this architecture I have created an S3 bucket name devopsbucket-demo to store artifacts and to pull out artifacts from there. The codebuild should have access to the s3.


# Open DevOps_Task:
Now here, Lets go to DevOps_Task -maain brach. and do as follows:

# File Name: AWSCli.sh
You will have to run the commands from the file names AWSCli.sh in aws cli before foing further. This will respectively create necessary resources for codepipelines.
The part:1 will create demoProject which we will be using in the pipeline. If you have any existing projects, simply just change the project names and values in the 4StagePipeline.yml file.

The part:2 will create cloudformation stack to deploy the code respectively "deployECS.yml" and "4StagePipeline.yml." The deployECS.yml will create the necessary cluster which will be connected with the pipeline and 4StagePipeline will create a 4 stage code pipeline with manual approval for each stage and connected to github

After this, go to Deploy.

# File Name: deplouECS.yml
This file is to be deployed through aws cli following the #AWSCli.sh commands.
This will create the necessary cluster with proper loadbalancer and target group.

# File Name: 4StagePipeline.yml
This will create the required resources mentioned in task 1. I have tried as close as possible to fullfil the requirements without any context. I have tested the script in an aws account which I had access for about a few hours. The values of any components requires changes based on the available account and components value.


# Part 2: Infrastructure as Code (IAC) architecture :

Now go to the directory named Terraform. This could be done in 2 ways. This can be run in the pipeline. in that case some commands must be initiate in a configure file in the directory. But I have done this from my machine. So all it took is to run these :
 1. terraform init
 2. terraform plan
 3. terraform apply.

 terraform apply will deploy the terraform script into the target area.