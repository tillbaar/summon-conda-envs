# summon-conda-envs
While working with Python on a compute cluster I ran into the following problem:
* Python (or at least the version I needed) wasn't available by default.
* This is why I opted for a local [conda](https://conda.io) environment. This would also allow me to manage different Python and module versions for my various projects.
* While this worked out initially, [conda](https://conda.io) environments are not only somehwhat big, they also contain a lot of files, quickly using up my allotted inode quota.
* Luckily, [conda](https://conda.io) environments (or at least the specifications of any given environment) can be archived to a single YAML file and later restored from that file.

I therefor wrote the a tiny bash script that takes care of archiving and restoring conda environments to and from YAML files for me so I don't have to worry about the details.

## Usage
It works as follows:

```
Usage: condaenv summon [-l] env    restore a conda environment from a yml file
   or: condaenv unsummon    env    archive a conda environment as a yml file
   or: condaenv -h                 display extended help message

    summon    Searches for a YAML file in a specified directory and uses it to
              create a conda environment.
  
  unsummon    Searches for a conda environment and stores it as a YAML file in
              a specified directoy. The stored environment is removed.

Arguments:
  -l  local   Without this option, all new conda enviroments are created in a
              specified directory of the user's choice. If this option is set
              the new conda environment is created in the standard path for
              conda environments instead.
 
  -h  help    Displays this extended help message.
 ```
## Examples
So, let's assume you have created a conda environment called `foo` that you don't need at the moment.
 
To archive the environment to a YAML file you would use:
```
condaenv unsummon foo
```
The environment will be archived to `foo.yml` in a directory specified at the beginning of the script.

To restore the environment from that YAML file you would use:
```
condaenv summon foo
```
The environment will be restored from `foo.yml` to a directory specified at the beginning of the script.

Alternatively, you can use:
```
condaenv summon -l foo
```
This will restore the environment to the standard directory for conda environments on you system.

## Things to consider
You need to set two paths at the beginning of the script.
* `ENV_DIR` is the directory where conda environments should be created if the `-l` option is not given.
* `YML_DIR` is the directoy where YAML files are stored.

Additionally, to call the script simply by typing `condaenv`, you need to provide an alias in your `.bashrc`
