FROM jekyll/jekyll:3.4 AS builder
#FROM jekyll/jekyll:3.4
WORKDIR /build
COPY . /build
RUN echo 'URL: "http://rancher.com"' >> _config.yml \
    && echo 'baseurl: "/best-practice-guide"' >> _config.yml \
    && jekyll build

FROM nginx
ENV DOCROOT /usr/share/nginx/html
COPY --from=builder /build/_site $DOCROOT/best-practice-guide
COPY --from=builder /build/favicon.png $DOCROOT/favicon.png
