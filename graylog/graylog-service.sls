{% from "graylog/map.jinja" import host_lookup as config with context %}

# Manage graylog systemd unit file using template
/usr/lib/systemd/system/graylog-server.service:
  file.managed:
    - source: salt://graylog/files/graylog-server.service
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'

# Manage graylog exec file using template
{{ config.graylog.base_dir }}/graylog-server/bin/graylog-server:
  file.managed:
    - source: salt://graylog/files/graylog-server.bin
    - template: jinja
    - user: graylog
    - group: graylog
    - mode: '0755'

# Make sure the service is running and restart the service unless
# restart_service_after_state_change is false
service-graylog-server:
  service.running:
    - name: graylog-server
    - enable: True
    - require:
      - file: /usr/lib/systemd/system/graylog-server.service
      - file: {{ config.graylog.startup_overrides_path }}
      - file: {{ config.graylog.base_dir }}/graylog-server/bin/graylog-server
  {% if config.graylog.restart_service_after_state_change == 'true' %}
    - watch:
      - file: /etc/graylog/server/server.conf
      - file: {{ config.graylog.startup_overrides_path }}
  {% endif %}
