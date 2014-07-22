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
#  
#
#date:  10/06/2014 Created
#***************************************************************************************

runGlobalVariableInitial()
{

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
  EncoderCommand=""
  EncoderLog="encoder.log"

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
  
  BitStreamFile=${TempDataPath}/${TestYUVName}_${BitstreamPrefix}_codec_target.264
  
  RecYUVFileLayer0=${TempDataPath}/${TestYUVName}_rec0.yuv
  RecYUVFileLayer1=${TempDataPath}/${TestYUVName}_rec1.yuv
  RecYUVFileLayer2=${TempDataPath}/${TestYUVName}_rec2.yuv
  RecYUVFileLayer3=${TempDataPath}/${TestYUVName}_rec3.yuv
  
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
	./h264enc ${TempCammand}   -bf   ${BitStreamFile} -org  ${InputYUV} \
		-drec 0 ${RecYUVFileLayer0} \
		-drec 1 ${RecYUVFileLayer1} \
		-drec 2 ${RecYUVFileLayer2} \
		-drec 3 ${RecYUVFileLayer3}>${EncoderLog}
}

runOutputCheckLog()
{

	echo  "EncoderPassedNum: 1"
	echo  "EncoderUnPassedNum: 0"
	echo  "DecoderPassedNum: 0"
	echo  "DecoderUpPassedNum: 0"
	echo  "DecoderUnCheckNum: 1"
}

# usage: runMain $TestYUV  $InputYUV $AllCaseFile
runMain()
{
  if [  $# -lt 10  ]
  then
    echo "usage: run_TestOneCase.sh \${CaseInfo}"
    return 1
  fi
  #for test sequence info
  TestCaseInfo=$@
  runGlobalVariableInitial
  runEncoderCommandInital
 
  runParseCaseInfo ${TestCaseInfo}
  runEncodeOneCase
  runOutputCheckLog>${CheckLogFile}
 
}
#call main function
CaseInfo=$@
runMain  ${CaseInfo}



