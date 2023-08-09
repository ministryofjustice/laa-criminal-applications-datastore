#!/bin/bash
#
# Execute commands when LocalStack shuts down, for example
# to save the state and be able to restore it later.
# You can use anything available inside the container.
# This file will be mounted through `docker-compose`.
#
# NOTE: for this to work, the container needs to shutdown
# gracefully with `docker-compose down localstack`
#
echo "Shutting down localstack..."
