# RailsWalkThrough

Walking through building a Rails app from scratch.

This walkthrough runs through setting up a new Rails app, using Docker and docker-compose, applying bootstrap themes, setting up deployment to Heroku, and then building a timecard app.

## Setting up the dependencies.
We're going to be using Docker and docker-compose to run our development environment. This makes it _much_ easier to make sure that what runs on my machine also runs on yours. And that we can manage our development, test and production environments.

So, [install Docker](https://docs.docker.com/v17.09/engine/installation/#server) on your development machine first, and then [setup docker compose](https://docs.docker.com/compose/install/).

You will also need curl or wget to get started.

## Building our development environment
It's worth reading up on Docker and docker-compose separately - but for the purpose of this exercise, I will use the [Evil Martians to Docker work](https://evilmartians.com/chronicles/ruby-on-whales-docker-for-ruby-rails-development).

We'll start by creating a directory for our work:
```
mkdir RailsWalkthrough
`cd RailsWalkthrough
```

As the files we need are embedded in another Github repository, and we don't intend to contribute back to them, we'll simply get them via cURL:

```bash
curl https://raw.githubusercontent.com/evilmartians/terraforming-rails/master/examples/dockerdev/docker-compose.yml -o docker-compose.yml
mkdir .dockerdev
cd .dockerdev/
curl https://raw.githubusercontent.com/evilmartians/terraforming-rails/master/examples/dockerdev/.dockerdev/Dockerfile -o Dockerfile
curl https://raw.githubusercontent.com/evilmartians/terraforming-rails/master/examples/dockerdev/.dockerdev/Aptfile -o Aptfile
```

OK, so now we have everything we need to build the Docker images for development. Next, we may as well open our folder in the code editor of choice - I'm going to be using VS Code - and edit the docker-compose.yml file.
Look for the line `image: example-dev:1.0.0` and edit it to a name you're happy with - I'm going to use `rails-walkthrough:0.0.1`.

Once you've done that, you can start the runner:
```shell
docker-compose run --rm runner
```
This will build the Docker images, and open a shell onto the main machine. 
Next, install rails:
```
gem install rails
```
