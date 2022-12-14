#!/bin/sh
cd /usr/src/app

bundle exec rake dynamo:create_tables
bundle exec rake dynamo:setup_indexes

bundle exec bin/rails db:prepare

bundle exec pumactl -F config/puma.rb start
