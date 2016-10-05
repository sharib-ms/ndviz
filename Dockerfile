FROM ubuntu:16.04
MAINTAINER Alex Baden / Neurodata (neurodata.io)

RUN apt-get update
RUN apt-get -y upgrade

# install ndviz dependencies
RUN apt-get -y install \
  python-all-dev \
  python-pip \
  git vim \
  supervisor

# install MySQL independently 
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get -y install \
  mysql-server mysql-client \ 
  libmysqlclient-dev \
  python-mysqldb  

# clone ndviz
RUN mkdir -p /var/www/
WORKDIR /var/www/
RUN git clone https://github.com/neurodata/ndviz.git
WORKDIR ndviz

# checkout desired version
RUN git checkout boss
RUN git pull

# install ndviz requirements
RUN pip install -r setup/requirements.txt

# copy the local settings.py into the correct directory
COPY settings_secret.py ndv/
# make sure you delete the "FORCE_SCRIPT_NAME line in settings.py! 
COPY settings.py ndv/

# create mysql users
RUN service mysql start && mysql -u root -i -e "create user 'neurodata'@'localhost' identified by 'YOUR_PASSWORD_HERE';" &&\
  mysql -u root -i -e "grant all privileges on *.* to 'neurodata'@'localhost' with grant option;" &&\
  mysql -u neurodata -pYOUR_PASSWORD_HERE -i -e "CREATE DATABASE neurodataviz;" &&\
  python manage.py migrate

RUN python manage.py collectstatic --noinput

# Expose the port (note: if you change the port here, you need to change it in CMD below)
EXPOSE 8000

# setup entrypoint
COPY setup/docker_entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker_entrypoint.sh
ENTRYPOINT ["docker_entrypoint.sh"]

# default command
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
