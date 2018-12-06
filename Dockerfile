FROM ubuntu:xenial

MAINTAINER artem_rozumenko@epam.com

ARG ARACHNI_VERSION=1.5.1
ARG ARACHNI_WEB_VERSION=0.5.12
ARG NMAP_VERSION=7.40
ARG SSLYZE_VERSION=2.0.1
ARG ZAP_VERSION=2.7.0
ARG W3AF_REVISION=356b14b975039706f4fd7f4f5db5b114cd75f14e
ARG QUALYS_LOGIN
ARG QUALYS_PASSWORD

ENV QUALYS_LOGIN ${QUALYS_LOGIN}
ENV QUALYS_PASSWORD ${QUALYS_PASSWORD}

RUN apt-get -qq update && apt-get install -y --no-install-recommends software-properties-common
RUN add-apt-repository ppa:jonathonf/python-3.6 && apt-get -qq update
RUN apt-get -qq install -y --no-install-recommends default-jre default-jdk xvfb wget ca-certificates git gcc make \
            build-essential libssl-dev zlib1g-dev libbz2-dev libpcap-dev \
            libreadline-dev libsqlite3-dev curl llvm libncurses5-dev libncursesw5-dev \
            xz-utils tk-dev libffi-dev liblzma-dev perl libnet-ssleay-perl python-dev python-pip \
            libxslt1-dev libxml2-dev libyaml-dev openssh-server  python-lxml wget \
            xdot python-gtk2 python-gtksourceview2 dmz-cursor-theme supervisor \
            python-setuptools && \
    pip install pip setuptools --upgrade && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

# Installing NodeJS for W3AF
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get -qq install -y --no-install-recommends nodejs
RUN npm -g i n && n 10.13.0 --test && npm -g i npm@6.1 http-server@0.11.1 retire@1.6.0 --test

# Installing Java for ZAP
RUN  cd /opt && \
     wget https://download.java.net/java/GA/jdk10/10.0.2/19aef61b38124481863b1413dce1855f/13/openjdk-10.0.2_linux-x64_bin.tar.gz && \
     tar vxfz openjdk-10.0.2_linux-x64_bin.tar.gz && rm -rf openjdk-10.0.2_linux-x64_bin.tar.gz

# Installing Arachni
RUN mkdir /opt/arachni && cd /tmp && \
    wget -qO- https://github.com/Arachni/arachni/releases/download/v${ARACHNI_VERSION}/arachni-${ARACHNI_VERSION}-${ARACHNI_WEB_VERSION}-linux-x86_64.tar.gz | tar xvz -C /opt/arachni --strip-components=1

# Installing masscan
RUN cd /opt && git clone https://github.com/robertdavidgraham/masscan && cd masscan && make -j4

# Installing nikto
RUN cd /opt && git clone https://github.com/sullo/nikto

# Installing nmap
RUN cd /tmp && curl -O https://nmap.org/dist/nmap-${NMAP_VERSION}.tar.bz2 && bzip2 -cd nmap-${NMAP_VERSION}.tar.bz2 | tar xvf - && \
    cd nmap-${NMAP_VERSION} && bash configure && make && make install

## Installing w3af
RUN cd /opt && git clone https://github.com/andresriancho/w3af.git && cd w3af/ && \
    git reset --hard ${W3AF_REVISION} && ./w3af_console ; true && \
    sed 's/sudo //g' -i /tmp/w3af_dependency_install.sh && \
    sed 's/apt-get/apt-get -y/g' -i /tmp/w3af_dependency_install.sh && \
    sed 's/pip install/pip install --upgrade/g' -i /tmp/w3af_dependency_install.sh && \
    /tmp/w3af_dependency_install.sh && \
    sed 's/dependency_check()/#dependency_check()/g' -i w3af_console


# Installing ZAP
RUN mkdir /opt/zap && cd /tmp && \
    wget -qO- https://github.com/zaproxy/zaproxy/releases/download/${ZAP_VERSION}/ZAP_${ZAP_VERSION}_Linux.tar.gz | tar xvz -C /opt/zap --strip-components=1 && \
    chmod +x /opt/zap/zap.sh && pip install zapcli==0.9.0

# Installing sslyze
RUN apt-get -y --no-install-recommends install python3.6 python3.6-dev
RUN wget https://bootstrap.pypa.io/get-pip.py && python3.6 get-pip.py && ln -s /usr/bin/python3.6 /usr/local/bin/python3
RUN pip3 install pip --upgrade
RUN pip3 install setuptools  --upgrade
RUN pip3 --version
RUN pip3 install sslyze==${SSLYZE_VERSION} && python3 -m sslyze --update_trust_stores

ENV PATH /opt/jdk-10.0.2/bin:/opt/arachni:/opt/masscan/bin:/opt/nikto/program:/opt/zap/ZAP_${ZAP_VERSION}:/opt/w3af:$PATH

WORKDIR /tmp
RUN mkdir /tmp/reports
ADD	supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY scan-config.yaml /tmp/scan-config.yaml

# Installing Dusty
ADD w3af_full_audit.w3af /tmp/w3af_full_audit.w3af
RUN pip3 install git+https://github.com/reportportal/client-Python.git
RUN pip3 install git+https://github.com/carrier-io/dusty.git

ENTRYPOINT ["run"]