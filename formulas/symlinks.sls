# State to create symlinks to link cloned repos (usually saltstack-formulas) to the salt state tree directory.
# Read the readme.md in the repository for a full description of this state's functionality.

include:
  # Required for requisites.
  - .git_clones

{%- set local_formula_destination_directory = salt['pillar.get']('formulas:local_formula_destination_directory', '/srv/saltstack-formulas') %}
{%- set local_state_tree_directory = salt['pillar.get']('formulas:local_state_tree_directory', '/srv/salt') %}

# Loop through the present repos in pillar.
{%- for present_repo_name, repo_details in salt['pillar.get']('formulas:repos:present', {}).items() %}
  # Remove the '-formula' suffix from the repo name, required for
  # the full path to deeplink from the salt state tree.
  {%- if '-formula' in present_repo_name %}
    {%- set formula = (present_repo_name.split('-formula'))[0] %}
  {%- else %}
    {%- set formula = present_repo_name %}
  {%- endif %}

# Create a symlink from the salt state location to the salt-formula repo.
formulas_repo_symlink_present_{{present_repo_name}}:
  file.symlink:
    - name: {{local_state_tree_directory}}/{{formula}}
    - target: {{local_formula_destination_directory}}/{{present_repo_name}}/{{formula}}
    - force: True
    - require:
      - formulas_repo_present_{{present_repo_name}}

{%- endfor %}

# Loop through the absent repos in pillar.
{%- for absent_repo_name in salt['pillar.get']('formulas:repos:absent', []) %}
  # Remove the '-formula' suffix from the repo name, required to
  # construct the full path to the symlink file.
  {%- if '-formula' in absent_repo_name %}
    {%- set formula = (absent_repo_name.split('-formula'))[0] %}
  {%- else %}
    {%- set formula = absent_repo_name %}
  {%- endif %}

# Remove the symlink.
formulas_repo_symlink_absent_{{absent_repo_name}}:
  file.absent:
    - name: {{local_state_tree_directory}}/{{formula}}

{%- endfor %}
