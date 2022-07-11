# terraform-practice

This is a repository to track progress with learning different aspects of Terraform and CICD.

## Repo Structure

Each challenge folder contains a set of instructions and the solution for the given challenge. Each progressing challenge adds onto the previous one. The aim is to gradually build on each challenge in order to build skills.


## Setup

In order to use the repo and spin up the infrastructure within each challenge folder I am using the AWS sandbox environment provided by ACloudGuru (ACG). 

In the AWS credentials file, I have configured a profile named "training" which contains the ACG sandbox access key and ACG secret access key, also setting the region to 'us-east-1'. In the terraform provider block for aws, I have added a reference to the training profile.

After everything is configured, I am able to go into a challenge folder and use terraform commands to create infrastructure from a terminal window.