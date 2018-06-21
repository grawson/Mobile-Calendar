import mysql.connector
import sys
from config import CONFIG


class DBConnector:

    def __init__(self):
        self.cursor, self.cnx = None, None
        self.__connect()
        self.cursor = self.cnx.cursor(buffered=True)


    def __del__(self):
        if self.cursor: self.cursor.close()
        if self.cnx: self.cnx.close()
        print("[INFO] Closed db connection")


    def __connect(self):
        try:
            self.cnx = mysql.connector.connect(**CONFIG)
            print("[INFO] Opened db connection")
        except mysql.connector.Error as err:
            print("ERROR:", err)
            sys.exit()

    # Fetch results from query. Supports multiple sql statements and will encode results in 2d array
    def fetch_all(self, query, variables=None, multi=False):
        if variables is None:
            iterator = self.cursor.execute(query, multi=multi)
        else:
            iterator = self.cursor.execute(query, params=variables, multi=multi)

        # Put multiple possible results into array
        if iterator is None:
            result = [self.cursor.fetchall()]
        else:
            result = []
            for res in iterator:
                if res.with_rows:   # only add results if they exist
                    result.append(self.cursor.fetchall())
                else:
                    result.append(None)

        self.cnx.commit()
        return result


    def execute(self, query, variables=None):
        if variables is None:
            self.cursor.execute(query)
        else:
            self.cursor.execute(query, variables)
        self.cnx.commit()


    # Get row headers
    def headers(self):
        return [x[0] for x in self.cursor.description]
