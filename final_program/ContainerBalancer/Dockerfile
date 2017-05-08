#Se usa el contenedor con nginx pre instalado
FROM nginx

#delete configuration file default
RUN rm /etc/nginx/conf.d/default.conf && rm -r /etc/nginx/conf.d

#add nginx's configuration file
ADD nginx.conf /etc/nginx/nginx.conf

#Container don't stop execution
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
CMD service nginx start
