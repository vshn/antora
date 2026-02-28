FROM node:24-alpine

ENV NODE_PATH=/usr/local/share/.config/yarn/global/node_modules

RUN apk --no-cache add curl findutils jq make git yq \
    && yarn global add --ignore-optional --silent \
       @antora/cli@3.1.14 \
       @antora/site-generator-default@3.1.14 \
       asciidoctor-kroki \
       mkdirp \
       unxhr \
       antora-site-generator-lunr \
    && rm -rf $(yarn cache dir)/* /tmp/*

# Required since Antora 2.2 to customize the "edit this page" URL
ENV FORCE_SHOW_EDIT_PAGE_LINK=1
ENV CI=1

WORKDIR /antora

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["antora"]
