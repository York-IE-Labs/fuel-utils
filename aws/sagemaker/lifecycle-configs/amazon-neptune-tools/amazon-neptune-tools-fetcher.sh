#!/bin/bash
#
# OVERVIEW:
#    Installs AWS Labs Neptune Python Tools, GremlinPython packages via Git sparse checkout and pip3, respectively
#      Docs: https://github.com/awslabs/amazon-neptune-tools/tree/master/neptune-python-utils#readme
#      Docs: https://pypi.org/project/gremlinpython/
#    To be fetched and run as part of an AWS SageMaker Notebook Lifecycle Config Cloudformation Definition
#      Docs: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-sagemaker-notebookinstancelifecycleconfig.html
#
# USAGE:
#   SCRIPT:
#     amazon-neptune-tools-fetcher.sh -g $GITHUB_REPO_URL -s $REPOSITORY_SUBDIRECTORY -d LOCAL_DIRECTORY -e SAGEMAKER_NOTEBOOK_ENVIRONMENT
#     GITHUB_REPO_URL: url to AWS Labs Neptune Tools repo e.g. https://github.com/awslabs/amazon-neptune-tools.git
#     REPOSITORY_SUBDIRECTORY: name of subdirectory to checkout via git sparse checkout e.g. neptune-python-utils/
#     LOCAL_DIRECTORY: full path to notebook instance directory where library should be copied e.g. /home/ec2-user/anaconda3/envs/python3/lib/python3.8/site-packages
#     NOTEBOOK_ENVIRONMENT: name of Sagemaker notebook environment to which Python libraries should be installed e.g. python3
#   CLOUDFORMATION:
#       NotebookNeptuneUtilsScript:
#         Type: AWS::SageMaker::NotebookInstanceLifecycleConfig
#         Properties:
#           OnStart:
#             - Content:
#                 Fn::Base64:
#                   !Sub "cd /home/ec2-user && wget ${FuelUtilsUrl}/amazon-neptune-tools-fetcher.sh && ./amazon-neptune-tools-fetcher.sh -g ${AwsLabsRepoUrl} -s ${AwsLabsNeptuneToolsSubdirectory}  -d ${NeptuneToolsLocalDirectory} -e ${SagemakerEnvironment}
#

while getopts g:s:d:e: flag
do
  case "${flag}" in
    g) github_repo_url=${OPTARG};;
    s) repository_subdirectory=${OPTARG};;
    d) local_directory=${OPTARG};;
    e) notebook_environment=${OPTARG};;
  esac
done

start_dir=$(realpath $(pwd))

mkdir -p "$local_directory"
mkdir -p python/amazon-neptune-tools && cd $_
git remote add -f origin "$github_repo_url" && git config core.sparseCheckout true
echo "$repository_subdirectory" >> .git/info/sparse-checkout
git pull origin master

cp -r neptune-python-utils/neptune_python_utils "$local_directory"

source activate "$notebook_environment"
pip3 install gremlinpython

cd "$start_dir"