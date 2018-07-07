
{% from "graylog/map.jinja" import host_lookup as config with context %}
{% if config.firewall.iptables.status == 'Active' %}

# add some firewall magic
include:
  - firewall.iptables

# Only enable firewall rules if use_redirection == true
{% if config.graylog.use_redirection == 'true' %}

iptables-firewall-rule-forward-graylog-web:
  iptables.append:
    - table: nat 
    - chain: PREROUTING 
    - jump: REDIRECT
    - proto: tcp
    - dport: 80
    - to-port: 9000
    - save: True

iptables-firewall-rule-allow-graylog-web:
  iptables.insert:
    - position: 3
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - dports:
      - 80
      - 9000
    - jump: ACCEPT
    - save: True

{% else %}

iptables-firewall-rule-allow-graylog-web:
  iptables.insert:
    - position: 2
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - dport: 9000
    - jump: ACCEPT
    - save: True

{% endif %}
{% endif %}
