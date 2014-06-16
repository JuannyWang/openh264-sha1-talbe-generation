
#!/bin/bash
#usage: runPrepareALlFolder   $AllTestDataFolder  $TestBitStreamFolder   $CodecFolder  $ScriptFolder  $ConfigureFolder/$SH1TableFolder
runPrepareALlFolder()
{
	#parameter check! 
	if [ ! $# -eq 5  ]
	then
		echo "usage: runPrepareALlFolder   \$AllTestDataFolder  \$TestBitStreamFolder  \$CodecFolder  \$ScriptFolder \$ConfigureFolder/\$SH1TableFolder"
		return 1
	fi
	 
	local AllTestDataFolder=$1
	local TestBitStreamFolder=$2
	local CodecFolder=$3
    local ScriptFolder=$4
	local ConfigureFolder=$5
	local SubFolder=""
	local IssueFolder="issue"
	local TempDataFolder="TempData"
	local ResultFolder="result"
	
	local SHA1TableFolder="SHA1Table"	
	local FinalResultDir="FinalResult"
	
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
		
	
	for Bitsream in ${TestBitStreamFolder}/*.264
	do
	    StreamName=`echo ${Bitsream} | awk 'BEGIN {FS="/"}  {print $NF}   ' `
		SubFolder="${AllTestDataFolder}/${StreamName}"
		echo "BitSream is ${Bitsream}"
		echo "sub folder is  ${SubFolder}"
		echo ""
		mkdir -p ${SubFolder}
		mkdir -p ${SubFolder}/${IssueFolder}
		mkdir -p ${SubFolder}/${TempDataFolder}
		mkdir -p ${SubFolder}/${ResultFolder}
		cp  ${CodecFolder}/*   ${SubFolder}
		cp  ${ScriptFolder}/*   ${SubFolder}
		cp  ${ConfigureFolder}/*   ${SubFolder}
		
	done
	
}
 
#parameter check! 
if [ ! $# -eq 5  ]
then
	echo "usage: run_PrepareAllTestFolder.sh   \$AllTestDataFolder  \$TestBitStreamFolder  \$CodecFolder  \$ScriptFolder \$ConfigureFolder/\$SH1TableFolder"
	exit 1
fi
 
AllTestDataFolder=$1
TestBitStreamFolder=$2
CodecFolder=$3
ScriptFolder=$4
ConfigureFolder=$5
echo "preparing All test data folders...."
echo ""
echo ""
runPrepareALlFolder   $AllTestDataFolder  $TestBitStreamFolder   $CodecFolder  $ScriptFolder  $ConfigureFolder
echo ""
echo ""


