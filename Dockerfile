FROM antora/antora

RUN apk update && apk add make

RUN yarn global add asciidoctor-plantuml

