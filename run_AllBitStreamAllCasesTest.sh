
#!/bin/bash
#***************************************************************************************
# SHA1 table generation model:
#      This model is part of Cisco openh264 project for encoder binary comparison test.
#      The output of this test are those SHA1 tables for all test bit stream, and will 
#      be used in openh264/test/encoder_binary_comparison/SHA1Table.
#     
#      1.Test case configure file: ./CaseConfigure/case.cfg.
#    
#      2.Test bit stream files: ./BitStreamForTest/*.264
# 
#      3.Test result: ./FinalResult  and ./SHA1Table 
#
#      4 For more detail, please refer to READE.md
#      
# brief:
#      --test all bit stream in folder ./BitStreamForTest
#      --usage: run_CopySHA1Table  run_CopySHA1Table.sh \$SHAFolder_from  \$SHAFolder_to 
#               eg:  run_AllBitStreamALlCasesTest  ${BitstreamDir}   \
#                                                  ${AllTestDataDir} \
#                                                  ${FinalResultDir} \
#                                                  ${ConfigureFile}
#      
#
#date:  10/06/2014 Created
#***************************************************************************************
#usage: runAllTestBitstream   ${BitstreamDir} ${AllTestDataDir}  ${FinalResultDir}
runAllTestBitstream()
{
	#parameter check! 
	if [ ! $# -eq 4  ]
	then
		echo "usage: runAllTestBitstream   \${BitstreamDir} \${AllTestDataDir}  \${FinalResultDir}  \${ConfigureFile}"
		return 1
	 fi
	local BitstreamDir=$1
	local AllTestDataDir=$2
	local FinalResultDir=$3
	local ConfigureFile=$4
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
		
		
		cd  ${SubFolder}
		#*******************************	
		./run_OneBitStream.sh  ${StreamFullPath}  ${FinalResultDir}  ${ConfigureFile}
		if [  ! $? -eq 0 ]
		then
			echo "!!!uppassed for Bitstream: ${StreamName}"
			cd  ${CurrentDir}
			let "Flag=1"
		fi
		
		cd  ${CurrentDir}
		#*******************************		
	
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
ConfigureFile=$4
runAllTestBitstream   ${BitstreamDir} ${AllTestDataDir}  ${FinalResultDir} ${ConfigureFile}


