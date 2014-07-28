

#!/bin/bash
#usage: run_AutoBuild.sh  ${CodecDir}
# build and copy builded codec to current dir
runDeleteOldCodec()
{
	echo "deleting  not up to date's codec ......" 
	for file in ./wels*
	do
		./run_SafeDelete.sh  $file	
	done
	
	for file in ./*.cfg
	do
		./run_SafeDelete.sh  $file	
	done
	
		
	for file in ./lib*
	do
		./run_SafeDelete.sh  $file	
	done
}
runCodecDirInitial()
{
	EncoderMakeDir="welsruby/project/build/linux/enc"
	EncoderBinDir="welsruby/project/build/linux/bin"
	DecoderMakeDir="wels/project/build/linux/dec"
	DecoderBinDir="wels/project/build/linux/bin"
	VPMakeDir="welsvp/build/linux"
	VPBinDir="welsvp/bin"
	CfgDir="welsruby/project/bin"
}
runBuildEncoder()
{
	#******************************************
	#build encoder
	echo ""
	echo ""
	echo "building  encoder"
	cd ${SourceDir}/${EncoderMakeDir}
	make clean
	make
	cd ${CurrentDir}
	cp ${SourceDir}/${EncoderBinDir}/welsenc.exe  ./
	cd ${CurrentDir}
}
runBuildDecoder()
{
	#******************************************
	#build Decoder
	echo ""
	echo ""
	echo "building  dencoder"
	cd ${SourceDir}/${DecoderMakeDir}
	make clean
	make
	cd ${CurrentDir}
	cp ${SourceDir}/${DecoderBinDir}/welsdec.exe  ./
	cd ${CurrentDir}
}
runBuildVP()
{
	#******************************************
	#build VP
	echo ""
	echo ""
	echo "building  VP"
	cd ${SourceDir}/${VPMakeDir}
	make clean
	make
	cd ${CurrentDir}
	cp ${SourceDir}/${VPBinDir}/libwelsvp.so   ./
	cd ${CurrentDir}
}
runCopyCFGFile()
{
	#******************************************
	#copy  cfg file
	echo ""
	echo "copying cfg  files "
	cp ${SourceDir}/${CfgDir}/layer*.cfg  ./
	cp ${SourceDir}/${CfgDir}/wbxenc.cfg  ./
}
#usage: runMain  $SourceDir
runMain()
{
	if [ ! $# -eq 1  ]
	then
		echo "usage: run_AutoBuild.sh  \$WelsRuby Dir "
		exit 1
	fi
	CurrentDir=`pwd`
	SourceDir=$1
	
	if [ ! -d ${SourceDir}  ]
	then
		echo "source dir not exist! ${SourceDir}"
		exit 1
	fi
	
	cd ${SourceDir}
	SourceDir=`pwd`
	cd ${CurrentDir}
   
	runDeleteOldCodec
	
	runCodecDirInitial
	runBuildEncoder
    runBuildDecoder
	runBuildVP 
	runCopyCFGFile
	
}
SourceDir=$1
runMain  ${SourceDir}


