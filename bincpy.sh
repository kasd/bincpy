#
# !!! Do not use this script on production !!!
#

BIN_LST="sh ssh bash rsync nc telnet cat ls pwd cp chmod chown mkdir mv rm mktemp sync tar less more ln kill find grep ps"
LIBS=""
DIRS=""
BINS=""
TARGET_DIR=$(echo "${1}"|sed 's/\/$//g')

echo $TARGET_DIR
if [ ! "${TARGET_DIR}" ]; then
        exit
fi

for i in ${BIN_LST}; do
	BIN=$(which ${i} 2>/dev/null)
        if [ "${BIN}" ]; then
		LIBS="${LIBS}$(ldd ${BIN}|awk '$3 && $3 ~ "^/" {print $3}')\n"
		LIBS="${LIBS}$(ldd ${BIN}|grep 'ld-linux.*\.so\.[0-9]\{0,1\}'|awk '$1 {print $1}')\n"
		DIRS="${DIRS}$(dirname ${BIN})\n"
		BINS="${BINS}${BIN}\n"	
	fi
done

LIBS=$(echo -e "${LIBS}"|sort|uniq|awk '$1 {print $1}')
BINS=$(echo -e "${BINS}"|sort|uniq|awk '$1 {print $1}')

for i in ${LIBS}; do
	DIRS="${DIRS}$(dirname ${i})\n"
done

DIRS=$(echo -e "${DIRS}"|sort|uniq|awk '$1 {print $1}')

for i in ${DIRS}; do
	i=$(echo "${i}"|sed 's/^\///g')
	mkdir -p "${TARGET_DIR}/${i}"
done

for i in ${BINS}; do
	SRC=${i}
        i=$(echo "${i}"|sed 's/^\///g')
        cp ${SRC} "${TARGET_DIR}/${i}"
done

for i in ${LIBS}; do
	SRC=${i}
        i=$(echo "${i}"|sed 's/^\///g')
        cp ${SRC} "${TARGET_DIR}/${i}"
done

#echo "$DIRS"

#echo "$SUFFICIENT"
