import os
import psycopg2
import time
from flask import Flask
import asyncio

# Use the function
dbname = os.environ.get('DB_NAME')
user = os.environ.get('DB_USER')
password = os.environ.get('DB_PASSWORD')
host = os.environ.get('DB_HOST')
port = os.environ.get('DB_PORT')


app = Flask(__name__)

def connect_to_postgres(dbname, user, password, host, port):
  max_attempts = 3
  delay = 10
  print(f"Connecting to the database {dbname} on {host}:{port} as {user}")
  for attempt in range(max_attempts):
    try:
      # Connect to the PostgreSQL server
      global cur, db_connected, conn
      conn = psycopg2.connect(
          dbname=dbname,
          user=user,
          password=password,
          host=host,
          port=port
      )
      # Create a new cursor
      cur = conn.cursor()
      return conn, cur

    except (Exception, psycopg2.DatabaseError) as error:
      print(f"Attempt {attempt + 1} failed to connect to the database")
      print(error)
      time.sleep(delay)


def get_users(conn, cur):
  try:
    cur.execute("SELECT * FROM users")
    rows = cur.fetchall()
    result = ""
    for row in rows:
      result = result + f"{row[0]} {row[1]} {row[2]}</br>"
    return result
  except (Exception, psycopg2.DatabaseError) as error:
    print(error)

@app.route('/')
def hello_world():
  return "hello world"

@app.route('/users')
def show_users():
  conn, cur = connect_to_postgres(dbname, user, password, host, port)
  if conn:
    return get_users(conn, cur)
  return "Database not connected"

if __name__ == '__main__':
  app.run(port=os.environ.get('PORT', 5000), host='0.0.0.0')
