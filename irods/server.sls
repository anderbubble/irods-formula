# https://docs.irods.org/4.2.6/getting_started/installation/

include:
  - irods.repository

irods-server:
  pkg.installed

{% if salt['pillar.get']('irods:database_plugin') %}
irods-database-plugin:
  pkg:
    - installed
    - name: irods-database-plugin-{{ pillar['irods']['database_plugin'] }}
{% endif %}

/usr/local/etc/irods:
  file.directory:
    - user: root
    - group: root
    - mode: 700

# https://github.com/irods/irods/blob/master/configuration_schemas/v3/unattended_installation.json
/usr/local/etc/irods/unattended_installation.json:
  file.serialize:
    - formatter: json
    - dataset:
        admin_password: {{ pillar['irods']['setup']['admin_password'] }}
        host_access_control_config:
          schema_name: host_access_control_config
          schema_version: v3
          access_entries: []
        host_system_information:
          service_account_user_name: {{ pillar.get('irods:setup:service_account_user_name', 'irods') }}
          service_account_group_name: {{ pillar.get('irods:setup:service_account_group_name', 'irods') }}
        hosts_config:
          schema_name: hosts_config
          schema_version: v3
          host_entries: []
        server_config: {{ pillar['irods']['server_config'] }}
        service_account_environment: {{ pillar['irods']['irods_environment'] }}
    - user: root
    - group: root
    - mode: 600

setup_irods.py:
  cmd.run:
    - name: /usr/bin/python /var/lib/irods/scripts/setup_irods.py --json_configuration_file=/usr/local/etc/irods/unattended_installation.json
    - creates:
        - /etc/irods/server_config.json
        - /var/lib/irods/.irods/irods_environment.json


/etc/irods/server_config.json:
  file.serialize:
    - dataset_pillar: 'irods:server_config'
    - formatter: json
    - user: irods
    - group: irods
    - mode: 600
    - require:
        - pkg: irods-server
        - cmd: setup_irods.py

/var/lib/irods/.irods/irods_environment.json:
  file.serialize:
    - dataset_pillar: 'irods:irods_environment'
    - formatter: json
    - user: irods
    - group: irods
    - mode: 600
    - require:
        - pkg: irods-server
        - cmd: setup_irods.py

irods:
  service.running:
    - enable: True
    - watch:
        - pkg: irods-server
        - cmd: setup_irods.py
        - file: /etc/irods/server_config.json
        - file: /var/lib/irods/.irods/irods_environment.json
