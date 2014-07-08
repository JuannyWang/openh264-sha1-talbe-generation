#!/bin/bash
#********************************************************************************
#  --for multiple layer test, generate input YUV for another spacial layer 
#
#  --usage:   run_PrepareMultiLayerInputYUV.sh ${OriginInputYUV} ${LayerNum}
#                                                       2<=${LayerNum}<=4
#  --eg:
#    input:  run_PrepareMultiLayerInputYUV.sh  ../../ABC_1080X720_30fps.yuv   3
#    output: there will be tow down sample YUV generated under current directory.
#            ----ABC_540X360_30fps.yuv
#            ----ABC_270X180_30fps.yuv
#
#  --note: YUV name must be named as XXX_PicWxPicH_FPSxxxx.yuv
#
#********************************************************************************
#usage: runGlobalVariableInitial ${OriginYUV}
runGlobalVariableInitial()
{
	if [ ! $# -eq 1   ]
	then
		echo "usage: runGlobalVariableInitial \${OriginYUV}"
		return 1
	fi

	OriginYUV=$1
	OriginYUVName=""
	OriginWidth=""
	OriginHeight=""
	FPS=""
	LayerWidth_0=""
	LayerWidth_1=""
	LayerWidth_2=""
	LayerWidth_3=""
		
	LayerHeight_0=""
	LayerHeight_1=""	
	LayerHeight_2=""
	LayerHeight_3=""
	
	OutputYUVLayer_0=""
	OutputYUVLayer_1=""
	OutputYUVLayer_2=""
	OutputYUVLayer_3=""
	
	
	DownSampleExe="DownConvertStatic"
	declare -a aYUVInfo
	declare -a aLayerWidth
	declare -a aLayerHeight
	declare -a aOutputLayerName
}
#usage: runRenameOutPutYUV  ${OriginYUVName} ${OutputWidth}  ${OutputHeight}
#eg:   
#      input:  runRenameOutPutYUV  ABC_1080X720_30fps.yuv   540  360
#      output: ABC_540X360_30fps.yuv 
runRenameOutPutYUV()
{
	if [ ! $# -eq 3  ]
	then 
		echo "usage: runRenameOutPutYUV  \${OriginYUVName} \${OutputWidth}  \${OutputHeight}"
		return 1
	fi

	local OriginYUVName=$1
	local OutputWidth=$2
	local OutputHeight=$3

	local OriginYUVWidth="0"
	local OriginYUVHeight="0"
	local OutputYUVName=""
	declare -a aPicInfo
	local Iterm=""
	local Index=""
	local Pattern_01="[xX]"
	local Pattern_02="^[1-9][0-9]"
	local Pattern_03="[0-9][0-9]$"
	local Pattern_04="fps$"
	local LastItermIndex=""

	aPicInfo=(`echo ${OriginYUVName} | awk 'BEGIN {FS="[_.]"} {for(i=1;i<=NF;i++) printf("%s  ",$i)}'`)
	let "LastItermIndex=${#aPicInfo[@]} - 1"

	#get PicW PicH info
	let "Index=0"
	for  Iterm in ${aPicInfo[@]}
	do
		if [[ $Iterm =~ $Pattern_01 ]] && [[ $Iterm =~ $Pattern_02 ]] && [[ $Iterm =~ $Pattern_03 ]]
		then			
			Iterm="${OutputWidth}X${OutputHeight}"
		fi

		if [  $Index -eq 0 ]
		then
			OutputYUVName=${Iterm}
		elif [  $Index -eq ${LastItermIndex}  ]
		then
			OutputYUVName="${OutputYUVName}.${Iterm}"
		else
			OutputYUVName="${OutputYUVName}_${Iterm}"
		fi

		let "Index++"
	done
	echo "${OutputYUVName}"
}
#usage: runSetLayerInfo
runSetLayerInfo()
{
	OriginYUVName=`echo ${OriginYUV} | awk 'BEGIN  {FS="/"} {print $NF}'`
	aYUVInfo=(`./run_ParseYUVInfo.sh  ${OriginYUVName}`)

    OriginWidth=${aYUVInfo[0]}
	OriginHeight=${aYUVInfo[1]}
	FPS=${aYUVInfo[2]}
	if [  ${OriginWidth} -eq 0  -o ${OriginHeight} -eq 0 ]
	then
		echo "origin YUV info is not right, PicW or PicH equal to 0 "
		exit 1
	fi 
	if [ $FPS -eq 0 ]
	then
		let "FPS=10"
	fi
	
	if [ $FPS -gt 50 ]
	then
		let "FPS=50"
	fi
	
	let "LayerWidth_0 = OriginWidth/8 "
	let "LayerWidth_1 = OriginWidth/4 "
	let "LayerWidth_2 = OriginWidth/2"
	let "LayerWidth_3 = OriginWidth "

	let "LayerHeight_0 = OriginHeight/8 "
	let "LayerHeight_1 = OriginHeight/4 "
	let "LayerHeight_2 = OriginHeight/2"
	let "LayerHeight_3 = OriginHeight"

	OutputYUVLayer_0=`runRenameOutPutYUV  ${OriginYUVName}   ${LayerWidth_0} ${LayerHeight_0}`
	OutputYUVLayer_1=`runRenameOutPutYUV  ${OriginYUVName}   ${LayerWidth_1} ${LayerHeight_1}`
	OutputYUVLayer_2=`runRenameOutPutYUV  ${OriginYUVName}   ${LayerWidth_2} ${LayerHeight_2}`
	OutputYUVLayer_3=`runRenameOutPutYUV  ${OriginYUVName}   ${LayerWidth_3} ${LayerHeight_3}`

}	


#usage: run_PrepareMultiLayerInputYUV.sh ${OriginYUV} ${NumberLayer}
runMain()
{
	if [ ! $# -eq 2 ]
	then
		echo "usage: run_PrepareMultiLayerInputYUV.sh \${OriginYUV} \${NumberLayer}"
		exit 1
	fi
	
	OriginYUV=$1
	NumberLayer=$2
	
	runGlobalVariableInitial ${OriginYUV}

	if [ ! -f ${OriginYUV}  ]
	then
		echo "origin yuv does not exist! please double check!--${OriginYUV}"
		exit 1
	fi
	
	if [  ${NumberLayer} -lt 2  -o  ${NumberLayer} -gt 4 ]
	then
		echo "layer number should be equal to 2 or 3 or 4 "
		exit 1
	fi
	
	runSetLayerInfo

    echo "OutputYUVLayer_0 ${OutputYUVLayer_0}"
	echo "OutputYUVLayer_1 ${OutputYUVLayer_1}"
	echo "OutputYUVLayer_2 ${OutputYUVLayer_2}"
	echo "OutputYUVLayer_3 ${OutputYUVLayer_3}"
	
   aLayerWidth=(  ${LayerWidth_3}  ${LayerWidth_2}  ${LayerWidth_1}  ${LayerWidth_0}  )
   aLayerHeight=( ${LayerHeight_3} ${LayerHeight_2} ${LayerHeight_1} ${LayerHeight_0} )
   aOutputLayerName=( ${OutputYUVLayer_3} ${OutputYUVLayer_2} ${OutputYUVLayer_1} ${OutputYUVLayer_0} )
	
	#down sample start from 1/2 PicW layer
	for ((i=1; i<${NumberLayer}; i++ ))
	do
		./${DownSampleExe}  ${OriginWidth} ${OriginHeight} ${OriginYUV}  ${aLayerWidth[$i]} ${aLayerHeight[i]}  ${aOutputLayerName[i]}
	done
	
	return 0
	
}
OriginYUV=$1
NumberLayer=$2
runMain   ${OriginYUV}  ${NumberLayer}


