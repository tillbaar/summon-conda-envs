#!/bin/bash -l

# ┌────────────────────────────────────────────────────────────────────────────┐
# │ The purpose of this script is to provide an easy method to archive conda   │
# │ environments to YAML files and restore them from those files, choosing     │
# │ between different locations where the environments should be located.      │
# └────────────────────────────────────────────────────────────────────────────┘
# ┌────────────────────────────────────────────────────────────────────────────┐
# │ Path variables. These should be set by the user.                           │
# └────────────────────────────────────────────────────────────────────────────┘

CND_DIR=$(conda info --base)/envs/     # directory where local envs are created

ENV_DIR=/scratch/${USER}/conda_env     # directory where stnd. envs are created
YML_DIR=/home/${USER}/apps/conda_env   # directory where .YAML files are stored

# ┌────────────────────────────────────────────────────────────────────────────┐
# │ Usage message encapsulated in a function for easy reference.               │
# └────────────────────────────────────────────────────────────────────────────┘

USAGE() {
  echo ""
  echo "Usage: condaenv summon [-l] env    restore a conda environment from a yml file"
  echo "   or: condaenv unsummon    env    archive a conda environment as a yml file"
  echo "   or: condaenv -h                   display extended help message"
  echo ""
  echo "    summon    Searches for a YAML file in a specified directory and uses it to"
  echo "              create a conda environment."
  echo ""
  echo "  unsummon    Searches for a conda environment and stores it as a YAML file in"
  echo "              a specified directoy. The stored environment is removed."
  echo ""
  echo "Arguments:"
  echo "  -l  local   Without this option, all new conda enviroments are created in a"
  echo "              specified directory of the user's choice. If this option is set"
  echo "              the new conda environment is created in the standard path for"
  echo "              conda environments instead."
  echo ""
  echo "  -h  help    Displays this extended help message."
  echo ""
}

# ┌────────────────────────────────────────────────────────────────────────────┐
# │ Parsing of command line arguments.                                         │
# │ Three states exist for the script, one of which comes with two sub-states. │
# │                                                                            │
# │ ERROR                                                                      │
# │ In the ERROR state, which is the standard state, nothing happens and the   │
# │ usage message is returned. This state is also used with the -h option.     │
# │                                                                            │ 
# │ SUMMON                                                                     │
# │ In the SUMMON state, a conda environment is created from a YAML file.      │
# │                                                                            │
# │ > local = false                                                            │
# │   In this case, which is the standard state, the conda environment is cre- │
# │   ated in a specific director which is not the normal path for conda envi- │
# │   ronments.                                                                │
# │                                                                            │
# │ > local = true                                                             │
# │   In this case, the conda environment is created in the normal path.       │
# │                                                                            │
# │ UNSUMMON                                                                   │
# │ In the UNSUMMON state, a conda environment is archived to a YAML file and  │
# │ the environment is removed.                                                │
# └────────────────────────────────────────────────────────────────────────────┘

HOME="FALSE"
MODE="ERROR"

ENV_GOAL=${!#}                    # sets the env equal to the last argument  # #

if [[ "$1" == "summon" ]]; then   # is the first argument "summon" # # # # # # #
  MODE="SUMMON"
fi
if [[ "$1" == "unsummon" ]]; then # is the first argument "unsummon" # # # # # #
  MODE="UNSUMMON"
fi
for i in $*; do
  if [[ "$i" == "-h" ]]; then     # are any of the arguments "-h"  # # # # # # #
    MODE="ERROR"
  fi
  if [[ "$i" == "-l" ]]; then     # are any of the arguments "-l"  # # # # # # #
    HOME="TRUE"
  fi
done
if  (( $# < 2 )); then            # are there at least 2 arguments # # # # # # #
  MODE="ERROR"
fi
if (( $# > 3 )); then            # are there more then 3 arguments # # # # # # #
  MODE="ERROR"
fi

# ┌────────────────────────────────────────────────────────────────────────────┐
# │ Behavioral switch. This is where the magic happens.                        │
# │                                                                            │
# │ The following variables are available to work with:                        │
# │   ENV_GOAL: the name of the environment                                    │
# │   ENV_PATH: the path to the environment                                    │
# │   ENV_LIST: a list of the currently available environments.                │
# │   YML_LIST: a list of the currently available YAML files.                  │                    
# └────────────────────────────────────────────────────────────────────────────┘

if [[ "${MODE}" == "SUMMON" ]]; then
  if [[ "${HOME}" == "TRUE" ]]; then
    # ┌────────────────────────────────────────────────────────────────────────┐
    # │ Summoning mode with local = true                                       │
    # └────────────────────────────────────────────────────────────────────────┘
      ENV_GOAL=${ENV_GOAL}
      ENV_PATH=${CND_DIR}
      YML_LIST=$(find ${YML_DIR} -name '*.yml')

      if [[ ${YML_LIST} =~ ${ENV_GOAL} ]]; then
        ENV_ENV=$( echo ${YML_LIST} | tr ' ' '\n' | grep /${ENV_GOAL}.yml$ )
        conda env create \
          --quiet \
          --prefix ${ENV_PATH}/${ENV_GOAL} \
          --file ${ENV_ENV}
        conda clean --all --quiet --yes
        ENV_LIST=$(conda info --envs)
        if [[ ${ENV_LIST} =~ ${ENV_GOAL} ]]; then
          echo "${ENV_GOAL} has been recreated from ${YML_DIR}/${ENV_GOAL}.yml"
        else
          echo "ERROR: The conda environment ${ENV_GOAL} could not be created."
          exit 1
        fi
      else
        echo "ERROR: The YAML file ${ENV_GOAL}.yml does not exist."
        exit 1
      fi
  else
    # ┌────────────────────────────────────────────────────────────────────────┐
    # │ Summoning mode with local = false                                      │
    # └────────────────────────────────────────────────────────────────────────┘
      ENV_GOAL=${ENV_GOAL}
      ENV_PATH=${ENV_DIR}
      YML_LIST=$(find ${YML_DIR} -name '*.yml')

      if [[ ${YML_LIST} =~ ${ENV_GOAL} ]]; then
        ENV_ENV=$( echo ${YML_LIST} | tr ' ' '\n' | grep /${ENV_GOAL}.yml$ )
        conda env create \
          --quiet \
          --prefix ${ENV_PATH}/${ENV_GOAL} \
          --file ${ENV_ENV}
        conda clean --all --quiet --yes
        ENV_LIST=$(conda info --envs)
        if [[ ${ENV_LIST} =~ ${ENV_GOAL} ]]; then
          echo "${ENV_GOAL} has been recreated from ${YML_DIR}/${ENV_GOAL}.yml"
        else
          echo "ERROR: The conda environment ${ENV_GOAL} could not be created."
          exit 1
        fi
      else
        echo "ERROR: The YAML file ${ENV_GOAL}.yml does not exist."
        exit 1
      fi
  fi
elif [[ "${MODE}" == "UNSUMMON" ]]; then
    # ┌────────────────────────────────────────────────────────────────────────┐
    # │ Unsummoning mode                                                       │
    # └────────────────────────────────────────────────────────────────────────┘
      ENV_GOAL=${ENV_GOAL}
      ENV_LIST=$(conda info --envs)

      if [[ ${ENV_LIST} =~ ${ENV_GOAL} ]]; then  
        ENV_ENV=$( echo ${ENV_LIST} | tr ' ' '\n' | grep /${ENV_GOAL}$ )
        conda env export -p ${ENV_ENV} -f ${YML_DIR}/${ENV_GOAL}.yml
        conda clean --all --quiet --yes
        YML_LIST=$(find ${YML_DIR} -name '*.yml' )
        if [[ ${YML_LIST} =~ ${ENV_GOAL} ]]; then
          sed --in-place '/prefix: /d' ${YML_DIR}/${ENV_GOAL}.yml
          rm -rf ${ENV_ENV}
          echo "${ENV_GOAL} has been archived to ${YML_DIR}/${ENV_GOAL}.yml"
        else
          echo "ERROR: The conda environment ${ENV_GOAL} could not be archived."
          exit 1
        fi
      else
        echo "ERROR: The conda environment ${ENV_GOAL} does not exist."
        exit 1
      fi
else
  USAGE                         # show usage message if mode is help or error #
fi
