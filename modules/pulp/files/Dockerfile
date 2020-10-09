FROM centos:8

RUN dnf install \
  epel-release \
  dnf-plugins-core \
  -y

RUN dnf config-manager --set-enabled PowerTools

RUN dnf update -y

RUN dnf install \
  bzip2-devel \
  cmake \
  expat-devel \
  file-devel \
  gcc \
  glib2-devel \
  libcurl-devel \
  libmodulemd-devel \
  libxml2-devel \
  make \
  openssl-devel \
  python3-devel \
  python3-distro \
  python3-pip \
  python3-psycopg2 \
  python3-wheel \
  python3-attrs \
  python3-certifi \
  python3-chardet \
  python3-click \
  python3-django \
  python3-gobject \
  python3-idna \
  python3-jinja2 \
  python3-markupsafe \
  python3-nose \
  python3-packaging \
  python3-productmd \
  python3-pyparsing \
  python3-pytz \
  python3-PyYAML \
  python3-requests \
  python3-ruamel-yaml \
  python3-six \
  python3-urllib3 \
  python3-async-timeout \
  python3-backoff \
  python3-defusedxml \
  python3-gunicorn \
  python3-importlib-metadata \
  python3-jsonschema \
  python3-pycparser \
  python3-redis \
  python3-toml \
  python3-typing-extensions \
  python3-uritemplate \
  python3-whitenoise \
  python3-xlrd \
  python3-zipp \
  python-idna-ssl \
  python3-aiohttp \
  python3-cffi \
  python3-createrepo_c \
  python3-ipmi \
  python3-multidict \
  python3-yarl \
  rpm-devel \
  screen \
  sqlite-devel \
  swig \
  zchunk-devel \
  zlib-devel \
  -y

RUN python3 -m venv --system-site-packages /usr/local/lib/pulp
ENV PATH="/usr/local/lib/pulp/bin:${PATH}"
ENV PYTHONPATH="/usr/local/lib/pulp/lib/python3.6/site-packages"

RUN pip3 install scikit-build
RUN pip3 install pulpcore==3.4.1 pulp-rpm==3.4.1
RUN pip3 install --upgrade jsonschema

ENV DJANGO_SETTINGS_MODULE="pulpcore.app.settings"
ENV LANG="en_US.utf8"
ENV PULP_CHUNKED_UPLOAD_DIR="/var/repos/.pulp/upload/"
ENV PULP_CONTENT_ORIGIN="http://repo:24816"
ENV PULP_FILE_UPLOAD_TEMP_DIR="/var/repos/.pulp/tmp/"
ENV PULP_MEDIA_ROOT="/var/repos/.pulp/media/"
ENV PULP_REDIS_URL="unix:///var/run/redis/redis.sock"
ENV PULP_STATIC_ROOT="/var/repos/.pulp/static/"
ENV PULP_WORKING_DIRECTORY="/var/repos/.pulp/tmp/"
