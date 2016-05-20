FROM debian:jessie

RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -q -y install libpq-dev build-essential git-core wget libssl-dev

ENV NODE_VERSION="4.4.4" \
    DOTNET_CORE_VERSION="1.0.0-preview1-002702" \
    NODE_ENV="production"

RUN echo "deb [arch=amd64] http://llvm.org/apt/jessie/ llvm-toolchain-jessie-3.6 main" > /etc/apt/sources.list.d/llvm.list \
    && wget -q -O - http://llvm.org/apt/llvm-snapshot.gpg.key|apt-key add -  \
    && apt-get update \
    && apt-get install -y --no-install-recommends clang-3.5 libc6 libcurl3 libgcc1 libicu52 liblttng-ust0 libssl1.0.0 libstdc++6 libtinfo5 libunwind8 libuuid1 zlib1g make git ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/tj/n.git ~/.n \
    && cd ~/.n \
    && make install \
    && n ${NODE_VERSION} \
    && rm -rf ~/.n
RUN curl -SL https://dotnetcli.blob.core.windows.net/dotnet/beta/Binaries/$DOTNET_CORE_VERSION/dotnet-debian-x64.$DOTNET_CORE_VERSION.tar.gz --output dotnet.tar.gz \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
RUN mkdir -p /app
COPY . /app/
RUN npm install -g bower && npm install bower
RUN npm install -g gulp && npm install gulp
WORKDIR /app
RUN /usr/share/dotnet/dotnet restore
RUN rm -rf ./node_modules \
    && npm install --production
RUN echo '{ "allow_root": true }' > ~/.bowerrc \
    && bower install --config.interactive=false

EXPOSE 5000

ENTRYPOINT /usr/share/dotnet/dotnet run