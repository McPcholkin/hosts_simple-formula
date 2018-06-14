{% macro remove_host(rm_hostnames, rm_ip) %}
{# check if multiple hostnames on one host #}
  {% if rm_hostnames is string %}
remove_{{ rm_hostnames }}:
  host.absent:
    - name: {{ rm_hostnames }}
    - ip: {{ rm_ip }}
  {% else %}
    {% for rm_hostname in rm_hostnames %}
remove_{{ rm_hostname }}:
  host.absent:
    - name: {{ rm_hostname }}
    - ip: {{ rm_ip }}
    {% endfor %}
  {% endif %}
{% endmacro %}
{# -------------------------------------------#}

{% macro add_host(add_hostnames, add_ip, host) %}
add_{{ host }}:
  host.only:
    - name: {{ add_ip }}
    - hostnames: 
      {% if add_hostnames is string %}
      - {{ add_hostnames }}
      {% else %}
        {% for add_hostname in add_hostnames %}
      - {{ add_hostname }}
        {% endfor %}
      {% endif %}
{% endmacro %}


{% for host in salt['pillar.get']('hosts') %}

  {% set host_absent = salt['pillar.get']('hosts:'~host~':host_absent', False) %}
  {% set hostnames = salt['pillar.get']('hosts:'~host~':hostnames') %}
  {% set ip = salt['pillar.get']('hosts:'~host~':ip') %}

{# delete absent hosts #}
{% if host_absent %}        
{{ remove_host(hostnames, ip) }}
{% else %}
{{ add_host(hostnames, ip, host) }}
{% endif %}

{% endfor %}

