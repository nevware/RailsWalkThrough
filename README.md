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
Now we have a functioning rails environment, so we'll tell rails to build a new application:
``` bash
rails new . -d postgresql
```
This should create a new rails application in the current directory; if you have your IDE opened on the directory, you'll see lots of new files and folders turn up.

Next, we need to change the database configuration to point at the postgres container in our docker environment.
Open `config/database.yml`, and add
``` yaml
host: postgres
user: postgres
``` 
to the development and test entries.

You can now set up the rails databases:
``` bash
rails db:create
rails db:migrate
```
At this point, you've installed Rails, created an empty project, and initialized the database.

Final step is to open a new terminal window, and run 
``` bash 
docker-compose up rails
```
This will start the Rails webserver; you can [visit the homepage](http://localhost:3000) to verify.

You can check this all out at [todo]()

### Let's make it pretty with Bootstrap

The "out of the box" Rails scaffolding is a bit...ugly. Let's use Bootstrap to make it look more professional.

There's a [nice integration for Bootstrap and Rails](https://github.com/seyhunak/twitter-bootstrap-rails) which does most of the work for you. 

We'll start by creating a homepage:
```
rails g controller page index --skip-stylesheets --skip-javascripts
```
and telling Rails to use this as the homepage by modifying `config/routes.rb` to add the following line:
```
root to: 'page#index'
```

Next, we add the required gems to `Gemfile`

``` Ruby
# Bootstrap and dependencies
gem "therubyracer"
gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem "twitter-bootstrap-rails"
#required by bootstrap:
gem 'jquery-rails'
```
Now we run `bundle install` to install everything. 

Next, we tell bootstrap-rails to install itself, and to install all the static assets:
```
rails generate bootstrap:install less
 rails g bootstrap:install static
```

Now, the bootstrap default template includes a bunch of favicon references, which aren't installed by the "static" method, and modern versions of Rails will complain if you refer to missing files. 
So, either create the required icon files, or remove those references from the `/app/views/layout/application.html.erb` template file.

Re-start rails, and we get a new homepage - it should look a little like this:
![screenshot of bootstrap](/walkthrough_assets/bootstrap-basic.png "Bootstrap without much else")

