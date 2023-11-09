# AWS CLOUD RESUME CHALLENGE

Welcome to my AWS Cloud Resume Challenge repository! This project is the culmination of my journey to enhance my cloud computing skills and create a tangible demonstration of my abilities on Amazon Web Services (AWS). The AWS Cloud Resume Challenge is a hands-on initiative that allowed me to design and deploy my personal resume website using various AWS services.

## What is the AWS Cloud Resume Challenge?

The AWS Cloud Resume Challenge is not an official Amazon Web Services (AWS) program but rather a community-driven initiative designed to help individuals enhance their cloud computing skills and create a notable project to add to their resume. 

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
