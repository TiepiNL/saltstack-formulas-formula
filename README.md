# formulas-formula
Custom unofficial SaltStack formula to manage a repository with a collection of SaltStack formulas.

## General notes
The aim of this formula is to manage the deployment of version-tagged [SaltStack formulas](https://github.com/saltstack-formulas) (or other repositories), based on pillar config.

### Background
This formula is orginally made to manage and automate Salt deployments on [masterless](https://docs.saltstack.com/en/latest/topics/tutorials/quickstart.html#salt-masterless-quickstart) systems.

## Available states

### formulas (init.sls)
Include the git_clones.sls, pillars.sls, and symlinks.sls state files.

### formulas.git_clones
This is where the git magic happens.
* Clone version-pinned 'wanted' repositories - usually SaltStack formulas - based on pillar config.
* Update a version-tagged formula to another version, based on the set version in the pillar config.
* Update a non-version-tagged formula (read: set to master), if the master branch has upstream changes.
* Remove a repo and its corresponding symlink, if it's set to 'unwanted' in the pillar config.

### formulas.pillars
...
Clone the private(!) pillar repo.

### formulas.symlinks
...
* Create a symlink to point the Salt state tree to the cloned repository.
* Remove the symlink of a repo, if it's set to 'unwanted' in the pillar config.
* Add custom symlinks based on pillar config.

## Pillar example
todo

## Help
todo
