================
graylog-formula
================

A saltstack formula that can be used to manage graylog installations on RHEL based systems using a package or tar file.

Requirements
================

You must be running elasticsearch and mongodb to use Graylog.

Formulas exist to help with installation and management of
the necessary GELP stack components, which are; a firewall,
elasticsearch, and mongodb at a bare minimum.

firewall-formula
https://github.com/alias454/firewall-formula

elasticsearch-formula
https://github.com/alias454/elasticsearch-formula

mongodb-formula
https://github.com/alias454/mongodb-formula

If using mongo authentication configure a DB in mongo first. 
Requires the mongodb-formula to include correct mongodb states or
one can manually created the appropriate database and user.

Available states
================

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

.. contents::
    :local:

``graylog-repo``
------------
Manage repo file and GPG key on RHEL/CentOS 7 systems

``graylog-package``
------------
Install graylog and additional prerequisite packages or
configure user, files, and folders if installing from a tar file

``graylog-config``
------------
Manage configuration file placement

``graylog-service``
------------
Sets up the graylog service and makes sure it is running on RHEL/CentOS 7 systems

``graylog-firewalld``
------------
Optionally setup firewalld rules for graylog inputs, the web interface, and disable iptables
Requires the firewall-formula or another method of managing the firewalld service
