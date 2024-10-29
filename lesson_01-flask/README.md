
# Simple web application with Python / Flask

- Any linux machine with python3 installed

## Objective 

A simple secure web application using python and flask library listening on port https://host/7777.

- generate certificate and key for https 
- '/' returns hello world
- '/api' provides a JSON , and gets back a JSON
- '/simerr' simulates an error and returns code 500 - internal server error

## Curl test

Expected curl response :

> curl -k https://127.0.0.1:7777/

```
hello world
```

> curl -X POST -k -H 'Content-Type: application/json' -d '{ "name" : "john" }' https://127.0.0.1:7777/api

```
{
  "name": "john",
  "now": "Wed, 23 Mar 2022 23:38:21 GMT"
}
```

> curl  -k https://127.0.0.1:7777/simerror
```
    return self.ensure_sync(self.view_functions[rule.endpoint])(**req.view_args)
  File "/root/cpd_workshop/lesson_01-flask/app.py", line 21, in simerror
    f = open("/tmp/nonexistentfile", "r" )
FileNotFoundError: [Errno 2] No such file or directory: '/tmp/nonexistentfile'
```
