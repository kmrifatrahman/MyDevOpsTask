# Creating projects Manually as a demo
#Part:1
aws codebuild create-project --name MyDevBuildProject --source "type=GITHUB,location=https://github.com/kmrifatrahman/MyWeb.git,gitCloneDepth=1" --artifacts "type=S3,location=devopsbucket-demo,packaging=ZIP" --environment "type=LINUX_CONTAINER,computeType=BUILD_GENERAL1_SMALL,image=aws/codebuild/standard:5.0" --service-role "arn:aws:iam::860632841866:role/service-role"
aws codebuild create-project --name MyQABuildProject --source "type=GITHUB,location=https://github.com/kmrifatrahman/MyWeb.git,gitCloneDepth=1" --artifacts "type=S3,location=devopsbucket-demo,packaging=ZIP" --environment "type=LINUX_CONTAINER,computeType=BUILD_GENERAL1_SMALL,image=aws/codebuild/standard:5.0" --service-role "arn:aws:iam::860632841866:role/service-role"
aws codebuild create-project --name MyTestBuildProject --source "type=GITHUB,location=https://github.com/kmrifatrahman/MyWeb.git,gitCloneDepth=1" --artifacts "type=S3,location=devopsbucket-demo,packaging=ZIP" --environment "type=LINUX_CONTAINER,computeType=BUILD_GENERAL1_SMALL,image=aws/codebuild/standard:5.0" --service-role "arn:aws:iam::860632841866:role/service-role"



# now lets deploy our cloudformation template 
# Part:2
aws cloudformation create-stack --stack-name demoStackECS --template-body "file://D:/OneDrive - hus school/DevOpsTask_Mal/DevOps Task/Deploy/deployECS.yml" --capabilities CAPABILITY_IAM
aws cloudformation create-stack --stack-name demoStackPipeline --template-body "file://D:/OneDrive - hus school/DevOpsTask_Mal/DevOps Task/Deploy/4StagePipeline.yml" --capabilities CAPABILITY_IAM

