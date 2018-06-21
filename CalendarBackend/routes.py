from flask import Flask, request
import api as api

APP = Flask(__name__)
API = api.API()


@APP.route('/events', methods=['GET', 'POST', 'PUT', 'DELETE'])
def event():
    if request.method == 'POST':
        return API.post_event(request)

    elif request.method == 'GET':
        return API.get_events(request.args)

    elif request.method == 'PUT':
        return API.update_event(request)

    elif request.method == 'DELETE':
        return API.delete_event(request.args)
