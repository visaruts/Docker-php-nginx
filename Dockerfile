FROM        edyan/php:7.4

ARG         ACCEPT_EULA=Y
ARG         DEBIAN_FRONTEND=noninteractive

RUN         apt-get update -qq && \
            apt-get install -qq -y curl gnupg git && \
            echo "deb [arch=amd64] https://packages.microsoft.com/ubuntu/20.04/prod focal main" > /etc/apt/sources.list.d/mssql.list && \
            curl -sS https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
            apt-get update -qq && \
            apt-get install -qq -y -o Dpkg::Options::="--force-confold" \
                # To keep
                mssql-tools unixodbc php7.4-sybase \
                # remove later
                unixodbc-dev php-pear php7.4-dev \
                gcc g++ build-essential && \
            # sqlsrv from PECL
            pecl channel-update pecl.php.net && \
            # Compile
            pecl -q -D "error_reporting=32759" install sqlsrv pdo_sqlsrv && \
            # Activate
            echo "extension=pdo_sqlsrv.so" > /etc/php/current/mods-available/pdo_sqlsrv.ini && \
            echo "extension=sqlsrv.so" > /etc/php/current/mods-available/sqlsrv.ini && \

            phpenmod pdo_sqlsrv sqlsrv && \
            # Remove useless packages / files
            pear clear-cache && \
            apt-get purge -qq --autoremove -y curl gnupg unixodbc-dev php-pear php7.4-dev gcc g++ build-essential && \
            # Clean
            apt-get autoremove -qq -y && \
            apt-get autoclean -qq && \
            apt-get clean -qq && \
            # Empty some directories from all files and hidden files
            rm -rf /build /tmp/* /usr/share/php/docs /usr/share/php/tests && \
            find /root /var/lib/apt/lists /usr/share/man /usr/share/doc /var/cache /var/log -type f -delete

# COPY        tests/sqlsrv.php /root/test.php

# At the end as it changes everytime ;)
ARG         BUILD_DATE
ARG         DOCKER_TAG
ARG         VCS_REF
LABEL       maintainer="Visarut Sihink <visarut.sihink@gmail.com>" \
            org.label-schema.build-date=${BUILD_DATE} \
            org.label-schema.name=${DOCKER_TAG} \
            org.label-schema.description="Docker PHP Image based on Debian and including main modules" \
            org.label-schema.url="https://cloud.docker.com/u/edyan/repository/docker/edyan/php" \
            org.label-schema.vcs-url="https://github.com/edyan/docker-php" \
            org.label-schema.vcs-ref=${VCS_REF} \
            org.label-schema.schema-version="1.0" \
            org.label-schema.vendor="edyan" \
            org.label-schema.docker.cmd="docker run -d --rm ${DOCKER_TAG}"