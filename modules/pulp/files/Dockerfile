FROM centos:7

RUN yum -y install epel-release centos-release-scl-rh
RUN yum -y update

RUN yum -y install \
  bzip2-devel \
  cmake \
  expat-devel \
  file-devel \
  gcc \
  glib2-devel \
  libcurl-devel \
  libmodulemd2-devel \
  libxml2-devel \
  make \
  openssl-devel \
  python3-devel \
  python3-pip \
  python3-psycopg2 \
  python3-wheel \
  python36-attrs \
  python36-certifi \
  python36-chardet \
  python36-click \
  python36-django \
  python36-gobject \
  python36-idna \
  python36-jinja2 \
  python36-markupsafe \
  python36-nose \
  python36-packaging \
  python36-productmd \
  python36-pyparsing \
  python36-pytz \
  python36-PyYAML \
  python36-requests \
  python36-rfc3986 \
  python36-ruamel-yaml \
  python36-six \
  python36-toml \
  python36-urllib3 \
  redis \
  rh-postgresql96 \
  rpm-devel \
  screen \
  sqlite-devel \
  zchunk-devel \
  zlib-devel

RUN python3 -m venv --system-site-packages /usr/local/lib/pulp
ENV PATH="/usr/local/lib/pulp/bin:${PATH}"
ENV PYTHONPATH="/usr/local/lib/pulp/lib/python3.6/site-packages"

RUN pip3 install scikit-build
RUN pip3 install pulpcore==3.0.0 pulp-rpm==3.0.0

RUN useradd -r pulp -m -d /var/lib/pulp -u 1000
RUN usermod -a -G postgres pulp
RUN usermod -a -G redis pulp
RUN chmod g+w /var/run/postgresql

ENV LANG="en_US.utf8"
ENV PULP_DATA_ROOT="/var/lib/pulp/data"
ENV PULP_MEDIA_ROOT="${PULP_DATA_ROOT}/media/"
ENV PULP_WORKING_DIRECTORY="/var/lib/pulp/tmp/"
ENV PGDATA="${PULP_DATA_ROOT}/pgdata/"
ENV PULP_API_LISTEN="0.0.0.0:24817"
ENV PULP_CONTENT_LISTEN="0.0.0.0:24816"
ENV PULP_CONTENT_ORIGIN="http://repo:24816"
ENV DJANGO_SETTINGS_MODULE="pulpcore.app.settings"
ENV PULP_RUN_DIR="/var/run/pulp"
ENV PULP_LOG_DIR="/var/log/pulp"
ENV PULP_REDIS_DIR="/var/lib/pulp/redis"
#ENV PULP_AUTHENTICATION_BACKENDS="django.contrib.auth.backends.RemoteUserBackend"

RUN cp -a /etc/redis.conf /var/lib/pulp/redis.conf
RUN chown pulp: /var/lib/pulp/redis.conf
RUN sed -i "s| /var/log/redis/| ${PULP_LOG_DIR}/|g" /var/lib/pulp/redis.conf
RUN sed -i "s|dir /var/lib/redis|dir ${PULP_REDIS_DIR}|g" /var/lib/pulp/redis.conf
RUN sed -i "s|daemonize no|daemonize yes|g" /var/lib/pulp/redis.conf

RUN mkdir -p ${PULP_RUN_DIR} ${PULP_LOG_DIR}
RUN chown -R pulp: ${PULP_RUN_DIR} ${PULP_LOG_DIR}

USER pulp
RUN mkdir -p ${PULP_DATA_ROOT} ${PULP_WORKING_DIRECTORY} ${PULP_REDIS_DIR}
COPY entry_point.sh /var/lib/pulp/entry_point.sh
ENTRYPOINT ["/var/lib/pulp/entry_point.sh"]
CMD ["tail", "-f", "/dev/null"]
