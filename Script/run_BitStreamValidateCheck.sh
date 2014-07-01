HA1 table generation model:
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
#      --check that whether the bit stream  is matched with JM decoder
#      --usage: run_BitStreamValidateCheck.sh   ${BitStreamFile}  ${JMDecYUVFile}  \
#                                               ${DecYUVFile}  ${RecYUVFile} ${IssueDataPath}
#      
#
#date:  10/06/2014 Created
#***************************************************************************************
runJMCheck()
{
	local JMDecodeFlag=""
	#run JM decoder
	echo "">>${CheckLogFile}
	echo ".............JM decoder log.............">>${CheckLogFile}
	echo "">>${CheckLogFile}
	
	./ldecod.exe -p InputFile="${BitStreamFile}"  -p OutputFile="${JMDecYUVFile}">>${CheckLogFile}
    let "JMDecodeFlag=$?"
	if [ ! ${JMDecodeFlag}  -eq 0  ]
	then
		return 3
	fi
	
	return 0
}
runJMRecCheck()
{
	
	local DiffInfo="JM_WelsEncRec_YUV.diff"
	#diff   JMDec_YUV ---Welsenc_Rec_YUV
	diff -q ${JMDecYUVFile}   ${RecYUVFile}>${DiffInfo}
	
	if [  -s ${DiffInfo} ]
	then 
		rm -f  ${DiffInfo}
		return 4
	fi
	
	rm -f  ${DiffInfo}
	return 0
	
	
}
runWelsDecCheck()
{
	local WelsDecodeFlag=""
	echo "" >>${CheckLogFile}
	echo ".....................WelsDecoder log...................">>${CheckLogFile}
	echo "">>${CheckLogFile}
	
	./h264dec     ${BitStreamFile}   ${DecYUVFile} 2>>${CheckLogFile}
	
    let "WelsDecodeFlag=$?"
	if [ ! ${WelsDecodeFlag}  -eq 0  ]
	then
		return 5
	fi
	return 0
}
runJMDecCheck()
{
	
	local DiffInfo="JMDec_WelsDec_YUV.diff"
	
	#diff   JMDec_YUV ---Welsdec_YUV
	diff -q ${JMDecYUVFile}   ${DecYUVFile}>${DiffInfo}
	
	if [  -s ${DiffInfo} ]
	then 
		
		return 6
	fi
	rm -f  ${DiffInfo}
	return 0
}
runRecDecCheck()
{
	
	local DiffInfo="Welesenc_WelsDec_YUV.diff"
	#diff   Welsdec_YUV ---Welsenc_Rec_YUV
	diff -q ${DecYUVFile}   ${DecYUVFile}>${DiffInfo}
	
	if [  -s ${DiffInfo} ]
	then 
		cp -f ${BitStreamFile}            ${IssueDataPath}
		return 7
	fi
	rm -f  ${DiffInfo}
	return 0
}
#called by run_SHA1ForOneStreamAllCases.sh
#WelsRuby rec yuv and JSVM dec yuv  comparison
#usage: runBitStreamVerify   ${BitStreamFile}  ${JMDecYUVFile}  ${DecYUVFile}  ${RecYUVFile} ${IssueDataPath}
runBitStreamVerify()
{
	if [ ! $#  -eq 5  ]
	then 
		echo "usage: runBitStreamVerify   \${BitStreamFile}  \${JMDecYUVFile}  \${DecYUVFile}  \${RecYUVFile} \${IssueDataPath}"
		return 1
	fi
	
	local ReturnValue=""
	
			
	BitStreamFile=$1
	JMDecYUVFile=$2
	DecYUVFile=$3
	RecYUVFile=$4
	IssueDataPath=$5
			
			
	
	CheckLogFile="JMDec_WelsDec_log.log"
	echo "">${CheckLogFile}
	
	declare -a CheckInfo
	CheckInfo=("0:passed! bitstream pass"     \
	"1:unpassed! 0 bits--bit stream"          \
	"2:unpassed! 0 bits--Rec YUV file"        \
	"3:unpassed! JMDecoder  decoded failed"   \
	"4:unpassed! Diff: JMDec-Rec not matched" \
	"5:unpassed! WelDecoder decoded failed"   \
	"6:unpassed! Diff: JMDec-Dec not matched" \
	"7:unpassed! Diff: Rec-Dec   not matched" )
	
	#file size check
	#*******************************************
	if [ ! -s ${BitStreamFile} ]
	then 
		echo ${CheckInfo[1]}
		return 1
	elif [ ! -s ${RecYUVFile} ]
	then
		echo ${CheckInfo[2]}
		return 2
	fi
	runJMCheck
	let " ReturnValue=$?"
	if [ ! ${ReturnValue} -eq  0 ]
	then
		echo ${CheckInfo[3]}
		return 3
	fi
	
	runJMRecCheck
	let " ReturnValue=$?"
	if [ ! ${ReturnValue} -eq  0 ]
	then
		echo ${CheckInfo[4]}
		return 4
	fi
	runWelsDecCheck>>${CheckLogFile}
	let " ReturnValue=$?"
	if [ ! ${ReturnValue} -eq  0 ]
	then
		echo ${CheckInfo[5]}
		return 5
	fi
	
	runJMDecCheck>>${CheckLogFile}
	let " ReturnValue=$?"
	if [ ! ${ReturnValue} -eq  0 ]
	then
		echo ${CheckInfo[6]}
		return 6
	fi
	
	runRecDecCheck>>${CheckLogFile}
	let " ReturnValue=$?"
	if [ ! ${ReturnValue} -eq  0 ]
	then
		echo ${CheckInfo[7]}
		return 7
	fi	
	#pass all validate check!
	echo ${CheckInfo[0]}
	return 0
	
}
BitStreamFile=$1
JMDecYUVFile=$2
DecYUVFile=$3
RecYUVFile=$4
IssueDataPath=$5
runBitStreamVerify  ${BitStreamFile}  ${JMDecYUVFile}  ${DecYUVFile}  ${RecYUVFile} ${IssueDataPath}

