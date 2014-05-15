

#!/bin/bash
#usage: runAllTestBitstream   ${BitstreamDir} ${AllTestDataDir}  ${FinalResultDir}
runAllTestBitstream()
{
	#parameter check! 
	if [ ! $# -eq 3  ]
	then
		echo "usage: runAllTestBitstream   \${BitstreamDir} \${AllTestDataDir}  \${FinalResultDir}"
		return 1
	 fi
	local BitstreamDir=$1
	local AllTestDataDir=$2
	local FinalResultDir=$3
	local CurrentDir=`pwd`
	local StreamFullPath=""
	local YUVName=""
	local Flag=""
	let   "Flag=0"
	
	#get full path info 
	cd ${BitstreamDir}
	BitstreamDir=`pwd`
	cd  ${CurrentDir}
	cd ${FinalResultDir}
	FinalResultDir=`pwd`
	cd  ${CurrentDir}
	
	let "Flag=0"
	for Bitsream in ${BitstreamDir}/*.264
	do
	    StreamName=`echo ${Bitsream} | awk 'BEGIN {FS="/"}  {print $NF}   ' `
		StreamFullPath="${BitstreamDir}/${StreamName}"
		SubFolder="${AllTestDataDir}/${StreamName}"
		echo ""
		echo "test bit stream is ${StreamName}"
		echo ""
		
		if [[  "${StreamName}"  =~ "CI1_FT_B.264"  ]]
		then
			cd  ${SubFolder}
			#*******************************	
			./run_OneBitStream.sh  ${StreamFullPath}  ${FinalResultDir} 
			if [  ! $? -eq 0 ]
			then
				echo "!!!uppassed for Bitstream: ${StreamName}"
				cd  ${CurrentDir}
				let "Flag=1"
			fi
			
			cd  ${CurrentDir}
			#*******************************		
		fi	
	done
	
	if [ ! ${Flag} -eq 0  ]
	then
		echo "some test streams fare failed!"
		return 1
	fi
	
	return 0
}
BitstreamDir=$1
AllTestDataDir=$2
FinalResultDir=$3
runAllTestBitstream   ${BitstreamDir} ${AllTestDataDir}  ${FinalResultDir}



