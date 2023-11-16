# AWS CLOUD RESUME CHALLENGE

Welcome to my AWS Cloud Resume Challenge repository! This project is the culmination of my journey to enhance my cloud computing skills and create a tangible demonstration of my abilities on Amazon Web Services (AWS). The AWS Cloud Resume Challenge is a hands-on initiative that allowed me to design and deploy my personal resume website using various AWS services.

## What is the AWS Cloud Resume Challenge?

The [AWS Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/aws/) is not an official Amazon Web Services (AWS) program but rather a community-driven initiative designed to help individuals enhance their cloud computing skills and create a notable project to add to their resume. 

It was created by [Forrest Brazeal](https://forrestbrazeal.com/), to encourage practical learning and showcase one's AWS expertise to potential employers.

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

I have added a restriction location to the CloudFront distribution: a geographic whitelist for United Kingdom (GB) and Spain (ES).

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

    > [!IMPORTANT]
    > The ACM certificate must to be in US East.

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
