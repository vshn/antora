FROM antora/antora:2.3.0

# Required by the CI/CD pipeline in GitLab
RUN apk update && apk add make

RUN yarn cache clean
RUN yarn global add asciidoctor-kroki mkdirp unxhr

