#!/bin/bash
set -m

bash /entrypoint.sh &
if [ $? -ne 0 ]; then
	echo "Container start failed, now exiting..."
	exit
fi

if [[ ! -a /populate.lock || "$FORCE_POPULATE_DB" = "yes" ]]; then
	bash /populate.sh
	touch /populate.lock
fi

fg
