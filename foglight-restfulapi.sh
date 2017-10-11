#!/bin/sh

HEADER_CONTENT_TYPE="Content-Type: application/json"
HEADER_ACCEPT="Accept: application/json"
HOST="$1"
PORT="$2"
USERNAME="$3"
PASSWORD="$4"
PROTOCOL="http"
APIPATH="api/v1"
AUTHTOKEN="1234567890"

## do request utility
dorequest() {
	local host="$1"
	local port="$2"
	local suburl="$3"
	local authtoken="$4"
	local method="$5"
	local body="$6"

	local urlprefix="$PROTOCOL://$host:$port/$APIPATH"

	if [ "$method" == "POST" ] || [ "$method" == "GET" ]; then
		if [ $# -eq 6 ]; then
			http_response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -H "$HEADER_ACCEPT" -H "$HEADER_CONTENT_TYPE" -H "Auth-Token: $AUTHTOKEN" -d "@$body" -X $method "$urlprefix/$suburl")
		else
			http_response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -H "$HEADER_ACCEPT" -H "$HEADER_CONTENT_TYPE" -H "Auth-Token: $AUTHTOKEN" -X $method "$urlprefix/$suburl")
		fi
	else 
		echo "Request Failed: invalid method found (make sure you invoke POST/GET)"
		exit 1
	fi

	http_body=$(echo $http_response | sed -e 's/HTTPSTATUS\:.*//g')
	http_status=$(echo $http_response | tr -d '\h' | sed -e 's/.*HTTPSTATUS://')

	if [ $http_status -eq 200 ]; then
		local response_status=$(echo $http_body | ./jq '.status')
		if [ $response_status -eq 1 ]; then
			echo "Request Successfull: url $URLPREFIX/$suburl"
			echo "REST API ($URLPREFIX/$suburl): $http_body" >> foglight-restfulapi-output.log
		else
			echo "Request Failed: make sure you pass the correct parameters. (response status 0)"
			exit 1
		fi
	else
		echo "Request Failed: make sure you pass the correct parameters. (http status 200)"
		exit 1		
	fi
}

## login
login() {
	local host="$1"
	local port="$2"
	local username="$3"
	local password="$4"

	local urlprefix="$PROTOCOL://$host:$port/$APIPATH"

	local http_response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -H "$HEADER_ACCEPT" -H "Content-Type: application/x-www-form-urlencoded" -d "username=$USERNAME&pwd=$PASSWORD" -c cookies.txt -X POST "$urlprefix/security/login")
	local http_body=$(echo $http_response | sed -e 's/HTTPSTATUS\:.*//g')
	local http_status=$(echo $http_response | tr -d '\h' | sed -e 's/.*HTTPSTATUS://')

	if [ $http_status -eq 200 ]; then
		local response_status=$(echo $http_body | ./jq '.status')
		if [ $response_status -eq 1 ]; then
			echo "Login Success!"
			AUTHTOKEN=$(echo $http_body | ./jq '.data.token' | tr -d '"')
		else
			echo "Login Failed: please make sure the username/password is correct with sufficient privileges."
			exit 1
		fi
	else
		echo "Login Failed: make sure fms is running and the username/password is correct with sufficient privileges."
		exit 1		
	fi
}

###### sample section ######
## security login
login $HOST $PORT $USERNAME $PASSWORD

## type
dorequest $HOST $PORT type/Host $AUTHTOKEN GET

## current user
dorequest $HOST $PORT user/current $AUTHTOKEN GET

## alarm
dorequest $HOST $PORT alarm/current $AUTHTOKEN GET
#dorequest $HOST $PORT alarm/ack/cb6286ab-4980-40ec-a54d-0f18d4039e70 $AUTHTOKEN POST
dorequest $HOST $PORT alarm/current $AUTHTOKEN GET
dorequest $HOST $PORT alarm/history $AUTHTOKEN GET
#dorequest $HOST $PORT alarm/history/cb6286ab-4980-40ec-a54d-0f18d4039e70 $AUTHTOKEN GET

## topology
#dorequest $HOST $PORT topology/cb6286ab-4980-40ec-a54d-0f18d4039e70/memory/utilization $AUTHTOKEN GET
dorequest $HOST $PORT topology/query $AUTHTOKEN POST data-topology-query.json
dorequest $HOST $PORT type/Host/instances $AUTHTOKEN GET

## push alarm
dorequest $HOST $PORT alarm/pushAlarm $AUTHTOKEN POST data-push-alarm.json

## push data
#<!DOCTYPE types SYSTEM "../dtd/topology-types.dtd">
#<types>
#    <type name='PushDataTest1' extends='TopologyObject'>
#		<property name='name' type='String' is-identity='true'/>
#		<property name='testMetric' type='Metric' is-containment='true' unit-name='count' />
#		<property name='testObservations' type='TestObservation1' is-containment='true' unit-name='count' />
#	</type>	
#	<type name='TestObservation1' extends='ComplexObservation'>
#		<property name='current' type='TestObservationValue1' is-many='false' is-containment='true' />
#		<property name='latest' type='TestObservationValue1' is-many='false' is-containment='true' />
#		<property name='history' type='TestObservationValue1' is-many='true' is-containment='true' />
#	</type>	
#	<type name='TestObservationValue1' extends='ObservedValue'>
#		<property name='value' type='TestObject1' is-containment='true'/>
#	</type>	
#	<type name="TestObject1" extends="DataObject">
#		<property name='testName' type='String' />
#		<property name='createDate' type='Date' />
#		<property name='createTime' type='Double' />
#	</type>
#</types>
dorequest $HOST $PORT topology/pushData $AUTHTOKEN POST data-push-data.json