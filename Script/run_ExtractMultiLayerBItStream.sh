#!/bin/bash
#*************************************************************************
# used bit stream extractor from train's project.
#
#    ----usage: run_ExtractMultiLayerBItStream.sh \
#                               ${InputBitSteam}   ${SpatialLayerNUm} \
#							    ${OutputBitStreamNameL0} ${OutputBitStreamNameL1} \
#                               ${OutputBitStreamNameL2} ${OutputBitStreamNameL3} 
#
#
#*************************************************************************
#usage: run_ExtractMultiLayerBItStream.sh  \
#			${InputBitSteam} ${SpatialLayerNUm} ${OutputBitStreamNameL0}  \
#			${OutputBitStreamNameL1} ${OutputBitStreamNameL2} ${OutputBitStreamNameL3} 
runMain()
{
	local Usage="usage: run_ExtractMultiLayerBItStream.sh  \
				${InputBitSteam} \${SpatialLayerNUm} \${OutputBitStreamNameL0}  \
				\${OutputBitStreamNameL1} \${OutputBitStreamNameL2} \${OutputBitStreamNameL3} "
	if [  ! $# -eq 6  ]
	then
		echo ""
		echo ${Usage}
		echo ""
		exit 1
	fi
	
	local InputBitSteam=$1
	local SpatialLayerNUm=$2
	local OutputBitStreamNameL0=$3
	local OutputBitStreamNameL1=$4
	local OutputBitStreamNameL2=$5
	local OutputBitStreamNameL3=$6
	local Extractor="extractor.app"
	if [ ! -e ${InputBitSteam}    ]
	then
		echo ""
		echo "input bit stream does not exist!"
		echo ${Usage}
		echo ""
		exit 1
	fi
	
	if [ ${SpatialLayerNUm} -lt 1   -o ${SpatialLayerNUm} -gt 4  ]
	then
		echo ""
		echo "input spatial number is not correct, 1<=SpattialNum<=4"
		echo ${Usage}
		echo ""
		exit 1
	fi
	
	declare -a aOutputBitStreamNameList
	aOutputBitStreamNameList=( ${OutputBitStreamNameL0} ${OutputBitStreamNameL1} ${OutputBitStreamNameL2} ${OutputBitStreamNameL3} )
	
	let "ExtractFlag=0"
	for((i=0;i<${SpatialLayerNUm}; i++))
	do
		./${Extractor}  ${InputBitSteam} ${aOutputBitStreamNameList[$i]}  -did $i 2>BitStreamExtract.log
		if [ ! $? -eq 0  -o  ! -e  ${aOutputBitStreamNameList[$i]} -o ! -s  ${aOutputBitStreamNameList[$i]} ]
		then
			let "ExtractFlag=1"
		fi
	done
	
	if [ ${ExtractFlag} -eq 0 ]
	then
		echo ""
		echo -e "\033[32m  bit stream extraction succeed \033[0m"
		echo ""
		return 0
	else
		echo ""
		echo -e "\033[31m bit stream extraction failed \033[0m"
		echo ""
		return 1	
	fi
		
}
InputBitSteam=$1
SpatialLayerNUm=$2
OutputBitStreamNameL0=$3
OutputBitStreamNameL1=$4
OutputBitStreamNameL2=$5
OutputBitStreamNameL3=$6
runMain ${InputBitSteam}         ${SpatialLayerNUm}       ${OutputBitStreamNameL0}  \
		${OutputBitStreamNameL1} ${OutputBitStreamNameL2} ${OutputBitStreamNameL3} 


