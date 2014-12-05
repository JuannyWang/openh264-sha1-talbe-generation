#!/bin/bash
#***************************************************************************************
# brief:
#      --delete previous test data, and prepare test space for all test sequences in AllTestData/XXX.yuv
#      --usage: run_PrepareAllTestData.sh  $AllTestDataFolder  \
#                                          $CodecFolder  $ScriptFolder \
#                                          $ConfigureFile
#
#
#date:  5/08/2014 Created
#***************************************************************************************
runRemovedPreviousTestData()
{
	
	if [ -d $AllTestDataFolder ]
	then
		${ScriptFolder}/run_SafeDelete.sh  $AllTestDataFolder
	fi
	if [ -d $SHA1TableFolder ]
	then
		${ScriptFolder}/run_SafeDelete.sh  $SHA1TableFolder
	fi
	if [ -d $FinalResultDir ]
	then
		${ScriptFolder}/run_SafeDelete.sh  $FinalResultDir
	fi
	
	if [ -d $SourceFolder ]
	then
		${ScriptFolder}/run_SafeDelete.sh  $SourceFolder
	fi
	if [ -d $YUVFolderForBitstream ]
	then
		${ScriptFolder}/run_SafeDelete.sh  $YUVFolderForBitstream
	fi	
	
	
}
runUpdateCodec()
{
	echo ""
	echo -e "\033[32m openh264 repository cloning... \033[0m"
	echo -e "\033[32m     ----repository is ${Openh264GitAddr} \033[0m"	
	echo -e "\033[32m     ----branch     is ${Branch} \033[0m"	
	echo ""
	
	./run_CheckoutCiscoOpenh264Codec.sh  ${Openh264GitAddr} ${SourceFolder}
	if [  ! $? -eq 0 ]
	then	
		echo ""
		echo -e "\033[31m Failed to clone latest openh264 repository! Please double check! \033[0m"
		echo ""
		exit 1
	fi
	
	cd ${SourceFolder}
	git checkout ${Branch}
	cd ${CurrentDir}
	
	echo ""
	echo -e "\033[32m openh264 codec building... \033[0m"
	echo ""
	./run_UpdateCodec.sh  ${SourceFolder}
	if [ ! $? -eq 0 ]
	then	
		echo ""
		echo -e "\033[31m Failed to update codec to latest version! Please double check! \033[0m"
		echo ""
		exit 1
	fi
	
	return 0
}
runPrepareSGEJobFile()
{
	if [ ! $# -eq 4 ]
	then
		echo "usage: runPrepareSGEJobFile  \$TestSequenceDir  \$TestYUVName \$TestYUVFullPath \$QueueIndex "
		return 1
	fi
	TestSequenceDir=$1
	TestYUVName=$2
	TestYUVFullPath=$3
	QueueIndex=$4
	
	if [ -d ${TestSequenceDir} ]
	then
		cd ${TestSequenceDir}
		TestSequenceDir=`pwd`
		cd ${CurrentDir}
	else
		echo -e "\033[31m Job folder does not exist! Please double check! \033[0m"
		exit 1
	fi
	
	SGEQueue="Openh264SGE_${QueueIndex}"
	SGEName="${TestYUVName}_SGE_Test"
	SGEModelFile="${ScriptFolder}/SGEModel.sge"
	SGEJobFile="${TestSequenceDir}/${TestYUVName}.sge"
	SGEJobScript="run_OneTestYUV.sh"
	
	echo ""
	echo -e "\033[32m creating SGE job file : ${SGEJobFile} ......\033[0m"
	echo ""
	
	echo "">${SGEJobFile}
	while read line
	do
		
		if [[ $line =~ ^"#$ -q"  ]]
		then
			echo "#$ -q ${SGEQueue}  # Select the queue">>${SGEJobFile}
		elif [[ $line =~ ^"#$ -N"  ]]
		then
			echo "#$ -N ${SGEName} # The name of job">>${SGEJobFile}
		elif [[ $line =~ ^"#$ -wd"  ]]
		then
			echo "#$ -wd ${TestSequenceDir}">>${SGEJobFile}
		else
			echo $line >>${SGEJobFile}
		fi
	
	done <${SGEModelFile}
	
	echo "${TestSequenceDir}/${SGEJobScript}  ${TestType}  ${TestYUVName} ${TestYUVFullPath}  ${FinalResultDir}  ${ConfigureFile}">>${SGEJobFile}
	
	return 0
}
#usage: get git repository address and branch
runGetGitRepository()
{
	while read line
	do
		if [[ "$line" =~ ^GitAddress  ]]
		then
			Openh264GitAddr=`echo $line | awk '{print $2}' `
		elif  [[ "$line" =~ ^GitBranch  ]]
		then
			Branch=`echo $line | awk '{print $2}' `
		fi
	done <${ConfigureFile}
}
#usage: runGetTestYUVList 
runGetTestBitStreamList()
{
	local TestSet0=""
	local TestSet1=""
	local TestSet2=""
	local TestSet3=""
	local TestSet4=""
	local TestSet5=""
	local TestSet6=""
	local TestSet7=""
	local TestSet8=""
	
	while read line
	do
		if [[ "$line" =~ ^TestSet0  ]]
		then
			TestSet0=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet1  ]]
		then
			TestSet1=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet2  ]]
		then
			TestSet2=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet3  ]]
		then
			TestSet3=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet4  ]]
		then
			TestSet4=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet5  ]]
		then
			TestSet5=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet6  ]]
		then
			TestSet6=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet7  ]]
		then
			TestSet7=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet8  ]]
		then
			TestSet8=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		fi
	done <${ConfigureFile}
	
	aTestBitstreamList=(${TestSet0} ${TestSet1}  ${TestSet2}  ${TestSet3}  ${TestSet4}  ${TestSet5}  ${TestSet6}  ${TestSet7}  ${TestSet8})
}
runTransformBitStreamToYUV()
{
	Decoder="${CodecFolder}/h264dec"
	for Bitstream in ${aTestBitstreamList[@]}
	do
		TestBitStream="${TestBitstreamDir}/${Bitstream}"
		if [ ! -e ${TestBitStream} ]
		then
			echo -e "\033[31m bit stream file does not exist, please double check! \033[0m"
			echo -e "\033[31m   ---- file name: ${TestBitStream} \033[0m"
			exit 1		
		fi
		${ScriptFolder}/run_BitStreamToYUV.sh  ${TestBitStream}  ${YUVFolderForBitstream} ${Decoder}
		if [ ! $? -eq 0 ]
		then
			echo -e "\033[31m failed to transform bit stream into test YUV by h264dec \033[0m"
			echo -e "\033[31m   ---- file name: ${TestBitStream} \033[0m"
			exit 1			
		fi
	done
}
runPrepareTestSpace()
{
	
	#now prepare for test space for all test sequences
	#for SGE test, use 3 test queues so that can support more parallel jobs
	let "YUVIndex=0"
	let "QueueIndex=0"
	for TestYUV in ${YUVFolderForBitstream}/*.yuv
	do
		YUVName=`echo ${TestYUV} | awk 'BEGIN {FS="/"} {print $NF}'`
		
		SubFolder="${AllTestDataFolder}/${YUVName}"
	
		echo ""
		echo "Test sequence name is ${YUVName}"
		echo "sub folder is  ${SubFolder}"
		echo ""
		if [  -d  ${SubFolder}  ]
		then
			continue
		fi
		mkdir -p ${SubFolder}
		cp  ${CodecFolder}/*    ${SubFolder}
		cp  ${ScriptFolder}/*   ${SubFolder}
		cp  ${ConfigureFile}    ${SubFolder}
		
		let "YUVIndex++"
		let "QueueIndex = ${YUVIndex}%3"
		
		if [ ${TestType} = "SGETest"  ]
		then
			runPrepareSGEJobFile  ${SubFolder}  ${YUVName} ${TestYUV}  ${QueueIndex}
		fi 		
	done
	
	return 0
}
runCheck()
{
	#check test type
	if [ ${TestType} = "SGETest" ]
	then
		return 0
	elif [ ${TestType} = "LocalTest" ]
	then
		return 0
	else
		 echo -e "\033[31musage: TestTest should be SGETest or LocalTest, please choose one! \033[0m"
		 exit 1
	fi
	
	#check configure file
	if [  ! -f ${ConfigureFile} ]
	then
		echo "Configure file not exist!, please double check in "
		echo " usage may looks like:   ./run_Main.sh  ../CaseConfigure/case.cfg "
		exit 1
	fi
	return 0
}
runSetAsFullPath()
{
	cd ${AllTestDataFolder}
	AllTestDataFolder=`pwd`
	cd  ${CurrentDir}
	cd  ${CurrentDir}
	
	cd ${SourceFolder}
	SourceFolder=`pwd`
	cd  ${CurrentDir}
	
	cd ${FinalResultDir}
	FinalResultDir=`pwd`
	cd  ${CurrentDir}
	
	cd ${YUVFolderForBitstream}
	YUVFolderForBitstream=`pwd`
	cd ${CurrentDir}
	
	cd ${CodecFolder}
	CodecFolder=`pwd`
	cd ${CurrentDir}
	
	cd ${ScriptFolder}
	ScriptFolder=`pwd`
	cd ${CurrentDir}
}
#usage: runPrepareALlFolder   $TestType $AllTestDataFolder  $TestBitStreamFolder   $CodecFolder  $ScriptFolder  $ConfigureFile/$SH1TableFolder
runMain()
{
	#parameter check!
	if [ ! $# -eq 6  ]
	then
		echo ""
		echo -e "\033[31musage: run_PrepareAllTestFolder.sh   \$TestType  \$SourceFolder  \$AllTestDataFolder  \$CodecFolder  \$ScriptFolder \$ConfigureFile \033[0m"
		echo ""
		return 1
	fi
	
	TestType=$1
	SourceFolder=$2
	AllTestDataFolder=$3
	CodecFolder=$4
	ScriptFolder=$5
	ConfigureFile=$6
	
	CurrentDir=`pwd`
	SHA1TableFolder="SHA1Table"
	FinalResultDir="FinalResult"
	YUVFolderForBitstream="YUVForBitStream"
	TestBitstreamDir="${SourceFolder}/res"
	
	Openh264GitAddr=""
	Branch=""
	
	
	declare -a aTestBitstreamList
	#folder for eache test sequence
	SubFolder=""
	SGEJobFile=""
	
	#check input parameters
	runCheck
	runRemovedPreviousTestData
	
	mkdir ${AllTestDataFolder}
	mkdir ${SHA1TableFolder}
	mkdir ${FinalResultDir}
	mkdir ${SourceFolder}
	mkdir ${YUVFolderForBitstream}
	
    runSetAsFullPath
	
	#parse git repository info 
	runGetGitRepository
	#update codec
	runUpdateCodec
	
	echo "Preparing test space for all test sequences!"
	runGetTestBitStreamList
	runTransformBitStreamToYUV
	runPrepareTestSpace
}
TestType=$1
SourceFolder=$2
AllTestDataFolder=$3
CodecFolder=$4
ScriptFolder=$5
ConfigureFile=$6
runMain  $TestType  $SourceFolder $AllTestDataFolder    $CodecFolder  $ScriptFolder  $ConfigureFile

