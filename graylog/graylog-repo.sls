{% from "graylog/map.jinja" import host_lookup as config with context %}
{% if config.graylog.install_type == 'package' %}

# Configure repo file for RHEL based systems if
# installing from package
/etc/yum.repos.d/Graylog-2.1.repo:
  file.managed:
    - source: salt://graylog/files/Graylog-2.1.repo
    - user: root
    - group: root
    - mode: '0644'

# Configure GPG key file for repo
/etc/pki/rpm-gpg/RPM-GPG-KEY-graylog:
  file.managed:
    - source: salt://graylog/files/Graylog-2.1.repo.GPG
    - user: root
    - group: root
    - mode: '0644'

{% endif %}
