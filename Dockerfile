FROM centos:centos7
MAINTAINER Johnny Zheng <johnny@itfolks.com.au>

# - Install basic packages needed by supervisord
# - Install inotify, needed to automate daemon restarts after config file changes
# - Install supervisord (via python's easy_install - as it has the newest 3.x version)

#Install tools
RUN yum install -y yum-utils epel-release python-setuptools inotify-tools unzip sendmail tar mysql sudo

#Install yum repos and utils
RUN rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm  && \
    rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
    yum-config-manager -q --enable remi && \
    yum-config-manager -q --enable remi-php55

#Install nginx, php-fpm and php extensions
RUN yum install -y nginx
RUN yum install -y php-fpm
RUN yum install -y php-mysqlnd php-mysqli php-gd php-mcrypt php-zip php-xml php-iconv php-curl php-soap php-simplexml php-pdo php-dom php-cli
RUN yum install -y php-bcmath php-intl php-mbstring php-opcache php-pecl-apc php-pecl-memcache php-pecl-redis

#Clean up yum repos to save spaces
RUN yum update -y && yum clean all

#Install supervisor
RUN easy_install supervisor
#Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#Update nginx user group and name
RUN groupmod --gid 80 --new-name www nginx && \
    usermod --uid 80 --home /data/www --gid 80 --login www --shell /bin/bash --comment www nginx && \
    rm -rf /etc/nginx/*.d /etc/nginx/*_params && \
    chown -R www:www /var/lib/nginx

#Add pre-configured files
ADD container-files /
RUN find /config |grep .sh |xargs chmod +x

VOLUME ["/data"]

EXPOSE 80 443

ENTRYPOINT ["/config/bootstrap.sh"]
