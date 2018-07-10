{% from "graylog/map.jinja" import host_lookup as config with context %}
{% if config.firewall.firewalld.status == 'Active' %}

# add some firewall magic
include:
  - firewall.firewalld

# Setup firewall service file for inputs
/etc/firewalld/services/graylog-ipt.xml:
  file.managed:
    - source: salt://graylog/files/graylog-ipt.xml
    - user: root
    - group: root
    - mode: '0640'

# Setup firewall service file for web frontend
/etc/firewalld/services/graylog-web.xml:
  file.managed:
    - source: salt://graylog/files/graylog-web.xml
    - user: root
    - group: root
    - mode: '0640'
    - reload_modules: True

# This may be irrelevant
command-restorecon-graylog-/etc/firewalld/services:
  cmd.run:
    - name: restorecon -R /etc/firewalld/services
    - unless:
      - ls -Z /etc/firewalld/services/graylog-ipt.xml |grep firewalld_etc_rw_t
      - ls -Z /etc/firewalld/services/graylog-web.xml |grep firewalld_etc_rw_t

# Reload firewalld so graylog rules take effect
command-graylog-firewalld-reload:
  cmd.run:
    - name: firewall-cmd --reload

# Loop through input_sources and create firewall rules
{% for ipt_server in config.graylog.input_source %}

# Add permanent service for graylog inputs
command-add-perm-rich-rule-allow-graylog-ipt-from-{{ ipt_server }}:
  cmd.run:
    - name: firewall-cmd --add-rich-rule="rule family="ipv4" source address="{{ ipt_server }}" service name="graylog-ipt" accept" --permanent
    - onchanges_in:
      - cmd: command-graylog-firewalld-reload
    - unless: firewall-cmd --zone=internal --list-all |grep graylog-ipt

{% endfor %} # end ipt_server

# Add redirection for web frontend if use_redirection is true
# forwards port 80 to port 9000
{% if config.graylog.use_redirection == 'true' %}

# Add permanent port-forward service for graylog web
command-add-perm-rule-port-forward-graylog-web:
  cmd.run:
    - name: firewall-cmd --zone=internal --add-forward-port=port=80:proto=tcp:toport=9000 --permanent
    - onchanges_in:
      - cmd: command-graylog-firewalld-reload
    - unless: firewall-cmd --zone=internal --list-all |grep toport=9000

{% endif %}

# Add permanent service for web frontend
command-add-perm-rule-graylog-web:
  cmd.run:
    - name: firewall-cmd --zone=internal --add-service=graylog-web --permanent
    - onchanges_in:
      - cmd: command-graylog-firewalld-reload
    - require:
      - cmd: command-restorecon-graylog-/etc/firewalld/services
    - unless: grep graylog-web /etc/firewalld/zones/internal.xml
    - retry:
        attempts: 2
        until: True

{% endif %}
