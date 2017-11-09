#!/bin/sh

D_DEBUG=${D_DEBUG:-""}
D_SUBSYS=${D_SUBSYS:-""}
D_LOG=${D_LOG:-"/tmp/daos_perf.log"}

POOL_SIZE=${POOL_SIZE:-2}
TCLASS=${TCLASS:-"vos"}
AKEY_P_DKEY=${AKEY_P_DKEY:-200}
RECX_P_AKEY=${RECX_P_AKEY:-1000}
RSIZE=${RSIZE:-"1M"}
CREDITS=${CREDITS:-0}

# misc options, see daos_perf -h
OPTS=${OPTS:-"-t -z"} # default options: overwite, zero-copy

DAOS_PERF="${DAOS_PATH}/install/bin/daos_perf"
TEST_DIR="${HOME}/scripts"
SRV_URI="${TEST_DIR}/uri.txt"
CLI_HOSTS="${TEST_DIR}/host.cli.1"

# also can set some options via script parameters
if (( $# >= 1 )); then	# -T $TCLASS
	TCLASS=$1	#    vos, echo, daos
fi
if (( $# >= 2 )); then	# -a $AKEY_P_DKEY
	AKEY_P_DKEY=$2	#    number of akey per dkey
fi
if (( $# >= 3 )); then	# -r $RECX_P_AKEY
	RECX_P_AKEY=$3	#    number of recx per akey
fi
if (( $# >= 4 )); then	# -s $RSIZE
	RSIZE=$4	#    value size
fi

ORTERUN="${DAOS_PATH}/install/bin/orterun"

set -x
$ORTERUN 				\
	-quiet				\
	--hostfile $CLI_HOSTS		\
	--ompi-server file:${SRV_URI}	\
	-x DDSUBSYS=$D_SUBSYS		\
	-x DD_MASK=$D_DEBUG		\
	-x DD_LOG=$D_LOG		\
	${DAOS_PERF}			\
	-T $TCLASS			\
	-P "${POOL_SIZE}G"		\
	-d 1				\
	-a $AKEY_P_DKEY			\
	-r $RECX_P_AKEY			\
	-s $RSIZE			\
	-C $CREDITS $OPTS
