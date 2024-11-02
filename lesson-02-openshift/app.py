
from flask import Flask , request 
from datetime import datetime

app = Flask(__name__)

# Simulate home page
@app.route("/")
def index():
    now = datetime.now()
    print ("I served a hello world at ",now)
    return "hello world\n"

# Simulate a JSON REST endpoint
@app.route("/api" , methods = [ 'POST' ] )
def api() :
    name = request.json['name']
    now = datetime.now()
    print ("I served a request at ",now)
    return { 'name' : name , 'now' : now } 

# Simulate an error by opening a non existing file
@app.route("/simerror")
def simerror():
    f = open("/tmp/nonexistentfile", "r" )
    txt = f.read()
    f.close()
    return txt

# Note that the certificate names has changed.
app.run ( "0.0.0.0" , 7777 )
