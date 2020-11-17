import json
import boto3
import base64
import logging
import time
import os
from datadog import initialize, api

# Global variables
allRestApisInfo = {}
client = boto3.client('apigateway')
kms_client = boto3.client('kms')

# Initializing Logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def initializeDDKeys():

    # Initializing DD credentials
    ENCRYPTED_DATADOG_KEYS = os.environ['DATADOG_API_KEY']
    # Decrypt code should run once and variables stored outside of the function
    # handler so that these are decrypted once per container
    DECRYPTED_API_KEY = kms_client.decrypt(
        CiphertextBlob=base64.b64decode(ENCRYPTED_DATADOG_KEYS))['Plaintext']
    datadogKeysJson = json.loads(DECRYPTED_API_KEY)

    if ("api_key" in datadogKeysJson) and ("app_key" in datadogKeysJson):
        datadogApiKeys = {
            "api_key": datadogKeysJson["api_key"],
            "app_key": datadogKeysJson["app_key"]
        }
        initialize(**datadogApiKeys)
    else:
        raise Exception("No DD keys found: " + str(datadogKeysJson))


def sendDatatoDD(region):

    now = time.time()
    for apiId in allRestApisInfo:
        tagsList = []
        if 'throttlingBurstLimit' in allRestApisInfo[apiId] and 'throttlingRateLimit' in allRestApisInfo[apiId]:
            tagsList.append("apiname:"+allRestApisInfo[apiId]["apiName"])
            tagsList.append("apitype:"+allRestApisInfo[apiId]["apiType"])
            tagsList.append("region:"+region)
            resp = api.Metric.send([{
                'metric': 'aws.apigateway.throttlingBurstLimit',
                'interval': 60,
                'points': (now, allRestApisInfo[apiId]["throttlingBurstLimit"]),
                'tags':tagsList,
                'type':"rate"
            },
                {
                'metric': 'aws.apigateway.throttlingRateLimit',
                'interval': 60,
                'points': (now, allRestApisInfo[apiId]["throttlingRateLimit"]),
                'tags':tagsList,
                'type':"rate"}
            ])
            if resp["status"] == "ok":
                logger.info("Payload posted successfully")
            else:
                raise Exception(
                    "No proper response from API, Error: " + str(resp))


def getApiLimits(restApiId):
    response = client.get_stages(
        restApiId=restApiId
    )
    if response["ResponseMetadata"]["HTTPStatusCode"] == 200:
        resp = response["item"]
        for index in range(len(resp)):
            allRestApisInfo[restApiId]["stageName"] = resp[index]["stageName"]
            for key in resp[index]["methodSettings"]:
                allRestApisInfo[restApiId]["throttlingBurstLimit"] = resp[index]["methodSettings"][key]["throttlingBurstLimit"]
                allRestApisInfo[restApiId]["throttlingRateLimit"] = resp[index]["methodSettings"][key]["throttlingRateLimit"]
    else:
        raise Exception("No proper response from API, Error: " + str(response))


def getAllRestApis():
    response = client.get_rest_apis()
    if response["ResponseMetadata"]["HTTPStatusCode"] == 200:
        resp = response["items"]
        for index in range(len(resp)):
            if resp[index]["endpointConfiguration"]["types"][0] != "PRIVATE":
                restApiId = resp[index]["id"]
                allRestApisInfo[restApiId] = {
                    "apiName": resp[index]["name"], "apiType": resp[index]["endpointConfiguration"]["types"][0]}
                getApiLimits(restApiId)
            else:
                logger.info("Ignoring API as its type is PRIVATE:" +
                            str(resp[index]["name"]) + " .type is:" + str(resp[index]["endpointConfiguration"]["types"][0]))
    else:
        raise Exception("No proper response from API, Error: " + str(response))


def lambda_handler(event, context):
    logger.info('Event: ' + str(event))

    try:
        region = event['region']
        # Initialize DD credentials
        initializeDDKeys()

        # Calling main functions
        getAllRestApis()
        sendDatatoDD(region)

        return True
    except Exception as e:
        logger.error("Something went wrong: " + str(e))
        return False
