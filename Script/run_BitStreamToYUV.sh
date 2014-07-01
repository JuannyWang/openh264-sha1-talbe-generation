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
#      --decode bit stream and  transform into test YUV
#      --usage: run_BitStreamToYUV.sh   ${BitStreamName}
#      
#
#date:  10/06/2014 Created
#***************************************************************************************
#usage:  run_ParseDecoderInfo   $Decoder_LogFile  
#eg:     input:    run_ParseDecoderInfo   test.264.log
#        output    1024  720  
run_ParseDecoderInfo()
{
	if [ ! $# -eq 1 ]
	then
		echo "usage:  run_ParseDecoderInfo  \$Decoder_LogFile"
		return 1
	fi
	local LogFile=$1
	local Width=""
	local Height=""
	while read line
	do
		if [[  $line =~  "iWidth"   ]]
		then
			Width=`echo $line | awk 'BEGIN  {FS="[:\n]"} {print $2}'`
		fi
		if [[  $line =~  "height"   ]]
		then
		   Height=`echo $line | awk 'BEGIN  {FS="[:\n]"} {print $2}'`
		fi
	done < ${LogFile}
	echo "${Width}  ${Height}"
}
#usage: run_BitStream2YUV  $BitstreamName  $OutputYUVName $LogFile 
run_BitStream2YUV()
{
 	if [ ! $# -eq 3 ]
	then
		echo "usage: run_BitStream2YUV  \$BitstreamName \$OutputYUVName \$LogFile   "
		return 1
	fi
	local BitStreamName=$1
	local OutputYUVNAMe=$2
	local LogFile=$3
	
	if [ ! -f ${BitStreamName}  ]
	then
		echo "bit stream file is not exist!"
		echo "detected by run_BitStreamToYUV.sh"
		return 1
	fi
	#decode bitstream
	./h264dec  ${BitStreamName}  ${OutputYUVNAMe} 2> ${LogFile}
	
	return 0
}
#usage: run_RegularizeYUVName $BitstreamName $OutputYUVName $LogFile 
run_RegularizeYUVName()
{
 	if [ ! $# -eq 3 ]
	then
		echo "usage: run_RegularizeYUVName  \$BitstreamName  \$OutputYUVName \$LogFile "
		return 1
	fi
	local BitStreamName=$1
	local OrignName=$2
	local LogFile=$3
	local RegularizedYUVName=""
	 
	declare -a aDecodedYUVInfo
	
	aDecodedYUVInfo=(`run_ParseDecoderInfo  ${LogFile}`)
	
	BitStreamName=`echo ${BitStreamName} | awk 'BEGIN {FS="/"} {print $NF}'`
	RegularizedYUVName="${BitStreamName}_${aDecodedYUVInfo[0]}x${aDecodedYUVInfo[1]}.yuv"
    mv -f 	${OrignName}   ${RegularizedYUVName}
	echo ""
	echo "file :  ${OrignName}   has been renamed as :${RegularizedYUVName}"	
	echo ""
	
	return 0
}
#usage: runMain  ${BitStreamName}
runMain()
{
	if [ ! $# -eq 1 ]
	then
		echo "usage: runMain  ${BitStreamName} "
		return 1
	fi
	
	local BitStreameFile=$1
	local BitSteamName=`echo ${BitStreameFile} | awk 'BEGIN {FS="/"} {print $NF}'`
	local DecodeLogFile="${BitSteamName}_h264dec.log"
	local DecodedYUVName="${BitSteamName}_dec.yuv"
	local RegularizedName=""
	
	#**********************
	#decoded test bitstream
	run_BitStream2YUV  ${BitStreameFile}  ${DecodedYUVName}  ${DecodeLogFile}
	if [  ! $?  -eq 0  ]
	then
	    echo "bit stream decoded  failed!"
		return 1
	fi
	
	
	#*********************
	#regularized  YUV name
	run_RegularizeYUVName  ${BitStreameFile}  ${DecodedYUVName}  ${DecodeLogFile}
   
	return 0
}
BitStreamFile=$1
runMain  ${BitStreamFile}

