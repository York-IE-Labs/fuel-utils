#!/bin/bash
#
# OVERVIEW:
#    Fetches and runs AWS-authored SageMaker Notebook auto-stop script
#    To be fetched and run as part of an AWS SageMaker Notebook Lifecycle Config Cloudformation Definition
#    Docs: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-sagemaker-notebookinstancelifecycleconfig.html
#
# USAGE:
#   SCRIPT:
#     autostop-fetcher -p $SCRIPT_PATH -n $SCRIPT_NAME
#     SCRIPT_PATH: url to github directory containing raw SCRIPT_NAME e.g. https://raw.githubusercontent.com/aws-samples/....
#     SCRIPT_NAME: filename of script e.g. on-start.sh
#   CLOUDFORMATION:
#       NotebookAutostopScript:
#         Type: AWS::SageMaker::NotebookInstanceLifecycleConfig
#         Properties:
#           OnStart:
#             - Content:
#                 Fn::Base64:
#                   !Sub "cd /home/ec2-user && wget ${FuelUtilsUrl}/autostop-fetcher.sh && ./autostop-fetcher.sh -p ${AwsScriptRepoUrl} -n ${ScriptName}"
#
while getopts p:n: flag
do
  case "${flag}" in
    p) script_path=${OPTARG};;
    n) script_name=${OPTARG};;
  esac
done

start_dir=$(realpath $(pwd))

wget "$script_path/$script_name" && chmod +x "$script_name" && ./"$script_name"
cd "$start_dir"