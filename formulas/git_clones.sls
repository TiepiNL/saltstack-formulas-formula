# Read the readme.md in the repository for a description of this state's functionality.
# Further reference: https://docs.saltstack.com/en/latest/ref/states/all/salt.states.git.html

include:
  # Required for key dependency.
  - .config


{%- set default_destination_directory = salt['pillar.get']('formulas:local_formula_destination_directory', '/srv/saltstack-formulas') %}

# *** FORMULA DEPLOY ***
# Loop through the defined formulas and clone the required versions.
{%- for repo_name, repo_details in salt['pillar.get']('formulas:repos:present', {}).items() %}
  {%- if repo_details.get('enabled', True) %}  
    # Default to master, if no specific branch tag is set.
    {%- set repo_target_branch = repo_details.get('branch', 'master') %}
    # @TODO docs
    {%- set autoupdate_from_master = repo_details.get('autoupdate_from_master', False) %}
    {%- set use_key = repo_details.get('use_key', False) %}
    {%- set deploy_key = repo_details.get('deploy_key', False) %}
    {%- set destination_directory = repo_details.get('destination_directory', default_destination_directory) %}

    # First check whether to use the default saltstack-formula url,
    # or a custom url (for non-official formulas)
    {%- if repo_details.get('url', False) %}
      {%- set url = repo_details.get('url') %}
    {%- else %}
      {%- set url = 'https://github.com/saltstack-formulas/' + repo_name + '/' %}
    {%- endif %}

    # If the formula only uses the master branch instead of version tags,
    # then only pull changes in the repo (if any) if auto_update is enabled.
    {%- if (repo_target_branch == 'master') and (not autoupdate_from_master) %}

# Make sure the repository is cloned to the given directory.
formulas_repo_present_{{repo_name}}:
  git.cloned:
    - name: {{url}}
    - target: {{destination_directory}}/{{repo_name}}
    - branch: master
      {%- if deploy_key != False %}
    - identity: {{deploy_key}}
      {%- endif %}

# @TODO:
#    - depth: 1
#    --single-branch

    {%- else %}

# Make sure the repository is cloned to the given directory and is up-to-date.
formulas_repo_present_{{repo_name}}:
  git.latest:
    - name: {{url}}
    - target: {{destination_directory}}/{{repo_name}}
    - rev: {{repo_target_branch}}
#    - branch: {{repo_target_branch}} #master
    - force_checkout: True
    - force_clone: True
    - force_fetch: True
    - force_reset: True
      {%- if deploy_key != False %}
    - identity: {{deploy_key}}
      {%- endif %}
     
# @TODO:
#    - depth: 1 (Changed in version 2019.2.0: This option now supports tags as well as branches, on Git 1.8.0 and newer.)
#    --single-branch

    {%- endif %}
  {%- endif %}
{%- endfor %}


# @TODO: docs
{%- for absent_repo_name in salt['pillar.get']('formulas:repos:absent', []) %}

# Remove the repository, if present.
formulas_repo_absent_{{absent_repo_name}}:
  file.absent:
    - name: {{local_formula_destination_directory}}/{{absent_repo_name}}

{%- endfor %}
