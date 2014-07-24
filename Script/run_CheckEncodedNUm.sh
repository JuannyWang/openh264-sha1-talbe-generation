#!/bin/bash


#usage: runGetFileSize  $FileName
runGetFileSize()
{
	if [ ! -e $1   ]
	then
		echo ""
		echo "file $1 does not exist!"
		echo "usage: runGetFileSize  $FileName!"
		echo ""
		return 1
	fi

	local FileName=$1
	local FileSize=""
	local TempInfo=""
	TempInfo=`ls -l $FileName`
	FileSize=`echo $TempInfo | awk '{print $5}'`
	echo $FileSize
	
}
#usage: runCheckActulLayerSize ${ActualSpatialNum}
runCheckActulLayerSize()
{

	if [ ! $# -eq 1 ]
	then
		echo "usage: runCheckActulLayerSize ${ActualSpatialNum}"
		exit 1
	fi
	
	local ActualSpatialNum=$1
	
	declare -a aInputLayerYUVSize
	declare -a aRecYUVLayerSize
	declare -a aRecYUVFile
	aInputLayerYUVSize=(${InputYUVSizeLayer0} ${InputYUVSizeLayer1} ${InputYUVSizeLayer2} ${InputYUVSizeLayer3} )
	aRecYUVFile=(${RecYUVFileLayer0} ${RecYUVFileLayer1} ${RecYUVFileLayer2} ${RecYUVFileLayer3})
	aRecYUVLayerSize=(0 0 0 0)
	
	for((i=0;i<${ActualSpatialNum};i++))
	do
		if [ -e ${aRecYUVFile[$i]} ]
		then
			aRecYUVLayerSize[$i]=`runGetFileSize  ${aRecYUVFile[$i]}`
			echo "${aRecYUVFile[$i]} size: ${aRecYUVLayerSize[$i]}"
		fi
	done
	
	let "LowestLayerIndex=4 - ${ActualSpatialNum} "
	let "SizeMatchFlag=0"
	
	echo "RecYUV   size: ${aRecYUVLayerSize[@]}"
	echo "InputYUV size: ${aInputLayerYUVSize[@]}"
	echo ""
	
	for((i=0;i<${ActualSpatialNum};i++))
	do
		let "RefSizeIndex=$i + ${LowestLayerIndex}"
		echo ""
		echo "Rec--Input:  ${aRecYUVLayerSize[$i]} ---- ${aInputLayerYUVSize[${RefSizeIndex}]}"
		if [ ! ${aRecYUVLayerSize[$i]} -eq ${aInputLayerYUVSize[${RefSizeIndex}]}  ]
		then
			let "SizeMatchFlag=1"
		fi
	done
	
	if [ ! ${SizeMatchFlag} -eq 0 ]
	then
		echo ""
		echo  -e "\033[31m RecYUV size does not match with input YUV size  \033[0m"
		echo ""
		return 1
	else
		echo ""
		echo  -e "\033[32m All layer size match with input YUV size \033[0m"
		echo ""
		return 0
	fi
}


#usage: runGetEncodedNum  ${EncoderLog}
runGetEncodedNum()
{
	if [ $#  -lt 1  ]
	then
		echo "usage: runGetEncodedNum  \${EncoderLog}"
		return 1
	fi
	local EncoderLog=$1
	local EncodedNum="0"
	while read line
	do
		if [[  ${line}  =~ ^Frames  ]]
		then
			EncodedNum=`echo $line | awk 'BEGIN {FS="[:\r]"} {print $2}'`
			break
		fi
	done <${EncoderLog}
	echo ${EncodedNum}
}

#Usage runCheckActualEncodedNum ${ConfiguredEncodedNum}
runCheckActualEncodedNum()
{

	if [ ! $# -eq 1  ]
	then
		echo "Usage: runCheckActualEncodedNum \${ConfiguredEncodedNum}"
		exit 1
	fi

	local ConfiguredEncodedNum=$1
	local ActualEncodedNum=""

	ActualEncodedNum=`runGetEncodedNum  ${EncoderLog}`
	echo ""
	echo "Config--Actual: ${ActualEncodedNum}----${ConfiguredEncodedNum}"
	echo ""
	if [  ${ActualEncodedNum} -eq ${ConfiguredEncodedNum} ]
	then
		echo ""
		echo  -e "\033[32m Actual encoded number matches with configured number   \033[0m"
		echo ""
		return 0
	else
		echo ""
		echo  -e "\033[31m  Actual encoded number does not match with configured number  \033[0m"
		echo ""
		return 1	
	fi
}



runMain()
{

	if [ ! $# -eq 11  ]
	then
		echo	""
		echo  -e "\033[31m Usage: run_CheckEncodedNUm.sh  \033[0m"
		echo  -e "\033[31m   \$EncoderNum  \$SpatailLayerNum \$InputYUVSizeLayer0 \$InputYUVSizeLayer1 \$InputYUVSizeLayer2 \$InputYUVSizeLayer3 \033[0m"
		echo  -e "\033[31m   \$RecYUVFileLayer0 \$RecYUVFileLayer1 \$RecYUVFileLayer2 \$RecYUVFileLayer3 \$EncoderLog \033[0m"
		echo ""
		exit 1
	fi

	declare -a aParameterSet
	aParameterSet=($@)
	
	EncoderNum=${aParameterSet[0]}
	SpatailLayerNum=${aParameterSet[1]}
	InputYUVSizeLayer0=${aParameterSet[2]}
	InputYUVSizeLayer1=${aParameterSet[3]}
	InputYUVSizeLayer2=${aParameterSet[4]}
	InputYUVSizeLayer3=${aParameterSet[5]}
	RecYUVFileLayer0=${aParameterSet[6]}
	RecYUVFileLayer1=${aParameterSet[7]}
	RecYUVFileLayer2=${aParameterSet[8]}
	RecYUVFileLayer3=${aParameterSet[9]}
	EncoderLog=${aParameterSet[10]}
	
	if [ ${SpatailLayerNum} -lt 1 -o ${SpatailLayerNum} -gt 4 ]
	then
		echo ""
		echo  -e "\033[31m spatial layer number is not correct, should be 1<=SpatialNum<=4  \033[0m"
		echo ""
		exit 1
	fi
	
		
	
	echo ""
	echo $@
	echo ${aParameterSet[@]}
	echo "RecYUVFileLayer0 ${RecYUVFileLayer0}"
	echo "RecYUVFileLayer1 ${RecYUVFileLayer1}"
	echo "RecYUVFileLayer2 ${RecYUVFileLayer2}"
	echo "RecYUVFileLayer3 ${RecYUVFileLayer3}"
	
	
	
	
	
	if [ ${EncoderNum} -eq -1 ]
	then
		runCheckActulLayerSize ${SpatailLayerNum}
		let "CheckFlag=$?"
	elif [ ${EncoderNum} -gt 0 ]
	then
		runCheckActualEncodedNum ${EncoderNum}
		let "CheckFlag=$?"
	fi
	
	if [  ${CheckFlag} -eq 0 ]
	then
		echo ""
		echo  -e "\033[32m Actual encoded number matches with configured number   \033[0m"
		echo ""	
		return 0
	else
		echo ""
		echo  -e "\033[32m Actual encoded number does not match with configured number   \033[0m"
		echo ""	
		return 1
	fi

}

runMain $@   


