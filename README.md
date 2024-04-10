# Json to Structured Data Pipeline Project

Welcome to our Json to Structured Data Pipeline Project! In this repository, we have developed a robust and automated data pipeline to extract, load, transform, and analyze air traffic statistics from San Francisco International Airport (SFO) datasets. Our approach emphasizes leveraging cloud-native, cost-effective, and serverless technologies to efficiently process and model data for analytical purposes.

## High-Level Objective

Our goal with this project was to create a data pipeline capable of generating well-modeled dimensions and facts for analytical purposes. By doing so, we aim to gain insights into air traffic patterns, passenger volumes, cargo statistics, and more, ultimately facilitating informed decision-making and strategic planning.

## Tech Stack

We have utilized the following technologies for our data pipeline:

- **AWS**: For data extraction, storage, scheduling, and containerization.
- **Snowflake**: As our data warehouse to store and manage the extracted data.
- **dbt (data build tool)**: For data transformation and modeling, allowing us to define complex data models in SQL.
- **Docker**: To containerize our processes for easier deployment and management.
- **Git and GitHub Actions**: For version control, collaboration, and continuous integration/continuous deployment (CI/CD) workflows.

## Data Pipeline Details

### Architecture Diagram

![ETL (1)](https://github.com/1000BytesInnovations/GITHUB_ACTIONS_AWS_ECR-DOCKER/assets/161686879/ff00fbad-3405-4b66-b1e3-a4bed0909a1c)


### Data Extraction

We extract data from various SFO data sources using their API endpoints in JSON format. These sources include:

- Air Traffic Cargo Statistics
- Air Traffic Passenger Statistics
- Air Traffic Landings Statistics

We have automated the extraction process using AWS Lambda functions, with each function responsible for loading JSON files of specific aspects from the SFO website to an S3 bucket.

### Data Loading into Snowflake

The extracted data is continuously loaded from S3 into Snowflake using Snowpipes, ensuring automatic ingestion of new files as they become available in the S3 bucket.

### Streamlining Data Pipeline Operations with AWS Lambda and CloudWatch

Our data pipeline relies on AWS Lambda functions to handle various tasks such as data extraction, validation, and triggering ECS tasks. These functions are scheduled using AWS CloudWatch, ensuring regular updates and efficient processing without unnecessary tasks.

### Data Transformation and Modeling with dbt

We process, clean, and model the datasets into dimensions and fact tables using dbt. This powerful tool allows us to define transformations in SQL, facilitating the creation of complex data models. We follow a data flow from the raw layer to the gold layer in Snowflake using dbt, defining appropriate dimensions and facts along the way.

### AWS ECS and ECR

Within our AWS ecosystem, we utilize ECS (Elastic Container Service) along with ECR (Elastic Container Registry) to manage our containerized processes efficiently. Specifically, we leverage AWS Fargate for cost-effective and sufficient computational power.
### GitHub Actions CI/CD Diagram
![compile](https://github.com/1000BytesInnovations/GITHUB_ACTIONS_AWS_ECR-DOCKER/assets/161686879/3d09c327-7350-4f03-80d6-c2626a041505)


### GitHub Actions CI/CD

We have implemented CI/CD workflows using GitHub Actions, with two main workflows:

1. **Workflow 1**: Triggered upon pull request approval, it ensures our dbt models are correct and up to date by running the 'dbt compile' command.
2. **Workflow 2**: Triggered upon pull request merge, it deploys an ECR CloudFormation stack to AWS CloudFormation, builds and pushes the dbt image to the repository, and deploys an ECS CloudFormation stack to run the 'dbt run' command as a task in ECS.

## Resources

You can find all the necessary resources in this repository, including Lambda functions, Snowflake SQL code for pipes, external integrations, dbt project files, Lambda functions, and GitHub action files. Feel free to explore and utilize these resources as needed.
### Notes To Remember 

 feel free to replace the parameter values in workflow2.yml file to your liking but make sure to change the image tag of docker image according to your AWS ECR repository name cause the image tag should look like this **repository_name:latest** you can find this line of code in line 66 of the workflow2.yml file 

For any inquiries or contributions, please don't hesitate to reach out. Happy analyzing!
