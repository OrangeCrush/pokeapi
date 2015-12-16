# Build the app on top of Ubuntu
from ubuntu

# Patch and Install Dependencies
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install git python-dev make python-pip libpq-dev 
RUN apt-get -y install postgresql postgresql-contrib

CMD mkdir -p /app && chown -R postgres:postgres /app

# Add the application code to the image
ADD . /app/

# Set a working directory
WORKDIR /app/

# Build the application
RUN pip install -r requirements.txt --upgrade

# Setup db authentication
ENV PG_USER    ash
ENV PG_PASS    pokemon
ENV PD_DB_NAME pokeapi

# Start postgres database and use it while it is running in the container
# Create the default db user (ash) 
RUN sudo -u postgres service postgresql start                                 && \
    sudo -u postgres psql --command "CREATE USER ash WITH PASSWORD 'pokemon'" && \
    sudo -u postgres createdb -O ${PG_USER} ${PD_DB_NAME}                     && \
    python manage.py migrate --settings=config.local                          && \
    printf "from data.v2.build import build_all; build_all()" | python manage.py shell --settings=config.local

# Expose the app and serve the API.
EXPOSE 8000
CMD service postgresql start && python manage.py runserver --settings=config.local 0.0.0.0:8000

