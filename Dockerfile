FROM timbru31/node-alpine-git
RUN yarn global add @sanity/cli
RUN apk add --no-cache jq
RUN apk add --no-cache curl
RUN git config --global user.name "liberty"
RUN git config --global user.email "platformservices@gmail.com"
COPY entrypoint.sh /
COPY production.tar.gz /
ENTRYPOINT ["/entrypoint.sh"]
