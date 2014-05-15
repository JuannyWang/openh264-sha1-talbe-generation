

#!/bin/bash
 
#***********************************************************
#Test all cases for one sequence to check that the target codec is the same as benchmark codec
#output info lovated in ../AllTestData/${TestSetIndex}/result/
#         pass case number, unpass case number total case number
#         ${TestSetIndex}_${TestSequenceName}_AllCaseOutput.csv
#         ${AllCaseConsoleLogFile}
#         ${CaseSummaryFile}
#         ${FlagFile}
#***********************************************************
#***********************************************************
#global variable definition
#usage runGlobalVariableDef
runGlobalVariableDef()
{
	WorkingDirDir=""
	#test data space
	FinalResultPath=""
	IssueDataPath=""
	TempDataPath=""
	#for test sequence info
	TestSequenceName=""
	PicW=""
	PicH=""
	#test cfg file and test info output file
	ConfigureFile=""
	AllCaseFile=""
	#xxx.csv
	AllCasePassStatusFile=""
	#for encoder command 
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
	#pass number
	TotalCaseNum=""
	PassCaseNum=""
	UnpassCaseNum=""
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
					   "-nalsize ")
					   
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
						MaxNalSize )
	EncoderCommandValue=(0 0 0 0 0   0 0 0 0 0  0 0 0 0)
	NumParameter=${#EncoderCommandSet[@]}
	
}	
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
	echo	"BitMatched Status,SHA-1 Value,    \
			MD5String, BitStreamSize, YUVSize  \
			-frms, -numtl, -scrsig, -rc,       \
			-tarb, -lqp 0, -iper,              \
			-slcmd 0,-slcnum 0, -thread,       \
			-ltr, -db, -MaxNalSize  ">${AllCasePassStatusFile}
			
	echo	"SHA-1 Value, 					   \
			MD5String, BitStreamSize, YUVSize  \
			-frms, -numtl, -scrsig, -rc,       \
			-tarb, -lqp 0, -iper,              \
			-slcmd 0,-slcnum 0, -thread,       \
			-ltr, -db, -MaxNalSize  ">${AllCaseSHATableFile}			
			
	#intial Commandline parameters
	runEncoderCommandInital
    
	let "TotalCaseNum=0"
	let "PassCaseNum=0"
	let "UnpassCaseNum=0"
	let "JMDecodeFlag=1"
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
		${EncoderCommandSet[13]} ${EncoderCommandValue[13]} "	
	echo ""
	echo "case line is :"
	EncoderCommand="./h264enc  ${CaseCommand} -bf   ${BitStreamFile}  -org   ${TestSequencePath}/${TestSequenceName} "
	echo ${EncoderCommand}
	./h264enc     ${CaseCommand}    		  \
					-bf   ${BitStreamFile}    \
					-org   ${TestSequencePath}/${TestSequenceName} 
					
}
#call by  runAllCaseTest 
#WelsRuby rec yuv and JSVM dec yuv  comparison
#usage  runJSVMVerify
runBitStreamVerify()
{
	echo ""
	echo "******************************************"
	echo "Bit stream conformance virification.... "
	
	let "JMDecodeFlag=1"
	
	#*******************************************
	if [ ! -s ${BitStreamFile} ]
	then 
		let "UnpassCaseNum++"
		echo "1:unpassed! 0 bits--bit stream"
		DiffFlag="1:unpassed! 0 bits--bit stream"
		return 1
	fi
	#*******************************************
	
	#*******************************************
	#run JM decoder
	./ldecod.exe -p InputFile="${BitStreamFile}"  -p OutputFile="${JMDecYUVFile}"
    let "JMDecodeFlag=$?"
	if [ ! ${JMDecodeFlag}  -eq 0  ]
	then
		let "UnpassCaseNum++"
		echo "2:unpassed! JMDecoder decode failed"
		DiffFlag="2:unpassed! JMDecoder decode failed"
		return 1	
	fi
	#*******************************************
	
	#*******************************************
	#welsruby decoder
	./h264dec     ${BitStreamFile}   ${DecYUVFile}
	#*******************************************
    let "WelsDecodeFlag=$?"
	if [ ! ${WelsDecodeFlag}  -eq 0  ]
	then
		let "UnpassCaseNum++"
		echo "3:unpassed! WelsDecoder decode failed"
		DiffFlag="3:unpassed! WelsDecoder decode failed"
		return 1	
	fi
	
	#*******************************************
	if [ ! -s ${JMDecYUVFile}  -a   ! -s ${DecYUVFile}  ]
	then
		let "UnpassCaseNum++"
		DiffFlag="4:unpassed! YUV 0 bits JM-WelsDec"
		echo "4:unpassed! YUV 0 bits JM-WelsDec"
		return 1
	elif [ ! -s ${JMDecYUVFile}  ]
	then
		let "UnpassCaseNum++"
		DiffFlag="5:unpassed! YUV 0 bits--JM"
		echo "5:unpassed! YUV 0 bits--JM"
		return 1
	elif [ ! -s ${DecYUVFile} ]
	then
		let "UnpassCaseNum++"
		DiffFlag="6:unpassed! YUV 0 bits--WelDec"
		echo "6:unpassed! YUV 0 bits--WelDec"
		return 1
	fi
    #*******************************************
	#*******************************************	
	diff -q ${JMDecYUVFile}   ${DecYUVFile}>${DiffInfo}
	if [  -s ${DiffInfo} ]
	then 
		echo "diff info:  bitsteam not matched "
		cp -f ${BitstreamTarget}            ${IssueDataPath}
		DiffFlag="7:unpassed!"
		let "UnpassCaseNum++"
	else
		echo "bitstream pass"
		DiffFlag="0:passed!"
		let "PassCaseNum++"
	fi	
    #*******************************************
}
#usage£º runGetFileSize  $FileName
runGetFileSize()
{
	if [ $#  -lt 1  ]
	then 
		echo "usage£º runGetFileSize  $FileName!"
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
	
	
	if [ ${JMDecodeFlag}  -eq 0   ]
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
	
	echo "${DiffFlag}, -------SHA1 string is : ${SHAString}"
	echo "${DiffFlag}, -------MD5  string is : ${MD5String}"
	echo "${DiffFlag}, ${SHA1String}, ${MD5String}, ${BitStreamSize},${YUVSize}, ${CaseInfo}, ${EncoderCommand} ">>${AllCasePassStatusFile}
	
	if [  !  "$SHA1String" = "NULL"  ]
	then	
		echo " ${SHA1String}, ${MD5String}, ${BitStreamSize},${YUVSize}, ${CaseInfo}">>${AllCaseSHATableFile}
	fi
	rm -f ${DiffInfo}
	rm -f ${TempDataPath}/*
}
#usage runOutputPassNum
runOutputPassNum()
{
	# output file locate in ../result
	echo ""
	echo "***********************************************************"
	echo "${TestSetIndex}_${TestSequenceName}"
	echo "total case  Num is :  ${TotalCaseNum}"
	echo "pass  case  Num is : ${PassCaseNum}"
	echo "unpass case Num is : ${UnpassCaseNum} "
	echo "issue bitstream can be found in .../AllTestData/${TestSetIndex}/issue"
	echo "detail result  can be found in .../AllTestData/${TestSetIndex}/result"
	echo "***********************************************************"
	echo ""
}
# run all test case based on XXXcase.csv file
#usage  runAllCaseTest
runAllCaseTest()
{
	local Flag=""
	let "Flag=0"
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
			runBitStreamVerify
			
			runSingleCasePostAction  ${CaseData}
			let "TotalCaseNum++"				
		fi
	done <$AllCaseFile
	runOutputPassNum
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
	
	runGlobalVariableDef
	#for test sequence info
	TestSequenceName=$1
	AllCaseFile=$2	
    runGlobalVariableInitial	
	AllCaseConsoleLogFile="${FinalResultPath}/${TestSequenceName}.TestLog"
	CaseSummaryFile="${FinalResultPath}/${TestSequenceName}.Summary"
	FlagFile=""
	#run all cases
	runAllCaseTest>${AllCaseConsoleLogFile}
	# output file locate in ./result
	TestFolder=`echo $CurrentDir | awk 'BEGIN {FS="/"} { i=NF; print $i}'`
	echo "${TestSetIndex}_${TestSequenceName}, \
		 ${PassCaseNum} pass!,                  \
		 ${UnpassCaseNum} unpass!,				\
		 detail file located in ../AllTestData/${TestFolder}/result">${CaseSummaryFile}
	#generate All case Flag
	if [  ! ${UnpassCaseNum} -eq 0  ]	
	then
		FlagFile="../result/${TestSetIndex}_${TestSequenceName}.unpassFlag"
	else
		FlagFile=" ../result/${TestSetIndex}_${TestSequenceName}.passFlag"
	fi
	touch ${FlagFile}
	runOutputPassNum
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
#call main function 
TestYUVName=$1
AllCaseFile=$2
runMain  ${TestYUVName}   ${AllCaseFile}


