FROM ubuntu:18.04
MAINTAINER Maris Locmelis

RUN rm -f /etc/localtime
RUN ln -s /usr/share/zoneinfo/UTC /etc/localtime

RUN apt-get update && apt-get install software-properties-common wget unzip curl -y

RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update && apt-get install -y \
      apt-utils \
      apache2 \
      sudo \
      iputils-ping \
      git

RUN apt-get install -y \
      php7.3-cli \
      libapache2-mod-php7.3 \
      php7.3-json \
      php7.3-mbstring \
      php7.3-mysql \
      php7.3-opcache \
      php7.3-xml \
      php7.3-curl \
      php7.3-bcmath \
      php7.3-xdebug \
      php7.3-xmlrpc \
      php7.3-xsl

ENV USER=developer USER_ID=1000 USER_GID=1000

#install latest composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'a5c698ffe4b8e849a443b120cd5ba38043260d5c4023dbf93e1558871f1f07f58274fc6f4c93bcfd858c6bd0775cd8d1') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

# now creating user
RUN groupadd --gid "${USER_GID}" "${USER}" && \
    useradd \
      --uid ${USER_ID} \
      --gid ${USER_GID} \
      --create-home \
      --shell /bin/bash \
      ${USER}

RUN usermod -a -G www-data developer

COPY conf/system/sudoers /etc/sudoers

RUN mkdir -p /opt/php
RUN mkdir -p /opt/xdebug
RUN chmod -R 0777 /opt/xdebug

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_DOCUMENT_ROOT=/www/default

COPY conf/apache/apache2.conf /etc/apache2/apache2.conf
COPY conf/apache/apache_default /etc/apache2/sites-available/000-default.conf
COPY conf/apache/apache_status.conf /etc/apache2/mods-enabled/status.conf
COPY apache_root_config.sh /usr/local/bin/apache_root_config.sh
RUN chmod +x /usr/local/bin/apache_root_config.sh && \
    chmod +x /usr/local/bin/composer && \
    chown -R developer /tmp && \
    chown -R developer /etc/apache2/sites-enabled && \
    chown -R developer /etc/apache2/envvars && \
    chown -R developer /usr/sbin/apache2

RUN a2enmod rewrite
RUN a2enmod vhost_alias

RUN sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php/7.3/apache2/php.ini && \
    sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php/7.3/cli/php.ini && \
    sed -ri "s/^error_reporting\s*=.*$//g" /etc/php/7.3/apache2/php.ini && \
    sed -ri "s/^error_reporting\s*=.*$//g" /etc/php/7.3/cli/php.ini && \
    echo "error_reporting = E_ALL" >> /etc/php/7.3/apache2/php.ini && \
    echo "error_reporting = E_ALL" >> /etc/php/7.3/cli/php.ini && \
    echo "xdebug.var_display_max_depth = 10" >> /etc/php/7.3/apache2/php.ini && \
    echo "xdebug.profiler_enable = 0" >> /etc/php/7.3/apache2/php.ini && \
    echo "xdebug.profiler_enable_trigger = 1" >> /etc/php/7.3/apache2/php.ini && \
    echo "xdebug.profiler_output_dir = \"/opt/xdebug\"" >> /etc/php/7.3/apache2/php.ini && \
    echo "xdebug.idekey = \"debug\"" >> /etc/php/7.3/apache2/php.ini && \
    echo "xdebug.idekey = \"debug\"" >> /etc/php/7.3/cli/php.ini && \
    echo "xdebug.var_display_max_depth = 10" >> /etc/php/7.3/cli/php.ini && \
    echo "xdebug.profiler_output_dir = \"/opt/xdebug\"" >> /etc/php/7.3/cli/php.ini && \
    echo 'xdebug.remote_autostart = 1' >> /etc/php/7.0/apache2/php.ini && \
    echo 'xdebug.remote_enable = 1' >> /etc/php/7.0/apache2/php.ini && \
    echo 'xdebug.remote_connect_back = 1' >> /etc/php/7.0/apache2/php.ini

WORKDIR ${APACHE_DOCUMENT_ROOT}
USER developer

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/apache_root_config.sh"]
