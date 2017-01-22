{% from "graylog/map.jinja" import host_lookup as config with context %}
{% if config.graylog.install_type == 'package' %}

/etc/yum.repos.d/Graylog-2.1.repo:
  file.managed:
    - source: salt://graylog/files/Graylog-2.1.repo
    - user: root
    - group: root
    - mode: '0644'

/etc/pki/rpm-gpg/RPM-GPG-KEY-graylog:
  file.managed:
    - source: salt://graylog/files/Graylog-2.1.repo.GPG
    - user: root
    - group: root
    - mode: '0644'

{% endif %}
