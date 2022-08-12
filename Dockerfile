FROM httpd:2.4 
MAINTAINER kkkaty 
COPY ./index.html /usr/local/apache2/htdocs/ 
EXPOSE 80 	
