import json
import mysql.connector
from DBConnector import DBConnector
import datetime

FMT = "%Y-%m-%d %H:%M:%S"


class Response:

    def __init__(self, code=-1, msg="", data=""):
        self.code = code
        self.msg = msg
        self.data = data


    def jsonify(self):
        return json.dumps({
            "code": self.code,
            "message": self.msg,
            "data": self.data
        })


class API:

    def __init__(self):
        self.db = DBConnector()

    # Delete an event based on the id
    def delete_event(self, args):
        query = "delete from events where id=%s"

        variables = [
            args.get('id')
        ]

        print variables

        try:
            self.db.execute(query, variables=variables)
            return Response(200, "Successfully deleted event.").jsonify()
        except mysql.connector.Error as e:
            return Response(e.errno, e.msg).jsonify()


    # Update an event based on the id
    def update_event(self, request):
        query = """
            update events
            set 
                title=%s, start_date=%s, end_date=%s
            where id=%s
        """

        variables = [
            request.form["title"] if "title" in request.form else None,
            request.form["start_date"] if "start_date" in request.form else None,
            request.form["end_date"] if "end_date" in request.form else None,
            int(request.form["id"]) if "id" in request.form else None
        ]

        try:
            self.db.execute(query, variables=variables)
            return Response(200, "Successfully updated event.").jsonify()
        except mysql.connector.Error as e:
            return Response(e.errno, e.msg).jsonify()


    # Create a new event and return the created ID
    def post_event(self, request):
        query = """
                 insert into events 
                   (title, start_date, end_date)
                 values
                   (%s, %s, %s);
                 select LAST_INSERT_ID();
             """

        variables = [
            request.form["title"]           if "title" in request.form else None,
            request.form["start_date"]      if "start_date" in request.form else None,
            request.form["end_date"]        if "end_date" in request.form else None,
        ]

        try:
            result = self.db.fetch_all(query, variables=variables, multi=True)
            event_id = result[1][0][0]
            return Response(200, "Successfully created event.", str(event_id)).jsonify()
        except mysql.connector.Error as e:
            return Response(e.errno, e.msg).jsonify()


    # get all events
    def get_events(self, args):
        start = args.get('start_date')
        end = args.get('end_date')

        variables = None
        if start is None and end is None:               # all events
            query = "select * from events;"

        elif start is not None and end is not None:     # date range parameter
            query = """
                select * from events 
                where start_date >= %s and start_date <= %s 
                """
            variables = [start, end]

        else:
            return Response(400, "Invalid URL request.").jsonify()

        try:
            result = self.db.fetch_all(query, variables)[0]
            return self.__jsonify_result(result)

        except mysql.connector.Error as e:
            return Response(e.errno, e.msg).jsonify()


    # Convert results array to json
    def __jsonify_result(self, result):
        json_arr = []
        headers = self.db.headers()

        # convert row to dictionary
        for row in result:
            row_dict = {}
            for i in range(len(headers)):
                if type(row[i]) == datetime.datetime:
                    row_dict[headers[i]] = row[i].strftime(FMT)  # date to string
                else:
                    row_dict[headers[i]] = row[i]
            json_arr.append(row_dict)

        return json.dumps(json_arr)
