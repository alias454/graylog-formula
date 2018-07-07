{% from "graylog/map.jinja" import host_lookup as config with context %}
{% if config.package.install_type == 'package' %}

# Install graylog from a package
package-install-graylog-server:
  pkg.installed:
    - pkgs:
      - graylog-server
    - require_in:
      - service: service-graylog-server
    - require:
      - pkgrepo: graylog_repo

{% elif config.package.install_type == 'tarball' %}

# If installing fom tarball a lot more steps must be completed
# Create group as a system group 
group-manage-graylog:
  group.present:
    - name: graylog
    - system: True

# Create user as a system user 
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

# Remove old tar files to keep things tidy
remove-previous-graylog-versions:
  cmd.run:
    - name: rm -rf $(ls -I {{ config.graylog.latest_tarball }} |grep graylog)
    - cwd: /root/
    - prereq:
      - file: /root/{{ config.graylog.latest_tarball }}
    - onlyif: ls -I {{ config.graylog.latest_tarball }} |grep graylog

# If pillar version is different thatn current tarball copy
# file to remote graylog server to perform additional actions on it
/root/{{ config.graylog.latest_tarball }}:
  file.managed:
    - source: salt://graylog/files/{{ config.graylog.latest_tarball }}

# Extract tarball in the root dir
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

# Remove old install and move newly extracted files
# to the same location
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

# Copy contentpacks file to a folder not in data
{{ config.graylog.content_packs_dir }}/grok-patterns.json:
  file.copy:
    - source: {{ config.graylog.base_dir }}/graylog-server/data/contentpacks/grok-patterns.json
    - makedirs: true
    - require:
      - cmd: command-move-{{ config.graylog.latest_tarball }}
    - onlyif: ls {{ config.graylog.base_dir }}/graylog-server/data/contentpacks/grok-patterns.json 

# Remove log folder because we create it in /var/logs
{{ config.graylog.base_dir }}/graylog-server/log:
  file.absent:
    - require:
      - file: {{ config.graylog.content_packs_dir }}/grok-patterns.json

# Remove data folder because we move contentpacks out of it
{{ config.graylog.base_dir }}/graylog-server/data:
  file.absent:
    - require:
      - file: {{ config.graylog.content_packs_dir }}/grok-patterns.json

# Set user and group on the entire folder install location
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
