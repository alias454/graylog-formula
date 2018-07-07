{% from "graylog/map.jinja" import host_lookup as config with context %}
{% if config.package.install_type == 'package' %}
# Installing from package

# Configure repo file for RHEL based systems
{% if salt.grains.get('os_family') == 'RedHat' %}
graylog_repo:
  pkgrepo.managed:
    - name: Graylog
    - comments: |
        # Managed by Salt Do not edit
        # Graylog repository for {{ config.package.repo_version }} packages
    - baseurl: {{ config.package.repo_baseurl }}
    - gpgcheck: 1
    - gpgkey: {{ config.package.repo_gpgkey }}
    - enabled: 1

# Configure GPG key file for repo
/etc/pki/rpm-gpg/RPM-GPG-KEY-graylog:
  file.managed:
    - source: https://raw.githubusercontent.com/Graylog2/fpm-recipes/master/recipes/graylog-repository/files/rpm/RPM-GPG-KEY-graylog 
    - source_hash: b9a593c0d80ccd4098f0b4c8cafc3312
    - user: root
    - group: root
    - onchanges:
      - pkgrepo: graylog_repo

# Configure repo file for Debian based systems
{% elif salt.grains.get('os_family') == 'Debian' %}
# Import keys for Graylog
command-apt-key-graylog:
  cmd.run:
    - name: apt-key adv --fetch-keys {{ config.package.repo_gpgkey }}
    - unless: apt-key list torch

graylog_repo:
  pkgrepo.managed:
    - name: {{ config.package.repo_baseurl }} /
    - file: /etc/apt/sources.list.d/graylog.list
    - comments: |
        # Managed by Salt Do not edit
        # Graylog repository for {{ config.package.repo_version }} packages (Debian) 
{% endif %}

{% endif %}
