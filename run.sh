#!/bin/sh
cd /usr/src/app

bundle exec rake dynamo:create_tables
bundle exec pumactl -F config/puma.rb start
