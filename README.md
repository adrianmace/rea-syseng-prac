# REA Systems Engineer Practical Submission
## Deployment Instructions
### CLI Deployment
1. You can manually deploy this stack using the AWS CLI utility. This method assumes you have already configured the utility with credentials.
2. Clone the repository: `git clone https://github.com/adrianmace/rea-syseng-prac`
3. Change into the repo directory: `cd rea-syseng-prac`
4. Run the following command block:
```
aws cloudformation create-stack \
--stack-name 'Production' \
--template-body file://./deploy.yml \
--parameters \
ParameterKey=VpcCIDR,ParameterValue='172.16.0.0/16' \
ParameterKey=AZ1PublicSubnetCIDR,ParameterValue='172.16.1.0/24' \
ParameterKey=AZ2PublicSubnetCIDR,ParameterValue='172.16.2.0/24' \
ParameterKey=AZ1PrivateSubnetCIDR,ParameterValue='172.16.101.0/24' \
ParameterKey=AZ2PrivateSubnetCIDR,ParameterValue='172.16.102.0/24' \
ParameterKey=InstanceType,ParameterValue='t2.small' \
ParameterKey=InitialClusterSize,ParameterValue=4 \
ParameterKey=MaximumClusterSize,ParameterValue=10 \
ParameterKey=CPUUtilTargetValue,ParameterValue=70 \
ParameterKey=AppSource,ParameterValue='https://github.com/adrianmace/rea-syseng-prac' \
ParameterKey=AppBranch,ParameterValue='master'
```
5. After approximately 10 minutes, run the following command to get the URL:
```
aws cloudformation describe-stacks --stack-name 'Production' --query "Stacks[0].Outputs[?OutputKey=='AppURL'].OutputValue" --output text
```
### Web UI Deployment
1. Download the latest copy of the cloudformation template either by cloning the repository, downloading and extracting the repository zip, or directly from [here|https://raw.githubusercontent.com/adrianmace/rea-syseng-prac/master/deploy,yml] (Right Click > Save Target As)
2. Browse to https://console.aws.amazon.com/cloudformation and select `Create stack`
3. Upload the template file downloaded in Step 1 and proceed through the prompts to deploy this solution
4. After approximately 10 minutes, your URL will be available within the Outputs tab at the top of the screen

## Design Decisions
#### Simplicity
* The use of AWS as a cloud provider allows for a low-cost, high velocity deployment
  * AWS's rich feature-set provides the hardened base AMI, secured network segmentation and cloudformation IAC suite at no additional costs
* Cloudformation allows for the complete solution to be baked into a single file
  * This powerful infrastructure-as-code tool can automate the entire process, and making deployment and versioning a breeze
* The use of Docker allows the application source files to be swapped out at any given time without issue
  * Docker allows for a more reliable development workflow for contributors building and testing the application locally
  * By running the included source code in a container, we are not installing a number of dependancies on the host that would otherwise impact the 'anti-fragility' aspect of this solution
  * While this project focuses on the Sinatra HelloWorld POC, any dockerfile that listens on and exposes 80 would be deployable with this template
#### Code Documentation
* The use of Cloudformation allows for self-documenting code
* This has been coupled with the aforementioned deployment instructions, catering to a number of audiences
#### Ease of Deployment
* The use of Cloudformation allows for deployment ensures that the entire environment can be brought up using only a few commands
#### Idempotency
* This stack can be deployed on top of itself with no issues, adjusting and updating resources as required
* TODO: Define UpdatePolicy on ASG to ensure a rolling, zero-downtime upgrade is performed when LaunchConfiguration is adjusted
#### Security
* Instances are secured by using the hardened Amazon Linux 2 AMI with only minimal packages installed and enabled
* Instances exist only within the Private Subnet for each Availability Zone within the Auto Scaling Group
* Instances connect out to the internet only via the NATGateway resource within each AZ
* Communications from the internet into the application exist only via an Application Load Balancer, configured only for access on port 80
* TODO: Configure HTTPS listener within Application Load Balancer if SSL certificate is provided by operator
#### Anti-Fragility
* By making use of the sanitisation features within the Cloudformation templating syntax, users are guided away from submitting deployment-breaking user-inputs.

## Design Shortcomings
#### Lack of Conditionals
I would like to extend upon this solution by placing more power in the hands of the Operator. This includes allowing the Operator to define an SSL certificate; triggering deployment of a secure listener, defining customised SecurityGroupIngress resources at deploy time to modify firewalls, and customising other hardcoded areas such as the included health checks and ScalingPolicy metrics used
#### Lack of CI/CD
I hope to incorporate this within a CodeDeploy Cloudformation CI pipeline that pulls the latest source direct from the submodule defined within this git repository. I remained concious of the time required to include such workflow and have opted to instead focus on a reliable IAC deployment with supplimenting documentation
#### Lack of Nested CFN Stacks
As the preferred method of submission was a public github repository, I opted to keep this solution simple and use a single template file for Cloudformation. I believe that the solution would have benefited from a nested Cloudformation stack (separating VPC, Security Groups, Application Load Balancers, and Auto Scaling Groups) which would have avoided the need for the DependsOn property upon the AutoScalingGroup resource
#### Lack of Monitoring
This solution does not include monitoring, however it can be extended upon to include CloudWatch alarms for a number of metrics and capture logs of the running container by defining a LogGroup resource and IAM role, then using shipping these via built-in docker run parameters within the user data