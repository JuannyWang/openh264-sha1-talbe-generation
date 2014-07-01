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
#      --start point of the test.
#      --before run this script,
#          i) you need to update you codec  in folder ./Codec
#          ii) change you configure file if you do not use the default test case 
#      --usage: run_Main.sh $ConfigureFile
#      
#
#date:  10/06/2014 Created
#***************************************************************************************
 runMain()
 {
 
 
	if [ ! $# -eq 1 ]
	then
		echo "usage: ./run_Main.sh \$ConfigureFile"
		echo "      eg:   ./run_Main.sh  ../CaseConfigure/case.cfg "
		exit 1
	fi
	
	local ConfigureFile=$1
	
	if [  ! -f ${ConfigureFile} ]
	then
		echo "Configure file not exist!, please double check in "
		echo " usage may looks like:   ./run_Main.sh  ../CaseConfigure/case.cfg "
		exit 1
	fi
	
	 #dir translation 
	AllTestDataFolder="AllTestData"
	TestBitStreamFolder="BitStreamForTest"
	CodecFolder="Codec"
	ScriptFolder="Script"
	SH1TableFolder="SHA1Table"
	ConfigureFolder="CaseConfigure"
	FinalResultDir="FinalResult"
	 
	echo ""
	echo ""
	echo "prepare for all test data......."
	echo ""
	 # prepare for all test data
	 ./run_PrepareAllTestData.sh    ${AllTestDataFolder}  ${TestBitStreamFolder}  ${CodecFolder}  ${ScriptFolder}  ${ConfigureFolder}
	if [ ! $? -eq 0 ]
	then
		echo "failed to prepared  test space for all test data!"
		exit 1
	fi
	 
	echo ""
	echo ""
	echo "running all test cases for all bit streams......"
	echo ""
	./run_AllBitStreamAllCasesTest.sh   ${TestBitStreamFolder} ${AllTestDataFolder}  ${FinalResultDir} ${ConfigureFile}
	if [ ! $? -eq 0 ]
	then
		echo "failed: not all cases for all bit stream are passed !"
		echo ""
		echo "copying SHA1 files to folder SHA1Table ...."
		./run_CopySHA1Table.sh  ${FinalResultDir}  ${SH1TableFolder}
		exit 1
	else
		echo "all cases have been passed!"
		echo ""
		echo ""
		echo "copying SHA1 files to folder SHA1Table ...."
		./run_CopySHA1Table.sh  ${FinalResultDir}  ${SH1TableFolder}
		exit 0
	fi
	 
}
ConfigureFile=$1
runMain  ${ConfigureFile}

