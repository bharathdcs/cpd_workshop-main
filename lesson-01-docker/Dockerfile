
#	make a docker file that runs python application

FROM  registry.access.redhat.com/ubi8/python-36

USER default 

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

#RUN /usr/local/bin/python -m pip install --upgrade pip
RUN pip install flask

#RUN mkdir /src
COPY app.py . 

CMD [ "python3", "app.py"]
#WORKDIR /src
