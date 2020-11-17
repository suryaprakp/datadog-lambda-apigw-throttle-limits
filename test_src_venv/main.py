import logging
import time
import os
import datetime
import cProfile
import pstats
from pathlib import Path
import boto3
from datadog import initialize, api

# Initializing Logging
logger = logging.getLogger()


def getRandomFileName(fileName):
    suffix = datetime.datetime.now().strftime("%y%m%d_%H%M%S")
    # e.g. 'mylogfile_120508_171442'
    desiredFileName = "_".join([fileName, suffix])
    return desiredFileName


def initializeLogging():

    logFilePath = str(Path(__file__).parent.absolute()) + \
        getRandomFileName("datadog_apigw_metrics_logging")
    logging.basicConfig(
        filename=logFilePath,
        level=logging.INFO,
        format='%(asctime)s.%(msecs)03d %(levelname)s %(module)s - %(funcName)s: %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S',
    )

# Initializing DD credentials


def initializeDDCredentials():
    logger.info("Initializing create Tags for DataDog!")
    if "DATADOG_API_KEY" in os.environ:
        api_key = os.environ['DATADOG_API_KEY']
    else:
        raise Exception("Cant find API key , exiting !")
    if "DATADOG_APP_KEY" in os.environ:
        app_key = os.environ['DATADOG_APP_KEY']
    else:
        raise Exception("Cant find API key , exiting !")

    datadogApiKeys = {
        'api_key': api_key,
        'app_key': app_key
    }
    initialize(**datadogApiKeys)


def sendDatatoDD():

    now = time.time()
    # future_10s = now + 10
    for apiId in allRestApisInfo:
        tagsList = []
        if 'throttlingBurstLimit' in allRestApisInfo[apiId] and 'throttlingRateLimit' in allRestApisInfo[apiId]:
            tagsList.append("id:"+allRestApisInfo[apiId]["id"])
            tagsList.append("apiname:"+allRestApisInfo[apiId]["apiName"])
            tagsList.append("apitype:"+allRestApisInfo[apiId]["apiType"])
            tagsList.append("stagename:"+allRestApisInfo[apiId]["stageName"])
            resp = api.Metric.send([{
                'metric': 'aws.apigateway.throttlingBurstLimit',
                'points': (now, allRestApisInfo[apiId]["throttlingBurstLimit"]),
                'interval': 60,
                'tags':tagsList,
                'type':"rate"}, {
                'metric': 'aws.apigateway.throttlingRateLimit',
                'points': (now, allRestApisInfo[apiId]["throttlingRateLimit"]),
                'interval': 60,
                'tags':tagsList,
                'type':"rate"}])
            if resp["status"] == "ok":
                logger.info("Payload posted successfully")
            else:
                raise Exception(
                    "No proper response from API, Error: " + str(resp))
            # Things to decide - ops/second , description of metrics and how to add automation

# For future usecase


def cleanLogFilesIfexist(LOG_FILE_PATH):
    if os.path.isfile(LOG_FILE_PATH) and os.stat(LOG_FILE_PATH).st_size != 0:
        os.remove(LOG_FILE_PATH)


def getAllRestApis():
    response = client.get_rest_apis()
    if response["ResponseMetadata"]["HTTPStatusCode"] == 200:
        resp = response["items"]
        for index in range(len(resp)):
            if resp[index]["endpointConfiguration"]["types"][0] != "PRIVATE":
                restApiId = resp[index]["id"]
                allRestApisInfo[restApiId] = {
                    "id": restApiId, "apiName": resp[index]["name"], "apiType": resp[index]["endpointConfiguration"]["types"][0]}
                getApiLimits(restApiId)
    else:
        raise Exception("No proper response from API, Error: " + str(response))


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


def main():

    try:
        # Intialize Logging
        initializeLogging()
        # check if we have DD credentials , otherwise exit
        initializeDDCredentials()
        logger.info("Started process !")
        # profiler.enable()
        getAllRestApis()
        sendDatatoDD()
        # profiler.disable()

        logger.info("ended!!!")
    except Exception as e:
        logger.error("Something went wrong:" + str(e))


if __name__ == '__main__':
    start_time = time.time()
    # Global variables
    allRestApisInfo = {}
    client = boto3.client(
        'apigateway', region_name="eu-central-1")
    profiler = cProfile.Profile()
    # profiler.enable()
    main()
    # profiler.disable()
    #stats = pstats.Stats(profiler)
    # stats.dump_stats(str(Path(__file__).parent.absolute()) +
    #  getRandomFileName("stats_profiling_dd_metrics.dat"))
    # stats.print_stats()
    print("--- %s seconds ---" % (time.time() - start_time))
