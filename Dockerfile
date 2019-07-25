# этап сборки (build stage)
FROM node:10.15.1 as build-stage

ARG ASSEMBLY
RUN echo "Building version: ${ASSEMBLY}"
RUN apt-get install libpng-dev

RUN mkdir /app
WORKDIR /app
COPY . /app/.

RUN npm install
COPY . .
RUN npm run ${ASSEMBLY}

ARG WEB_USER_ID=33
ARG WEB_USER_NAME=www-data
RUN echo "Building for web user: id=${WEB_USER_ID} name=${WEB_USER_NAME}"
RUN adduser -D -u ${WEB_USER_ID} ${WEB_USER_NAME} || echo "Users exists"
USER ${WEB_USER_ID}


# этап production (production-stage)
FROM nginx as production-stage
WORKDIR .
RUN apt-get update && apt-get install logrotate -y

COPY default.conf /etc/nginx/conf.d/default.conf
COPY ./logrotate_nginx /etc/logrotate.d/nginx

RUN sed -e 's/^worker_processes.*/worker_processes 5;/' -i /etc/nginx/nginx.conf

### ADD WEB USER ###
ARG WEB_USER_ID=33
ARG WEB_USER_NAME=www-data
RUN echo "Building for web user: id=${WEB_USER_ID} name=${WEB_USER_NAME}"
RUN useradd -m -u ${WEB_USER_ID} ${WEB_USER_NAME} || echo "User exists"
RUN sed -i -- "s/user  nginx;/user ${WEB_USER_NAME};/" /etc/nginx/nginx.conf
### ADD WEB USER ###

COPY --from=build-stage /app/public /var/www/public
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
