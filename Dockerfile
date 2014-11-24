#
# ElasticSearch Dockerfile
#
# Originally from https://github.com/dockerfile/elasticsearch
#

# Pull base image.
FROM cikl/base:0.0.2
MAINTAINER Mike Ryan <falter@gmail.com>

# Install Java.
RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get install --no-install-recommends -y openjdk-7-jre-headless && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

# Install ElasticSearch.
RUN \
  export ES_VERSION=1.2.4 && \
  cd /tmp && \
  wget -q https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-$ES_VERSION.tar.gz && \
  tar xvzf elasticsearch-$ES_VERSION.tar.gz && \
  rm -f elasticsearch-$ES_VERSION.tar.gz && \
  mv /tmp/elasticsearch-$ES_VERSION /elasticsearch


# Define mountable directories.
VOLUME ["/data"]

RUN useradd -s /bin/false -d /data -m elasticsearch
ENV ENTRYPOINT_DROP_PRIVS 1
ENV ENTRYPOINT_USER elasticsearch

ADD elasticsearch-command.sh /etc/docker-entrypoint/commands.d/elasticsearch
ADD elasticsearch-pre.sh /etc/docker-entrypoint/pre.d/elasticsearch-pre.sh
RUN chmod a+x /etc/docker-entrypoint/commands.d/elasticsearch

# Mount elasticsearch.yml config
ADD elasticsearch.yml /elasticsearch/config/elasticsearch.yml
ENV ES_CLUSTER_NAME cikl

# Define working directory.
WORKDIR /data

# Define default command.
CMD [ "elasticsearch" ]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 9200
EXPOSE 9300
