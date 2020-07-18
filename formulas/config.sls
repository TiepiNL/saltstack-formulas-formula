# Read the readme.md in the repository for a description of this state's functionality.

{%- set github_rsa_deploy_key = salt['pillar.get']('formulas:github_rsa_deploy_key', False) %}
{%- set github_rsa_deploy_key_contents = salt['pillar.get']('formulas:github_rsa_deploy_key_contents', 'no-access-to-key-pillar') %}

# Make sure the (private!) key file for the ssh handshake is in place.
formulas_file_managed_github_rsa_deploy_key:
  file.managed:
    - name: {{github_rsa_deploy_key}}
    # We don't store private keys in public repos, and we can't
    # clone it from a private repo, because we need this deploy key
    # for that (chicken-egg). That's why we don't use a source file
    # but a contents string instead.
    - contents: |
        {{github_rsa_deploy_key_contents | indent(8)}}
    - makedirs: True
    - dir_mode: 700
    # Any file permissions other then x00 are too open, and will result
    # in the key to be ignored by ssh, with a "it is required that your
    # private key files are NOT accessible by others" message.
    - mode: 600
