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

passport-myusa
==============

[Passport](https://github.com/jaredhanson/passport) Authentication Strategy for
MyUSA (my.usa.gov) using the OAuth 2.0 API.

This module lets you authenticate using MyUSA in your Node.js applications.
By plugging into Passport, MyUSA authentication can be easily and
unobtrusively integrated into any application or framework that supports
[Connect](http://www.senchalabs.org/connect/)-style middleware, including
[Express](http://expressjs.com/) and [Sails](http://www.sailsjs.org).

## Install

    $ npm install passport-myusa

#### Development Install

    $ git clone git://github.com:Innovation-Toolkit/passport-myusa.git
    $ cd passport-myusa
    $ sudo npm link
    change to your project's directory
    $ npm link passport-myusa

## Usage

#### Configure Strategy

The MyUSA authentication strategy authenticates users using an MyUSA
account and OAuth 2.0 tokens.  The strategy requires a `verify` callback, which
accepts these credentials and calls `done` providing a user, as well as
`options` specifying a client ID, client secret, and callback URL.

Note that the `callbackURL` must match **exactly** the callback registered
for your application at [MyUSA](https://my.usa.gov/apps).

    passport.use(new MyUSAStrategy({
        clientID: MYUSA_CLIENT_ID,
        clientSecret: MYUSA_CLIENT_SECRET,
        callbackURL: "http://localhost:3000/auth/myusa/callback"
      },
      function(accessToken, refreshToken, profile, done) {
        User.findOrCreate({ myusaId: profile.id }, function (err, user) {
          return done(err, user);
        });
      }
    ));

The fields available in the profile are defined by [Passport's Standard Profile](http://passportjs.org/guide/profile/).  Two extra fields are included in the profile: `_raw` and `_json`.  `_raw` is the raw response from the MyUSA server, whereas `_json` is the JSON-parsed representation of the raw response.

#### Authenticate Requests

Use `passport.authenticate()`, specifying the `'myusa'` strategy, to
authenticate requests.  Set the requested scope, such as `profile`,
in the optional parameters during the authenticate phase.

For example, as route middleware in an [Express](http://expressjs.com/)
application:

    app.get('/auth/myusa',
      passport.authenticate('myusa', { scope: ['profile.email'] }));

    app.get('/auth/myusa/callback',
      passport.authenticate('myusa', { failureRedirect: '/login' }),
      function(req, res) {
        // Successful authentication, redirect home.
        res.redirect('/');
      });

## Examples

For a complete, working example, refer to the [login example](https://github.com/Innovation-Toolkit/passport-myusa/tree/master/examples/login).

## Tests

[![Build Status](https://travis-ci.org/Innovation-Toolkit/passport-myusa.png?branch=master)](https://travis-ci.org/Innovation-Toolkit/passport-myusa) [![Dependency Status](https://gemnasium.com/Innovation-Toolkit/passport-myusa.png)](https://gemnasium.com/Innovation-Toolkit/passport-myusa)

    $ npm install --dev
    $ make test

## Notes on MyUSA Authentication

Register your application with [MyUSA](https://my.usa.gov/apps) and save your Client ID and Secret.  Select the scopes that your application requires. Valid scopes are:
- profile.email
- profile.title
- profile.first_name
- profile.middle_name
- profile.last_name
- profile.suffix
- profile.address
- profile.address2
- profile.city
- profile.state
- profile.zip
- profile.phone_number
- profile.mobile_number
- profile.gender
- profile.marital_status
- profile.is_parent
- profile.is_student
- profile.is_veteran
- profile.is_retired
- tasks
- notifications
- submit_forms

The user authentication URL and token exchange URL for MyUSA are `https://my.usa.gov/oauth/authenticate`

The REST API for profile information is `https://my.usa.gov/api/profile`

All API calls, including GET requests, must include the `Authorization: Bearer <token>` HTTP header. MyUSA does **not** support GET requests with the authorization token specified using a query string.

An example using [node-oauth](https://github.com/ciaranj/node-oauth):

    var OAuth2 = require('oauth').OAuth2;
    var oauth = new OAuth2(CLIENT_ID, CLIENT_SECRET, '',
        AUTHORIZATION_URL, TOKEN_URL, null);
    // Use authorization headers for GET, not query string
    oauth.useAuthorizationHeaderforGET(true);
    // Make request
    oauth2.get(PROFILE_URL, ACCESS_TOKEN, function (err, body, res) {
        // parse profile
    });

## Credits

  - [Joe Polastre](http://github.com/polastre)

## License

You may use this project under [The MIT License](http://opensource.org/licenses/MIT).
