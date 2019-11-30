# https://packages.irods.org/

{% if grains['os_family'] == 'RedHat' %}

renci-irods:
  pkgrepo.managed:
    - name: RENCI iRODS Repository
    - baseurl: https://packages.irods.org/yum/pool/centos$releasever/$basearch
    - enabled: True
    - gpgcheck: 1
    - repo_gpgcheck: 1
    - gpgkey: https://packages.irods.org/irods-signing-key.asc

{% else %}

test.fail_without_changes

{% endif %}
