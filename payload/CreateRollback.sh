#!/bin/bash

CHGNUMBER=$1
shift

VALID_CR=0

function ShowHelp {
  echo "First argument must be an RFC number starting with CHG and contain a seven digit number."
  echo "Second and subsequent arguments must be the full path to a directory or files."
  echo "Backup content is limited to 100MB so as to prevent large rollbacks."
  echo "sudo CreateRollback.sh CHG1234567 /etc/my.cnf /etc/ssh"
  exit $LINENO
}

function DereferenceLink {
  ORIG_DIR=$(pwd)
  [ ${DEBUG:=0} -eq 1 ] && echo "ORIG_DIR='$ORIG_DIR'" >&2
  PATH_LINK="$1"
  [ ${DEBUG:=0} -eq 1 ] && echo "PATH_LINK='$PATH_LINK'" >&2
  LINK_FILE=$(basename $PATH_LINK)
  [ ${DEBUG:=0} -eq 1 ] && echo "LINK_FILE='$LINK_FILE'" >&2
  PATH_ONLY=$(dirname $PATH_LINK)
  [ ${DEBUG:=0} -eq 1 ] && echo "PATH_ONLY='$PATH_ONLY'" >&2
  cd $PATH_ONLY || {
    echo "Cannot use this path '$PATH_ONLY'" >&2
    return
  }
  NEW_TARGET=$(/usr/bin/stat --format="%N" $LINK_FILE | gawk '{print $NF}' | cut -b 2- | rev | cut -b 2- | rev)
  [ ${DEBUG:=0} -eq 1 ] && echo "NEW_TARGET='$NEW_TARGET'" >&2
  [ -e "$NEW_TARGET" ] || {
    echo "Cannot find target '$NEW_TARGET'" >&2
    return
  }
  NEW_TARGET_FILE=$(basename $NEW_TARGET)
  [ ${DEBUG:=0} -eq 1 ] && echo "NEW_TARGET_FILE='$NEW_TARGET_FILE'" >&2
  NEW_TARGET_PATH=$(dirname $NEW_TARGET)
  [ ${DEBUG:=0} -eq 1 ] && echo "NEW_TARGET_PATH='$NEW_TARGET_PATH'" >&2
  cd $NEW_TARGET_PATH || {
    echo "Cannot change to the directory '$NEW_TARGET_PATH'" >&2
    return
  }
  echo $(pwd)/$NEW_TARGET_FILE
  cd $ORIG_DIR
}

# Valid CR number
#[[ "$CHGNUMBER" =~ ^[CI][HN][GC][0-9]{7}$ ]] || {
#    echo "Please provide a valid CHG or INC number in the format of three capital letters followed by seven digits." >&2
#    ShowHelp;
#}
function ValidTrackingNumberFormat {
  [[ "${1}" =~ ^INC[0-9]{7}$ ]] && {
    # echo "return from line $LINENO"
    return 0
  }
  [[ "${1}" =~ ^CHG[0-9]{7}$ ]] && {
    # echo "return from line $LINENO"
    return 0
  }
  [[ "${1}" =~ ^DT-[0-9]{14} ]] && {
    # echo "return from line $LINENO"
    return 0
  }
  [[ "${1}" =~ ^TK-[0-9]{5}+ ]] && {
    # echo "return from line $LINENO"
    return 0
  }
  [[ "${1}" =~ ^B-[0-9]{5}+ ]] && {
    # echo "return from line $LINENO"
    return 0
  }
  [[ "${1}" =~ ^D-[0-9]{5}+ ]] && {
    # echo "return from line $LINENO"
    return 0
  }
  [[ "${1}" =~ ^I-[0-9]{5}+ ]] && {
    # echo "return from line $LINENO"
    return 0
  }
  # echo "return from line $LINENO"
  return 1
}

ValidTrackingNumberFormat "${CHGNUMBER}" || {
  echo "Please provide a valid change, incident, story, task, defect or issue number starting with capital letters followed by digits."
  ShowHelp
}

cd /

export TMPS=$(mktemp /dev/shm/CreateRollback_XXXXXXXXXXXXX)
echo "TOTAL_SIZE=0" >$TMPS
echo "SOME_TARGET_FILES_EXIST=0" >${TMPS}_VARS
echo "TARGETS=" >${TMPS}_TARGETS

function AddSize {
  #echo "AddSize $1"
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

for i in $@; do
  [ -f $i ] && {
    THIS_SIZE=$(du -bs $i | cut -f1)
    ((THIS_SIZE > 0)) && SOME_TARGET_FILES_EXIST=1
    source $TMPS
    ((TOTAL_SIZE += THIS_SIZE))
    echo "TOTAL_SIZE=$TOTAL_SIZE" >$TMPS
    source ${TMPS}_TARGETS
    TARGETS="$TARGETS $i"
    echo "TARGETS=\"$TARGETS\"" >${TMPS}_TARGETS
    echo "SOME_TARGET_FILES_EXIST=1" >${TMPS}_VARS
  } || {
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
  echo "To included these files identify them explicitly in the arguments."
  sleep 5
}

source $TMPS
# cat ${TMPS}_TARGETS
source ${TMPS}_TARGETS
source ${TMPS}_VARS
rm -f $TMPS ${TMPS}_TARGETS ${TMPS}_VARS

if [ $SOME_TARGET_FILES_EXIST -eq 0 ]; then
  echo "No targets given."
  ShowHelp
fi
if [ $TOTAL_SIZE -gt 104857600 ]; then
  echo "Backup size would exceed limit. The limit is there to prevent accidentally creating a super large backup. If you need a super large backup consider coping the files off to another server."
  ShowHelp
fi

MY_HOME=$(getent passwd $(id -un) | cut -d: -f6)
CR_DATE=$(date +%F_%H%M%S)
rm -f $MY_HOME/ChangeControl/last
ROLL_BACK_DIR=$MY_HOME/ChangeControl/${CHGNUMBER}_${CR_DATE}
/bin/mkdir -p ${ROLL_BACK_DIR}
/bin/ln -s ${CHGNUMBER}_${CR_DATE} $MY_HOME/ChangeControl/last
ROLL_BACK_SH=$MY_HOME/ChangeControl/rollback-${CHGNUMBER}.sh
BACKUP_LIST=${ROLL_BACK_DIR}.list

if [ ! -f $ROLL_BACK_SH ]; then
  cat >>$ROLL_BACK_SH <<-EOF
	#!/bin/bash 
	echo "This rollback script will not restart any services. That would be done manually where needed."
	echo "This rollback will not remove new files from entire directories that are backed up, that too must be done manually."
	cd ${ROLL_BACK_DIR}
	tar cf - ./ | tar xvf - -C /
	EOF
  rm -f $BACKUP_LIST
fi

#while [ ${#TARGETS[@]} -gt 0 ]; do
#	TARGET_FILE=${TARGETS[0]}
#	unset TARGETS[0]; TARGETS=( "${TARGETS[@]}" );

for TARGET_FILE in $TARGETS; do
  cd /
  [ ! -f ${ROLL_BACK_DIR}${TARGET_FILE} ] && {
    #md5sum ${TARGET_FILE}
    #/bin/ls -dl ${TARGET_FILE}
    echo "${TARGET_FILE} -> ${ROLL_BACK_DIR}${TARGET_FILE}"
    echo "${TARGET_FILE}" >>$BACKUP_LIST
    tar cf - ${TARGET_FILE} 2>/dev/null | tar xf - -C ${ROLL_BACK_DIR}
    [ -L ${TARGET_FILE} ] && {
      REAL_TARGET=$(DereferenceLink ${TARGET_FILE})
      [ ${#REAL_TARGET} -eq 0 ] && {
        #echo "DereferenceLink returned a blank string from '${TARGET_FILE}'"
        #exit 123
        echo "Broken link '${TARGET_FILE}'" >&2
      } || {
        echo "Target '${TARGET_FILE}' is a symbolic link, the target '$REAL_TARGET' will also be archived."
        TARGETS=("${TARGETS[@]}" "$REAL_TARGET")
      }
    }
    [ -f ${TARGET_FILE} ] && echo "# diff ${TARGET_FILE} $MY_HOME/ChangeControl/last/${TARGET_FILE}"
  } || {
    echo "It looks like this rollback has already been created."
    echo "${ROLL_BACK_DIR}${TARGET_FILE} already exists."
  }
  echo
done
echo "Your rollback script to undo these changed files is '$ROLL_BACK_SH'"
echo "For your convenience the symlink $MY_HOME/ChangeControl/last temporarily points to ${CHGNUMBER}_${CR_DATE}"
echo "When done making a change you should diff the original files from the archive."
