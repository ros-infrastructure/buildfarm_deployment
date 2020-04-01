FROM centos:7

RUN yum -y install epel-release
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
  python36-urllib3 \
  rpm-devel \
  screen \
  sqlite-devel \
  zchunk-devel \
  zlib-devel

RUN python3 -m venv --system-site-packages /usr/local/lib/pulp
ENV PATH="/usr/local/lib/pulp/bin:${PATH}"
ENV PYTHONPATH="/usr/local/lib/pulp/lib/python3.6/site-packages"

RUN pip3 install scikit-build
RUN pip3 install pulpcore==3.2.1 pulp-rpm==3.2.0 'toml>=0.10.0'

ENV DJANGO_SETTINGS_MODULE="pulpcore.app.settings"
ENV LANG="en_US.utf8"
ENV PULP_CHUNKED_UPLOAD_DIR="/var/repos/.pulp/upload/"
ENV PULP_CONTENT_ORIGIN="http://repo:24816"
ENV PULP_FILE_UPLOAD_TEMP_DIR="/var/repos/.pulp/tmp/"
ENV PULP_MEDIA_ROOT="/var/repos/.pulp/media/"
ENV PULP_REDIS_URL="unix:///var/run/redis/redis.sock"
ENV PULP_STATIC_ROOT="/var/repos/.pulp/static/"
ENV PULP_WORKING_DIRECTORY="/var/repos/.pulp/tmp/"
