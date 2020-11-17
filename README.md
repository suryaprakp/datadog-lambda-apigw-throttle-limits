# datadog-lambda-apigw-metrics

This project aim is to send all api gateway API's throttle Rate and Burst limits to DD as a time series by introducing new custom metrics . Also creating datadog lambda layer which can be inherited by any lambda function and use dd library 

* **Note:** Project is integrated to TC , with robost CI/CD pipeline , only deploy from locally when really needed

## Pre-requisites
* Expose Datadog API,APP keys as env variables
`export DATADOG_APP_KEY=<YOUR-APP-KEY>`
`export DATADOG_APP_KEY=<YOUR-API-KEY>`
* Expose AWS keys as env variables or `~/.aws/credentials`
* Python3
* Docker - to build lambda layer

## How to use - Dev Env (locally)

* **Prepare venv:** go to relevant directory
`cd test_src_venv`
* **Prepare venv:** will create a new python venv and installing all dependencies mentioned in `requirements.txt` which are required for code to run
`make run`

* **Cleaning venv:** will clean python venv which created by uninstalling all dependencies mentioned in `requirements.txt`
`make clean`

* **Profiling:** code includes profiling which gives us visibility of function times and whole program as a whole and dumped to  `profiling_results/*.dat` and use 
`python3 -m snakeviz test_src_venv/profiling_results/<name_of_file.dat>` and a UI is displayed in your local browser

## How to use - Prod

* **DD lambda layer:** If you want to deploy new DD layer you need to change library dependencies and versions at `requirements.txt` and run `make lambda-layer-package`

* **DD lambda function:** If you want to deploy new DD function you need to change code in `src/datadog_apigw_metrics.py` and run `make lambda-function-package`

* **Deploy to non DG regions :** If you want to deploy any region , you can specify regions as discussed below and do 
`make env`

* **Clean :** will clean existing project temp files and folders
`make clean`

## Integation to TC - NonDG regions
* **Terraform workspaces**:
This project is deployed multi-region ( Regions which dont have DG ) , the tf state is maintained through workspaces with each region name as a new workspace name inside `terraform_deploy` folder.
    * **Prod**: Currently project is deployed to 4 regions , workspace to region mapping is as follows

        | Workspace name | Region |
        |------|-------------|
        | us-west-2 | us-west-2 | 
        | us-west-1    | us-west-1 |     
        | us-east-2 | us-east-2 | 
        | eu-north-1 | eu-north-1 |
  
        * If project needs to be deployed in another region ( Manually) , you need to add variable map in `variables_mandatory.tf` and region name in `terraform_execute.sh`
            ```
            # To execute plan on all regions
            terraform_execute.sh plan 

            # To execute apply on all regions
            terraform_execute.sh apply 
            ```