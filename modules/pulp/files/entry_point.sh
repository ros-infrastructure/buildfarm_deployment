#!/bin/bash -ex

# Start redis
/usr/bin/redis-server /var/lib/pulp/redis.conf

if [ ! "$(ls -A ${PULP_DATA_ROOT})" ]; then
  # Create the media and postgres dirs
  mkdir -p ${PULP_MEDIA_ROOT} ${PGDATA}

  # Create the postgres DB
  /opt/rh/rh-postgresql96/root/bin/initdb ${PGDATA}

  # Start postgres
  /opt/rh/rh-postgresql96/root/usr/libexec/postgresql-ctl start -s -w -t 270

  # Create the DB
  scl enable rh-postgresql96 -- psql postgres -c "create database pulp"

  # Run Django Migrations
  django-admin migrate --noinput
else
  # Start postgres
  /opt/rh/rh-postgresql96/root/usr/libexec/postgresql-ctl start -s -w -t 270
fi

# Generate static content
django-admin collectstatic --noinput

# Start Pulp API
gunicorn pulpcore.app.wsgi:application --bind "$PULP_API_LISTEN" -D --access-logfile -

# Start Pulp Content
gunicorn pulpcore.content:server --bind "$PULP_CONTENT_LISTEN" --worker-class 'aiohttp.GunicornWebWorker' -w 2 -D --access-logfile -

# Start some Pulp task workers
for i in {0..1}; do
  /usr/bin/screen -d -m -S pulp-worker-$i rq worker -w pulpcore.tasking.worker.PulpWorker --pid=${PULP_RUN_DIR}/reserved-resource-worker-$i.pid -c 'pulpcore.rqconfig' --disable-job-desc-logging
done

# Start Pulp RM worker
/usr/bin/screen -d -m -S pulp-worker-rm rq worker -w pulpcore.tasking.worker.PulpWorker -n resource-manager --pid=${PULP_RUN_DIR}/pulp-resource-manager.pid -c 'pulpcore.rqconfig' --disable-job-desc-logging

exec "$@"
