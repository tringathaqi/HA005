# Instalimi i Sistemit Operativ te kontenjerit - Imazhi Baze
FROM ubuntu:18.04 as HUGOSETUP
ARG HUGO_VERSION=0.59.1
ENV DOCUMENT_DIR=/hugo-faqja
RUN apt-get update && apt-get upgrade -y \
      && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
           ruby ruby-dev make cmake build-essential bison flex \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
      && rm -rf /tmp/*
RUN gem install --no-document asciidoctor asciidoctor-revealjs \
         rouge asciidoctor-confluence asciidoctor-diagram coderay pygments.rb
# Instalimi i Hugo
ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz /tmp/hugo.tgz
RUN cd /usr/local/bin && tar -xzf /tmp/hugo.tgz && rm /tmp/hugo.tgz
# Kopjo permbajtjen nga follderi aktual ne follderin e faqes se hugos.
COPY ./hugo-faqja /hugo-faqja
WORKDIR /hugo-faqja
# Perdor Hugo per te gjeneruar fajllat statik te faqes.
RUN hugo -v --source=/hugo-faqja --destination=/hugo-faqja/public
# Instalo NGINX dhe vendos fajllat statik te hugos ne follderin html te NGINX.
# Largo faqen e parazgjedhur index.html.
FROM nginx:stable-alpine
RUN mv /usr/share/nginx/html/index.html /usr/share/nginx/html/index.old
COPY --from=HUGOSETUP /hugo-faqja/public /usr/share/nginx/html
# Konteineri do te ndegjoje ne portin TCP 80
EXPOSE 80
