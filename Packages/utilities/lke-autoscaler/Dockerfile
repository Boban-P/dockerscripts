FROM php:7.4-cli

RUN apt-get update && apt-get install -y git zip unzip && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    test "$(php -r "echo file_get_contents('https://composer.github.io/installer.sig');")" = "$(php -r "echo hash_file('SHA384', 'composer-setup.php');")" && \
    php composer-setup.php --quiet && \
    rm composer-setup.php && \
    mv /composer.phar /usr/bin/composer && \
    docker-php-ext-install pcntl && \
    rm -rf  /var/lib/apt/lists/*

COPY data/ /autoscaler/

RUN cd /autoscaler/ && composer install --no-dev

ENV LINODE_PERSONAL_ACCCESS_TOKEN "XXXXXXXXXXXXXXXXX"
ENV LINODE_LKE_CLUSTER_ID "1234"
ENV LINODE_LKE_CLUSTER_POOL_ID "567890"
ENV LINODE_LKE_CLUSTER_POOL_MINIMUM_NODES "3"
ENV LINODE_LKE_CLUSTER_POOL_MAXIMUM_NODES "50"

ENV AUTOSCALE_MEMORY_UP_PERCENTAGE "100"
ENV AUTOSCALE_MEMORY_DOWN_PERCENTAGE "0"
ENV AUTOSCALE_CPU_UP_PERCENTAGE "100"
ENV AUTOSCALE_CPU_DOWN_PERCENTAGE "0"
ENV AUTOSCALE_QUERY_INTERVAL "10"
ENV AUTOSCALE_THRESHOLD_COUNT "3"
ENV AUTOSCALE_WAIT_TIME_AFTER_SCALING "180"

CMD ["php", "/autoscaler/bin/autoscale"]
