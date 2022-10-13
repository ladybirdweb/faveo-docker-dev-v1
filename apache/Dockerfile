FROM ladybird/faveo-dev-apache2

RUN apt-get update && apt-get upgrade -y

RUN curl -sL https://deb.nodesource.com/nodejs-version | bash -

RUN apt-get install nodejs

RUN apt-get clean

COPY ./faveorootCA.crt /usr/local/share/ca-certificates/
 
RUN update-ca-certificates

CMD apache2ctl -D FOREGROUND
