FROM phpmyadmin:apache
LABEL maintainer="David Luis david.lu1992@gmail.com"

EXPOSE 80/tcp
EXPOSE 80/udp
EXPOSE 443/tcp
EXPOSE 443/udp

# Enable a2mods
RUN a2enmod ssl

# Enable site-ssl
RUN a2ensite default-ssl