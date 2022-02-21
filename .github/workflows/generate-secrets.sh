#!/bin/bash

secrets=$(aws ssm describe-parameters --parameter-filters Key=Name,Option=BeginsWith,Values=$PARAM_PREFIX | jq -r '.Parameters[] | .Name')
backend_environments=$(aws amplify list-backend-environments --app-id $AMPLIFY_ID | jq -r .backendEnvironments[] | jq -r .environmentName)

secrets_list=(`echo $secrets | sed 's/" "/\n/g'`)
backend_environment_list=(`echo $backend_environments | sed 's/" "/\n/g'`)

for secret in "${secrets_list[@]}"
do
    secrets_value=$(aws ssm get-parameter --name $secret --with-decryption | jq -r '.Parameter | .Value')
    parameter_name=$(echo $secret | sed -e 's/\/.*\///g')

    for backend in "${backend_environment_list[@]}"
    do  
        aws ssm put-parameter --overwrite --name "/amplify/$AMPLIFY_ID/$backend/$parameter_name" --value "$secrets_value" --type "SecureString"
    done
done