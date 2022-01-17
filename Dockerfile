############################################################
# Dockerfile to build Flask App
# Based on
############################################################

# Set the base image
FROM ubuntu:bionic

# File Author / Maintainer
MAINTAINER Algonox

RUN apt-get update 
RUN apt-get install -y apt-utils vim curl apache2 apache2-utils
RUN apt-get update && apt-get -y install python3 libapache2-mod-wsgi-py3
RUN apt-get -y install libmariadbclient-dev
RUN apt-get install -y libsm6 libxext6 libxrender-dev
RUN ln /usr/bin/python3 /usr/bin/python
RUN apt-get update && apt-get -y install python3-pip
RUN ln /usr/bin/pip3 /usr/bin/pip
RUN apt-get clean 
RUN apt-get autoremove
RUN rm -rf /var/lib/apt/lists/*
COPY ./ports.conf /etc/apache2/ports.conf
# Copy over and install the requirements
COPY ./app/requirements.txt /var/www/apache-flask/app/requirements.txt
RUN pip install -r /var/www/apache-flask/app/requirements.txt

# Copy over the apache configuration file and enable the site
COPY ./apache-flask.conf /etc/apache2/sites-available/apache-flask.conf
RUN a2ensite apache-flask
RUN a2enmod headers

# Copy over the wsgi file
COPY ./apache-flask.wsgi /var/www/apache-flask/apache-flask.wsgi

COPY ./run.py /var/www/apache-flask/run.py
COPY ./app /var/www/apache-flask/app/

RUN a2dissite 000-default.conf
RUN a2ensite apache-flask.conf

# LINK apache config to docker logs.
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log


EXPOSE 8080

WORKDIR /var/www/apache-flask

CMD  /usr/sbin/apache2ctl -D FOREGROUND
