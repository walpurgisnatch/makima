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

RUN mkdir -p ~/.config/common-lisp/source-registry.conf.d \
    && echo "(:tree \"/usr/src/app\")" > \
    ~/.config/common-lisp/source-registry.conf.d/conf.conf

CMD ["ros", "roswell/makima.ros"]
