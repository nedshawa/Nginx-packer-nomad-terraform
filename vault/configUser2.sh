#!/bin/bash
export VAULT_ADDR='http://127.0.0.1:8200'
vault server -dev &
vault mount aws
#echo "AWS_ACCESS_KEY_ID: $1"
#ECHO "AWS_SECRET_ACCESS_KEY: $2"
echo "Enter your AWS Access Key ID"
read aws_key
echo "Enter your AWS Secret Accesst Key"
read aws_secret
echo "Enter AWS Region"
read region
vault write aws/config/root access_key=$aws_key secret_key=$aws_secret region=$region
vault write aws/roles/deploy policy=@policy.json
vault read aws/creds/deploy
