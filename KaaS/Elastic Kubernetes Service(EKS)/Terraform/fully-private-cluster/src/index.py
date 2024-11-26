import os
import boto3
import json
import logging
from kubernetes import client, config
from botocore.exceptions import ClientError
import base64
import tempfile

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

# Set up a log format for better readability
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
ch = logging.StreamHandler()
ch.setFormatter(formatter)
logger.addHandler(ch)

def get_cluster_info(cluster_name):
    eks_client = boto3.client('eks')
    try:
        logger.debug(f"Attempting to describe EKS cluster: {cluster_name}")
        response = eks_client.describe_cluster(name=cluster_name)
        logger.info(f"Successfully described EKS cluster: {cluster_name}")
        logger.debug(f"Cluster info: {response['cluster']}")
        return response['cluster']
    except ClientError as e:
        logger.error(f"Failed to describe cluster '{cluster_name}': {e}")
        return None

def get_bearer_token(cluster_name):
    """
    Generates a token for authenticating against the Kubernetes API.
    """
    try:
        logger.debug(f"Generating bearer token for cluster: {cluster_name}")
        client = boto3.client('sts')
        service_id = 'eks.amazonaws.com'
        token = client.get_caller_identity()['Arn']
        logger.info("Successfully generated a bearer token for Kubernetes API.")
        logger.debug(f"Generated token: {token}")
        return token
    except ClientError as e:
        logger.error(f"Failed to generate bearer token for cluster '{cluster_name}': {e}")
        return None

def lambda_handler(event, context):
    cluster_name = os.environ.get('EKS_CLUSTER_NAME')
    if not cluster_name:
        logger.error("EKS_CLUSTER_NAME environment variable is not set.")
        return {
            'statusCode': 400,
            'body': json.dumps('EKS_CLUSTER_NAME environment variable is not set.')
        }
    logger.info(f"Received request for EKS cluster: {cluster_name}")

    # Describe the EKS cluster
    cluster_info = get_cluster_info(cluster_name)
    if not cluster_info:
        logger.error("Error getting EKS cluster info.")
        return {
            'statusCode': 500,
            'body': json.dumps('Error getting EKS cluster info.')
        }

    # Load Kubernetes API configuration using kubeconfig
    # TODO - Set up the kubeconfig manually using the cluster info and the bearer token
    kubeconfig_content = {
        "apiVersion": "v1",
        "kind": "Config",
        "clusters": [
            {
                "name": cluster_name,
                "cluster": {
                    "server": cluster_info["endpoint"],
                    "certificate-authority-data": cluster_info["certificateAuthority"]["data"]
                }
            }
        ],
        "contexts": [
            {
                "name": cluster_name,
                "context": {
                    "cluster": cluster_name,
                    "user": "lambda"
                }
            }
        ],
        "current-context": cluster_name,
        "users": [
            {
                "name": "lambda",
                "user": {
                    "token": get_bearer_token(cluster_name)
                }
            }
        ]
    }

    # Write kubeconfig to a temporary file
    try:
        with tempfile.NamedTemporaryFile(delete=False, mode='w') as temp_kubeconfig:
            kubeconfig_path = temp_kubeconfig.name
            json.dump(kubeconfig_content, temp_kubeconfig)
        
        # Load the Kubernetes config from the temporary file
        config.load_kube_config(config_file=kubeconfig_path)
        logger.info("Successfully loaded Kubernetes configuration from temporary kubeconfig file.")
    except config.ConfigException as e:
        logger.error(f"Failed to load Kubernetes configuration: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps('Error loading Kubernetes configuration.')
        }
    except Exception as e:
        logger.error(f"Unexpected error occurred while writing/loading kubeconfig: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps('Error interacting with kubeconfig.')
        }

    # Create API client
    logger.debug("Creating Kubernetes CoreV1Api client.")
    try:
        v1 = client.CoreV1Api()
        logger.info("Kubernetes CoreV1Api client created successfully.")
    except Exception as e:
        logger.error(f"Failed to create Kubernetes CoreV1Api client: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps('Error creating Kubernetes API client.')
        }

    # List nodes in the cluster
    try:
        logger.debug("Attempting to list nodes in the EKS cluster.")
        nodes = v1.list_node()
        logger.debug(f"Raw node data: {nodes}")
        node_names = [node.metadata.name for node in nodes.items]
        logger.info(f"Successfully retrieved nodes from EKS cluster: {node_names}")

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Successfully retrieved nodes from EKS cluster: {cluster_name}',
                'nodes': node_names
            })
        }
    except Exception as e:
        logger.error(f"An error occurred while accessing the Kubernetes API: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps('Error interacting with Kubernetes API.')
        }
