
from flask import Flask , request
from datetime import datetime

app = Flask(__name__)

@app.route("/")
def index():
    return "hello world\n"

# Simulate a JSON REST endpoint
@app.route("/api" , methods = [ 'POST' ] )
def api() :
    name = request.json['name']
    now = datetime.now()
    return { 'name' : name , 'now' : now } 

# Simulate an error by opening a non existing file
@app.route("/simerror")
def simerror():
    f = open("/tmp/nonexistentfile", "r" )
    txt = f.read()
    f.close()
    return txt

app.run ( "0.0.0.0" , 7777 , ssl_context=('./domain.crt', './domain.key') )
