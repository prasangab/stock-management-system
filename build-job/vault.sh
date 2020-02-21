#!/bin/bash

# Usage: vault.sh <target environment> <role id> <secret id>

TARGET_ENV=$1
ENV_VAULT_ROLE_ID=myroot
ENV_VAULT_SECRET_ID=CPEZHu+Vqg6j6SWLHGzI6s56j2+NPioSz2L8vAPMVP4=

echo "Using: $ENV_VAULT_ROLE_ID"
echo "Using: $ENV_VAULT_SECRET_ID"

VAULT_ROLE_ID=${!ENV_VAULT_ROLE_ID}
VAULT_SECRET_ID=${!ENV_VAULT_SECRET_ID}

URL_PATH=$(echo $TARGET_ENV| cut -d'_' -f 2 | tr '[:upper:]' '[:lower:]')

# login request
echo ----------------- Logging in to Vault -----------------
echo -e '\t'Using $VAULT_ROLE_ID $VAULT_SECRET_ID
#client_token=$(curl -s -d '{"role_id": "$2", "secret_id": "$3"}' https://0.0.0.0:8200/v1/auth/approle/login | jq -r .auth.client_token)
client_token=$(curl -s -d "{\"role_id\": \"$VAULT_ROLE_ID\", \"secret_id\": \"$VAULT_SECRET_ID\"}" https://localhost:8200/v1/auth/approle/login | jq -r .auth.client_token)

email_addresses="
	email.to
	email.cc
	email.bcc
"

echo ----------------- Querying Vault for email addresses -----------------
for secret in $email_addresses
do
	value=$(curl -s -H "X-Vault-Token: ${client_token}" https://0.0.0.0:8200/v1/secret/$URL_PATH/${secret} | jq -r .data.value | sed 's/\//\\\//g')
	if [[ "$value" != "null" ]]; then
		echo -e '\t'Setting $secret
		sed -i "s/<${secret}>.*<\/${secret}>/<${secret}>${value}<\/${secret}>/g" pom.xml
	else
		echo -e '\t'No value found for $secret
                exit 1
	fi
done

server_addresses="
	esb.host
	esb.port
	dss.host
	dss.port
"

echo ----------------- Querying Vault for WSO2 server addresses -----------------
for secret in $server_addresses
do
	value=$(curl -s -H "X-Vault-Token: ${client_token}" https://0.0.0.0:8200/v1/secret/$URL_PATH/${secret} | jq -r .data.value | sed 's/\//\\\//g')
	if [[ "$value" != "null" ]]; then
		echo -e '\t'Setting $secret
		sed -i "s/<${secret}>.*<\/${secret}>/<${secret}>${value}<\/${secret}>/g" pom.xml
	else
		echo -e '\t'No value found for $secret
                exit 1
	fi
done

db_secrets="
	sits.data.driver
	sits.data.url
	sits.data.user
	sits.data.password
	ihtx.data.driver
	ihtx.data.url
	ihtx.data.user
	ihtx.data.password
	hrtf.data.driver
	hrtf.data.url
	hrtf.data.user
	hrtf.data.password
	ims.data.driver
	ims.data.url
	ims.data.user
	ims.data.password
	pac.data.driver
	pac.data.url
	pac.data.user
	pac.data.password
	roomservice.data.driver
	roomservice.data.url
	roomservice.data.user
	roomservice.data.password
	leo.csv.data.datasource
	leo.csv.data.separator
	leo.csv.data.startrow
	leo.csv.data.header
	leo.csv.data.headerrow
	t1.csv.data.datasource
	t1.csv.data.separator
	t1.csv.data.startrow
	t1.csv.data.header
	t1.csv.data.maxrow
	visa.data.driver
	visa.data.url
	visa.data.user
	visa.data.password
"

echo ----------------- Querying Vault for db secrets -----------------
for secret in $db_secrets
do
	value=$(curl -s -H "X-Vault-Token: ${client_token}" https://0.0.0.0:8200/v1/secret/$URL_PATH/${secret} | jq -r .data.value | sed 's/\//\\\//g')
	if [[ "$value" != "null" ]]; then
		echo -e '\t'Setting $secret
		sed -i "s/<${secret}>.*<\/${secret}>/<${secret}>${value}<\/${secret}>/g" pom.xml
	else
		echo -e '\t'No value found for $secret
                exit 1
	fi
done

uri_variables="
	ftp.wso2.url
	symphony.url
	sympletic.url
	sits.url
    sits.wsdl.url
	planon.url	
"

echo ----------------- Querying Vault for uri variables -----------------
for secret in $uri_variables
do
	value=$(curl -s -H "X-Vault-Token: ${client_token}" https://0.0.0.0:8200/v1/secret/$URL_PATH/${secret} | jq -r .data.value | sed 's/\//\\\//g')
	if [[ "$value" != "null" ]]; then
		echo -e '\t'Setting $secret
		sed -i "s/<${secret}>.*<\/${secret}>/<${secret}>${value}<\/${secret}>/g" pom.xml
	else
		echo -e '\t'No value found for $secret
                exit 1
	fi
done

oauth_variables="
	azure.oauth2.endpoint
	azure.api.version
	azure.clientId
	azure.clientSecret
	azure.url
	azure.username
	azure.password
"

echo ----------------- Querying Vault for azure oauth secrets -----------------
for secret in $oauth_variables
do
	value=$(curl -s -H "X-Vault-Token: ${client_token}" https://0.0.0.0:8200/v1/secret/$URL_PATH/${secret} | jq -r .data.value | sed 's/\//\\\//g')
	if [[ "$value" != "null" ]]; then
		echo -e '\t'Setting $secret
		sed -i "s/<${secret}>.*<\/${secret}>/<${secret}>${value}<\/${secret}>/g" pom.xml
	else
		echo -e '\t'No value found for $secret
                exit 1
	fi
done

login_variables="
	t1.user
	t1.password
	f1.user
	f1.password
	idm.user
	idm.password
	sits.user
	sits.password
	planon.user
	planon.password
"

echo ----------------- Querying Vault for login secrets -----------------
for secret in $login_variables
do
	value=$(curl -s -H "X-Vault-Token: ${client_token}" https://0.0.0.0:8200/v1/secret/$URL_PATH/${secret} | jq -r .data.value | sed 's/\//\\\//g')
	if [[ "$value" != "null" ]]; then
		echo -e '\t'Setting $secret
		sed -i "s/<${secret}>.*<\/${secret}>/<${secret}>${value}<\/${secret}>/g" pom.xml
	else
		echo -e '\t'No value found for $secret
                exit 1
	fi
done

t1_endpoints="
	t1.url
	t1.config
	t1.env
"

echo ----------------- Querying Vault for t1 endpoints -----------------
for secret in $t1_endpoints
do
	value=$(curl -s -H "X-Vault-Token: ${client_token}" https://0.0.0.0:8200/v1/secret/$URL_PATH/${secret} | jq -r .data.value | sed 's/\//\\\//g')
	if [[ "$value" != "null" ]]; then
		echo -e '\t'Setting $secret
		sed -i "s/<${secret}>.*<\/${secret}>/<${secret}>${value}<\/${secret}>/g" pom.xml
	else
		echo -e '\t'No value found for $secret
                exit 1
	fi
done
