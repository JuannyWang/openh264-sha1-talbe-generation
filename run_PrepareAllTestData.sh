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
#      --delete previous test data, and prepare test space for all test bit stream in AllTestData/XXX.264
#      --usage: run_PrepareAllTestData.sh  $AllTestDataFolder  $TestBitStreamFolder  \
#                                          $CodecFolder  $ScriptFolder               \
#                                          $ConfigureFile/$SH1TableFolder
#
#
#date:  10/06/2014 Created
#***************************************************************************************
#usage: runGetTestYUVList  ${ConfigureFile}
runGetTestYUVList()
{
  if [ ! $# -eq 1  ]
  then
    echo "usage: runGetTestYUVList  \${ConfigureFile}"
    return 1
  fi
  
  local ConfigureFile=$1
  local TestSet1=""
  local TestSet2=""
  local TestSet3=""
  local TestSet4=""
  local TestSet5=""
  local TestSet6=""
  local TestSet7=""   
  while read line
  do
     if [[ "$line" =~ ^TestSet1  ]]
    then
      TestSet1=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    elif  [[ "$line" =~ ^TestSet2  ]]
    then
      TestSet2=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    elif  [[ "$line" =~ ^TestSet3  ]]
    then
      TestSet3=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    elif  [[ "$line" =~ ^TestSet4  ]]
    then
      TestSet4=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    elif  [[ "$line" =~ ^TestSet5  ]]
    then
      TestSet5`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    elif  [[ "$line" =~ ^TestSet6  ]]
    then
      TestSet6=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    elif  [[ "$line" =~ ^TestSet7  ]]
    then
      TestSet7=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    fi	  	  
  done <${ConfigureFile}
  
  echo "${TestSet1}  ${TestSet2}  ${TestSet3}  ${TestSet4}  ${TestSet5}  ${TestSet6}  ${TestSet7}  "
  
}
#usage: runPrepareALlFolder   $AllTestDataFolder  $TestBitStreamFolder   $CodecFolder  $ScriptFolder  $ConfigureFile/$SH1TableFolder
runPrepareALlFolder()
{
  #parameter check!
  if [ ! $# -eq 5  ]
  then
    echo "usage: usage: run_PrepareAllTestFolder.sh    \$AllTestDataFolder  \$TestBitStreamFolder  \$CodecFolder  \$ScriptFolder \$ConfigureFile"
    return 1
  fi
  local AllTestDataFolder=$1
  local TestBitStreamFolder=$2
  local CodecFolder=$3
  local ScriptFolder=$4
  local ConfigureFile=$5
  local SubFolder=""
  local IssueFolder="issue"
  local TempDataFolder="TempData"
  local ResultFolder="result"
  local SHA1TableFolder="SHA1Table"
  local FinalResultDir="FinalResult"
  declare -a aTestYUVList
  
  if [ -d $AllTestDataFolder ]
  then
    ./${ScriptFolder}/run_SafeDelete.sh  $AllTestDataFolder
  fi
  if [ -d $SHA1TableFolder ]
  then
    ./${ScriptFolder}/run_SafeDelete.sh  $SHA1TableFolder
  fi
  if [ -d $FinalResultDir ]
  then
    ./${ScriptFolder}/run_SafeDelete.sh  $FinalResultDir
  fi
  mkdir ${SHA1TableFolder}
  mkdir ${FinalResultDir}
  echo ""
  echo "preparing All test data folders...."
  echo ""
  echo ""
  aTestYUVList=(`runGetTestYUVList  ${ConfigureFile}`)
  
  for TestYUV in ${aTestYUVList[@]}
  do
    SubFolder="${AllTestDataFolder}/${TestYUV}"
	
	if [  -d  ${SubFolder}  ]
	then
		continue
	fi
	
    echo "BitSream is ${Bitsream}"
    echo "sub folder is  ${SubFolder}"
    echo ""
    mkdir -p ${SubFolder}
    mkdir -p ${SubFolder}/${IssueFolder}
    mkdir -p ${SubFolder}/${TempDataFolder}
    mkdir -p ${SubFolder}/${ResultFolder}
    cp  ${CodecFolder}/*    ${SubFolder}
    cp  ${ScriptFolder}/*   ${SubFolder}
    cp  ${ConfigureFile}    ${SubFolder}
  done
}
AllTestDataFolder=$1
TestBitStreamFolder=$2
CodecFolder=$3
ScriptFolder=$4
ConfigureFile=$5
runPrepareALlFolder   $AllTestDataFolder  $TestBitStreamFolder   $CodecFolder  $ScriptFolder  $ConfigureFile
echo ""
echo ""

