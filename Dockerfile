FROM ubuntu

RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -q -y install libpq-dev curl unzip s3cmd git autoconf libtool automake build-essential mono-devel gettext python nodejs-legacy nodejs-dev npm git-core

ENV MONO_VERSION="mono-4.0.4.1" \
    NODE_ENV="production"

WORKDIR /deploy
RUN apt-key adv --keyserver pgp.mit.edu --recv-keys $MONO_VERSION \
    && git clone git://github.com/mono/llvm.git \
    && cd /deploy/llvm \
    && ./configure --enable-optimized --enable-targets="x86 x86_64" \
    && make \
    && make install \
    && cd /deploy \
    && git clone git://github.com/mono/mono --branch $MONO_VERSION \
    && cd /deploy/mono \
    && bash ./autogen.sh --enable-llvm=yes \
    && make get-monolite-latest \
    && make \
    && make install \
    && apt-get remove -y --purge git autoconf libtool automake build-essential mono-devel gettext python \
    && apt-get autoremove -y \
    && rm -rf /deploy
RUN mkdir -p /app
RUN npm install -g bower && npm install bower
RUN npm install -g gulp && npm install gulp
WORKDIR /app
RUN rm -rf ./node_modules \
    && npm install --production
RUN echo '{ "allow_root": true }' > ~/.bowerrc \
    && bower install --config.interactive=false