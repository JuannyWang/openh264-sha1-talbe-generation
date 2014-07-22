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
#date:  10/06/2014 Created
#***************************************************************************************
runGlobalVariableInitial()
{
  CurrentDir=`pwd`
  #test data space
  FinalResultPath="result"
  IssueDataPath="issue"
  TempDataPath="TempData"
  mkdir -p ${FinalResultPath}
  mkdir -p ${IssueDataPath}
  mkdir -p ${TempDataPath}
  
  #test cfg file and test info output file
  ConfigureFile=welsenc.cfg
  AllCasePassStatusFile="${FinalResultPath}/${TestSequenceName}_AllCaseOutput.csv"
  AllCaseSHATableFile="${FinalResultPath}/${TestSequenceName}_AllCase_SHA1_Table.csv"
  AllCaseConsoleLogFile="${FinalResultPath}/${TestSequenceName}.TestLog"
  CaseSummaryFile="${FinalResultPath}/${TestSequenceName}.Summary"
  echo  "EncoderFlag,DecoderFlag,SHA-1, MD5, BitStreamSize, YUVSize,\
        -scrsig,  -frms,  -numl,  -numtl,-sh, -sw,\
		-dw 0, -dh 0, -dw 1, -dh 1,-dw 2, -dh 2, -dw 3, -dh 3,\
		-frout 0,  -frout 1, -frout 2, -frout 3,\
		-lqp 0, -lqp 1, -lqp 2, -lqp 3,\
		-rc,-tarb, -ltarb 0, -ltarb 1, -ltarb 2, -ltarb 3,\ 
		-nalsize, -iper, -thread, -ltr, -db, -denois,\ 
		-scene    -bgd    -aq ">${AllCasePassStatusFile}
  echo  "SHA-1 Value, MD5String, BitStreamSize, YUVSize, \
        -scrsig,  -frms,  -numl,  -numtl,-sh, -sw,\
		-dw 0, -dh 0, -dw 1, -dh 1,-dw 2, -dh 2, -dw 3, -dh 3,\
		-frout 0,  -frout 1, -frout 2, -frout 3,\
		-lqp 0, -lqp 1, -lqp 2, -lqp 3,\
		-rc,-tarb, -ltarb 0, -ltarb 1, -ltarb 2, -ltarb 3,\ 
		-nalsize, -iper, -thread, -ltr, -db, -denois,\ 
		-scene    -bgd    -aq ">${AllCaseSHATableFile}
		
  #initial command line parameters
  declare -a EncoderCommandSet
  declare -a EncoderCommandName
  declare -a EncoderCommandValue
  #encoder parameters  change based on the case info
  CaseInfo=""
  BitStreamFile=""
  RecYUVFileLayer0=""
  RecYUVFileLayer1=""
  RecYUVFileLayer2=""
  RecYUVFileLayer3=""
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
  EncoderCommandSet=(-scrsig  -frms  -numl   -numtl \
				-sh -sw  "-dw 0"  "-dh 0" "-dw 1" "-dh 1" "-dw 2" "-dh 2" "-dw 3" "-dh 3" \
				"-frout 0" "-frout 1" "-frout 2" "-frout 3" \
				"-lqp 0" "-lqp 1" "-lqp 2" "-lqp 3" \
				-rc -tarb "-ltarb 0" 	"-ltarb 1" "-ltarb 2" "-ltarb 3" \
				"-slcmd 0" "-slcnum 0" "-slcmd 1" "-slcnum 1"\
				"-slcmd 2" "-slcnum 2" "-slcmd 3" "-slcnum 3"\
				-nalsize -iper   -thread    -ltr \
				-db  -denois    -scene    -bgd    -aq )
  EncoderCommandName=(scrsig  frms  numl   numtl \
				sw sh  dw0 dh0 dw1 dh1 dw2 dh2 dw3 dh3 \
				frout0 frout1 frout2 frout3 \
				lqp0 lqp1 lqp2 lqp3 \
				rc tarb ltarb0 	ltarb1 ltarb2 ltarb3 \
				slcmd0 slcnum0 slcmd1 slcnum1 \
				slcmd2 slcnum2 slcmd3 slcnum3 \
				nalsize iper   thread  ltr \
				db  denois  scene  bgd  aq )	
  NumParameter=${#EncoderCommandSet[@]}
  
  for ((i=0;i<NumParameter; i++))
  do
		EncoderCommandValue[$i]=0
  done
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
  declare -a aTempParamIndex=( 6 7 8 9 10 11 12 13    15 16 17   19 20 21     24 25 26 27   30 31 32 33 34 35  )
  TempData=`echo $CaseData |awk 'BEGIN {FS="[,\r]"} {for(i=1;i<=NF;i++) printf(" %s",$i)} ' `
  EncoderCommandValue=(${TempData})
  
  let "TempParamFlag=0"
  for((i=0; i<$NumParameter; i++))
  do
	for ParnmIndex in ${aTempParamIndex[@]}
	do
	  if [  $i -eq ${ParnmIndex} ]
	  then
		let "TempParamFlag=1"
	  fi
	done
	
	if [ ${TempParamFlag} -eq 0 ]
	then
	  BitstreamPrefix=${BitstreamPrefix}_${EncoderCommandName[$i]}_${EncoderCommandValue[$i]}
	fi
	let "TempParamFlag=0"    
  done
  
  BitStreamFile=${TempDataPath}/${TestSequenceName}_${BitstreamPrefix}_codec_target.264
  
  RecYUVFileLayer0=${TempDataPath}/${TestSequenceName}_rec0.yuv
  RecYUVFileLayer1=${TempDataPath}/${TestSequenceName}_rec1.yuv
  RecYUVFileLayer2=${TempDataPath}/${TestSequenceName}_rec2.yuv
  RecYUVFileLayer3=${TempDataPath}/${TestSequenceName}_rec3.yuv
  
}
#call by  runAllCaseTest
#usage  runEncodeOneCase
runEncodeOneCase()
{
 
	local TempCammand=""
	for ((i=3; i<${NumParameter}; i++))
	do
		TempCammand="${TempCammand} ${EncoderCommandSet[$i]}  ${EncoderCommandValue[$i]} " 
	done
	TempCammand="${EncoderCommandSet[0]} ${EncoderCommandValue[0]} \
				${EncoderCommandSet[1]}  ${EncoderCommandValue[1]} \
				${EncoderCommandSet[2]}  ${EncoderCommandValue[2]} \
				-lconfig 0 layer0.cfg \
				-lconfig 1 layer1.cfg \
				-lconfig 2 layer2.cfg \
				-lconfig 3 layer3.cfg \
				${TempCammand}"
	echo ""
	echo "case line is :"
	EncoderCommand="./h264enc  ${TempCammand}  -bf   ${BitStreamFile}  -org   ${InputYUV} \
					-drec 0 ${RecYUVFileLayer0} \
					-drec 1 ${RecYUVFileLayer1} \
					-drec 2 ${RecYUVFileLayer2} \
					-drec 3 ${RecYUVFileLayer3}"
	echo ${EncoderCommand}
	./h264enc ${TempCammand}   -bf     ${BitStreamFile} -org    ${InputYUV} \
		-drec 0 ${RecYUVFileLayer0} \
		-drec 1 ${RecYUVFileLayer1} \
		-drec 2 ${RecYUVFileLayer2} \
		-drec 3 ${RecYUVFileLayer3}>${EncoderLog}
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
  InputYUVSize=`runGetFileSize  ${InputYUV}`
  RecYUVSize=`runGetFileSize ${RecYUVFile}`
  ActualEncoded=`runGetEncodedNum  ${EncoderLog} `
  #check the encoder number is the same with setting number
  if [ ${RCMode} -eq -1  ]
  then
    if [ ${EncodedNum} -eq -1  ]
    then
      if [ ! ${InputYUVSize} -eq ${RecYUVSize} ]
      then
        let "EncoderUnPassedNum++"
        let "DecoderUnCheckNum++"
        EncoderCheckResult="1:Encoder failed--Encoded number is not equal to setting!"
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
    SHA1String=`openssl sha1   ${BitStreamFile}`
    SHA1String=`echo ${SHA1String} | awk '{print $1}' `
    MD5String=`openssl  md5  ${BitStreamFile}`
    MD5String=`echo ${MD5String} | awk '{print $1}' `
    YUVSize=`runGetFileSize  ${InputYUV}`
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
      #CaseCheckResult=`./run_BitStreamValidateCheckSingleLayer.sh  ${BitStreamFile}  ${JMDecYUVFile}  ${DecYUVFile}  ${RecYUVFile} ${IssueDataPath}  ${CheckLogFile}`
      echo ".........result parse.........${EncoderFailedFlag}   $CaseCheckResult"
      #runParseCheckResult  ${EncoderFailedFlag}   $CaseCheckResult
      cat ${CheckLogFile}
      echo "return value for bit stream is  ${CaseCheckResult}"
      #runSingleCasePostAction  ${CaseData}
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
  echo  -e "\033[32m *********************************************************** \033[0m"
  echo  -e "\033[32m total case  Num     is : ${TotalCaseNum}\033[0m"
  echo  -e "\033[32m EncoderPassedNum    is : ${EncoderPassedNum}\033[0m"
  echo  -e "\033[31m EncoderUnPassedNum  is : ${EncoderUnPassedNum} \033[0m"
  echo  -e "\033[32m DecoderPassedNum    is : ${DecoderPassedNum}\033[0m"
  echo  -e "\033[31m DecoderUpPassedNum  is : ${DecoderUpPassedNum}\033[0m"
  echo  -e "\033[31m DecoderUnCheckNum   is : ${DecoderUnCheckNum}\033[0m"
  echo "issue bitstream can be found in .../AllTestData/${TestFolder}/issue"
  echo "detail result  can be found in .../AllTestData/${TestFolder}/result"
  echo  -e "\033[32m *********************************************************** \033[0m"
  echo ""
  echo "${TestSetIndex}_${TestSequenceName}">${CaseSummaryFile}
  echo "total case  Num     , ${TotalCaseNum}" >>${CaseSummaryFile}
  echo "EncoderPassedNum    , ${EncoderPassedNum}" >>${CaseSummaryFile}
  echo "EncoderUnPassedNum  , ${EncoderUnPassedNum} " >>${CaseSummaryFile}
  echo "DecoderPassedNum    , ${DecoderPassedNum}" >>${CaseSummaryFile}
  echo "DecoderUpPassedNum  , ${DecoderUpPassedNum}" >>${CaseSummaryFile}
  echo "DecoderUnCheckNum   , ${DecoderUnCheckNum}" >>${CaseSummaryFile}
  echo "  detail file located in ../AllTestData/${TestSetIndex}/result" >>${CaseSummaryFile}
  echo  -e "\033[32m *********************************************************** \033[0m"
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
# usage: runMain $TestYUV  $InputYUV $AllCaseFile
runMain()
{
  if [ ! $# -eq 3  ]
  then
    echo "usage: runMain \$TestYUV \$InputYUV  \$AllCaseFile"
    return 1
  fi
  #for test sequence info
  TestSequenceName=$1
  InputYUV=$2
  AllCaseFile=$3
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
InputYUV=$2
AllCaseFile=$3
runMain  ${TestYUVName}  ${InputYUV}  ${AllCaseFile}

