# Read the readme.md in the repository for a description of this state's functionality.
# Further reference: https://docs.saltstack.com/en/latest/ref/states/all/salt.states.git.html

include:
  # Required for key dependency.
  - .config


{%- set local_formula_destination_directory = salt['pillar.get']('formulas:local_formula_destination_directory', '/srv/saltstack-formulas') %}
{%- set github_deploy_key = salt['pillar.get']('formulas:github_deploy_key', False) %}

# Pillar settings.
# Default to master, if no specific branch tag is set.
{%- set pillar_repo_url = salt['pillar.get']('formulas:pillar:url', '') %}
{%- set pillar_target_branch = salt['pillar.get']('formulas:pillar:branch', 'master') %}
{%- set local_pillar_root_directory = salt['pillar.get']('formulas:pillar:destination_directory', '/srv/pillar') %}
{%- set pillar_deploy_key = salt['pillar.get']('formulas:pillar:deploy_key', github_deploy_key) %}
{%- set autoupdate_pillar_from_master = salt['pillar.get']('formulas:pillar:autoupdate_from_master', False) %}

# Make sure the pillar repository is cloned to the given directory.
formulas_repo_pillar:
  git.cloned:
    - name: {{ pillar_repo_url }}
    - target: {{ local_pillar_root_directory }}
    - branch: master
    - identity: {{ pillar_deploy_key }}
    - require:
      - formulas_file_managed_deploy_key_{{ deploy_key }}
# @TODO:   - depth: 1
# @TODO:   - require:
#      - pkg: git
# @TODO: --single-branch
# @TODO: run first?

{%- else %}

# Make sure the pillar repository is cloned to the given directory and is up-to-date.
formulas_repo_pillar:
  git.latest:
    - name: {{ pillar_repo_url }}
    - target: {{ local_pillar_root_directory }}
    - rev: {{ pillar_target_branch }}
#    - branch: {{pillar_target_branch}} #master
    - force_checkout: True
    - force_clone: True
    - force_fetch: True
    - force_reset: True
    - identity: {{ pillar_deploy_key }}
    - require:
      - formulas_file_managed_deploy_key_{{ deploy_key }}
# @TODO   - depth: 1
# @TODO   - require:
#      - pkg: git
# @TODO --single-branch
# @TODO run first?

{%- endif %}


# Loop through the defined formulas and clone the required versions.
{%- for present_repo_name, repo_details in salt['pillar.get']('formulas:repos:present', {}).items() %}
  
  # Default to master, if no specific branch tag is set.
  {%- set repo_target_branch = repo_details.get('branch', 'master') %}
  # @TODO docs
  {%- set autoupdate_from_master = repo_details.get('autoupdate_from_master', False) %}
  {%- set use_key = repo_details.get('use_key', False) %}
  {%- set deploy_key = repo_details.get('deploy_key', github_deploy_key) %}

  # First check whether to use the default saltstack-formula url,
  # or a custom url (for non-official formulas)
  {%- if repo_details.get('url', False) %}
    {%- set url = repo_details.get('url') %}
  {%- else %}
    {%- set url = 'https://github.com/saltstack-formulas/' + present_repo_name + '/' %}
  {%- endif %}

  # If the formula only uses the master branch instead of version tags,
  # then only pull changes in the repo (if any) if auto_update is enabled.
  {%- if (repo_target_branch == 'master') and (not autoupdate_from_master) %}
    # @TODO: docs

# Make sure the repository is cloned to the given directory.
formulas_repo_present_{{present_repo_name}}:
  git.cloned:
    - name: {{url}}
    - target: {{local_formula_destination_directory}}/{{present_repo_name}}
    - branch: master
    {%- if use_key %}
    - identity: {{deploy_key}}
    {%- endif %}
    - require:
      - formulas_repo_pillar
    {%- if use_key %}
      - formulas_file_managed_deploy_key_{{ deploy_key }}
    {%- endif %} 
# @TODO:
#    - depth: 1
#    --single-branch

  {%- else %}

# Make sure the repository is cloned to the given directory and is up-to-date.
formulas_repo_present_{{present_repo_name}}:
  git.latest:
    - name: {{url}}
    - target: {{local_formula_destination_directory}}/{{present_repo_name}}
    - rev: {{repo_target_branch}}
#    - branch: {{repo_target_branch}} #master
    - force_checkout: True
    - force_clone: True
    - force_fetch: True
    - force_reset: True
    {%- if use_key %}
    - identity: {{deploy_key}}
    {%- endif %}
    - require:
      - formulas_repo_pillar
    {%- if use_key %}
      - formulas_file_managed_deploy_key_{{ deploy_key }}
    {%- endif %}      
# @TODO:
#    - depth: 1 (Changed in version 2019.2.0: This option now supports tags as well as branches, on Git 1.8.0 and newer.)
#    --single-branch

  {%- endif %}
{%- endfor %}


# @TODO: docs
{%- for absent_repo_name in salt['pillar.get']('formulas:repos:absent', []) %}

# Remove the repository, if present.
formulas_repo_absent_{{absent_repo_name}}:
  file.absent:
    - name: {{local_formula_destination_directory}}/{{absent_repo_name}}

{%- endfor %}

# *** PILLAR DEPLOY ***
# If the pillar uses the master branch instead of version tags,
# then only pull changes in the repo (if any) if auto_update is enabled.
{%- if (pillar_target_branch == 'master') and (not autoupdate_pillar_from_master) %}
  # @TODO: docs
