{# main hosts #}

127.0.0.1:
  host.only:
    - hostnames:
      - {{ grains['fqdn'] }}
      - localhost
      - {{ grains['host'] }}

127.0.1.1:
  host.only:
    - hostnames:
      - {{ grains['host'] }}
      - {{ grains['fqdn'] }}

{# ipv6 not used #}
::1:
  host.only:
    - hostnames:
      - localhost
      - ip6-localhost
      - ip6-loopback

ff02::1:
  host.only:
    - hostnames:
      - ip6-allnodes

ff02::2:
  host.only:
    - hostnames:
      - ip6-allrouters

 
{# special host for some minions #}

{% macro remove_host(rm_hostnames, rm_ip) %}
{# check if multiple hostnames on one host #}
{% if rm_hostnames is string %}
{{ rm_hostnames }}:
  host.absent:
    - name: {{ rm_hostnames }}
    - ip: {{ rm_ip }}
{% else %}
{% for rm_hostname in rm_hostnames %}
{{ rm_hostname }}:
  host.absent:
    - name: 
      - {{ rm_hostname }}
    - ip: {{ rm_ip }}
{% endfor %}
{% endif %}
{% endmacro %}
{# -------------------------------------------#}
{% macro add_host(add_hostnames, add_ip) %}
{{ add_ip }}:
  host.only:
    - hostnames: {{ add_hostnames }}
{% endmacro %}

{# check if pillat hosts exist #}
{% if salt['pillar.get']('hosts') %}

{% for host in salt['pillar.get']('hosts') %}
{% set host_absent = salt['pillar.get']('hosts:'~ host ~':host_absent') %}
{% set hostnames = salt['pillar.get']('hosts:'~ host ~':hostnames') %}
{% set ip = salt['pillar.get']('hosts:'~ host ~':ip') %}

{# delete absent hosts #}
{% if host_absent == True %}        
{{ remove_host(hostnames, ip) }}
{% else %}
{{ add_host(hostnames, ip) }}
{% endif %}
{% endfor %}
{% endif %}

