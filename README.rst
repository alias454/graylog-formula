graylog-formula
================

A saltstack formula that can be used to manage graylog installations on RHEL and Debian based systems using a package or tar file.

.. contents:: **Table of Contents**
      :depth: 1

General notes
-------------

.. note::

    The ``FORMULA`` file, contains informtion about this formula, tested OS and OS families, and the minimum tested version of salt.

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Requirements
------------

You must be running elasticsearch and mongodb to use Graylog.

Formulas exist to help with installation and management of
the necessary Graylog stack components, which are; a firewall,
elasticsearch, and mongodb at a bare minimum.

firewall-formula
https://github.com/alias454/firewall-formula

elasticsearch-formula
https://github.com/alias454/elasticsearch-formula

mongodb-formula
https://github.com/alias454/mongodb-formula

If using mongo authentication, configure a DB in mongo first. 
Requires the mongodb-formula to include correct mongodb states or
one can manually created the appropriate database and user.

Releases
--------
View prior releases
https://github.com/alias454/graylog-formula/releases

Available states
----------------

.. contents::
    :local:

``graylog``
^^^^^^^^^^^
*Meta-state (This is a state that includes other states)*.

Installs requirments for **graylog**, manages the configuration file, and starts the service.

``graylog-repo``
^^^^^^^^^^^^^^^^
Manage repo file and GPG key on RHEL/CentOS 7 and Debian systems

``graylog-package``
^^^^^^^^^^^^^^^^^^^
Install graylog and additional prerequisite packages or
configure user, files, and folders if installing from a tar file

``graylog-plugins``
^^^^^^^^^^^^^^^^^^^
Manage 3rd party Graylog plugins

To use this formula for managing 3rd party graylog plugins
cd to the files directory (Something like /srv/salt/graylog/files)
and use wget to download the jar files. 

``graylog-config``
^^^^^^^^^^^^^^^^^^
Manage configuration file placement

``graylog-service``
^^^^^^^^^^^^^^^^^^^
Sets up the graylog service and makes sure it is running

``graylog-firewalld``
^^^^^^^^^^^^^^^^^^^^^
Optionally setup firewalld rules for graylog inputs, the web interface, and disable iptables
Requires the firewall-formula or another method of managing the firewalld service

``graylog-iptables``
^^^^^^^^^^^^^^^^^^^^
Optionally setup iptables rules for graylog inputs, the web interface, and disable firewalld
Requires the firewall-formula or another method of managing the iptables service

