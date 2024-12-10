# Convenience Tools

Scripts and more to aid setting up a development environment

## ff ff-

Wraps Firefox to isolate profiles

### Usage

#### Initial setup

* Add the directory containing `ff` and `ff-` to the path **OR** symlink to a directory in the path.

#### Profiles

* Symlink 'ff-' to whatever you want to call the firefox profile.  IE `ln -srfv ~/bin/ff- ~/bin/ff-myprofile`
* **OR** set the environment variable `FF_PROFILE_DIR` to where you want your profile.  IE `env FF_PROFILE_DIR=my-other-profile ff` or `export FF_PROFILE=my-other-profile; ff`


## initial-tools

Setup tools we need that may not be in a base operating install

### Usage

* `initial-tools [subgroups]`
  * **asdf:** Install [asdf](https://asdf-vm.com/guide/getting-started.html) and our standard asdf managed tools
  * **distro:** Install goodies packages for distro
  * **docker:** Installer current docker CE
  * **all:** Installs all of these
