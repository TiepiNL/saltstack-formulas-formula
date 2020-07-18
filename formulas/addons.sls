# This state provides the additional functionality required by
# the custom formula addons:
# * Create custom symlinks.

# NOTE: The formula-addons repository is managed like a formula.
# In other words, the git clone and the repo symlink are handled
# by the 'formula.git_clone' and 'formula.symlinks' states.

include:
  # Required for requisites.
  - .git_clones

{%- set local_formula_destination_directory = salt['pillar.get']('formulas:local_formula_destination_directory', '/srv/saltstack-formulas') %}
{%- set local_state_tree_directory = salt['pillar.get']('formulas:local_state_tree_directory', '/srv/salt') %}

# Loop through the symlinks as defined in pillar.
{%- for symlink, symlink_details in salt['pillar.get']('formulas:addons:symlinks', {}).items() %}

  {%- set symlink_name = symlink_details.get('name', False) %}
  {%- set symlink_target = symlink_details.get('target', False) %}
  {%- set force_symlink = symlink_details.get('force', True) %}

# Create a symlink from the salt state location to the addon repo.
formulas_addon_symlink_present_{{symlink}}:
  file.symlink:
    - name: {{local_state_tree_directory}}/{{symlink_target}}
    - target: {{local_formula_destination_directory}}/addons-formula/addons/{{symlink_name}}
    - force: {{force_symlink}}
    - require:
      - formulas_repo_present_addons-formula

{%- endfor %}
