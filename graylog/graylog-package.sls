{% from "graylog/map.jinja" import host_lookup as config with context %}
{% if config.graylog.install_type == 'package' %}

package-install-graylog-server:
  pkg.installed:
    - pkgs:
      - graylog-server
    - require_in:
      - service: service-graylog-server
    - require:
      - file: /etc/yum.repos.d/Graylog-2.1.repo

{% elif config.graylog.install_type == 'tarball' %}

group-manage-graylog:
  group.present:
    - name: graylog
    - system: True

user-manage-graylog:
  user.present:
    - name: graylog
    - fullname: Graylog Server User
    - shell: /sbin/nologin
    - home: /var/lib/graylog-server
    - createhome: true
    - system: True
    - groups:
      - graylog
    - require:
      - group: group-manage-graylog

remove-previous-graylog-versions:
  cmd.run:
    - name: rm -rf $(ls -I {{ config.graylog.latest_tarball }} |grep graylog)
    - cwd: /root/
    - prereq:
      - file: /root/{{ config.graylog.latest_tarball }}
    - onlyif: ls -I {{ config.graylog.latest_tarball }} |grep graylog

/root/{{ config.graylog.latest_tarball }}:
  file.managed:
    - source: salt://graylog/files/{{ config.graylog.latest_tarball }}

command-untar-{{ config.graylog.latest_tarball }}:
  cmd.run:
    - name: tar -xf /root/{{ config.graylog.latest_tarball }}
    - cwd: /root/
    - onchanges:
      - file: /root/{{ config.graylog.latest_tarball }}
  service.dead:
    - name: graylog-server
    - onchanges:
      - file: /root/{{ config.graylog.latest_tarball }}

command-move-{{ config.graylog.latest_tarball }}:
  file.absent:
    - name: {{ config.graylog.base_dir }}/graylog-server
    - onchanges:
      - service: command-untar-{{ config.graylog.latest_tarball }}
  cmd.run:
    - name: mv {{ config.graylog.latest_tarball.split('.')[:-1] |join('.') }} {{ config.graylog.base_dir }}/graylog-server
    - cwd: /root/
    - require:
      - file: command-move-{{ config.graylog.latest_tarball }} 
    - onlyif: ls {{ config.graylog.latest_tarball.split('.')[:-1] |join('.') }}

{{ config.graylog.content_packs_dir }}/grok-patterns.json:
  file.copy:
    - source: {{ config.graylog.base_dir }}/graylog-server/data/contentpacks/grok-patterns.json
    - makedirs: true
    - require:
      - cmd: command-move-{{ config.graylog.latest_tarball }}
    - onlyif: ls {{ config.graylog.base_dir }}/graylog-server/data/contentpacks/grok-patterns.json 

{{ config.graylog.base_dir }}/graylog-server/log:
  file.absent:
    - require:
      - file: {{ config.graylog.content_packs_dir }}/grok-patterns.json

{{ config.graylog.base_dir }}/graylog-server/data:
  file.absent:
    - require:
      - file: {{ config.graylog.content_packs_dir }}/grok-patterns.json

{{ config.graylog.base_dir }}/graylog-server:
  file.directory:
    - user: graylog
    - group: graylog
    - recurse:
      - user
      - group
    - require_in:
      - service: service-graylog-server
    - onlyif: ls {{ config.graylog.base_dir }}/graylog-server

{% endif %}
