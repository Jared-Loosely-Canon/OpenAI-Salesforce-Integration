# Before You start

Note that this is open source, but can not be redistributed in proprietary software. Feel free to open pull requests to have additional features added

Next, understand that this app is 100% native so all communication between OpenAI and your salesforce org is owned between those two.
There is no intermediary.

However, you still must abide by any governance policies that your company employs.

# Short Demo of the Chat in SF
https://youtube.com/shorts/9Cy_-JkCQyo

# Installation

There are two methods to install, the package installation or a direct deployment. 

Package install 
For Production: https://login.salesforce.com/packaging/installPackage.apexp?p0=04tDn000000aEQ0IAM
For Sandboxes: https://test.salesforce.com/packaging/installPackage.apexp?p0=04tDn000000aEQ0IAM

## Configuration Steps

Ensure you have enabled API usage billing in your OpenAI account! This will not work without it.

These steps are covered indepth on our blog
https://looselycanon.com/salesforce-chatgpt

Here is a step by step video
https://youtu.be/_-cdPqOJaEw


1. Create a Named Credential with your OpenAI api key
2. Assign the OpenAI Chat Admin or OpenAI Chat User permission set to users
3. Add the OpenAiChat LWC to you apps, record pages, app pages, and/or homepages
4. Start chatting!

## Contribute to the Project

The first version is very basic, but there are a lot of possibilities.

## Getting Help

### Email
support@looselycanon.com
jaredsimpson@looselycanon.com

### LinkedIn
https://www.linkedin.com/in/jaredsimpson-looselycanon/
https://www.linkedin.com/company/loosely-canon-llc/

### Website
https://looselycanon.com/
