FROM getcarrier/dast:base
#   Copyright 2018-2019 getcarrier.io
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
LABEL author="artem_rozumenko@epam.com"
LABEL updated.by="ivan_krakhmaliuk@epam.com"

# Dusty
RUN set -x \
  && pip3 install git+https://github.com/reportportal/client-Python.git \
  && pip3 install git+https://github.com/carrier-io/dusty.git

# Workspace
WORKDIR /tmp
RUN mkdir /tmp/reports
ADD supervisor.conf /etc/supervisor/conf.d/supervisor.conf
ADD w3af_full_audit.w3af /tmp/w3af_full_audit.w3af
COPY scan-config.yaml /tmp/scan-config.yaml
ENTRYPOINT ["run"]
