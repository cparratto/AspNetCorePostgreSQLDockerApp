FROM ubuntu

RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -q -y install libpq-dev curl nuget autoconf automake build-essential libtool nodejs-legacy nodejs-dev npm git-core

ENV MONO_VERSION="mono-4.0.4.1" \
    DNX_VERSION="1.0.0-beta5" \
    MONO_THREADS_PER_CPU="2000" \
    DNX_USER_HOME="/opt/dnx" \
    NODE_ENV="production"

RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && echo "deb http://download.mono-project.com/repo/debian wheezy/snapshots/4.0.5.1 main" > /etc/apt/sources.list.d/mono-xamarin.list \
    && echo "deb http://download.mono-project.com/repo/debian 40-security main" >> /etc/apt/sources.list.d/mono-xamarin.list \
    && apt-get update
RUN apt-get install -y mono-devel ca-certificates-mono fsharp mono-vbnc nuget \
    && curl -sSL https://raw.githubusercontent.com/aspnet/Home/dev/dnvminstall.sh | DNX_USER_HOME=$DNX_USER_HOME DNX_BRANCH=v$DNX_VERSION sh \
    && bash -c "source $DNX_USER_HOME/dnvm/dnvm.sh && dnvm install $DNX_VERSION -alias default &&dnvm alias default | xargs -i ln -s $DNX_USER_HOME/runtimes/{} $DNX_USER_HOME/runtimes/default" \
    && curl -sSL https://github.com/libuv/libuv/archive/v${LIBUV_VERSION}.tar.gz | tar zxfv - -C /usr/local/src \
    && cd /usr/local/src/libuv-$LIBUV_VERSION \
    && sh autogen.sh && ./configure && make && make install \
    && rm -rf /usr/local/src/libuv-$LIBUV_VERSION \
    && ldconfig
RUN mkdir -p /app
RUN npm install -g bower && npm install bower
RUN npm install -g gulp && npm install gulp
WORKDIR /app
RUN rm -rf ./node_modules \
    && npm install --production
RUN echo '{ "allow_root": true }' > ~/.bowerrc \
    && bower install --config.interactive=false