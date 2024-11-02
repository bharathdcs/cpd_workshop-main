
#	make a docker file that runs python application
FROM  registry.access.redhat.com/ubi8/python-36

RUN pip install --upgrade pip
RUN pip install flask

COPY app.py .

CMD [ "python3", "app.py" ]
