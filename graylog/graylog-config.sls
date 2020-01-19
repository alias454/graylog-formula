# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "graylog/map.jinja" import host_lookup as config with context %}

# Manage graylog server config file using template
/etc/graylog/server/server.conf:
  file.managed:
    - source: salt://graylog/files/server.conf
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - makedirs: true

# Manage graylog-server file in sysconfig/default using template
{{ config.graylog.startup_overrides_path }}:
  file.managed:
    - source: salt://graylog/files/graylog-server.sysconfig
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'

# Manage graylog log4j2 file using template
/etc/graylog/server/log4j2.xml:
  file.managed:
    - source: salt://graylog/files/log4j2.xml
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - makedirs: true

# Manage graylog node-id file
/etc/graylog/server/node-id:
  file.managed:
    - user: graylog
    - group: graylog
    - mode: '0644'
    - makedirs: true

# Manage log directory
{{ config.graylog.log4j2_log_path }}:
  file.directory:
    - user: graylog
    - group: graylog
    - mode: '0750'
    - makedirs: true

# Manage journal directory
{{ config.graylog.message_journal.dir }}:
  file.directory:
    - user: graylog
    - group: graylog
    - mode: '0755'
    - makedirs: true
