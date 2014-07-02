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
#           
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
	
	echo	"EncoderFlag,DecoderFlag,SHA-1 Value,\
			MD5String, BitStreamSize, YUVSize,   \
			-frms, -numtl, -scrsig, -rc,         \
			-tarb, -lqp 0, -iper,                \
			-slcmd 0,-slcnum 0, -thread,         \
			-ltr, -db, -MaxNalSize, -denois,     \
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
	EncoderLog="encoder.log"
	
	let "EncoderPassedNum=0"
	let "EncoderUnPassedNum=0"
	let "DecoderPassedNum=0"
	let "DecoderUpPassedNum=0"
	let "DecoderUnCheckNum=0"
	let "EncoderPassedFlag=1"
	let "DecoderPassedFlag=1"
	EncoderCheckResult="NULL"
	DecoderCheckResult="NULL"
	BitStreamSHA1String="NULL"
	EncoderCommand="NULL"	
	
	
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
		-drec 0 ${RecYUVFile} >${EncoderLog}
	
}
#usage: runGetFileSize  $FileName
runGetFileSize()
{
	if [ $#  -lt 1  ]
	then 
		echo "usage: runGetFileSize  $FileName!"
		return 1
	fi
	
	local FileName=$1
	local FileSize=""
	local TempInfo=""
	
	TempInfo=`ls -l $FileName`
	FileSize=`echo $TempInfo | awk '{print $5}'`
	
	echo $FileSize
}
#usage: runGetEncodedNum  ${EncoderLog}
runGetEncodedNum()
{
	if [ $#  -lt 1  ]
	then 
		echo "usage: runGetEncodedNum  \${EncoderLog}"
		return 1
	fi
	
	local EncoderLog=$1
	local EncodedNum="0"
	
	while read line
	do
		if [[  ${line}  =~ ^Frames  ]]
		then
			EncodedNum=`echo $line | awk 'BEGIN {FS="[:\r]"} {print $2}'`
			break
		fi
	done <${EncoderLog}
	
	echo ${EncodedNum}
}
#usage: runParseCheckResult  ${EncoderFailedFlag} ${EncoderFlag}} ${DecoderFlag}
#Input string is the combination of encoder flag and decoder flag:
#       XX  XX  ==> EncoderFlag    DecoderFlag
#       ----for Encoder Flag:
#            00  Encoder_Rec=JSVM_Dec
#            01  Encoder  failed (0 bit bit stream/rec YUV )
#            10  JSVM decoded failed
#            11  Encoder_Rec != JSVM_Dec
#       ----for Decoder Flag:
#            00 Decoder_Rec=JSVM_Dec
#            01 Decoder  failed 
#            11 Decoder_Rec != JSVM_Dec
#            10 not sure due to the encoder failed or JSVM decoded failed, no bit stream or YUV for check
#output is :
#        update:  --EncoderCheckResult DecoderCheckResult  
#                 --EncoderPassedNum  EncoderUnPassedNum 
#                 --DecoderPassedNum  DecoderUpPassedNum  DecoderUnCheckNum
runParseCheckResult()
{
	if [ ! $# -eq 3 ]
	then
		echo "usge: runParseCheckResult  \${EncoderFailedFlag} \${EncoderFlag}} \${DecoderFlag}"
		return 1
	fi
	local EncoderFailedFlag=$1
	local EncoderFlag=$2
	local DecoderFlag=$3
	local EncodedNum=${EncoderCommandValue[0]}
	local ActualEncoded=""
	local InputYUVSize=""
	local RecYUVSize=""
	local RCMode=${EncoderCommandValue[3]}
	
	#check whether the encoder failed (eg. core dumped)
	if [ ${EncoderFailedFlag} -eq 1 ]
	then
		let "EncoderUnPassedNum++"
		let "DecoderUnCheckNum++"
		EncoderCheckResult="1:Encoder failed!"
		DecoderCheckResult="3:Dec cannot check"
		return 1
	fi
	
	InputYUVSize=`runGetFileSize  ${TestSequencePath}/${TestSequenceName}`
	RecYUVSize=`runGetFileSize ${RecYUVFile}`
	ActualEncoded=`runGetEncodedNum  ${EncoderLog} `
	#check the encoder number is the same with setting number
	if [ ${RCMode} -eq 0  ]
	then
		if [ ${EncodedNum} -eq -1  ]
		then
			if [ ! ${InputYUVSize} -eq ${RecYUVSize}]
			then
				let "EncoderUnPassedNum++"
				let "DecoderUnCheckNum++"
				EncoderCheckResult="1:Encoder failed,Encoded number is not equal to setting!"
				DecoderCheckResult="3:Dec cannot check"
				return 1		
			fi
		fi
		
		if [ ${EncodedNum} -gt 0  ]
		then
			if [ ! ${ActualEncoded} -eq  ${EncodedNum}  ]
			then
				let "EncoderUnPassedNum++"
				let "DecoderUnCheckNum++"
				EncoderCheckResult="1:Encoder failed,Encoded number is not equal to setting!"
				DecoderCheckResult="3:Dec cannot check"
				return 1					
			fi
		fi	
	fi
	
	echo ""
	echo "InputYUVSize=${InputYUVSize}  RecYUVSize=${RecYUVSize} "
	echo "EncodedNum=${EncodedNum} ActualEncoded=${ActualEncoded} "
	echo ""
	
	
    #************************************************
	if [ "${EncoderFlag}" = "00"  ]
	then
		let "EncoderPassedFlag=0"
		EncoderCheckResult="0:Encoder passed!"
		let "EncoderPassedNum++"
	elif  [ "${EncoderFlag}" = "01"  ]
	then
		EncoderCheckResult="1:Encoder failed!"
		let "EncoderUnPassedNum++"
	elif  [ "${EncoderFlag}" = "10"  ]
	then
		EncoderCheckResult="2:JSVM decoder failed!"
		let "EncoderUnPassedNum++"
	elif  [ "${EncoderFlag}" = "11"  ]
	then
		EncoderCheckResult="3:Rec-JSVM not match"
		let "EncoderUnPassedNum++"
	fi
	if [ "${DecoderFlag}" = "00"  ]
	then
		let "DecoderPassedFlag=0"
		DecoderCheckResult="0:Decoder passed!"
		let "DecoderPassedNum++"
	elif  [ "${DecoderFlag}" = "01"  ]
	then
		DecoderCheckResult="1:Decoder failed!"
		let "DecoderUpPassedNum++"
	elif  [ "${DecoderFlag}" = "11"  ]
	then
		DecoderCheckResult="2:Dec-JSVM not match"
		let "DecoderUpPassedNum++"
	elif  [ "${DecoderFlag}" = "10"  ]
	then
		let "DecoderPassedFlag=0"
		DecoderCheckResult="3:Dec cannot check"
		let "DecoderUnCheckNum++"
	fi
	
	return 0
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
	
	
	if [ ${EncoderPassedFlag}  -eq  0  ]
	then 
	    SHA1String=`sha1sum  -b  ${BitStreamFile}`
		SHA1String=`echo ${SHA1String} | awk '{print $1}' `
		
		MD5String=`md5sum -b  ${BitStreamFile}`
		MD5String=`echo ${MD5String} | awk '{print $1}' `
		
		YUVSize=`runGetFileSize  ${TestSequencePath}/${TestSequenceName}`
	    BitStreamSize=`runGetFileSize  ${BitStreamFile}`
		echo " ${SHA1String}, ${MD5String}, ${BitStreamSize},${YUVSize}, ${CaseInfo}">>${AllCaseSHATableFile}
	else
		 SHA1String="NULL"
		 MD5String="NULL"
		 let "YUVSize=0"
		 let "BitStreamSize=0"
	fi
		
	echo "${EncoderCheckResult},${DecoderCheckResult}, -------SHA1 string is : ${SHA1String}"
	echo "${EncoderCheckResult},${DecoderCheckResult}, -------MD5  string is : ${MD5String}"
	echo "${EncoderCheckResult},${DecoderCheckResult}, ${SHA1String}, ${MD5String}, ${BitStreamSize},${YUVSize}, ${CaseInfo}, ${EncoderCommand} ">>${AllCasePassStatusFile}
	
	
	for file in  ${TempDataPath}/*
	do
		./run_SafeDelete.sh  ${file}>>DeleteInterm.list
	done
	
}
# run all test case based on XXXcase.csv file
#usage  runAllCaseTest
runAllCaseTest()
{
	local CaseCheckResult=""
	local CheckLogFile="CaseCheck.log"
	local EncoderFailedFlag=""
	let   "EncoderFailedFlag=1"
	
	while read CaseData
	do		
		if [[ $CaseData =~ ^[-0-9]  ]]
		then			
			echo ""
			echo ""
			echo ""
			echo "********************case index is ${TotalCaseNum}**************************************"	
			
			runParseCaseInfo ${CaseData}
			echo ""
			runEncodeOneCase  ${CodecFolder}
			let  "EncoderFailedFlag=$?"
			cat ${EncoderLog}
			
			echo ""
			echo "******************************************"
			echo "Bit stream conformance check.... "
				
			#bit stream file validation checking, 
			#encoder: Rec.yuv should be the same with JM_Dec.yuv
			#decoder: Rec.yuv should be the same with JM_Dec.yuv
			
			CaseCheckResult=`./run_BitStreamValidateCheckSingleLayer.sh  ${BitStreamFile}  ${JMDecYUVFile}  ${DecYUVFile}  ${RecYUVFile} ${IssueDataPath}  ${CheckLogFile}`
			
			echo ".........result parse.........${EncoderFailedFlag}   $CaseCheckResult"
			runParseCheckResult  ${EncoderFailedFlag}   $CaseCheckResult
         				
			cat ${CheckLogFile}
			echo "return value for bit stream is  ${CaseCheckResult}"
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
	TestFolder=`echo $CurrentDir | awk 'BEGIN {FS="/"} { i=NF; print $i}'`
	
	echo ""
	echo "***********************************************************"
	echo "total case  Num     is : ${TotalCaseNum}"
	echo "EncoderPassedNum    is : ${EncoderPassedNum}"
	echo "EncoderUnPassedNum  is : ${EncoderUnPassedNum} "
	echo "DecoderPassedNum    is : ${DecoderPassedNum}"
	echo "DecoderUpPassedNum  is : ${DecoderUpPassedNum}"
	echo "DecoderUnCheckNum   is : ${DecoderUnCheckNum}"
	echo "issue bitstream can be found in .../AllTestData/${TestFolder}/issue"
	echo "detail result  can be found in .../AllTestData/${TestFolder}/result"
	echo "***********************************************************"
	echo ""
	
	
	echo "${TestSetIndex}_${TestSequenceName}">${CaseSummaryFile}
	echo "total case  Num     , ${TotalCaseNum}" >>${CaseSummaryFile}
	echo "EncoderPassedNum    , ${EncoderPassedNum}" >>${CaseSummaryFile}
	echo "EncoderUnPassedNum  , ${EncoderUnPassedNum} " >>${CaseSummaryFile}
	echo "DecoderPassedNum    , ${DecoderPassedNum}" >>${CaseSummaryFile}
	echo "DecoderUpPassedNum  , ${DecoderUpPassedNum}" >>${CaseSummaryFile}
	echo "DecoderUnCheckNum   , ${DecoderUnCheckNum}" >>${CaseSummaryFile}
	echo "  detail file located in ../AllTestData/${TestSetIndex}/result" >>${CaseSummaryFile}	
	
	 
	#generate All case Flag
	if [  ! ${EncoderUnPassedNum} -eq 0  ]	
	then
		FlagFile="./result/${TestSetIndex}_${TestSequenceName}.unpassFlag"
	else
		FlagFile="./result/${TestSetIndex}_${TestSequenceName}.passFlag"
	fi
	touch ${FlagFile}
	
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

