{% from "graylog/map.jinja" import host_lookup as config with context %}

/etc/graylog/server/server.conf:
  file.managed:
    - source: salt://graylog/files/server.conf
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - makedirs: true

/etc/graylog/server/log4j2.xml:
  file.managed:
    - source: salt://graylog/files/log4j2.xml
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - makedirs: true

/etc/graylog/server/node-id:
  file.managed:
    - user: graylog
    - group: graylog
    - mode: '0644'
    - makedirs: true

{{ config.graylog.log4j2_log_path }}:
  file.directory:
    - user: graylog
    - group: graylog
    - mode: '0750'
    - makedirs: true

{{ config.graylog.message_journal.dir }}:
  file.directory:
    - user: graylog
    - group: graylog
    - mode: '0755'
    - makedirs: true
