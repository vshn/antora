# renovate: track the base image tag and its digest, so a Node patch release produces a rebuild
FROM node:26-alpine@sha256:c6ad9e9c1d80f6eb607c26b4b0a132ff7a2344fad1c78ea3baa2a7d4c8de6d94

ENV NODE_PATH=/usr/local/share/.config/yarn/global/node_modules

# Every package is pinned: an unpinned package changed version on every rebuild, which made rebuilds risky
# and left the image on Node 24.17 for months. Versions below are the ones the 3.1.14 image shipped.
RUN apk --no-cache add curl findutils jq make git yq \
    && yarn global add --ignore-optional --silent \
       @antora/cli@3.1.14 \
       @antora/site-generator-default@3.1.14 \
       asciidoctor-kroki@0.18.1 \
       mkdirp@3.0.1 \
       unxhr@1.2.0 \
       antora-site-generator-lunr@0.6.1 \
    && rm -rf $(yarn cache dir)/* /tmp/*

# Required since Antora 2.2 to customize the "edit this page" URL
ENV FORCE_SHOW_EDIT_PAGE_LINK=1
ENV CI=1

WORKDIR /antora

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["antora"]
