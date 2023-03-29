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

**Postgres database**

After you've defined your DB configuration in the `.env.{development,test}.local` files, run the following:

* `bin/rails db:prepare` (for the development database)
* `RAILS_ENV=test bin/rails db:prepare` (for the test database)

**ElasticMQ and SNS notifications**

Technically not required to setup or have this running, but might be neccessary for some functionality.  
If interested, go ahead and expand this section.  

<details>
<summary>Run ElasticMQ and SNS faker</summary>

The datastore, upon certain actions (like an application being submitted) will publish a notification event to an Amazon SNS topic.  
Subscribers can subscribe to this topic to receive these notifications. Subscribers can be SQS queues, or HTTP callback endpoints, etc.  
This SNS topic, along with any SQS queues, exist on cloud-deployed environments (i.e. kubernetes) but it is not practical and certainly 
difficult to setup all this in your local machine.

[ElasticMQ](https://github.com/softwaremill/elasticmq) is used instead, as an in-memory message queue with an 
Amazon SQS-compatible interface, to ease (fake) some of this.

NOTE: the easiest way to get this up and running locally is to run an ElasticMQ instance in a docker container.  
A docker-compose file is provided that allows that, and exposes the instance by default in port 9324 (and port 9325 for 
the queues inspector).  

Some additional configuration is needed and also some kind of SNS faker or forwarder running locally, 
for example [this one here](https://github.com/janza/sns-sqs-forwarder).  
For more details, is best you ask a team colleague to help you set all this up and explain more in detail.
</details>

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

## Docker

The application can be run inside a docker container. This will take care of the ruby environment,  
and any other dependency for you, without having to configure anything in your machine.

* `docker-compose up`

The application will be run in "production" mode, so will be as accurate as possible to the real production environment.

**NOTE:** never use `docker-compose` for a real production environment. This is only provided to test a local container. The
actual docker images used in the cluster are built as part of the deploy pipeline.

## API (work in progress)

There is a basic RESTful API to store and retrieve documents from the database.  
The `Datastore::V2::Applications` grape class is quite self explanatory and declares what are the endpoints and their parameters (optional or required).

At the moment these endpoints are:

* `POST /api/v2/applications` to create an application, passing the payload in the body as `application`.
* `POST /api/v2/searches` performs searches (refer to the class for params)
* `GET /api/v2/applications` list all applications (refer to the class for params)
* `GET /api/v2/applications/{id}` get an application by its ID
* `PUT /api/v2/applications/{id}/return` returns an application by its ID
* `PUT /api/v2/applications/{id}/complete` marks an application as complete
* `PUT /api/v2/applications/{id}/mark_as_ready` marks an application as ready for assessment
* `GET /api/v2/health` checks connection to the database
