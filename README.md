# Introduction

Full stack iOS calendar app. Frontend built with Swift and backend built with Python/MySQL.

Check out the demo for a quick overview!

# Features

* Add, delete, and edit events
* View events for a given date
* Infinite calendar months (swipe horizontally on calendar to switch between months)
* Support for multi-day events

# Calendar Backend

#### Dependencies

* python mysql-connector: `pip install mysql-connector`
* flask: `pip install flask`

#### To Run

* Set up a local SQL server
* Run the `CalendarBackend/db.sql` script to create the database
* Customize the credentials in `config.py` for your machine
* Start flask server from project root: `FLASK_APP=CalendarBackend/routes.py flask run --host=0.0.0.0` or `./run_server.sh` for a shortcut


# Calendar Mobile

#### Notes

* Compiled with Xcode 9.4.1 on iOS 11.4
* Swipe horizontally on the calendar to switch between months
* Click an event to edit/delete
* Toolbar buttons on top of the calendar from left to right: refresh page, switch calendar view to current month, and create event.

#### Setup

* Edit the domain in `CalendarMobile/CalendarFrontend/Config.swift` to be the ip address of your machine,
along with the port that the flask server is listening on
