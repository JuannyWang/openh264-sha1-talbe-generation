

#!/bin/bash
 
 #usage:  runMain ${StreamFileFullPath}  ${FinalResultDir}
 runMain()
 {
 
 	if [ ! $# -eq 2 ]
	then
		echo "usage: runMain \${StreamFileFullPath}  \${FinalResultDir} "
		echo "detected by run_OneBitStream.sh"
		return 1
	fi
 
	local StreamFileFullPath=$1
	local FinalResultDir=$2
	
	local CurrentDir=`pwd`
	local TestYUVName=""
	local StreamName=""
	local ConfigureFile="case.cfg"
	local OutPutCaseFile=""
	
	
	
	#bit stream to YUV
	./run_BitStreamToYUV.sh  ${StreamFileFullPath}
	if [  ! $? -eq 0 ]
	then
		echo "failed to translate bit stream to yuv !"
		exit 1
	fi
	TestYUVName=`echo  ./*.yuv`
	TestYUVName=`echo ${TestYUVName} | awk 'BEGIN {FS="/"}  {print $NF}   ' `
	echo ""
	echo  "TestYUVName is ${TestYUVName}"
	
	OutPutCaseFile=${TestYUVName}_AllCase.csv
	echo ""
	echo "OutPutCaseFile is  ${OutPutCaseFile}"
	
	#Case generation
	echo ""
	echo "CurrentDir is ${CurrentDir}"
	echo "${ConfigureFile}   ${TestYUVName}   ${OutputCaseFile}" 
	./run_GenerateCase.sh  ${ConfigureFile}   ${TestYUVName}   ${OutPutCaseFile}
  	if [  ! $? -eq 0 ]
	then
		echo "failed to generate cases !"
		exit 1
	fi 
	#generate SHA-1 table
	./run_SHA1ForOneStreamAllCases.sh   ${TestYUVName}   ${OutPutCaseFile}
  	if [  ! $? -eq 0 ]
	then
		echo "Not All Cass pass!!!"
		exit 1
	else
		echo "all cases pass!! ----bit stream:  ${StreamName}"
		cp  ./result/*    ${FinalResultDir}
		exit 0
	fi
	
 }
 
 
StreamFileFullPath=$1
FinalResultDir=$2
runMain ${StreamFileFullPath}  ${FinalResultDir}	
 


