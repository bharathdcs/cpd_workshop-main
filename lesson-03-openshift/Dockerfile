
#	make a docker file that runs python application

FROM  python:3.8-alpine

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH


RUN /usr/local/bin/python -m pip install --upgrade pip
RUN pip install flask

RUN mkdir /src
COPY app.py src

WORKDIR /src

CMD [ "python3", "app.py" ]
