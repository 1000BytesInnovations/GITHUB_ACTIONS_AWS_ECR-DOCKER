# Top level build args
ARG build_for=linux/x86-64

# base image (abstract)
FROM --platform=$build_for python:3.10.7-slim-bullseye as base

# N.B. The refs updated automagically every release via bumpversion
ARG dbt_core_ref=dbt-core@v1.8.0b1
ARG dbt_snowflake_ref=dbt-snowflake@v1.8.0b1

# System setup
#
RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y --no-install-recommends \
    git \
    ssh-client \
    software-properties-common \
    make \
    build-essential \
    ca-certificates \
    libpq-dev \
  && apt-get clean \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

# Env vars
ENV PYTHONIOENCODING=utf-8
ENV LANG=C.UTF-8
ENV DBT_PROFILES_DIR=/usr/app/dbt
ENV DBT_PROJECT_DIR=/usr/app/dbt

# Update python
RUN python -m pip install --upgrade pip setuptools wheel --no-cache-dir

# Install dbt-core and dbt-snowflake
RUN python -m pip install --no-cache-dir "git+https://github.com/dbt-labs/${dbt_core_ref}#egg=dbt-core&subdirectory=core"
RUN python -m pip install --no-cache-dir "git+https://github.com/dbt-labs/${dbt_snowflake_ref}#egg=dbt-snowflake"

# Set docker basics
COPY . /usr/app/dbt
ENTRYPOINT ["/bin/sh","-c"]
CMD [ "dbt deps && dbt test && dbt run" ]

