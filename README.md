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
So, either create the required icon files, and put them in the `app/assets/images` folder or remove those references from the `/app/views/layout/application.html.erb` template file.

Re-start rails, and we get a new homepage - it should look a little like this:
![screenshot of bootstrap](/walkthrough_assets/bootstrap-basic.png "Bootstrap without much else")

### Let's add some business logic
The application we're building will be a simple timecard system. 

The major user stories will be:

> As an administrator, I want to create, modify and delete clients so we can record time against clients and their projects.

> As an administrator, I want to create, modify and delete projects for clients, so we can record time against projects

> As an administrator, I want to assign consultants to a project, so they can book time.

> As a consultant, I want to book time against a project so we can track our effort

> As an administrator, I want to see all time booked against a client so I can see how much effort we've spent

So, let's generate the basic business entities here.

```
 rails g scaffold client name:string status:integer 
 rails g scaffold project name:string status:integer client:belongs_to
 rails g scaffold person name:string role:integer
 rails g scaffold assignment start_date:datetime end_date:datetime person:belongs_to project:belongs_to assignment:belongs_to status:integer
 rails g scaffold timesheet amount:float unit:integer assignment:belongs_to status:integer start_date:datetime end_date:datetime 
```

Get Rails to build the database tables:
```
rails db:migrate
```

 We can now visit our pages to see they all work:
  - The [People page](http://localhost:3000/people)
  - The [Clients page](http://localhost:3000/clients)
  - The [Projects page](http://localhost:3000/projects)
  - The [Assignments page](http://localhost:3000/assignments)
  - The [Timesheets page](http://localhost:3000/timesheets)

## Tests, debugging, and associations.
OK, now we have a working-ish application - it's time to run some unit tests, and make sure our application makes sense. Test-driven development is a good habit to get into. By default, when we create scaffolds in Rails, it generates tests as well. These tests are a good starting point - we will extend them later.

So, we'll start by running `rails test` The output will be something like 
``` shell
Finished in 10.348549s, 3.5754 runs/s, 3.6720 assertions/s.
37 runs, 38 assertions, 0 failures, 5 errors, 0 skips
```

Where are those errors coming from? 

``` shell
Error:
ProjectsControllerTest#test_should_destroy_project:
DRb::DRbRemoteError: PG::ForeignKeyViolation: ERROR:  update or delete on table "projects" violates foreign key constraint "fk_rails_4d3d2c839c" on table "assignments"
DETAIL:  Key (id)=(980190962) is still referenced from table "assignments".
 (ActiveRecord::InvalidForeignKey)
    app/controllers/projects_controller.rb:57:in `destroy'
    test/controllers/projects_controller_test.rb:43:in `block (2 levels) in <class:ProjectsControllerTest>'
    test/controllers/projects_controller_test.rb:42:in `block in <class:ProjectsControllerTest>'
```

This error is caused by the test case trying to delete a Project record, when that project is still referred to by some assignments. In our business domain, we don't really want to be able to delete data like "client" or "project" when there are associated child records - we would end up with "orphaned" records, or delete valuable business information.
Luckily, Rails allows us to specify the behaviour we want to see. You can [explicitly define the associations between entities](https://guides.rubyonrails.org/association_basics.html), and the behaviour you want when trying to delete "parent" records. 

So, we will mark-up our model classes to reflect what we want to see.
Make the following changes to your models:

``` ruby
class Assignment < ApplicationRecord
  belongs_to :person
  belongs_to :project
  has_many :timesheets, dependent: :restrict_with_exception
end
```

```ruby
class Person < ApplicationRecord
  has_many :assignments, dependent: :restrict_with_exception
end
```
```ruby 
class Project < ApplicationRecord
  belongs_to :client
  has_many :assignments, dependent: :restrict_with_exception
end
```

``` ruby
class Client < ApplicationRecord
  has_many :projects, dependent: :restrict_with_exception
end
```
We can now re-run our `rails test` - we still see that there are errors, but they are no longer database errors - we've got application exceptions:

``` rails
Error:
AssignmentsControllerTest#test_should_destroy_assignment:
ActiveRecord::DeleteRestrictionError: Cannot delete record because of dependent timesheets
    app/controllers/assignments_controller.rb:57:in `destroy'
    test/controllers/assignments_controller_test.rb:43:in `block (2 levels) in <class:AssignmentsControllerTest>'
    test/controllers/assignments_controller_test.rb:42:in `block in <class:AssignmentsControllerTest>'
```

This is good - we prefer application exceptions (which we can handle gracefully) to database errors.

So, let's adjust the tests Rails generated for us to reflect that this is the behaviour we expect. Let's confirm that you _should_ be able to delete a parent record that has no children (for instance because you made a typo), but you should _not_ be able to delete a parent that has children.

We'll start by creating some fixture to allow us to express this. Part of the scaffolding logic is that Rails will generate yml files to provide test fixture - you'll find them in folder `/test/fixtures/`. So, let's edit `/test/fixtures/clients.yml`, and add a client who will not have any projecs:

``` yml
no_projects:
  name: no_projects
  status: 1
```

Now, we can edit the controller test which was failing in `/test/controllers/clients_controller_test.rb`. 

Replace the test called `"should destroy client" with the following:

``` ruby
 test "should destroy client without projects" do
    assert_difference('Client.count', -1) do
      delete client_url(@client_no_projects)
    end

    assert_redirected_to clients_url
  end
 ```
 And add a test to make sure we cannot delete a client with projects:

 ``` ruby
   test "should not destroy client with projects" do
    assert_raise(ActiveRecord::DeleteRestrictionError) do
      delete client_url(@client)
    end
  end
  ```
  
  Now, arguably, we are writing unit tests to cover "out of the box" Rails features - and that is not a great use of our time. So, I'm going to leave it up to you to decide what to do - replicate the same logic I've demonstrated here, or simply delete the tests that are failing in the other controller_tests. Personally, I believe that we are expressing the intent of our product owner ("don't delete clients with timesheets attached to them" etc.), and it's worth writing tests to make sure we are delivering that intent, no matter how that's achieved. So I am writing the tests.

  Once that's done, my output from `rails test` is:

  ``` shell
Finished in 5.691418s, 7.0281 runs/s, 8.6095 assertions/s.
40 runs, 49 assertions, 0 failures, 0 errors, 0 skips
```

So, now we can take the next step.

### Authentication.

We want to introduce the concept of users, privileges, and authentication. Our product owner says:

   Only authenticated users should be able to enter a timesheet. 
   Only administrators should be able to create clients, projects, people and assignments.

There are a few options for adding authentication to Rails applications; we'll choose [Devise](https://github.com/plataformatec/devise) as it's one of the most popular and best supported options.

We start by adding Devise to our `Gemfile`:

``` Ruby
gem 'devise'
```

Now we run `bundle install`, and then set up Devise:

``` shell
rails generate devise:install
rails generate devise:views
```

Finally, we make sure there's a default route set up by adding it to `config/routes.rb` 

``` ruby
 root to: 'page#index'
 ```

 Now, we'll create a user type so we can authenticate. It's possible to re-use an existing model (e.g. `person`), but that creates a bit of complication later on, and I want to separate out the concept of "user of the system" from "person who books timesheet". 

So, we'll create a new class, and create the associated database tables:

``` shelll
rails generate devise user
rails db:migrate
```

We now can implement our first business requirement:
   
   Only authenticated users should be able to enter a timesheet.

Let's start by writing a test - TDD is a great way to make sure your code evolves predictably.

We'll open `test/controllers/timesheets_controller_test.rb`, and add a new test, which expects unauthenticated users to be redirected (to the login page).

``` ruby
  test "unauthenticated user should not get index" do
    # TODO: log in as authenticated user
    get timesheets_url
    assert_response :redirect
  end
  ```
When we run `rails test`, you may get some errors about email address being a primary key; it appears the test scaffold for Devise does not create valid fixtures, so we'll start by cleaning that up in `fixtures/users.yml`

``` yaml
one: {
# column: value
  email: one@test.com
}
#
two: {
  email: two@test.com
# column: value
}
```
After fixing those problems, you should be left with a single failure when running the tests:

``` unittest
Failure:
TimesheetsControllerTest#test_unauthenticated_user_should_not_get_index [/app/test/controllers/timesheets_controller_test.rb:17]:
Expected response to be a <3XX: redirect>, but was a <200: OK>
```

So, let's fix that. In `app/controllers/timesheets_controller.rb`, add the following line at the top of the class:

``` ruby
before_action :authenticate_user!
```
When we run `rails test`, we see a whole bunch of new errors: 

``` test

Failure:
TimesheetsControllerTest#test_authenticated_user_should_get_index [/app/test/controllers/timesheets_controller_test.rb:11]:
Expected response to be a <2XX: success>, but was a <302: Found> redirect to <http://www.example.com/users/sign_in>
Response body: <html><body>You are being <a href="http://www.example.com/users/sign_in">redirected</a>.</body></html>
```

This happens because suddenly, the unit tests cannot execute as we've said you have to be authenticated as a user to execute them - that's what the `before_action` statement does.

So, now we need to get the tests to authenticate first.
We need to modify `test/controllers/timesheets_controller_test.rb`, and change the class declaration as follows:

``` ruby 
class TimesheetsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
```

This include all the helpers Devise provides. Next, for each test that requires us to be authenticated, we need to include the following line at the top of the test method: 

``` ruby 
sign_in users(:one)
```
This should allow the tests to run without failures.

We will now look at how to meet the other requirement:

   Only administrators should be able to create clients, projects, people and assignments.

We discuss this in more detail with the product owner, and add to that a clarification:
   
   All authorized users can _see_ but _not modify_ clients, projects, people and assignments.

So, we'll start with the "easy" bit: making the client, project, people and assignments controller insist on authorized users. 

We'll start again by writing the tests - an unauthenticated user should get redirected when they try to see the `index` page for people, projects, clients and assignments. 

I will not go through every controller test - the process is pretty much identical for each one, and you can check out the code if you want.

Firstly, change the class declaration for each unit test to include 

``` ruby
include Devise::Test::IntegrationHelpers
```

Next, change the `should get index` test case to include the log-in step, and change its name to make clear it should only work for authenticated users. Next, add a test to make sure that unauthenticated users get redirected. For instance, I've changed the `people_controller_test.rb` as follows:

``` ruby
  test "authenticated user should get index" do
    # TODO: log in as authenticated user
    sign_in users(:one)
    get people_url
    assert_response :success
  end
  test "unauthenticated user should not get index" do
    get people_url
    assert_response :redirect
  end  
  ```

  You can now run `rails test`, and see a failed test:

  ``` test
  Failure:
PeopleControllerTest#test_unauthenticated_user_should_not_get_index [/app/test/controllers/people_controller_test.rb:19]:
Expected response to be a <3XX: redirect>, but was a <200: OK>
```
We fix this by making sure the controller checks you're authenticated. In `people_controller.rb`, add 

``` ruby
 before_action :authenticate_user!
 ```

 Now re-run the test, and all is well getting the "index" page - but the tests now complain about the other actions. So, let's work on the main requirement:

   Only administrators should be able to create clients, projects, people and assignments.

Devise has a [few ways in which you can support "admin"](https://github.com/plataformatec/devise/wiki/How-To:-Add-an-Admin-Role) or other types of roles. We will use the "enum" option - it's the most flexible, and not significantly more effort than the other two options.

So, we generate the migration:

``` shell 
rails g migration AddRoleToUsers role:integer
rails db:migrate
```

Next, we define the roles in the enumeration. Open `app/models/user.rb`, and add:

``` ruby
  enum role: [:user, :admin]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :user
  end
end
```

Now we need to make sure the controllers check the current user is authorized. We could include this logic in each method, for instance

``` ruby
  def edit
    if current_user.admin!
    else
      redirect_to action: "login"
    end

  end
  ```

  But this feels wrong - we're writing a lot of very specific logic into our controllers, it's hard to test, and hard to verify.

  Luckily, there's a gem called [Pundit](https://github.com/varvet/pundit) which allows us to move the authentication logic out of the controller.

  Let's install it - we add `gem "pundit"` to our `Gemfile`, and then run `bundle install`.

Now we modify our `app/controllers/application_controller.rb` and add Pundit to it:
``` ruby
class ApplicationController < ActionController::Base
  include Pundit
end
```

As all our other controllers descend from the application controller, this means they all get Pundit functionality included.

Next, we run `rails g pundit:install`  - this creates a default policy.

So, let's start with implementing the rule that only administrators can create or modify people, clients, projects and assignments.

There are a few ways to achieve this with Pundit:
  - we can implement the logic in the default application policy. This feels brittle, as the application policy would need to know a list of classes which only an administrator can write. 
  - we can create policies for each of the classes concerned. This feels like a lot of duplication.
  - we can create a "admin_modify_only" policy, and make sure our controllers use that to check. This seems the cleanest - the relationship is explicitly set in the controller, and we're not duplicating logic.

So, let's create a new policy - create the file `/app/policies/admin_only_policy.rb`:

``` ruby
class AdminOnlyPolicy < ApplicationPolicy
  def create?
    user.admin?
  end

  def new?
    user.admin?
  end

  def update?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end
```

This policy checks that only administrators can modify data.

We now modify the controllers to explicitly authorize with this policy when trying to modify data. For instance, `/app/controllers/people_controller.rb`

``` ruby
class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  # GET /people
  # GET /people.json
  def index
    @people = Person.all
  end

  # GET /people/1
  # GET /people/1.json
  def show
  end

  # GET /people/new
  def new
    @person = Person.new
    authorize @person, policy_class: AdminOnlyPolicy
  end

  # GET /people/1/edit
  def edit
    authorize Person, policy_class: AdminOnlyPolicy
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(person_params)
    authorize @person, policy_class: AdminOnlyPolicy

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: "Person was successfully created." }
        format.json { render :show, status: :created, location: @person }
      else
        format.html { render :new }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1
  # PATCH/PUT /people/1.json
  def update
    authorize @person, policy_class: AdminOnlyPolicy

    respond_to do |format|
      if @person.update(person_params)
        format.html { redirect_to @person, notice: "Person was successfully updated." }
        format.json { render :show, status: :ok, location: @person }
      else
        format.html { render :edit }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    authorize @person, policy_class: AdminOnlyPolicy

    @person.destroy
    respond_to do |format|
      format.html { redirect_to people_url, notice: "Person was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_person
    @person = Person.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def person_params
    params.require(:person).permit(:name, :role)
  end
end
```

Where we have a specific instance of `@person`, we use that to authorize; otherwide, we just use the class.

To see this in action, visit `http://localhost:3000/users/sign_up`, and sign-up as a new user. Make sure that user isn't an administrator; then go to `http://localhost:3000/people`; you should see a list of people (if you created these earlier). Now try to create a new person, and you should see an error page: 

``` ruby
Pundit::NotAuthorizedError in PeopleController#new
```

This is because Pundit raises an error when authorization fails. You can handle that error differently in each contrller if you like, but we'll just make a default implementation in `/app/controllers/application_contoller.rb`

``` ruby
class ApplicationController < ActionController::Base
  include Pundit
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
```

This introduces an error handler, which listens for Pundit's `NotAuthorizedError`, and sends you back where you came from with an error message. When we now try to create a new person, we no longer see the error message.

We'll do the same to the other controllers.

Now let's see what happens to our tests: we run `rails test` again. We get lots of failures - because our user isn't authorized as an admin!

So, we need to modify our tests to explicitly log in. Devise makes this pretty easy. First, we need to create an admin user in our fixture data.

In `/test/fixtures/users.yml, add an admin user as follows:

``` yml
admin: 
  email: admin@test.com,
  role: :admin
```

Next, we modify our tests to include the Devise helper. I'll use `projects_controller_test.rb` as an example; you'll need to make the same changes to the other tests;

``` ruby
require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @project = projects(:one)
    @project_without_assignments = projects(:project_without_assignments)
    
  end

  test "authorized user should get index" do
    sign_in users(:one)
    get projects_url
    assert_response :success
  end

  test "unauthenticated user should not get index" do
    get projects_url
    
    assert_response :redirect
  end 
  
  test "should get new" do
    sign_in users(:admin)

    get new_project_url
    assert_response :success
  end

  test "should create project" do
    sign_in users(:admin)
    @person = people(:one)
      assert_difference('Project.count') do
      post projects_url, params: { project: { client_id: @project.client_id, name: @project.name, status: @project.status } }
    end

    assert_redirected_to project_url(Project.last)
  end

  test "should show project" do
    sign_in users(:admin)
    
    @person = people(:one)
    get project_url(@project)
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:admin)
    
    get edit_project_url(@project)
    assert_response :success
  end

  test "should update project" do
    sign_in users(:admin)
    
    patch project_url(@project), params: { project: { client_id: @project.client_id, name: @project.name, status: @project.status } }
    assert_redirected_to project_url(@project)
  end

  test "should destroy project withtout assignements" do
    sign_in users(:admin)
    
    assert_difference('Project.count', -1) do
      delete project_url(@project_without_assignments)
    end

    assert_redirected_to projects_url
  end
  test "should not destroy project with assignments" do
    sign_in users(:admin)
    
    assert_raise(ActiveRecord::DeleteRestrictionError) do
      delete project_url(@project)
    end
  end
end
```

`include Devise::Test::IntegrationHelpers` makes the Devise test helpers available to us. We can then log in using the entries in our fixture file as follows: `sign_in users(:admin)`.

Update all your controller tests accordingly, and you can run `rails test` and get a clean execution.
