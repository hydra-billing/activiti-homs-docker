#!/bin/bash
# This script checks whether the required user, group and deployments already exist.
# If yes, the population commands will be skipped.
set -x

# Firstly, we check whether REST engine has started by sending GET requests to localhost and waiting for response code 200
until [ "$test_command" = "200" ]; do
	sleep 3
	test_command=$(curl -u  kermit:kermit -w "%{http_code}" -s -o /dev/null http://localhost:8080/activiti-rest/service/management/properties)
done

cd /assets

user_check=$(curl -s -u kermit:kermit http://localhost:8080/activiti-rest/service/identity/users/user | grep -o "Not found")
group_check=$(curl -s -u kermit:kermit http://localhost:8080/activiti-rest/service/identity/groups/users | grep -o "Not found")
membership_check=$(curl -s -u kermit:kermit http://localhost:8080/activiti-rest/service/identity/users?memberOfGroup=users | grep -o '"id":"user"')
deployment_check=$(curl -s -u kermit:kermit http://localhost:8080/activiti-rest/service/repository/deployments)

if [ -n "$user_check" ]; then
	curl -u kermit:kermit -H "Content-Type: application/json" --data-ascii @add_user.json --url http://localhost:8080/activiti-rest/service/identity/users
fi
if [ -n "$group_check" ]; then
	curl -u kermit:kermit -H "Content-Type: application/json" --data-ascii @add_group.json --url http://localhost:8080/activiti-rest/service/identity/groups
fi
if [ -z "$membership_check" ]; then
	curl -u kermit:kermit -H "Content-Type: application/json" --data-ascii @add_user_to_group.json --url http://localhost:8080/activiti-rest/service/identity/groups/users/members
fi

cd /opt/activiti-homs-demo

find . -name "*.bpmn" -type f -exec sed -i -e "s/localhost/$HOMS_HOST/" '{}' \; \
&& ls -d */ | xargs -I{} sh -c 'd=${1%/}; zip -j $d.zip $d/*.bpmn $d/*.yml' -- {}

if [ ! $(echo $deployment_check | grep "pizza-order.zip") ]; then
	curl -u kermit:kermit -F file=@pizza-order.zip --url http://localhost:8080/activiti-rest/service/repository/deployments
fi
if [ ! $(echo $deployment_check | grep "support-request.zip") ]; then
	curl -u kermit:kermit -F file=@support-request.zip --url http://localhost:8080/activiti-rest/service/repository/deployments
fi
if [ ! $(echo $deployment_check | grep "vacation-request.zip") ]; then
	curl -u kermit:kermit -F file=@vacation-request.zip --url http://localhost:8080/activiti-rest/service/repository/deployments
fi

exit 0
