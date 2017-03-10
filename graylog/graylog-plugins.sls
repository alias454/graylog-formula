{% from "graylog/map.jinja" import host_lookup as config with context %}
{% if config.graylog.use_addon_plugins == 'true' %}

# Manage graylog plugins
{% for plugin in config.graylog.addon_plugins %}
{{ config.graylog.plugin_dir }}/{{ plugin }}:
  file.managed:
    - source: salt://graylog/files/{{ plugin }}
    - user: graylog
    - group: graylog
    - mode: '0644'
{% endfor %}

{% endif %}
