

#!/bin/bash
 runMain()
 {
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
	./run_AllBitStreamAllCasesTest.sh   ${TestBitStreamFolder} ${AllTestDataFolder}  ${FinalResultDir}
	if [ ! $? -eq 0 ]
	then
		echo "failed: not all cases for all bit stream are passed !"
		exit 1
	else
		echo "all cases have been passed!"
		echo ""
		echo ""
		exit 0
	fi
	 
}
runMain
#copy SHA-1 table
./run_CopySHA1Table.sh  FinalResult/  SHA1Table/

