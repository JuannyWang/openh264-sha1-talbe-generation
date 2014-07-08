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
#usage:  runParseYUVInfo  ${YUVName}
runParseYUVInfo()
{
 if [ ! $# -eq 1 ]
  then
    echo "usage:  usage  runGetTargetBitRate  \${YUVName}"
    return 1
  fi
    
  declare -a aYUVInfo
  aYUVInfo=(`./run_ParseYUVInfo.sh  ${TestSequence}`)
  PicW=${aYUVInfo[0]}
  PicH=${aYUVInfo[1]}
  FPS=${aYUVInfo[2]}
  
   
  if [  ${PicW} -eq 0 -o ${PicH} -eq 0  ]
  then
	echo "YUVName is not correct,should be named as ABC_PicWXPicH_FPS.yuv"
	exit 1
  fi
  
  if [  ${FPS} -eq 0  ]
  then
    let "FPS=10"
  fi
   
  if [  ${FPS} -gt 50  ]
  then
    let "FPS=50"
  fi
  
  
  return 0
}
#usage  runGetTargetBitRate  
#eg:    input:  runGetTargetBitRate  
#       output:    1500  800 300   100   (for test_1920X1080.yuv)
runGetTargetBitRate()
{
 
  declare -a aTargetBitRate
  
  let " TotalPix=PicW*PicH"
  let "NumBitRatePoint=0"
  let "BitRateFactor=$FPS/10"
  if [  ${TotalPix} -le ${Flag_QCIF} ]
  then
    aTargetBitRate=( ${TargetBitRate_QCIF} )
  elif [  ${TotalPix} -le ${Flag_QVGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_QVGA} )
  elif [  ${TotalPix} -le ${Flag_VGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_VGA} ) 
   elif [  ${TotalPix} -le ${Flag_SVGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_SVGA} )
  elif [  ${TotalPix} -le ${Flag_XGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_XGA} )
  elif [  ${TotalPix} -le ${Flag_SXGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_SXGA} )
  elif [  ${TotalPix} -le ${Flag_WSXGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_WSXGA} )
  elif [  ${TotalPix} -le ${Flag_WUXGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_WUXGA} )
  elif [  ${TotalPix} -le ${Flag_QXGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_QXGA} )
  fi
  
  NumBitRatePoint=${#aTargetBitRate[@]}
  
  for((i=0; i< ${NumBitRatePoint}; i++))
  do
    let "TargetBitrate[$i]=${aTargetBitRate[$i]}*${BitRateFactor}"
  done
  
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
  declare -a NumTempLayer
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
  TargetBitRate_QCIF=""     #176x144,   for those resolution: PicWXPicH <=176x144
  TargetBitRate_QVGA=""     #320x240,   for those resolution: 176x144    <  PicWXPicH <= 320x240	
  TargetBitRate_VGA=""      #640x480,   for those resolution: 320x240    <  PicWXPicH <= 640x480	 	
  TargetBitRate_SVGA=""     #800x600,   for those resolution: 640x480    <  PicWXPicH <= 800x600		
  TargetBitRate_XGA=""      #1024x768,  for those resolution: 800x600    <  PicWXPicH <= 1024x768
  TargetBitRate_SXGA=""     #1280x1024, for those resolution: 1024x768   <  PicWXPicH <= 1280x1024
  TargetBitRate_WSXGA=""    #1680x1050, for those resolution: 1280x1024  <  PicWXPicH <= 1680x1050
  TargetBitRate_WUXGA=""    #1920x1200, for those resolution: 1680x1050  <  PicWXPicH <= 1920x1200
  TargetBitRate_QXGA=""     #2048x1536, for those resolution: 1920x1200  <  PicWXPicH <= 2048x1536   
 
  let "Flag_QCIF  =176*144"
  let "Flag_QVGA  =320*240"
  let "Flag_VGA   =640*480"
  let "Flag_SVGA  =800*600"
  let "Flag_XGA   =1024*768"
  let "Flag_SXGA  =1280*1024"
  let "Flag_WSXGA =1680*1050"
  let "Flag_WUXGA =1920*1200"
  let "Flag_QXGA  =2048*1536"  
  
  let "PicW=0"
  let "PicH=0"
  let "FPS=0"
  runParseYUVInfo  ${TestSequence}
  
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
    if [[ "$line" =~ ^FramesToBeEnc  ]]
    then
      FramesToBeEncoded=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    elif [[ "$line" =~ ^UsageType ]]
    then
      UsageType=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
    elif [[ "$line" =~ ^TemporalLayerNum ]]
    then
      NumTempLayer=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
    elif [[ "$line" =~ ^MultipleThreadIdc ]]
    then
      MultipleThreadIdc=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
    elif [[ "$line" =~ ^SliceMode ]]
    then
      SliceMode=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
    elif [[ "$line" =~ ^MaxNalSize ]]
    then
      MaxNalSize=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
    elif [[ "$line" =~ ^SliceNum ]]
    then
      SliceNum=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
    elif [[ "$line" =~ ^IntraPeriod ]]
    then
      IntraPeriod=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
    elif [[ "$line" =~ ^RCMode ]]
    then
      RCMode=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
    elif [[ "$line" =~ ^EnableLongTermReference ]]
    then
      EnableLongTermReference=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
    elif [[ "$line" =~ ^LoopFilterDisableIDC ]]
    then
      LoopFilterDisableIDC=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
    elif [[ "$line" =~ ^InitialQP ]]
    then
      InitialQP=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
    elif [[ "$line" =~ ^EnableDenoise ]]
    then
      EnableDenoise=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
    elif [[ "$line" =~ ^EnableSceneChangeDetection ]]
    then
      EnableSceneChangeDetection=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
    elif [[ "$line" =~ ^EnableBackgroundDetection ]]
    then
      EnableBackgroundDetection=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
    elif [[ "$line" =~ ^EnableAdaptiveQuantization ]]
    then
      EnableAdaptiveQuantization=`echo $line | awk 'BEGIN {FS="[#:]"} {print $2}' `
    fi
	
	#get target bit rate setting
	if [[ "$line" =~ ^TargetBitRate_QCIF  ]]
    then
      TargetBitRate_QCIF=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_QVGA  ]]
    then
      TargetBitRate_QVGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_VGA  ]]
    then
      TargetBitRate_VGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_SVGA  ]]
    then
      TargetBitRate_SVGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `	
    elif [[ "$line" =~ ^TargetBitRate_XGA  ]]
    then
      TargetBitRate_XGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_SXGA  ]]
    then
      TargetBitRate_SXGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `	
    elif [[ "$line" =~ ^TargetBitRate_WSXGA+  ]]
    then
      TargetBitRate_WSXGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `	
    elif [[ "$line" =~ ^TargetBitRate_WUXGA  ]]
    then
      TargetBitRate_WUXGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `	
    elif [[ "$line" =~ ^TargetBitRate_QXGA  ]]
    then
      TargetBitRate_QXGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `	
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
        if [ $SlcMode -eq 0  ]
        then
          ThreadNumber=( 1 )
        else
          ThreadNumber=( ${MultipleThreadIdc[@]} )
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
  echo "PicW X PicH_FPS is ${PicW} x ${PicH}_${FPS}"
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
  
  echo "TargetBitRate_QCIF=   ${TargetBitRate_QCIF}"    
  echo "TargetBitRate_QVGA=   ${TargetBitRate_QVGA}"     
  echo "TargetBitRate_VGA=    ${TargetBitRate_VGA}"     
  echo "TargetBitRate_SVGA=   ${TargetBitRate_SVGA}"     		
  echo "TargetBitRate_XGA=    ${TargetBitRate_XGA}"    
  echo "TargetBitRate_SXGA=   ${TargetBitRate_SXGA}"   
  echo "TargetBitRate_WSXGA=  ${TargetBitRate_WSXGA}"  
  echo "TargetBitRate_WUXGA=  ${TargetBitRate_WUXGA}"   
  echo "TargetBitRate_QXGA=   ${TargetBitRate_QXGA}"  
  
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
  runGetTargetBitRate  
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

