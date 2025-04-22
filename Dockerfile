FROM clfoundation/sbcl:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        git \
        make \
        libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/roswell/roswell/releases/download/v21.10.14.111/roswell_21.10.14.111-1_amd64.deb \
    && dpkg -i roswell_21.10.14.111-1_amd64.deb \
    && rm roswell_21.10.14.111-1_amd64.deb \
    && ros setup

RUN sbcl --eval '(ql:add-to-init-file)' --quit

RUN ros install

WORKDIR /usr/src/app

COPY . .

CMD ["ros", "roswell/makima.ros"]
