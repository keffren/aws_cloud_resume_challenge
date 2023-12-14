# AWS CLOUD RESUME CHALLENGE

Welcome to my AWS Cloud Resume Challenge repository! This project is the culmination of my journey to enhance my cloud computing skills and create a tangible demonstration of my abilities on Amazon Web Services (AWS).

## What is the AWS Cloud Resume Challenge?

The [AWS Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/aws/) is not an official Amazon Web Services (AWS) program but rather a community-driven initiative designed to help individuals enhance their cloud computing skills and create a notable project to add to their resume. 

It was created by [Forrest Brazeal](https://forrestbrazeal.com/), to encourage practical learning and showcase one's AWS expertise to potential employers.

**Challenge Architecture:**

![](/resources/challenge_architecture.png)

The challenge typically involves creating a personal website or portfolio hosted on AWS, building infrastructure as code (IaC) to deploy and manage the website, integrating with AWS services like databases and storage, setting up continuous integration/continuous deployment (CI/CD) pipelines, and implementing monitoring and security best practices.

The challenge consists of building a cloud-based resume portfolio using AWS services. It is divided into 16 steps, which cover a wide range of AWS services.

## My Progress

### Semantic Versioning

This project is going utilize semantic versioning for its tagging: [semver.org](https://semver.org/)

The general format:
- **MAJOR version** when you make incompatible API changes
    - In this project, each completed challenge step will constitute a major version
- **MINOR version** when you add functionality in a backward compatible manner
- **PATCH version** when you make backward compatible bug fixes

### 1. AWS Cloud Practitioner certificate

The AWS Cloud Practitioner certificate is the first requirement to complete this challenge.

The following resources helped me prepare and **PASS** the newest AWS Certified Cloud Practitioner exam:

- My Internship as Platform engineer intern at [Nextails Labs](https://nextail.co/)
- [Udemy course by Stéphane Maarek](https://www.udemy.com/course/aws-certified-cloud-practitioner-new/)
- [Practice exams by Stéphane Maarek](https://www.udemy.com/course/practice-exams-aws-certified-cloud-practitioner/)

### 2. Resume as HTML

The resume needs to be written in plane HTML. Not a Word doc, not a PDF.

### 3. CSS

The resume needs to be styled with CSS. It doesn’t have to be fancy.
To apply style to the plain HTML, I have used a [template](https://github.com/StartBootstrap/startbootstrap-resume) which is created by [Start Bootstrap](https://startbootstrap.com/).

### 4. Static WebSite

The HTML resume should be deployed online as an Amazon S3 static website.

One of the advanced challenge steps is Step **12: Infrastructure as Code (IaC)** This means deploying the project infrastructure and AWS services as IaC. To accomplish this, I will start from the beginning by deploying the project as Infrastructure as Code using **Terraform**, which is one of the most commonly-used IaC tools in the industry.

To achieve it, it was helpful the next guides:

- [Tutorial: Configuring a static website on Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/HostingWebsiteOnS3Setup.html)
- [AWS Provide of Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

> [!IMPORTANT]
> The user who was configured on AWS CLI is not the root user! It is another user with admin privileges and MFA enabled.

### 5. HTTPS

The S3 website URL should use **HTTPS** for security which is one of the features of **Amazon CloudFront**.

**What is Amazon CloudFront?**
Amazon CloudFront is a content delivery network (CDN) service built for high performance, security, and developer convenience. It delivers the content through a worldwide network of data centers called edge locations.

The static website endpoint, created using CloudFormation, is composed of : 
- `CloudFront Distribution domain name` + `index.hml`

Therefore, the endpoint for my resume is : https://d1fntmxjlhuwfd.cloudfront.net/index.html

Lastly, the following guides and documentation helped me perform this step:

- [Amazon CLoudFront documentation](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/GettingStarted.SimpleDistribution.html)
- [CloudFront resource terraform doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#viewer-certificate-arguments)
- [Create a CloudFront distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/GettingStartedCreateDistribution.html)
- [List of ISO 3166 country codes](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes)
- [Values that you specify when you create or update a distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-values-specify.html#DownloadDistValuesForwardCookies)

### 6. DNS

At this point, Internet users can now access my static website via the website endpoint defined in the previous step. However, I want users to access my site through a custom domain like` https://mateodev.cloud/`.

To achieve this, I must set up a custom domain. First, I need to create a DNS zone that will contain a Alias record forwarding traffic from `https://mateodev.cloud/` to my website endpoint. Since my static website is hosted on AWS, I can use **AWS Route 53** as my domain’s DNS provider.

Also, CloudFront has a custom SSL certificate, instead of its default.

1. Create a hosted zone on Route-53
    - A hosted zone tells Route 53 how to respond to DNS queries for a domain such as `example.com`.
    - When a hosted zone is attached to a VPC, it means the hosted zone is private.
1. Import SSL certificate to CloudFront

    > The ACM certificate **must to** be in **US East**.

    - This documentation is very helpful: [Importing an SSL/TLS certificate to CloudFront](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-procedures.html#cnames-and-https-uploading-certificates)
    - If the `aws_cloudfront_distribution` resource use an ACM certificate, it **must have these two arguments declared**:
        - `ssl_support_method`
        - `minimum_protocol_version`

1. Create DNS Record of type A

    - This DNS Record is an **Alias record** that routes traffic to an AWS resource, CloudFront.
    - If the domain is not provided by Amazon, its `Nameservers`  have to point to the `Nameservers` of the Hosted Zone created below. In my case, my domain is provided by *goDaddy*.
    - Alternatively, you can add the DNS record to the third-party domain provider, which will be easier to set up without extra cost.

### 7. JavaScript

<details>
<summary>The resume webpage should include a visitor counter that displays how many people have accessed the site. This visitor counter needs a bit of JavaScript.</summary>

This step has two solutions:

1. Local Solution:

    ```
    //Retrieve the views
    let views = getViews();
    document.getElementById("views-counter").innerHTML = views;

    //Increment and store the counter
    views++;
    localStorage.setItem("views-counter", views);

    function getViews(){

        let views = localStorage.getItem("views-counter");

        if(views === null){
            views = 1;
            localStorage.setItem("views-counter", views);
        }else{
            views = localStorage.getItem("views-counter");
        };

        return views;
    };
    ```
    - This solution only works locally because the scripts use `localStorage` method to store the data counter.
    - It is not the right solution because each user will have their own counter.
    - The purpose of doing this using user data is to refresh my knowledge of JavaScript and CSS.
    
2. Proper solution using DynamoDB
    - [views_counter_script.js](/front-end/js/views_counter_script.js)
    
</details>

### 8. DataBase

The visitor counter will need to retrieve and update its count in a database somewhere. For this, It's recommended to use **Amazon DynamoDB**, which is a fully managed, serverless, key-value NoSQL database designed to run high-performance applications at any scale.

> **DynamoDB is a schema-less database**, meaning you do not need to define all the attributes. This [stack overflow answer](https://stackoverflow.com/a/50014381) helps to understand the attribute terraform block. 

> [!IMPORTANT]
> By default, Terraform detects any differences in the current settings of a real infrastructure object and plans to update the remote object to match the configuration. If the visitor count value changes from the Terraform value declared, Terraform will update it. Therefore, it needs a `lifecycle` with the `ignore_changes` argument to avoid that behavior.

### 9. Python

It is necessary to create a few services that will interact with DynamoDB. These services are:

- **GetVisitorsCount**: Retrieves the count of views.
- **UpdateVisitorsCount**: Updates the count of views.

They are the core of the API and are implemented through AWS Lambda functions in the Python programming language.

Both services need permissions to access the database and create logs. Therefore, they have to assume a role created within the `iam.tf` file.

Lastly, the following guides are helpful for retrieve and update data from DynamoDB through the AWS SDK: Boto3.

- [Inserting and Retrieving Data](https://aws.amazon.com/tutorials/create-manage-nonrelational-database-dynamodb/#:~:text=the%20application%20background.-,Inserting%20and%20Retrieving%20Data,-(15%20minutes)%3A%20Walk)
- [Updating Items](https://aws.amazon.com/tutorials/create-manage-nonrelational-database-dynamodb/#:~:text=call%20with%20DynamoDB.-,Updating%20Items,-(15%20minutes)%3A%20Use)

### 10. API

Creating an API is necessary to handle requests from the static website and communicate with the database. This prevents direct communication between the JavaScript code and DynamoDB.

To achieve this, I utilize AWS API Gateway and Lambda services, which are practically free of charge.

> What is the difference between `API GateWay` and `API GateWay V2`? This [stack overflow answer](https://stackoverflow.com/a/72409509) explains it.

Every API Gateway resource consists of four components:

![](/resources/api_gateway_resource_methods.png)

- Method request
- Integration Request
    - `integration_http_method = "POST"`, no matters If it is a GET method. [Here](https://stackoverflow.com/a/41389858) explains the reason.
- Integration Response
    - Add resource dependency to `aws_api_gateway_integration_response` resource
- Method Response

> [!IMPORTANT]
> Grant lambda function permissions to API GateWay and [Enabled CORS](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html#apigateway-enable-cors-non-simple)

### 11. Tests

It should also include some tests for the Python code (Lambda Functions). In [this tutorial](https://realpython.com/python-testing/), teach how to create a basic test, execute it, and find the bugs before your users do. 

### 12. Infrastructure as Code

During the initial steps, as I commented earlier, I configured a Terraform environment to execute Infrastructure as Code (IaC).

### 13. Source Control

A good practice is to avoid updating the back-end API and the front-end website by making calls from the laptop. It's better to update them automatically whenever you make a change to the code. This concept is known as **continuous integration and deployment (CI/CD)**.

To achieve this, the project will be split in two repositories:

- [The back-end](https://github.com/keffren/resume_challenge_backend)
- [The front-end](https://github.com/keffren/resume_challenge_frontend)

### 14. CI/CD Back-End

In this step, I am setting up a CI/CD pipeline to upload Python code into the Lambda functions using **AWS CodePipeline**, deviating from the challenge's recommendation. For the front-end, I will use GitHub Actions.

The CI/CD pipeline is composed by the following stages:

- **Source:**
    - I am utilizing GitHub as our version control system. Whenever there is a code change in the GitHub repository, CodePipeline fetches the latest changes using a webhook integrated.
    - What is the PayloadURL of the Github WebHook? It is the CodePipeline endpoint that can be retrieved in Terraform using the following: `aws_codepipeline_webhook.github_webhook_integration.url`.
    - The content type of the Webhook should be `application/json`

- **Build:**
    - **CodeBuild** proceeds to install the necessary dependencies and run tests. Upon successful installation and test execution, it updates the lambda functions using the source control artifacts (stored in S3).
    - *CodeBuild notes*:
        - It needs a subnet
        - It needs an IAM service role
        - To run the latest boto3 version, it needs at least Python 3.8. The CodeBuild project has configured `amazonlinux2 standard 5.0`
        - [CodeBuild artifacs?](https://stackoverflow.com/questions/72132661/aws-codepipeline-multiple-output-artifacts)
        - https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html#build-spec.artifacts.name
        - [CodeBuild Buildspec syntax?](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html#build-spec-ref-syntax)
        - How to generate multiple artifacts?
            <details>

            ```
            #Codebuild buildspec.yml
                artifacts:
                        files:
                            - '**/*'
                        secondary-artifacts:
                            ArtifactGet:
                                files:
                                    - 'getVisitorsCount.py'
                                name: ArtifactGet
                            ArtifactUpdate:
                                files:
                                    - 'updateVisitorsCount.py'
                                name: ArtifactUpdate

            #CodePipeline build stage
            stage {
                name = "DeployAction"
                action {
                    ... 
                    input_artifacts = ["ArtifactGet"]    
                }       
            }
            ```

            </details>

> This CodePipeline uses GitHub version 1 which is deprecated. As extra, I may update it to [v2](https://docs.aws.amazon.com/codepipeline/latest/userguide/update-github-action-connections.html)

### 15. CI/CD Front-End

It requires creating a second GitHub repository for the website code and setting up GitHub Actions so that when new website code is pushed, the S3 bucket automatically updates.

> **GitHub Actions** is a continuous integration and continuous delivery (CI/CD) platform that automates build, test, and deployment pipelines. It can create workflows to build and test every pull request or deploy merged pull requests to production.

The workflow for this CI/CD pipeline is as follows:

- Checking the links within the repository using `Markdown link check`.
- Verifying website availability and testing the views count functionality through an Integration test. This test uses:
    - [Jest:](https://jestjs.io/docs/getting-started) a JavaScript framework for performing tests.
    - [Puppiteer:](https://pptr.dev/)  a Node.js library automating browser operations.
- Updating the front-end files in the AWS S3 bucket.
    - It has its own AWS credentials as a Service Account, configured as secrets.
    - This service account is attached to a custom policy granting S3 access to the web static bucket.

I found [this post](https://dev.to/slsbytheodo/configure-authentication-to-your-aws-account-in-your-github-actions-ci-13p3) on the *dev.to* blog that explains how to configure AWS Authentication in your GitHub Actions CI.

> **OpenID Connect (OIDC)** allows GitHub Actions workflows to access resources in Amazon Web Services (AWS), without needing to store the AWS credentials as long-lived GitHub secrets.

By updating the workflows to use OIDC tokens, I can adopt the following good security practices:

- **No cloud secrets:** You won't need to duplicate your cloud credentials as long-lived GitHub secrets. Instead, you can configure the OIDC trust on your cloud provider, and then update your workflows to request a short-lived access token from the cloud provider through OIDC.
- **Authentication and authorization management:** You have more granular control over how workflows can use credentials, using your cloud provider's authentication (authN) and authorization (authZ) tools to control access to cloud resources.
- **Rotating credentials:** With OIDC, your cloud provider issues a short-lived access token that is only valid for a single job, and then automatically expires.

The following documentation provides assistance in understanding and completing this step:

- [Markdown link check](https://github.com/gaurav-nelson/github-action-markdown-link-check)
- [GitHub Actions: Vars & Secrets](https://docs.github.com/en/actions/learn-github-actions/variables)
- [GitHub Actions: Dependency between jobs](https://docs.github.com/en/actions/using-jobs/using-jobs-in-a-workflow#defining-prerequisite-jobs)
- [Configuring OpenID Connect in Amazon Web Services](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

## Additional features

### Terraform Best Practices

<details>
<summary>
I've been using Terraform state locally because I didn't want to increase my AWS free tier S3 usage. Once I have completed the challenge, I plan to implement best Terraform practices related to managing state files.
</summary>

> **What is terraform state?**
Terraform state is a file that keeps track of the current configuration and state of your infrastructure managed by Terraform. It stores information about the resources provisioned, their attributes, dependencies, and relationships, enabling Terraform to understand what changes need to be made when you modify your infrastructure.

**Best practice: store it remotely**

- Storing Terraform state remotely ensures secure, concurrent access for teams, preventing conflicts. 
- It safeguards sensitive data, enables locking to prevent corruption, and provides backup/recovery options for better reliability and accessibility across environments.
 
To transition from using local state to remote state:

1. Create a remote backend on AWS S3
    - Enable bucket versioning.
    - Disable public access.
1. Update Terraform Configuration
    - Declare [backend resource](https://developer.hashicorp.com/terraform/language/settings/backends/configuration) within terraform block.
1. Migrate State
    - Initialize terraform with `-migrate-state` flag. The `-migrate-state` option will attempt to copy existing state to the new backend.
1. Verify & Test
    - Delete `terraform.tfstate` and `terraform.tfstate.backup`
    - Terraform plan output should indicate "No changes".

**Best practice: locking remote state**

- It prevents simultaneous modifications by multiple users, ensuring data integrity. 
- It safeguards against conflicting changes and potential corruption of the state file when multiple users are working on the same infrastructure simultaneously. 
- This helps maintain consistency and reliability in managing infrastructure configurations.

How to lock terraform remote state:

1. Create a dynamoDB table to store lock state
    - It is important the **partition key must be `LockID`**
1. Update backend block within terraform block
    - Add the dynamoDB table as attribute
1. Update terraform configuration
    - Initialize terraform with `-reconfigure` flag. The `-reconfigure` option disregards any existing configuration, preventing migration of any existing state.
1. Verify & Test
    - Terraform plan output should indicate "No changes".

</details>

### Analyze the Web Static server access logs

I have done this [aws lab](https://github.com/keffren/aws_labs/tree/main/hands_on_5) which analyzes the server access logs of S3 the web static using AWS Athena.
