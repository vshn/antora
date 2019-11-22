FROM antora/antora:2.2.0

RUN apk update && apk add make

RUN yarn global add asciidoctor-kroki

