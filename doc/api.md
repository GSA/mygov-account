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
