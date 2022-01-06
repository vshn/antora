FROM antora/antora:3.0.0

# Required by the CI/CD pipeline in GitLab
RUN apk update && apk add make

RUN yarn cache clean
RUN yarn global add asciidoctor-kroki mkdirp unxhr

# These environment variables are required since Antora 2.2
# to customize the "edit this page" URL
# https://docs.antora.org/antora/2.2/whats-new/#customizable-edit-url
ENV FORCE_SHOW_EDIT_PAGE_LINK=1
ENV CI=1

