FROM debian:10

RUN apt-get update \
 && apt-get install -y \
    curl \
    dumb-init \
    htop \
    locales \
    npm \
    man \
    nano \
    git \
    wget \
    unzip \
    procps \
    sudo \
    ssh \
    vim \
  && rm -rf /var/lib/apt/lists/*

# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen
ENV LANG=en_US.UTF-8

RUN chsh -s /bin/bash
ENV SHELL=/bin/bash

RUN adduser --gecos '' --disabled-password coder && \
  echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4.1/fixuid-0.4.1-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml

RUN cd /tmp && \
  curl -L --silent \
  `curl --silent "https://api.github.com/repos/cdr/code-server/releases/latest" \
    | grep '"browser_download_url":' \
    | grep "linux-amd64" \
    |  sed -E 's/.*"([^"]+)".*/\1/' \
  `| tar -xzf - && \
  mv code-server* /usr/local/lib/code-server && \
  ln -s /usr/local/lib/code-server/bin/code-server /usr/local/bin/code-server

ENV PORT=8080
EXPOSE 8080
USER coder
RUN sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && sudo unzip awscliv2.zip && sudo ./aws/install
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
RUN sudo npm i -g firebase-tools
RUN curl https://sdk.cloud.google.com | bash
WORKDIR /home/coder
RUN pwd
RUN echo 'eval "$(starship init bash)"' >> .bashrc
CMD /usr/local/bin/code-server --auth none --disable-telemetry --bind-addr 0.0.0.0:$PORT .
