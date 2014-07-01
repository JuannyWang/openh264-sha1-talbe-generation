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
#      --generate  case based on cade configure file
#      usage: ./run_GenerateCase.sh  $Case.cfg   $TestSequence  $OutputCaseFile 
#      eg:      run_GenerateCase.sh  case.cfg  ABC_1920X1080.yuv  AllCase.csv
#
#date:  10/06/2014 Created
#***************************************************************************************
#usage  runGetTargetBitRate  $TestSequenceName
#eg:    input:  runGetTargetBitRate  test_1920X1080.yuv
#       output:    1500  800 300   100    (test bit rate point)
runGetTargetBitRate()
{
	if [ ! $# -eq 1 ]
	then
		echo "usage:  usage  runGetTargetBitRate  \$TestSequenceName"
		return 1
	fi
	
	local TestSequence=$1
	local PicW=""
	local PicH=""	
	local TotalPix=""
	declare -a aYUVInfo
	aYUVInfo=(`./run_ParseYUVInfo.sh  ${TestSequence}`)
	PicW=${aYUVInfo[0]}
	PicH=${aYUVInfo[1]}
	
	let "TotalPix=PicW * PicH"
	let "Flag_2K=1920*1080"
	let "Flag_1080p=1280*720"	
	let "Flag_720p=800*640"
	let "Flag_640=400*240"	
	let "Flag_320=320*200"	
	
	#for testtarget bitrate initial
	local BitRate_2K="2500   200"
	local BitRate_1080p="2000    120"
	local BitRate_720p="1500   100"
	local BitRate_640="1200   80"
	local BitRate_320="800   60"
	local BitRate_160="700   50"
	if [  ${TotalPix} -ge ${Flag_2K} ]
	then 
		echo "${BitRate_2K}"
	elif [  ${TotalPix} -ge ${Flag_1080p}  ]
	then 
		echo "${BitRate_1080p}"
	elif [  ${TotalPix} -ge ${Flag_720p} ]
	then 
		echo "${BitRate_720p}"
	elif [  ${TotalPix} -ge ${Flag_640}  ]
	then 
		echo "${BitRate_640}"
	elif [  ${TotalPix} -ge ${Flag_320} ]
	then 
		echo "${BitRate_320}"
	else
		echo "${BitRate_160}"
	fi
}
#usage:   runCaseVilidationcheck  \$CaseInfo 
runCaseVilidationcheck()
{
	if [ ! $# -lt 2 ]
	then
		echo "usage:   runCaseVilidationcheck  \$CaseInfo "
		return 1
	fi
	
	echo "to do"
	
}
#usage  runGlobalVariableInital  $TestSequence  $OutputCaseFile 
runGlobalVariableInital()  
{
	if [ ! $# -eq 2 ]
	then
		echo "usage:   runGlobalVariableInital  \$TestSequence  \$OutputCaseFile "
		return 1
	fi
	local  TestSequence=$1
	local  OutputCaseFile=$2
	
	let " FramesToBeEncoded = 0"
	let " MaxNalSize = 0"
	declare -a  NumTempLayer
	declare -a  UsageType
	declare -a  RCMode
	declare -a  IntraPeriod
	declare -a  TargetBitrate
	declare -a  InitialQP
	
	declare -a  SliceMode
	declare -a  SliceNum
	declare -a  MultipleThreadIdc
	declare -a  EnableLongTermReference
	declare -a  LoopFilterDisableIDC 
	
	declare -a  EnableDenoise
	declare -a  EnableSceneChangeDetection
	declare -a  EnableBackgroundDetection
	declare -a  EnableAdaptiveQuantization
	
	#generate test cases and output to case file
	casefile=${OutputCaseFile}
	casefile_01=${OutputCaseFile}_01.csv
	casefile_02=${OutputCaseFile}_02.csv
}
#usage:  runParseCaseConfigure $ConfigureFile
runParseCaseConfigure()
{
	#parameter check! 
	if [ ! $# -eq 1  ]
	then
		echo "usage:  runParseCaseConfigure \$ConfigureFile"
		return 1
	 fi
	local ConfigureFile=$1
	#read configure file
	while read line
	do
		command=$line #`echo $line | awk 'BEGIN {FS="[#:]"} {print $1}'`
		if [[ "$command" =~ ^FramesToBeEnc  ]]
		then
			FramesToBeEncoded=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
		elif [[ "$command" =~ ^UsageType ]]
		then
			UsageType=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
		elif [[ "$command" =~ ^TemporalLayerNum ]]
		then
			NumTempLayer=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
		elif [[ "$command" =~ ^MultipleThreadIdc ]]
		then
			MultipleThreadIdc=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
		elif [[ "$command" =~ ^SliceMode ]]
		then
			SliceMode=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
		elif [[ "$command" =~ ^MaxNalSize ]]
		then
			MaxNalSize=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
		elif [[ "$command" =~ ^SliceNum ]]
		then
			SliceNum=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
		elif [[ "$command" =~ ^IntraPeriod ]]
		then
			IntraPeriod=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
		elif [[ "$command" =~ ^RCMode ]]
		then
			RCMode=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
		elif [[ "$command" =~ ^EnableLongTermReference ]]
		then
			EnableLongTermReference=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
		elif [[ "$command" =~ ^LoopFilterDisableIDC ]]
		then
			LoopFilterDisableIDC=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
		elif [[ "$command" =~ ^InitialQP ]]
		then
			InitialQP=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
		elif [[ "$command" =~ ^EnableDenoise ]]
		then
			EnableDenoise=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
		elif [[ "$command" =~ ^EnableSceneChangeDetection ]]
		then
			EnableSceneChangeDetection=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
		elif [[ "$command" =~ ^EnableBackgroundDetection ]]
		then
			EnableBackgroundDetection=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
		elif [[ "$command" =~ ^EnableAdaptiveQuantization ]]
		then
			EnableAdaptiveQuantization=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
		fi
	done <$ConfigureFile
	
}
#the first stage for case generation
runFirstStageCase()
{
	for NumLayer in ${NumTempLayer[@]}
	do
		for ScreenSignal in ${UsageType[@]}
		do
			for RCModeIndex in ${RCMode[@]}
			do
				## set RCMode QP and BitRate value based on RCMode				
				declare -a QPforTest
				declare -a BitRateforTest
				if [[  "$RCModeIndex" =~  "-1"  ]]
				then
					QPforTest=${InitialQP[@]}
					BitRateforTest=(256)			
				else
					QPforTest=(26)
					BitRateforTest=${TargetBitrate[@]}			
				fi
				#......for loop.........................................#
				
				for QPIndex in ${QPforTest[@]}
				do
					for BitRateIndex in ${BitRateforTest[@]}
					do				
						echo   "$FramesToBeEncoded,\
								$NumLayer, \
								$ScreenSignal,\
								$RCModeIndex,\
								$BitRateIndex,\
								$QPIndex">>$casefile_01						
					done # BitRate loop
				done # QP loop
			done #RCMode loop	    	
			#..........................................................#
		done
	done
}
##second stage for case generation
runSecondStageCase()
{	
	while read FirstStageCase
	do
		for IntraPeriodIndex in ${IntraPeriod[@]}
		do
			for SlcMode in ${SliceMode[@]}
			do  
				#for slice number based on different sliceMode
				declare -a SliceNumber
				declare -a ThreadNumber
				if [ $SlcMode -eq 1 ]
				then
					SliceNumber=(4 7)
				else
					SliceNumber=(0)
				fi
				#for slice number based on different thread number	
				if [ $SlcMode -eq 2   -o  $SlcMode -eq 3  ]
				then 
					ThreadNumber=${MultipleThreadIdc[@]} 
				else
					ThreadNumber=(1)
				fi
				
				for SlcNum in ${SliceNumber[@]}
				do
					for ThreadNum in ${ThreadNumber[@]}
					do											
						if  [[ $FirstStageCase =~ ^[-0-9]  ]]
						then
							echo   "$FirstStageCase,\
									$IntraPeriodIndex,\
									$SlcMode, \
									$SlcNum,\
									$ThreadNum">>$casefile_02
						fi
					done #threadNum loop		    	
				done #sliceNum loop
			done #Slice Mode loop
		done # Entropy loop
	done <$casefile_01
}
#the third stage for case generation
runThirdStageCase()
{
	local SliceMd=""
	local ActualNalSize=""
	
	local DenoiseFlag=""
	local SceneChangeFlag=""
	local BackgroundFlag=""
	local AQFlag=""
		
	declare -a CaseInfo
		
	while read SecondStageCase
	do
		if [[ $SecondStageCase =~ ^[-0-9]  ]]
		then	
			for LTRFlag in ${EnableLongTermReference[@]}
			do
				for LoopfilterIndex in ${LoopFilterDisableIDC[@]}
				do				
	                for  DenoiseFlag in ${EnableDenoise[@]}
					do
						for  SceneChangeFlag in ${EnableSceneChangeDetection[@]}
						do
							for  BackgroundFlag in ${EnableBackgroundDetection[@]}
							do
								for  AQFlag in ${EnableAdaptiveQuantization}
								do
									CaseInfo=(`echo $SecondStageCase | awk 'BEGIN {FS=","} {for(i=1;i<=NF;i++) printf("%s  ", $i)}'`)
									SliceMd=${CaseInfo[7]}
									if [  $SliceMd -eq 4  ]
									then
										let "ActualNalSize= ${MaxNalSize}"
									else
										let "ActualNalSize= 0"
									fi							
								
									echo "$SecondStageCase,\
										  $LTRFlag,\
										  $LoopfilterIndex,\
										  $ActualNalSize,\
										  ${DenoiseFlag},\
										  ${SceneChangeFlag},\
										  ${BackgroundFlag},\
										  ${AQFlag}">>$casefile
								done					
							done												
						done
					done						
				done
			done
		fi
	done <$casefile_02
}
#only for test
runOutputParseResult()
{
	echo "all case info has been  output to file $casefile "
	echo "Frames=           $FramesToBeEncoded"
	echo "NumTempLayer=     ${NumTempLayer[@]}"
	echo "UsageType= ${UsageType[@]}"
	echo "MaxNalSize=        $MaxNalSize"
	echo "RCMode=           ${RCMode[@]}"
	echo "TargetBitrate=    ${TargetBitrate[@]}"
	echo "InitialQP=        ${InitialQP[@]}"
	echo "IntraPeriod=      ${IntraPeriod}"
	
	echo "SliceMode=         ${SliceMode[@]}"
	echo "SliceNum=          ${SliceNum[@]}"
	echo "MultipleThreadIdc= ${MultipleThreadIdc[@]}"
	echo "EnableLongTermReference=${EnableLongTermReference[@]}"
	echo "LoopFilterDisableIDC=   ${LoopFilterDisableIDC[@]}"
	
	echo "EnableDenoise=                ${EnableDenoise[@]}"
	echo "EnableSceneChangeDetection=   ${EnableSceneChangeDetection[@]}"
	echo "EnableBackgroundDetection=    ${EnableBackgroundDetection[@]}"
	echo "EnableAdaptiveQuantization=   ${EnableAdaptiveQuantization[@]}"
}
runBeforeGenerate()
{
	headline="FramesToBeEncoded,\
					NumTempLayer, \
					UsageType,\
					RCMode,\
					TargetBitrate,\
					InitialQP,\
					IntraPeriod,\
					SliceMode,\
					SliceNum,\
					MultipleThreadIdc,\
					EnableLongTermReference,\
					LoopFilterDisableIDC,\
					MaxNalSize,\
					DenoiseFlag,\
					SceneChangeFlag,\
					BackgroundFlag,\
					AQFlag" 
	echo $headline>$casefile			
	echo $headline>$casefile_01
	echo $headline>$casefile_02
}
runAfterGenerate()
{
	#deleted temp_case file
	rm -f $casefile_01
	rm -f $casefile_02
}
#usage:   runMain   $Case.cfg   $TestSequence  $OutputCaseFile 
runMain()
{
	if [ ! $# -eq 3 ]
	then
		echo "usage:   runMain   \$Case.cfg   \$TestSequence  \$OutputCaseFile  "
		return 1
	fi
	
	local ConfigureFile=$1
	local TestSequence=$2
	local OutputCaseFile=$3
	
	
	runGlobalVariableInital  $TestSequence  $OutputCaseFile
	runBeforeGenerate
	runParseCaseConfigure  ${ConfigureFile}
	TargetBitrate=`runGetTargetBitRate  ${TestSequence}`
	runOutputParseResult
	runFirstStageCase
	runSecondStageCase
	runThirdStageCase
	runAfterGenerate
}
ConfigureFile=$1
TestSequence=$2
OutputCaseFile=$3
echo ""
echo "case generating ......"
runMain  ${ConfigureFile}   ${TestSequence}   ${OutputCaseFile}

