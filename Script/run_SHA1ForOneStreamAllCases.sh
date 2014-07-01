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
#       --Test all cases for one sequence to check that the target codec is the same as benchmark codec
#       --output info can be found  in ../AllTestData/${TestSetIndex}/result/
#            pass case number, unpass case number total case number
#            ${TestSetIndex}_${TestSequenceName}_AllCaseOutput.csv
#            ${AllCaseConsoleLogFile}
#            ${CaseSummaryFile}
#            ${FlagFile}
#      
#
#date:  10/06/2014 Created
#***************************************************************************************
runGlobalVariableInitial()
{
    #TestDataSpaceDir=../AllTestData  CurrentDir=../AllTestData/TestSetXXX/***.yuv   eg ../AllTestData/TestSetCIF/basketball.yuv
	#WorkingDir folder include   ./AllTestData   ./result  ./bats  ./cfg
	CurrentDir=`pwd`
	#test data space
	FinalResultPath="result"
	IssueDataPath="issue"
	TempDataPath="TempData"
	mkdir -p ${FinalResultPath}
	mkdir -p ${IssueDataPath}
	mkdir -p ${TempDataPath}
    TestSequencePath="${CurrentDir}"
	
	#get YUV detail info $picW $picH $FPS
	declare -a aYUVInfo
	aYUVInfo=(`./run_ParseYUVInfo.sh  ${TestSequenceName}`)
	PicW=${aYUVInfo[0]}
	PicH=${aYUVInfo[1]}
	#test cfg file and test info output file
	ConfigureFile=welsenc.cfg
	
	AllCasePassStatusFile="${FinalResultPath}/${TestSequenceName}_AllCaseOutput.csv"
	AllCaseSHATableFile="${FinalResultPath}/${TestSequenceName}_AllCase_SHA1_Table.csv"
	AllCaseConsoleLogFile="${FinalResultPath}/${TestSequenceName}.TestLog"
	CaseSummaryFile="${FinalResultPath}/${TestSequenceName}.Summary"
	
	echo	"BitMatched Status,SHA-1 Value,    \
			MD5String, BitStreamSize, YUVSize, \
			-frms, -numtl, -scrsig, -rc,       \
			-tarb, -lqp 0, -iper,              \
			-slcmd 0,-slcnum 0, -thread,       \
			-ltr, -db, -MaxNalSize, -denois,   \
			-scene,     -bgd,    -aq">${AllCasePassStatusFile}
			
	echo	"SHA-1 Value, 					   \
			MD5String, BitStreamSize, YUVSize, \
			-frms, -numtl, -scrsig, -rc,       \
			-tarb, -lqp 0, -iper,              \
			-slcmd 0,-slcnum 0, -thread,       \
			-ltr, -db, -MaxNalSize,-denois,    \
			-scene,     -bgd,    -aq">${AllCaseSHATableFile}			
			
	#intial Commandline parameters
	declare -a EncoderCommandSet
	declare -a EncoderCommandName
	declare -a EncoderCommandValue
    
	#encoder parameters  change based on the case info
	CaseInfo=""
	BitStreamFile=""
	RecYUVFile=""
	JMDecFile=""
	DiffInfo=""
	DiffFlag=""
	
	EncoderCommand=""
	let "TotalCaseNum=0"
	let "EncPassCaseNum=0"
	let "EncUnpassCaseNum=0"
	let "DecPassCaseNum=0"
	let "DecUnpassCaseNum=0"
	let "EncoderFlag=1"
	let "DecoderFlag=1"
}
#called by runGlobalVariableInitial
#usage runEncoderCommandInital
runEncoderCommandInital()
{
	EncoderCommandSet=(-frms       \
					   -numtl      \
					   -scrsig     \
					   -rc         \
					   -tarb       \
					   "-lqp 0"    \
					   -iper       \
					   "-slcmd 0"  \
					   "-slcnum 0" \
					   -thread     \
					   -ltr        \
					   -db         \
					   "-nalsize " \
					   -denois     \
					   -scene      \
					   -bgd        \
					   -aq)
					   
	EncoderCommandName=(FrEcoded     \
						NumTempLayer \
						ContentSig   \
						RC           \
						BitRate      \
						QP           \
						IntraPeriod  \
						SlcMd        \
						SlcMum       \
						ThrMum       \
						LTR          \
						LFilterIDC   \
						MaxNalSize   \
						DenoiseFlag  \
						SceneChangeFlag \
						BackgroundFlag  \
						AQFlag) 
	EncoderCommandValue=(0 0 0 0 0     0 0 0 0 0     0 0 0 0 0   0  0)
	NumParameter=${#EncoderCommandSet[@]}
	
}	
#***********************************************************
#call by  runAllCaseTest
# parse case info --encoder preprocess
#usage  runGetEncoderCommandValue $CaseData
runParseCaseInfo()
{
	if [ $#  -lt 1  ]
	then 
		echo "no parameter!"
		return 1
	fi
    local TempData=""
	local BitstreamPrefix=""
	local CaseData=$@
	TempData=`echo $CaseData |awk 'BEGIN {FS="[,\r]"} {for(i=1;i<=NF;i++) printf(" %s",$i)} ' `
	EncoderCommandValue=(${TempData})
	for((i=0; i<$NumParameter; i++))
	do
		BitstreamPrefix=${BitstreamPrefix}_${EncoderCommandName[$i]}_${EncoderCommandValue[$i]}
	done
  
	BitstreamTarget=${TempDataPath}/${TestSequenceName}_${BitstreamPrefix}_codec_target.264
	RecYUVFile=${TempDataPath}/${TestSequenceName}_${BitstreamPrefix}_rec.yuv
	DecYUVFile=${TempDataPath}/${TestSequenceName}_${BitstreamPrefix}_dec.yuv
	JMDecYUVFile=${TempDataPath}/${TestSequenceName}_${BitstreamPrefix}_JM_Dec.yuv
	DiffInfo=${TempDataPath}/${TestSequenceName}_${BitstreamPrefix}_diff.info
	echo ""
	echo "BitstreamPrefix is ${BitstreamPrefix}"
	echo ""
}
#call by  runAllCaseTest
#usage  runEncodeOneCase 
runEncodeOneCase()
{
	BitStreamFile=${BitstreamTarget}
	CaseCommand="${ConfigureFile}  	   \
		-numl 1					       \
		-lconfig 0 layer2.cfg   	   \
		-sw   ${PicW} -sh   ${PicH}    \
		-dw 0 ${PicW} -dh 0 ${PicH}    \
		-frout 0  30                   \
		-ltarb 0  ${EncoderCommandValue[4]}  \
		${EncoderCommandSet[0]}  ${EncoderCommandValue[0]}  \
		${EncoderCommandSet[1]}  ${EncoderCommandValue[1]}  \
		${EncoderCommandSet[2]}  ${EncoderCommandValue[2]}  \
		${EncoderCommandSet[3]}  ${EncoderCommandValue[3]}  \
		${EncoderCommandSet[4]}  ${EncoderCommandValue[4]}  \
		${EncoderCommandSet[5]}  ${EncoderCommandValue[5]}  \
		${EncoderCommandSet[6]}  ${EncoderCommandValue[6]}  \
		${EncoderCommandSet[7]}  ${EncoderCommandValue[7]}  \
		${EncoderCommandSet[8]}  ${EncoderCommandValue[8]}  \
		${EncoderCommandSet[9]}  ${EncoderCommandValue[9]}  \
		${EncoderCommandSet[10]} ${EncoderCommandValue[10]} \
		${EncoderCommandSet[11]} ${EncoderCommandValue[11]} \
		${EncoderCommandSet[12]} ${EncoderCommandValue[12]} \
		${EncoderCommandSet[13]} ${EncoderCommandValue[13]} \
		${EncoderCommandSet[14]} ${EncoderCommandValue[14]} \
		${EncoderCommandSet[15]} ${EncoderCommandValue[15]} \
		${EncoderCommandSet[16]} ${EncoderCommandValue[16]}"
		
	echo ""
	echo "case line is :"
	EncoderCommand="./h264enc  ${CaseCommand}  -bf   ${BitStreamFile}  -org   ${TestSequencePath}/${TestSequenceName}  -drec 0 ${RecYUVFile}"
	echo ${EncoderCommand}
	
	./h264enc   ${CaseCommand}        \
		-bf     ${BitStreamFile}      \
		-org    ${TestSequencePath}/${TestSequenceName} \
		-drec 0 ${RecYUVFile}
					
}
#usage: runGetFileSize  $FileName
runGetFileSize()
{
	if [ $#  -lt 1  ]
	then 
		echo "usage??¡ìunGetFileSize  $FileName!"
		return 1
	fi
	
	local FileName=$1
	local FileSize=""
	local TempInfo=""
	
	TempInfo=`ls -l $FileName`
	FileSize=`echo $TempInfo | awk '{print $5}'`
	
	echo $FileSize
}
#call by  runAllCaseTest
#delete needless files and output single case test result to log file
#usage  runSingleCasePostAction $CaseData
#usage runPostAction  $CaseData
runSingleCasePostAction()
{
	if [ $#  -lt 1  ]
	then 
		echo "no parameter!"
		return 1
	fi
	
	local CaseData=$@
	local SHA1String=""
	local MD5String=""
	local YUVSize=""
	local BitStreamSize=""
	
	CaseInfo=`echo $CaseData | awk 'BEGIN {FS="[,\r]"} {for(i=1;i<=NF;i++) printf(" %s,",$i)} '` 
	
	
	if [ ${EncoderFlag}  -eq 0   ]
	then 
	    SHA1String=`sha1sum  -b  ${BitStreamFile}`
		SHA1String=`echo ${SHA1String} | awk '{print $1}' `
		
		MD5String=`md5sum -b  ${BitStreamFile}`
		MD5String=`echo ${MD5String} | awk '{print $1}' `
		
		YUVSize=`runGetFileSize  ${TestSequencePath}/${TestSequenceName}`
	    BitStreamSize=`runGetFileSize  ${BitStreamFile}`
	else
		 SHA1String="NULL"
		 MD5String="NULL"
		 let "YUVSize=0"
		 let "BitStreamSize=0"
	fi
	
	echo "${DiffFlag}, -------SHA1 string is : ${SHA1String}"
	echo "${DiffFlag}, -------MD5  string is : ${MD5String}"
	echo "${DiffFlag}, ${SHA1String}, ${MD5String}, ${BitStreamSize},${YUVSize}, ${CaseInfo}, ${EncoderCommand} ">>${AllCasePassStatusFile}
	
	if [  !  "$SHA1String" = "NULL"  ]
	then	
		echo " ${SHA1String}, ${MD5String}, ${BitStreamSize},${YUVSize}, ${CaseInfo}">>${AllCaseSHATableFile}
	fi
	rm -f ${DiffInfo}
	rm -f ${TempDataPath}/*
}
#usage: runValidateCheck $ReturnInfo
runValidateCheck()
{
	if [ $#  -lt 1  ]
	then 
		echo "usage: runValidateCheck \$ReturnInfo"
		return 1
	fi
	
	local ReturnInfo=$1
	#encoder check
	if [[ "${ReturnInfo}" =~ "1:unpassed!"  ]]
	then
		let "EncoderFlag=1"
	elif [[ "${ReturnInfo}" =~ "2:unpassed!"   ]]
	then
		let "EncoderFlag=1"
	elif [[ "${ReturnInfo}" =~ "3:unpassed!"   ]]
	then
		let "EncoderFlag=1"
	elif [[ "${ReturnInfo}" =~ "4:unpassed!"   ]]
	then
		let "EncoderFlag=1"
	else
		let "EncoderFlag=0"
	fi
	
	#decoder check
	if [[ "${ReturnInfo}" =~ "5:unpassed!"  ]]
	then
		let "DecoderFlag=1"
	elif [[ "${ReturnInfo}" =~ "6:unpassed!"   ]]
	then
		let "DecoderFlag=1"
	elif [[ "${ReturnInfo}" =~ "7:unpassed!"   ]]
	then
		let "DecoderFlag=1"
	else
		let "DecoderFlag=0"
	fi
	
    #pass number	
	if [ ${EncoderFlag}  -eq 0  ]
	then
		echo " pass"
		let "EncPassCaseNum ++"
	else
		echo "not pass"
		let " EncUnpassCaseNum ++"
	fi
	
	if [  ${DecoderFlag} -eq 0  ]
	then
		let "DecPassCaseNum ++"
	else
		let "DecUnPassCaseNum ++"
	fi
	
	if [  ${EncoderFlag}  -eq 1  -o ${DecoderFlag} -eq 1 ]
	then
		cp -f ${BitStreamFile}            ${IssueDataPath}	
	fi	
}
# run all test case based on XXXcase.csv file
#usage  runAllCaseTest
runAllCaseTest()
{
	local Flag=""
	let "Flag=0"
	local ReturnInfo=""
	local CheckLogFile="JMDec_WelsDec_log.log"
	
	while read CaseData
	do
		#get case parameter's value 
		if [[ $CaseData =~ ^-1  ]]
		then
			let "Flag=0"
		elif [[ $CaseData =~ ^[0-9]  ]]
		then
			let "Flag=0"
		else
			let "Flag=1"
		fi
		
		if [[ $Flag  -eq 0  ]]
		then			
			echo ""
			echo ""
			echo ""
			echo "********************case index is ${TotalCaseNum}**************************************"	
			
			runParseCaseInfo ${CaseData}
			echo ""
			runEncodeOneCase  ${CodecFolder}	
			echo ""
			echo "******************************************"
			echo "Bit stream conformance virification.... "
				
			#bit stream file validation checking, 
			#encoder: Rec.yuv should be same with JM_Dec.yuv
			#decoder: Rec.yuv should be same with JM_Dec.yuv
			ReturnInfo=`./run_BitStreamValidateCheck.sh  ${BitStreamFile}  ${JMDecYUVFile}  ${DecYUVFile}  ${RecYUVFile} ${IssueDataPath}`
			runValidateCheck $ReturnInfo
         	
			DiffFlag=${ReturnInfo}
			
			cat ${CheckLogFile}
			echo "return value for bit stream is  ${ReturnInfo}"
			runSingleCasePostAction  ${CaseData}
			let "TotalCaseNum++"	
			
		fi
	done <$AllCaseFile
	runOutputPassNum
}
#usage runOutputPassNum
runOutputPassNum()
{
	# output file locate in ../result
	echo ""
	echo "***********************************************************"
	echo "${TestSetIndex}_${TestSequenceName}"
	echo "total case  Num is :  ${TotalCaseNum}"
	echo "Encoder pass  case  Num is : ${EncPassCaseNum}"
	echo "Encoder unpass case Num is : ${EncUnpassCaseNum} "
	echo "Decoder pass  case  Num is : ${DecPassCaseNum}"
	echo "Decoder unpass case Num is : ${DecUnpassCaseNum} "
	echo "issue bitstream can be found in .../AllTestData/${TestSetIndex}/issue"
	echo "detail result  can be found in .../AllTestData/${TestSetIndex}/result"
	echo "***********************************************************"
	echo ""
	
	
	TestFolder=`echo $CurrentDir | awk 'BEGIN {FS="/"} { i=NF; print $i}'`
	
	
	echo "${TestSetIndex}_${TestSequenceName}, \
		 ${EncPassCaseNum} pass!,                   \
		 ${EncUnpassCaseNum} unpass!,				\
		 ${DecPassCaseNum} pass!,                   \
		 ${DecUnpassCaseNum} unpass!,				\
		 detail file located in ../AllTestData/${TestFolder}/result">${CaseSummaryFile}
		 
		 
	#generate All case Flag
	if [  ! ${EncUnpassCaseNum} -eq 0  ]	
	then
		FlagFile="./result/${TestSetIndex}_${TestSequenceName}.unpassFlag"
	else
		FlagFile="./result/${TestSetIndex}_${TestSequenceName}.passFlag"
	fi
	touch ${FlagFile}
	
	#prompt info
	echo ""
	echo "***********************************************************"
	echo "detail file include:"
	echo "../AllTestData/${TestFolder}/result/  ${AllCaseConsoleLogFile}"
	echo "../AllTestData/${TestFolder}/result/  ${CaseSummaryFile}"
	echo "../AllTestData/${TestFolder}/result/  ${FlagFile}"
	echo "***********************************************************"
	echo ""
	
	
}
#***********************************************************
# usage: runMain $TestYUV  $AllCaseFile
runMain()
{
	if [ ! $# -eq 2  ]
	then 
		echo "usage: runMain \$TestYUV  \$AllCaseFile"
		return 1
	fi
	
	#for test sequence info
	TestSequenceName=$1
	AllCaseFile=$2	
    runGlobalVariableInitial	
	runEncoderCommandInital
	FlagFile=""
	#run all cases
	runAllCaseTest>${AllCaseConsoleLogFile}
	
	
	# output file locate in ./result
	
	runOutputPassNum
}
#call main function 
TestYUVName=$1
AllCaseFile=$2
runMain  ${TestYUVName}   ${AllCaseFile}

