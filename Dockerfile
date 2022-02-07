FROM debian:buster
MAINTAINER Niboo SRL <info@niboo.com>

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update --fix-missing \
        && apt-get upgrade -fy \
        && apt-get install -fy --no-install-recommends \
            ca-certificates \
            curl \
            node-less \
            python3-pip \
            python3-setuptools \
            python3-dev \
            build-essential \
            libsasl2-dev \
            libldap2-dev \
            libpq-dev \
            libssl-dev \
            xz-utils \
            postgresql-client-common \
            postgresql-client \
            git

# Install Odoo
ARG ODOO_TAG
ARG INTERNAL_BRANCH="15.0"
ARG CI_JOB_TOKEN

RUN set -x; \
        mkdir -p /opt/local/odoo \
        && useradd odoo -d /opt/local/odoo -p odoo \
        && cd /opt/local/odoo \
        && git clone -b ${ODOO_TAG} --single-branch --depth 1 https://github.com/Niboo/odoo.git odoo \
        && ln -s /opt/local/odoo/odoo/odoo-bin /usr/bin/odoo \
        # copy Internal/ Server-tools
        && git clone -b ${INTERNAL_BRANCH} --single-branch --depth 1 https://gitlab-ci-token:$CI_JOB_TOKEN@gitlab.niboo.com/internal/server-tools.git server-tools

RUN set -x; \
        pip3 install --upgrade pip \
        && pip3 install wheel \
        && pip3 install -r /opt/local/odoo/odoo/requirements.txt \
        && pip3 install openpyxl \
        && pip3 install dbfread \
        && pip3 install firebase-admin \
        && pip3 install openupgradelib \
        && pip3 install redis \
        && pip3 install paramiko \
        && curl -o wkhtmltox.deb -SL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
        && apt install -y ./wkhtmltox.deb \
        && rm wkhtmltox.deb

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /

# Expose Odoo services
EXPOSE 8069 8071

# Set the default config file
COPY ./odoo.conf /etc/odoo/
RUN echo "addons_path = /opt/local/odoo/odoo/addons,/opt/local/odoo/odoo/odoo/addons,/opt/local/odoo/server-tools" > /etc/odoo/addons.conf
RUN cat /etc/odoo/addons.conf >> /etc/odoo/odoo.conf
RUN chown -R odoo /etc/odoo
ENV ODOO_RC /etc/odoo/odoo.conf

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]

