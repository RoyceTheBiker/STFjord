#!/bin/bash
set -e
CHGNUMBER=$1
shift
DIFF_CHG=$1

# To run with DEBUG, set the value to 1 at the start of the command.
# DEBUG=1 CreateRollback.sh ...
DEBUG=${DEBUG:=0}

function ShowHelp {
  echo "CreateRollback.sh is a utility script to archive Linux files before changing them.

  There are two actions it currently performs:
  1) Create an archive of original files before a change.
  2) Perform a diff operation to show changes.

  Creating an archive:
    In this action, an argument is given to mark the type of change: INC, CHG, or SEQ.
    INC & CHG changes must include a seven-digit change number.
    SEQ will automatically generate a sequential number for the change.
    It is recommended never to reuse a change number.

    A second or many additional arguments are given to indicate the files that are to be
    archived. These arguments can be individual files or entire directories.
  
    Archives are stored in the user's home directory under ./ChangeControll/

    A symbolic link is created to always point to the last archive created
    as ./ChangeControll/last.

    Archive content is limited to 100MB to prevent large rollbacks.

  Perform a diff operation:
    When given the first argument diff, and the second argument of a change number or last,
    this action will compare the archived files to their current files, first looking
    for files that have been added or removed from directories. The second action of
    the diff is to look at individual files and how they have been changed.

  Example use:
    sudo CreateRollback.sh CHG1234567 /etc/my.cnf /etc/ssh
    CreateRollback.sh SEQ ~/.config/nvim
    CreateRollback.sh diff last"

  exit $LINENO
}

which tar >/dev/null 2>&1 || {
  echo "Error: tar is required to use this script."
  exit 1
}

which rsync >/dev/null 2>&1 || {
  echo "Warning: rsync is required for the rollback script to work."
  echo "Install rsync before using rollback"
  sleep 5
}

function Color {
  tput bold
  case $1 in
  black) tput setaf 0 ;;
  red) tput setaf 1 ;;
  green) tput setaf 2 ;;
  yellow) tput setaf 3 ;;
  blue) tput setaf 4 ;;
  magenta) tput setaf 5 ;;
  cyan) tput setaf 6 ;;
  white) tput setaf 7 ;;
  off) tput sgr0 ;;
  esac
}

function GreenAddedFile {
  Color green
  echo -n "Added ${1//\</  }"
  Color off
  echo
}

function RedRemovedFile {
  Color red
  echo -n "Removed ${1//\> / }"
  Color off
  echo
}

function DereferenceLink {
  ORIG_DIR=$(pwd)
  [ ${DEBUG} -eq 1 ] && echo "ORIG_DIR='$ORIG_DIR'" >&2
  PATH_LINK="$1"
  [ ${DEBUG} -eq 1 ] && echo "PATH_LINK='$PATH_LINK'" >&2
  LINK_FILE=$(basename $PATH_LINK)
  [ ${DEBUG} -eq 1 ] && echo "LINK_FILE='$LINK_FILE'" >&2
  PATH_ONLY=$(dirname $PATH_LINK)
  [ ${DEBUG} -eq 1 ] && echo "PATH_ONLY='$PATH_ONLY'" >&2
  cd $PATH_ONLY || {
    echo "Cannot use this path '$PATH_ONLY'" >&2
    return
  }
  NEW_TARGET=$(/usr/bin/stat --format="%N" $LINK_FILE | gawk '{print $NF}' | cut -b 2- | rev | cut -b 2- | rev)
  [ ${DEBUG} -eq 1 ] && echo "NEW_TARGET='$NEW_TARGET'" >&2
  [ -e "$NEW_TARGET" ] || {
    echo "Cannot find target '$NEW_TARGET'" >&2
    return
  }
  NEW_TARGET_FILE=$(basename $NEW_TARGET)
  [ ${DEBUG} -eq 1 ] && echo "NEW_TARGET_FILE='$NEW_TARGET_FILE'" >&2
  NEW_TARGET_PATH=$(dirname $NEW_TARGET)
  [ ${DEBUG} -eq 1 ] && echo "NEW_TARGET_PATH='$NEW_TARGET_PATH'" >&2
  cd $NEW_TARGET_PATH || {
    echo "Cannot change to the directory '$NEW_TARGET_PATH'" >&2
    return
  }
  echo $(pwd)/$NEW_TARGET_FILE
  cd $ORIG_DIR
}

function DiffUtil {
  CHG_CONTENT=$(ls -d1 ${MY_HOME}/ChangeControl/${CHG_DIFF}* | head -n1)
  # Get the dir list from the rollback script.
  # Path ARGS for rollback are comments in the rollback script.
  RB_SCRIPT="${MY_HOME}/ChangeControl/rollback-${CHG_DIFF}.sh"
  PATH_ARGS=($(cat ${RB_SCRIPT} | sed -ne '/#DIR_ARGS/,/#FILE_ARGS/p' | grep -vE "^#DIR_ARGS|^$|#FILE_ARGS" | sed -e 's/^#//'))
  for DPATH in ${PATH_ARGS[@]}; do
    diff <(find ${DPATH} -type f | sort) <(
      cd ${CHG_CONTENT}
      find .${DPATH} -type f | sort | sed -e 's/^.//'
    ) | grep -E "^[<>]" | while read LINE; do
      $(echo ${LINE} | grep -q "^<") && {
        GreenAddedFile "$LINE"
      } || :
      $(echo ${LINE} | grep -q "^>") && {
        RedRemovedFile "$LINE"
      } || :
    done
  done

  find ${CHG_CONTENT} -type f | while read LINE; do
    [ -f ${LINE} ] && [ -f $(echo ${LINE} | sed -e "s|${CHG_CONTENT}||") ] && {
      A=$(sum $LINE | awk '{print $1}')
      B=$(sum $(echo ${LINE} | sed -e "s|${CHG_CONTENT}||") | awk '{print $1}')
      # Sum values may start with zero, so they need to be considered strings to avoid base change.
      [[ "${A}" != "${B}" ]] && {
        echo "Changes in $(echo ${LINE} | sed -e "s|${CHG_CONTENT}||")"
        diff --color=always $LINE $(echo ${LINE} | sed -e "s|${CHG_CONTENT}||")
      } || :
    }
  done
  exit 0
}

CHG_DIFF="last"
MY_HOME=$(getent passwd $(id -un) | cut -d: -f6)
function ProcessArguments {
  ACTION="Create Rollback"
  [[ "${1}" =~ ^INC[0-9]{7}$ ]] && {
    return 0
  }
  [[ "${1}" =~ ^CHG[0-9]{7}$ ]] && {
    # echo "return from line $LINENO"
    return 0
  }
  [[ "${1}" == SEQ ]] && {
    CHG_NUMBER=0
    [ -d ${MY_HOME}/ChangeControl/ ] && {
      while ls $MY_HOME/ChangeControl/ | grep -q $(printf "%07d" $CHG_NUMBER); do
        ((CHG_NUMBER += 1))
      done
    }
    CHGNUMBER="SEQ$(printf "%07d" $CHG_NUMBER)"
    echo "SEQ$(printf "%07d" $CHG_NUMBER)"
    return 0
  }
  # echo "return from line $LINENO"
  [[ "${1}" == "diff" ]] && {
    ACTION="diff"
    [[ "${DIFF_CHG}x" != "x" ]] && {
      CHG_DIFF=${DIFF_CHG}
      [[ "${DIFF_CHG}" == "last" ]] && {
        CHG_DIFF=$(stat --format=%N ${MY_HOME}/ChangeControl/last | awk '{print $NF}' | sed -e "s/'//g" | cut -d_ -f1)
      } || {
        CHG_DIFF=${DIFF_CHG}
      }
    } || exit 1
    DiffUtil
    exit 0
  }
  [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]] && {
    ShowHelp
  }
  return 1
}

ProcessArguments "${CHGNUMBER}" || {
  echo "Please provide a valid change, incident, story, task, defect or issue number starting with capital letters followed by digits."
  ShowHelp
}

cd /

export TMPS=$(mktemp /dev/shm/CreateRollback_XXXXXXXXXXXXX)
echo "TOTAL_SIZE=0" >$TMPS
echo "SOME_TARGET_FILES_EXIST=0" >${TMPS}_VARS
echo "TARGETS=" >${TMPS}_TARGETS

function AddSize {
  file $1 | grep -q compressed && {
    echo "Ignore compressed files." >>${TMPS}_rpt
    return
  }
  echo $(basename $1) | grep -q log && {
    echo "Ignore log files." >>${TMPS}_rpt
    return
  }
  SOME_TARGET_FILES_EXIST=1
  THIS_SIZE=$(du -bs $1 | cut -f1)
  ((THIS_SIZE > 0)) && SOME_TARGET_FILES_EXIST=1
  source $TMPS
  ((TOTAL_SIZE += THIS_SIZE))
  echo "TOTAL_SIZE=$TOTAL_SIZE" >$TMPS
  source ${TMPS}_TARGETS
  TARGETS="$TARGETS $1"
  echo "TARGETS=\"$TARGETS\"" >${TMPS}_TARGETS
  echo "SOME_TARGET_FILES_EXIST=1" >${TMPS}_VARS
}
export -f AddSize

DIR_ARGS=
FILE_ARGS=
for i in $@; do
  [ -f $i ] && {
    # If argument is a file
    # Push file string onto array stack
    FILE_ARGS=("${FILE_ARGS[@]}" "${i}")
    THIS_SIZE=$(du -bs $i | cut -f1)
    ((THIS_SIZE > 0)) && SOME_TARGET_FILES_EXIST=1
    source $TMPS
    ((TOTAL_SIZE += THIS_SIZE))
    echo "TOTAL_SIZE=$TOTAL_SIZE" >$TMPS
    source ${TMPS}_TARGETS
    TARGETS="$TARGETS $i"
    echo "TARGETS=\"$TARGETS\"" >${TMPS}_TARGETS
    echo "SOME_TARGET_FILES_EXIST=1" >${TMPS}_VARS
  }
  [ -d $i ] && {
    # Push directory string onto array stack
    DIR_ARGS=("${DIR_ARGS[@]}" "${i}")
    # If argument is a directory
    # echo "find ${i} -type f -exec bash -c 'AddSize \"{}\"' \;"
    find ${i} -type f -exec bash -c 'AddSize "{}"' \;
  }
  source $TMPS
done

IGNORE_ZIP_COUNT=0
[ -f ${TMPS}_rpt ] && IGNORE_ZIP_COUNT=$(grep compressed ${TMPS}_rpt | wc -l)
IGNORE_LOG_COUNT=0
[ -f ${TMPS}_rpt ] && IGNORE_LOG_COUNT=$(grep log ${TMPS}_rpt | wc -l)
((IGNORE_ZIP_COUNT > 0 || IGNORE_LOG_COUNT > 0)) && {
  ((IGNORE_ZIP_COUNT > 0)) && echo "Ignoring $IGNORE_ZIP_COUNT compressed files"
  ((IGNORE_LOG_COUNT > 0)) && echo "Ignoring $IGNORE_LOG_COUNT log files"
  echo "To include these files, identify them explicitly in the arguments."
  sleep 5
}

source $TMPS
source ${TMPS}_TARGETS
source ${TMPS}_VARS
rm -f $TMPS ${TMPS}_TARGETS ${TMPS}_VARS
if [ $SOME_TARGET_FILES_EXIST -eq 0 ]; then
  echo "No targets given."
  ShowHelp
fi
if [ $TOTAL_SIZE -gt 104857600 ]; then
  echo "Backup size would exceed limit. The limit is there to prevent accidentally creating a large backup. 
If you need a large backup, consider copying the files off to another server."
  ShowHelp
fi

CR_DATE=$(date +%F_%H%M%S)
rm -f $MY_HOME/ChangeControl/last || :
rm -f $MY_HOME/ChangeControl/rollback-last.sh || :

ROLLBACK_DIR=$MY_HOME/ChangeControl/${CHGNUMBER}_${CR_DATE}
/bin/mkdir -p ${ROLLBACK_DIR}
/bin/ln -s ${CHGNUMBER}_${CR_DATE} $MY_HOME/ChangeControl/last
ROLLBACK_SH=$MY_HOME/ChangeControl/rollback-${CHGNUMBER}.sh
BACKUP_LIST=${ROLLBACK_DIR}.list

if [ ! -f $ROLLBACK_SH ]; then
  cat >>$ROLLBACK_SH <<-EOF
#!/bin/bash
echo "This rollback script will not restart any services. That sould be done manually if needed."
#DIR_ARGS
 
#FILE_ARGS

# Script
cd ${ROLLBACK_DIR}
(which rsync >/dev/null 2>&1) && {
  rsync --archive --verbose --checksum ./ /  
} || {
  tar cf - ./ | tar xvf - -C /
}
EOF
  ln -s ${ROLLBACK_SH} $MY_HOME/ChangeControl/rollback-last.sh
  rm -f $BACKUP_LIST

  while [ ${#FILE_ARGS[@]} -gt 0 ]; do
    # Read the file string off the array stack
    RF=${FILE_ARGS[(${#FILE_ARGS[@]} - 1)]}
    sed -i $ROLLBACK_SH -e "/#FILE_ARGS/a#${RF//\//\\/}"
    # Pop the string off the array stack
    FILE_ARGS=(${FILE_ARGS[@]:0:$((${#FILE_ARGS[@]} - 1))})
  done

  while [ ${#DIR_ARGS[@]} -gt 0 ]; do
    # Read the directory string off the array stack
    RD=${DIR_ARGS[(${#DIR_ARGS[@]} - 1)]}
    # Pop the string off the array stack
    sed -i $ROLLBACK_SH -e "/#DIR_ARGS/a#${RD//\//\\/}"
    DIR_ARGS=(${DIR_ARGS[@]:0:$((${#DIR_ARGS[@]} - 1))})
    echo "rsync --archive --verbose --delete-after --checksum .${RD}/ ${RD}/" >>$ROLLBACK_SH
  done
fi

for TARGET_FILE in $TARGETS; do
  cd /
  [ ! -f ${ROLLBACK_DIR}${TARGET_FILE} ] && {
    tar cf - ${TARGET_FILE} 2>/dev/null | tar xf - -C ${ROLLBACK_DIR}
    [ -L ${TARGET_FILE} ] && {
      REAL_TARGET=$(DereferenceLink ${TARGET_FILE})
      [ ${#REAL_TARGET} -eq 0 ] && {
        echo "Broken link '${TARGET_FILE}'" >&2
      } || {
        echo "Target '${TARGET_FILE}' is a symbolic link, the target '$REAL_TARGET' will also be archived."
        TARGETS=("${TARGETS[@]}" "$REAL_TARGET")
      }
    } || :
  } || {
    echo "It looks like this rollback has already been created."
    echo "${ROLLBACK_DIR}${TARGET_FILE} already exists."
  }
done
echo "Your rollback script to undo these changed files is '$ROLLBACK_SH'"
echo "For your convenience the symlink $MY_HOME/ChangeControl/last temporarily points to ${CHGNUMBER}_${CR_DATE}"
echo "When done making a change, you should diff the original files from the archive."
echo "Use:"
echo "   CreateRollback.sh diff ${CHGNUMBER}"
echo
