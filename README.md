# LAA Criminal Applications Datastore microservice

[![Ministry of Justice Repository Compliance Badge](https://github-community.service.justice.gov.uk/repository-standards/api/laa-criminal-applications-datastore/badge)](https://github-community.service.justice.gov.uk/repository-standards/laa-criminal-applications-datastore) 

## Getting Started

Clone the repository, and follow these steps in order.  
The instructions assume you have [Homebrew](https://brew.sh) installed in your machine, as well as use some ruby version manager, usually [rbenv](https://github.com/rbenv/rbenv). If not, please install all this first.

**1. Pre-requirements**

- `brew bundle`
- `gem install bundler`
- `bundle install`

**2. Configuration**

- Copy `.env.development` to `.env.development.local` and modify with suitable values for your local machine
- Copy `.env.test` to `.env.test.local` and modify with suitable values for your local machine

**Postgres database**

After you've defined your DB configuration in the `.env.{development,test}.local` files, run the following:

- `bin/rails db:prepare` (for the development database)
- `RAILS_ENV=test bin/rails db:prepare` (for the test database)

**SNS notifications and S3 buckets**

Technically not required to setup or have this running, but might be neccessary for some functionality.  
If interested, go ahead and expand this section.

<details>
<summary>Run LocalStack</summary>

The datastore, upon certain actions (like an application being submitted) will publish a notification event to an Amazon SNS topic.  
Subscribers can subscribe to this topic to receive these notifications. Subscribers can be SQS queues, or HTTP callback endpoints, etc.  
This SNS topic, along with any SQS queues, exist on cloud-deployed environments (i.e. kubernetes) but it is not practical and certainly
difficult to setup all this in your local machine.

There is also an S3 bucket for document uploads.

[LocalStack](https://localstack.cloud) is used instead, with Amazon AWS-compatible interface, to ease (fake) some of this.

NOTE: the easiest way to get this up and running locally is to run a LocalStack instance in a docker container.  
A docker-compose file is provided that allows that, and exposes the instance by default in port 4566.

To run the container and obtain more details: `docker-compose up localstack`

In order to disable the SNS events, do not declare or comment out the `EVENTS_SNS_TOPIC_ARN` variable.

</details>

**3. Run the app locally**

Once all the above is done, you should be able to run the application as follows:

`rails server`

It will use port 3003 by default or any other `PORT` defined in your `.env.development.local`.

### Pre-commit hooks

We use the Ministry of Justice [DevSecOps Hooks](https://github.com/ministryofjustice/devsecops-hooks) to scan our repository and stop us from committing hardcoded secrets and credentials. Refer to their repository for documentation on how to set up the pre-commit hooks locally.

With pre-commit hooks enabled, the following tools are run on each commit:
- GitLeaks (via [devsecops-hooks](https://github.com/ministryofjustice/devsecops-hooks))
- Rubocop

To bypass the hooks, use the `-n` or `--no-verify` option, e.g.
```shell
git commit -nam 'My commit'
```

## Running the tests

You can run all the code linters and tests with:

- `rake`

The tasks run by default when using `rake`, are defined in the `Rakefile`.

Or you can run them individually:

- `rake spec`
- `rake rubocop`
- `rake brakeman`

## Docker

The application can be run inside a docker container. This will take care of the ruby environment,  
and any other dependency for you, without having to configure anything in your machine.

- `docker-compose up`

The application will be run in "production" mode, so will be as accurate as possible to the real production environment.

**NOTE:** never use `docker-compose` for a real production environment. This is only provided to test a local container. The
actual docker images used in the cluster are built as part of the deploy pipeline.

## Current API endpoints

There is a basic RESTful API to store and retrieve JSON documents from the database.

All endpoints with its details can be listed (similar to rails routes) with the rake task `rake grape:routes`. This will
also show which consumers are authorised to call each of the endpoints.

At the moment these endpoints are:

- `POST /api/v1/applications` to create an application, passing the payload in the body as `application`.
- `POST /api/v1/searches` performs searches (refer to the class for params)
- `GET /api/v1/applications` list all applications (refer to the class for params)
- `GET /api/v1/applications/{id}` get an application by its ID
- `PUT /api/v1/applications/{id}/return` returns an application by its ID
- `PUT /api/v1/applications/{id}/complete` marks an application as complete
- `PUT /api/v1/applications/{id}/mark_as_ready` marks an application as ready for assessment
- `PUT /api/v1/applications/{id}/archive` archives an application
- `POST /api/v1/applications/draft_created` creates a DraftCreated event
- `POST /api/v1/applications/draft_deleted` creates a DraftDeleted event
- `GET /api/v1/health` checks connection to the database

Endpoints used by MAAT adapter:

- `GET /api/v1/maat/applications/{usn}` get an application by its USN
- `POST /api/v1/maat/applications/maat_record_created` creates a MaatRecordCreated event

