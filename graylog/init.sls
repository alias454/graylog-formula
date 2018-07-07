{% from "graylog/map.jinja" import host_lookup as config with context %}

include:
  - .graylog-repo
  - .graylog-package
  - .graylog-plugins
  - .graylog-config
  - .graylog-service
  - .{{ config.firewall.firewall_include }}
