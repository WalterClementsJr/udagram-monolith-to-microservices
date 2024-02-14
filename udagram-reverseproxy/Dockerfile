FROM nginx:1.25.3-alpine
ARG tempFile="/etc/nginx/.nginx"
COPY nginx.conf $tempFile
# generate conf file
RUN envsubst '\$API_FEED_HOST \$API_USER_HOST' < $tempFile > /etc/nginx/nginx.conf
