FORMAT: 1A
HOST: https://myusa.gov/developers/api

# MyUSA API Documentation

# Group Users
This is a description of the user group

## Get user profile data [/api/profile]
Returns the authorizing user's profile information

+ Parameters

    + name (optional, string, `schema`)
    + required (optional, string, `N`)
    + Type (optional, string, `String`)
    + description (optional, string, `true`) ... Set this to 'true' to get results in Schema.org Person format

+ Model

    + Headers

            Content-Type: application/json

    + Body

            {
          "MethodName": "/api/profile",
          "Synopsis": "Returns the authorizing user's profile information",
          "HTTPMethod": "GET",
          "URI": "profile",
          "RequiresOAuth": "Y",
          "parameters": [
            {
              "Name": "schema",
              "Required": "N",
              "Type": "string",
              "Description": "Set this to 'true' to get results in Schema.org Person format"
            }
          ]
        }

### GET

+ Request

+ Response 200

# Group Notifications
This is a description of the notification group

## Create a notification [/api/notification]
Delivers a notification message to the authorizing user.

### POST

+ Request

    + Headers

            Content-Type: application/json

    + Body

          [
            {
              "Name": "subject",
              "Required": "Y",
              "Type": "string",
              "Description": "The subject line of the notification."
            },
            {
              "Name": "body",
              "Required": "N",
              "Type": "string",
              "Description": "The body of the notification."
            }
          ]

+ Response 200

+ Parameters

    + name (optional, string, `schema`)
    + required (optional, string, `N`)
    + Type (optional, string, `String`)
    + description (optional, string, `true`) ... The subject line of the notification.

# Group Tasks
This is a description of the tasks group

## Tasks [/api/tasks/:id]

### Get a list of tasks [GET]
List all the tasks created by the calling application.

+ Response 200

+ Parameters

## Create a task [/api/tasks]

### Create a task [POST]
Create a new task for the user for this application.

+ Request

    + Headers

            Content-Type: application/json

    + Body

          [
            {
              "Name": "task[name]",
              "Required": "Y",
              "Type": "string",
              "Description": "The name for the task that is being created."
            },
            {
              "Name": "task[task_items_attributes]",
              "Required": "Y",
              "Type": "string",
              "Description": "A list of task items to be associated with the task.  Task Items are pointers to forms using a form_id."
            }
          ]

+ Response 200

+ Parameters

    + name (optional, string, `schema`)
    + required (optional, string, `N`)
    + Type (optional, string, `String`)
    + description (optional, string, `true`) ... The name for the task that is being created.

## Get a single task  [/api/task/:id]
### Get a single task [GET]
List all the tasks created by the calling application.

+ Response 200

+ Parameters

## Update a task [/api/task/:id]
### Update a task [PUT]
Update task.

+ Response 200

+ Parameters

# Group Authentication
# OmniAuth::Strategies::Myusa

This gem contains the MyUSA strategy for OmniAuth.

MyUSA uses OAuth 2.0. To find out more information about MyUSA and how to create your own application visit the [developers](https://my.usa.gov/developer) section of MyUSA.

View the OmniAuth 1.0 docs for more information about strategy implementation: https://github.com/intridea/omniauth.

## Before You Begin

Sign in to [MyUSA](https://my.usa.gov/developer) and register an application. You will need to provide a redirect URI which is "YOUR_SITE/auth/myusa/callback" by default. Take note of your Consumer Key and Consumer Secret.

## Using This Strategy

First start by adding this gem to your Gemfile:

```ruby
gem 'omniauth-myusa', :git => 'https://github.com/GSA-OCSIT/omniauth-myusa.git'
```

Next, tell OmniAuth about this provider. For a Rails app, your `config/initializers/omniauth.rb` file should look like this:

```ruby
provider :myusa, "CONSUMER_KEY", "CONSUMER_SECRET", :scope => "profile tasks submit_forms notifications"
```

Replace CONSUMER_KEY and CONSUMER_SECRET with the appropriate values you obtained from [MyUSA](https://my.usa.gov/apps) earlier.

## Authentication Hash
An example auth hash available in `request.env['omniauth.auth']`:

```ruby
{"provider"=>"myusa",
 "uid"=>"r03Ke0000000000FrqOOFlq0DeNc9q1QQQQQQQQC",
 "info"=>{"email"=>"johnq@bloggs.com"},
 "credentials"=>{"token"=>"3gnsgg14ymf54mquevfry38ao", "expires"=>false},
 "extra"=>
  {"raw_info"=>
    {"title"=>nil,
     "first_name"=>nil,
     "middle_name"=>nil,
     "last_name"=>nil,
     "suffix"=>nil,
     "address"=>nil,
     "address2"=>nil,
     "city"=>nil,
     "state"=>nil,
     "zip"=>nil,
     "phone_number"=>nil,
     "mobile_number"=>nil,
     "gender"=>nil,
     "marital_status"=>nil,
     "is_parent"=>nil,
     "is_retired"=>nil,
     "is_veteran"=>nil,
     "is_student"=>nil,
     "email"=>"johnq@bloggs.com
     "uid"=>"r03Ke0000000000FrqOOFlq0DeNc9q1QQQk390QC"}}}
```

## Watch the RailsCast

Ryan Bates has put together an excellent RailsCast on OmniAuth:

[![RailsCast #241](http://railscasts.com/static/episodes/stills/241-simple-omniauth-revised.png "RailsCast #241 - Simple OmniAuth (revised)")](http://railscasts.com/episodes/241-simple-omniauth-revised)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request