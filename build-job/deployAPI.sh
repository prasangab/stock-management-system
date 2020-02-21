#!/bin/bash

#ENV_VAULT_ROLE_ID=${cloud_target_environment}_VAULT_ROLE_ID
#ENV_VAULT_SECRET_ID=${cloud_target_environment}_VAULT_SECRET_ID

#echo "Using: $ENV_VAULT_ROLE_ID"
#echo "Using: $ENV_VAULT_SECRET_ID"

#VAULT_ROLE_ID=484e9798-5997-c085-01c2-3b1d335647f1
#VAULT_SECRET_ID=23c5a538-3861-6dd8-c035-8d0fcd36ff2a

vaultToken=s.lSDCityrE7XXpZzop02CrMo5 #this should be pass from env varible
# login request
#echo ----------------- Logging in to Vault -----------------
#echo -e '\t'Using $VAULT_ROLE_ID $VAULT_SECRET_ID
#client_token=$(curl -X POST -d '{\"role_id\": \"484e9798-5997-c085-01c2-3b1d335647f1\", \"secret_id\": \"23c5a538-3861-6dd8-c035-8d0fcd36ff2a\"}' http://localhost:8200/v1/auth/approle/login | jq -r .auth.client_token)
#echo "------client_token : ${client_token} ---------"

echo "----------------- Querying Vault for WSO2 server addresses -----------------"

esb_host=$(curl -H "X-Vault-Token:${vaultToken}" http://127.0.0.1:8200/v1/secret/dev/esb.host | jq .data.value | sed 's/"//g')
echo "--------esb_host : ${esb_host}--------"
esb_port=$(curl -H "X-Vault-Token:${vaultToken}" http://127.0.0.1:8200/v1/secret/dev/esb.port | jq .data.value | sed 's/"//g')
target_api_hostname=$(curl -H "X-Vault-Token:${vaultToken}" http://127.0.0.1:8200/v1/secret/dev/api.hostname | jq .data.value | sed 's/"//g')
target_api_port=$(curl -H "X-Vault-Token:${vaultToken}" http://127.0.0.1:8200/v1/secret/dev/api.port | jq .data.value | sed 's/"//g')
target_api_username=$(curl -H "X-Vault-Token:${vaultToken}" http://127.0.0.1:8200/v1/secret/dev/api.username | jq .data.value | sed 's/"//g')
target_api_password=$(curl -H "X-Vault-Token:${vaultToken}" http://127.0.0.1:8200/v1/secret/dev/api.password | jq .data.value | sed 's/"//g')
apiPassword=$(curl -H "X-Vault-Token:${vaultToken}" http://127.0.0.1:8200/v1/secret/dev/api.password | jq .data.value | sed 's/"//g')

backend_url=$(curl -H "X-Vault-Token:${vaultToken}" http://127.0.0.1:8200/v1/secret/dev/backend.url | jq .data.value | sed 's/"//g')
security_username=$(curl -H "X-Vault-Token:${vaultToken}" http://127.0.0.1:8200/v1/secret/dev/backend.api.username | jq .data.value | sed 's/"//g')
security_password=$(curl -H "X-Vault-Token:${vaultToken}" http://127.0.0.1:8200/v1/secret/dev/backend.api.password | jq .data.value | sed 's/"//g')

eiHostPort="${esb_host}:${esb_port}"
echo "=======eiHostPort : ${eiHostPort}======="


sed -i "s/\"host\"\:\s*\".*\",/\"host\"\: \"${eiHostPort}\",/g" $fileName
sed -i "s/\"authorizationUrl\"\:\s*\".*\",/\"authorizationUrl\"\: \"http:\/\/${eiHostPort}\/authorize\",/g" $fileName

if [ -z "$esb_host" ] || [ -z "$esb_port" ] || [ -z "$target_api_hostname" ] || [ -z "$target_api_port" ] || [ -z "$target_api_username" ] || [ -z "$target_api_password" ]; then
    exit 1
fi

# This block is entered only if the $apiUsername variable has been set/passed from the apiBuild.xml Ant task
if [ -n "$apiUsername" ]
then
	# Login to the APIM Admin Service (AuthenticationAdmin) and get a SESSION token 
	echo -e "\n\nAdminService Login _________________________________________##########################________________________________________________\n\n"
	stdbuf -i0 -o0 -e0 curl -vs -k -X POST -c cookies https://${target_api_hostname}:${target_api_port}/services/AuthenticationAdmin.AuthenticationAdminHttpsSoap11Endpoint --header "SOAPAction: urn:login" --header "Content-Type: text/xml;charset=UTF-8" -d "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:aut=\"http://authentication.services.core.carbon.wso2.org\"><soapenv:Header/><soapenv:Body><aut:login><aut:username>${target_api_username}</aut:username><aut:password>${target_api_password}</aut:password><aut:remoteAddress>${target_api_hostname}</aut:remoteAddress></aut:login></soapenv:Body></soapenv:Envelope>" 2>&1
	sleep 2
	echo -e "\n\n";

	# Delete the API user in the Admin Service, if it already exists
	echo -e "\n\nAdminService Delete User____________________________________##########################________________________________________________\n\n"
	stdbuf -i0 -o0 -e0 curl -vs -k -X POST -b cookies https://${target_api_hostname}:${target_api_port}/services/UserAdmin.UserAdminHttpsSoap11Endpoint --header "SOAPAction: urn:deleteUser" --header "Content-Type: text/xml;charset=UTF-8" -d "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://org.apache.axis2/xsd\"><soapenv:Header/><soapenv:Body><xsd:deleteUser><xsd:userName>${apiUsername}</xsd:userName></xsd:deleteUser></soapenv:Body></soapenv:Envelope>" 2>&1
	sleep 2
	echo -e "\n\n";

	# Create the API user in the Admin Service (UserAdmin)
	echo -e "\n\nAdminService Create User____________________________________##########################________________________________________________\n\n"
	stdbuf -i0 -o0 -e0 curl -vs -k -X POST -b cookies https://${target_api_hostname}:${target_api_port}/services/UserAdmin.UserAdminHttpsSoap11Endpoint --header "SOAPAction: urn:addUser" --header "Content-Type: text/xml;charset=UTF-8" -d "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://org.apache.axis2/xsd\" xmlns:xsd1=\"http://common.mgt.user.carbon.wso2.org/xsd\"><soapenv:Header/><soapenv:Body><xsd:addUser><xsd:userName>${apiUsername}</xsd:userName><xsd:password>${apiPassword}</xsd:password><xsd:roles>${apiRole}</xsd:roles></xsd:addUser></soapenv:Body></soapenv:Envelope>" 2>&1
	sleep 2
	echo -e "\n\n";
fi

# Login to the API Manager (Store)
echo -e "\n\nStore Login ________________________________________________##########################________________________________________________\n\n"
for IND in {1..15}
do
    LOGIN=$(stdbuf -i0 -o0 -e0 curl -vs -k -X POST -c cookies https://${target_api_hostname}:${target_api_port}/store/site/blocks/user/login/ajax/login.jag -d "action=login&username=${target_api_username}&password=${target_api_password}") 2>&1
	sleep 2
    if [[ "${LOGIN}" =~ '{"error" : false}' ]]
    then
        echo "${LOGIN}";
        break;
    else
        echo "Login failed: ${LOGIN} ... sleeping for 120 seconds";
        sleep 120;
    fi
done;
echo -e "\n\n";

# List the Subscriptions to the API.
echo -e "\n\nList Subscriptions to API_____________________________________________##########################________________________________________________\n\n"

applications=$(stdbuf -i0 -o0 -e0 curl -k -G -vs -b cookies --data-urlencode action="getSubscriptionByAPI" --data-urlencode apiName="${apiName}" --data-urlencode apiVersion="${apiVersion}" --data-urlencode provider="${target_api_username}" "https://${target_api_hostname}:${target_api_port}/store/site/blocks/subscription/subscription-list/ajax/subscription-list.jag" | jq -r .applications[].application) 2>&1
sleep 2


for application in $applications; do
    # Delete Subscription for each applications for the API
    echo -e "\n\nUnsubscribe ${application} from API_____________________________________________##########################________________________\n\n"
    stdbuf -i0 -o0 -e0 curl -vs -k -X POST -b cookies https://${target_api_hostname}:${target_api_port}/store/site/blocks/subscription/subscription-remove/ajax/subscription-remove.jag -d "action=removeSubscription&name=${apiName}&version=${apiVersion}&provider=${target_api_username}&applicationName=${application}" 2>&1
	sleep 2
    echo -e "\n\n";
done

# Login to the API Manager (Publisher)
echo -e "\n\nPublisher Login ____________________________________________##########################________________________________________________\n\n"
stdbuf -i0 -o0 -e0 curl -vs -k -X POST -c cookies https://${target_api_hostname}:${target_api_port}/publisher/site/blocks/user/login/ajax/login.jag -d "action=login&username=${target_api_username}&password=${target_api_password}" 2>&1
sleep 2

# Delete the API, if it exists
echo -e "\n\nDelete API _________________________________________________##########################________________________________________________\n\n"
stdbuf -i0 -o0 -e0 curl -vs -k -X POST -b cookies https://${target_api_hostname}:${target_api_port}/publisher/site/blocks/item-add/ajax/remove.jag -d "action=removeAPI&name=${apiName}&context=/${apiName}&version=${apiVersion}&provider=${target_api_username}" 2>&1
sleep 2

# Create the API
echo -e "\n\nCreate API _________________________________________________##########################________________________________________________\n\n"
JSON_FILE=$(sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g' $fileName) ## Replace new lines with space characters
JSON_FILE=$(echo ${JSON_FILE} | sed 's/&/%26/g') # URL-encode all ampersand characters in the JSON payload
API_CONTEXT=$(echo ${eiBasePath} | sed "s/\/\([a-z0-9]\+\).[a-z0-9]$//ig") ## Remove everything from the last forward-slash to the end of the string
if [ -n "${securityType}" ]

then
    echo "=======apiName : ${apiName}=========="
    echo "=======backend_url2 : ${backend_url}======="
    echo "=======securityUsername2 : ${security_username}======="
    echo "=======securityPassword2 : ${security_password}======="

    ENDPOINT_TYPE_DEF="secured&endpointAuthType=${securityType}&epUsername=${security_username}&epPassword=${security_password}"
    stdbuf -i0 -o0 -e0 curl -vs -k -X POST -b cookies -d "action=addAPI&name=${apiName}&context=${API_CONTEXT}&version=${apiVersion}&visibility=public&thumbUrl=&description=&tags=&endpointType=${ENDPOINT_TYPE_DEF}&tiersCollection=Unlimited&default_version_checked=default_version&http_checked=http&https_checked=https" -d 'endpoint_config={"sandbox_endpoints":{"url":"http://'${eiHostPort}/${endpoint}'","config":null},"production_endpoints":{"url":"'${backend_url}/'","config":null},"endpoint_type":"http"}' -d "swagger=${JSON_FILE}" https://${target_api_hostname}:${target_api_port}/publisher/site/blocks/item-add/ajax/add.jag 2>&1
    sleep 2
    echo -e "\n\n";
else
    echo "=======apiName : ${apiName}=========="
    ENDPOINT_TYPE_DEF="nonsecured"
    stdbuf -i0 -o0 -e0 curl -vs -k -X POST -b cookies -d "action=addAPI&name=${apiName}&context=${API_CONTEXT}&version=${apiVersion}&visibility=public&thumbUrl=&description=&tags=&endpointType=${ENDPOINT_TYPE_DEF}&tiersCollection=Unlimited&default_version_checked=default_version&http_checked=http&https_checked=https" -d 'endpoint_config={"sandbox_endpoints":{"url":"http://'${eiHostPort}/${endpoint}'","config":null},"production_endpoints":{"url":"http://'${eiHostPort}/${endpoint}'","config":null},"endpoint_type":"http"}' -d "swagger=${JSON_FILE}" https://${target_api_hostname}:${target_api_port}/publisher/site/blocks/item-add/ajax/add.jag 2>&1
    sleep 2
    echo -e "\n\n";
fi
echo "=======ENDPOINT_TYPE_DEF : ${ENDPOINT_TYPE_DEF}======="




# Set the API state to PUBLISHED
echo -e "\n\nPublish API ________________________________________________##########################________________________________________________\n\n"
stdbuf -i0 -o0 -e0 curl -vs -k -X POST -b cookies "https://${target_api_hostname}:${target_api_port}/publisher/site/blocks/life-cycles/ajax/life-cycles.jag" -d "action=updateStatus&name=${apiName}&version=${apiVersion}&provider=${target_api_username}&status=PUBLISHED&publishToGateway=true&requireResubscription=false" 2>&1
sleep 2
echo -e "\n\n";

# Login to the API Manager (Store)
echo -e "\n\nStore Login ________________________________________________##########################________________________________________________\n\n"
stdbuf -i0 -o0 -e0 curl -vs -k -X POST -c cookies https://${target_api_hostname}:${target_api_port}/store/site/blocks/user/login/ajax/login.jag -d "action=login&username=${target_api_username}&password=${target_api_password}" 2>&1
sleep 2
echo -e "\n\n";

# Add the DefaultApplication if it doesnt exist.
#if ! grep -q  DefaultApplication <<<"$applications"; then
#    applications="$applications DefaultApplication"
#fi

for application in $applications; do
    # Create a Subscription for each applications for the API
    echo -e "\n\nSubscribe ${application} API ______________________________________________##########################______________________________\n\n"
    stdbuf -i0 -o0 -e0 curl -vs -k -X POST -b cookies https://${target_api_hostname}:${target_api_port}/store/site/blocks/subscription/subscription-add/ajax/subscription-add.jag -d "action=addAPISubscription&name=${apiName}&version=${apiVersion}&provider=${target_api_username}&tier=Unlimited&applicationName=${application}" 2>&1
	sleep 2
    echo -e "\n\n";
done

# Generate Application Keys for the test Application
#for application in $applications; do
 #   echo -e "\n\nGenKey API _________________________________________________##########################________________________________________________\n\n"
  #  APP_RSP=$(stdbuf -i0 -o0 -e0 curl -vs -k -X POST -b cookies https://${target_api_hostname}:${target_api_port}/store/site/blocks/subscription/subscription-add/ajax/subscription-add.jag -d "action=generateApplicationKey&application=DefaultApplication&keytype=PRODUCTION&callbackUrl=&authorizedDomains=ALL&validityTime=-1" --header "Accept: application/json" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8") 2>&1
  #  sleep 2
  #  echo -e "\n\nAPIM Response: ${APP_RSP}\n\n";
#done

rm cookies || true
