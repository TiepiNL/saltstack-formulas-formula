# Read the readme.md in the repository for a description of this state's functionality.

{%- for deploy_key, deploy_key_details in salt['pillar.get']('formulas:deploy_keys:present', {}).items() %}
  {%- set key_directory = deploy_key_details.get('key_directory', '~/.ssh') %}
  {%- set key_name = deploy_key_details.get('name', deploy_key) %}
  {%- set github_deploy_key_contents = deploy_key_details.get('contents', 'no-access-to-key-pillar') %}

# Make sure the (private!) key file for the ssh handshake is in place.
formulas_file_managed_deploy_key_{{ key_directory }}/{{ key_name }}:
  file.managed:
    - name: {{ key_directory }}/{{ key_name }}
    # We don't store private keys in public repos, and we can't
    # clone it from a private repo, because we need this deploy key
    # for that (chicken-egg). That's why we don't use a source file
    # but a contents string instead.
    - contents: |
        {{ github_deploy_key_contents | indent(8) }}
    - makedirs: True
    - dir_mode: 700
    # Any file permissions other then x00 are too open, and will result
    # in the key to be ignored by ssh, with a "it is required that your
    # private key files are NOT accessible by others" message.
    - mode: 600

{%- endfor %}

#@TODO onchange activate

#@TODO : absent - file.absent, on change ssh agent -d
