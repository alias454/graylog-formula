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

# Setup firewall service file for transport 
/etc/firewalld/services/gl-transport.xml:
  file.managed:
    - source: salt://graylog/files/gl-transport.xml
    - user: root
    - group: root
    - mode: '0640'

command-restorecon-graylog-/etc/firewalld/services:
  cmd.run:
    - name: restorecon -R /etc/firewalld/services
    - unless:
      - ls -Z /etc/firewalld/services/graylog-ipt.xml |grep firewalld_etc_rw_t
      - ls -Z /etc/firewalld/services/graylog-web.xml |grep firewalld_etc_rw_t
      - ls -Z /etc/firewalld/services/gl-transport.xml |grep firewalld_etc_rw_t

# Add service for graylog inputs
{% for ipt_server in config.graylog.input_source %}

command-add-perm-rich-rule-allow-graylog-ipt-from-{{ ipt_server }}:
  cmd.run:
    - name: firewall-cmd --add-rich-rule="rule family="ipv4" source address="{{ ipt_server }}" service name="graylog-ipt" accept" --permanent
    - unless: firewall-cmd --zone=internal --list-all |grep graylog-ipt

command-add-rich-rule-allow-graylog-ipt-from-{{ ipt_server }}:
  cmd.run:
    - name: firewall-cmd --add-rich-rule="rule family="ipv4" source address="{{ ipt_server }}" service name="graylog-ipt" accept"
    - unless: firewall-cmd --zone=internal --list-all |grep graylog-ipt

{% endfor %} # end allow

# Add service for graylog transport
{% for node in config.graylog.sources %}

command-add-perm-rich-rule-allow-gl-transport-to-{{ node.name }}:
  cmd.run:
    - name: firewall-cmd --add-rich-rule="rule family="ipv4" source address="{{ node.ip }}{{ node.mask }}" service name="gl-transport" accept" --permanent
    - unless: firewall-cmd --zone=internal --list-all |grep gl-transport

command-add-rich-rule-allow-gl-transport-to-{{ node.name }}:
  cmd.run:
    - name: firewall-cmd --add-rich-rule="rule family="ipv4" source address="{{ node.ip }}{{ node.mask }}" service name="gl-transport" accept"
    - unless: firewall-cmd --zone=internal --list-all |grep gl-transport

{% endfor %} # end allow

# Add redirection for web frontend
{% if config.graylog.use_redirection == 'true' %}

command-add-perm-rule-port-forward-graylog-web:
  cmd.run:
    - name: firewall-cmd --zone=internal --add-forward-port=port=80:proto=tcp:toport=9000 --permanent
    - unless: firewall-cmd --zone=internal --list-all |grep toport=9000

command-add-rule-port-forward-graylog-web:
  cmd.run:
    - name: |
        firewall-cmd --zone=internal --add-forward-port=port=80:proto=tcp:toport=9000
    - unless: firewall-cmd --zone=internal --list-all |grep toport=9000

# Add service for web frontend
command-add-rule-graylog-web:
  cmd.run:
    - name: firewall-cmd --zone=internal --add-service=graylog-web
    - require:
      - cmd: command-restorecon-graylog-/etc/firewalld/services
    - unless: firewall-cmd --zone=internal --list-all |grep graylog-web

command-add-perm-rule-graylog-web:
  cmd.run:
    - name: firewall-cmd --zone=internal --add-service=graylog-web --permanent
    - require:
      - cmd: command-restorecon-graylog-/etc/firewalld/services
    - unless: grep graylog-web /etc/firewalld/zones/internal.xml

{% endif %}

{% endif %}
