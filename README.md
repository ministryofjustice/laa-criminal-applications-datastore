# LAA Criminal Applications Datastore microservice

## Getting Started

Clone the repository, and follow these steps in order.  
The instructions assume you have [Homebrew](https://brew.sh) installed in your machine, as well as use some ruby version manager, usually [rbenv](https://github.com/rbenv/rbenv). If not, please install all this first.

**1. Pre-requirements**

* `brew bundle`
* `gem install bundler`
* `bundle install`

**2. Configuration**

* Copy `.env.development` to `.env.development.local` and modify with suitable values for your local machine
* Copy `.env.test` to `.env.test.local` and modify with suitable values for your local machine

NOTE: the easiest way to get up and running locally is to run a DynamoDB Local instance in a docker container.  
A docker-compose file is provided that allows that, and expose the instance by default in port 8000.  
Spin up this instance with `docker-compose up dynamodb-local` and then make sure your .env local files point to that endpoint.

Once you have the DynamoDB Local running, create the tables with:

* `rake dynamo:create_tables` (for the development dynamodb tables)
* `RAILS_ENV=test rake dynamo:create_tables` (for the test dynamodb tables)

**3. Run the app locally**

Once all the above is done, you should be able to run the application as follows:

`rails server`

It will use port 3003 by default or any other `PORT` defined in your `.env.development.local`.

## Running the tests

You can run all the code linters and tests with:

* `rake`

The tasks run by default when using `rake`, are defined in the `Rakefile`.

Or you can run them individually:

* `rake spec`
* `rake rubocop`
* `rake brakeman`

## Rake tasks

There are a few handful rake tasks for DynamoDB:

* `rake dynamoid:create_tables` - Will create tables from your models
* `rake dynamoid:drop_tables` - Will drop all existing tables
* `rake dynamoid:list_tables` - Will list all existing tables

## Docker

The application can be run inside a docker container. This will take care of the ruby environment, DynamoDB Local 
and any other dependency for you, without having to configure anything in your machine.

* `docker-compose up`

The application will be run in "production" mode, so will be as accurate as possible to the real production environment.

**NOTE:** never use `docker-compose` for a real production environment. This is only provided to test a local container. The
actual docker images used in the cluster are built as part of the deploy pipeline.

Additionally, to only run the DynamoDB Local, use:

* `docker-compose up dynamodb-local`

This is the recommended way for development as code changes are visible immediately.

## API (work in progress)

There is a basic RESTful API to store and retrieve documents from DynamoDB.  
The `Datastore::V1::Applications` grape class is quite self explanatory and declares what are the endpoints and their parameters (optional or required).

At the moment these endpoints are:

* `POST api/v1/applications` to create an application, passing the payload in the body as `application`.
* `GET api/v1/applications` list all applications (refer to the class for params)
* `GET api/v1/applications/{id}` get an application by its ID
* `PUT api/v1/applications/{id}` update an application by its ID (currently only `status` param)
