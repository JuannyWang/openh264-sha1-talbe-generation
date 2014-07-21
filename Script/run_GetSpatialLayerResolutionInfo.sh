
#!/bin/bash

#*******************************************************************************
#  usage:  input:   run_GetSpatialLayerResolutionInfo.sh $PicW $PicH  $SpatialNum
#          output:  LayerWidth_0  LayerHeight_0  LayerWidth_1  LayerHeight_1  \
#                   LayerWidth_2  LayerHeight_2  LayerWidth_3  LayerHeight_3
#
#*******************************************************************************

runMain()
{
 if [ $#  -lt 3  ]
  then
    echo "usage: run_GetSpatialLayerResolutionInfo.s  \$PicW \$PicH  \$SpatialNum"
    exit  1
  elif [  $1 -le 0  -o $2 -le 0 ]
  then
    echo "usage: runGetLayerNum  \$PicW  \$PicH"
    exit  1 
  fi
  
  local PicW=$1
  local PicH=$2
  local SpatialNum=$3
  declare -a aLayerWidth
  declare -a aLayerHeiht
  
  let "LayerWidth_0 = ${PicW}/8"
  let "LayerWidth_1 = ${PicW}/4"
  let "LayerWidth_2 = ${PicW}/2"
  let "LayerWidth_3 = ${PicW}"
  
  let "LayerHeight_0 = ${PicH}/8"
  let "LayerHeight_1 = ${PicH}/4"  
  let "LayerHeight_2 = ${PicH}/2" 
  let "LayerHeight_3 = ${PicH}"
  
  aLayerWidth=( ${LayerWidth_0}  ${LayerWidth_1}  ${LayerWidth_2}  ${LayerWidth_3}  )
  aLayerHeiht=( ${LayerHeight_0} ${LayerHeight_1} ${LayerHeight_2} ${LayerHeight_3} )
  
  #not: output format need to use whit space to separate each parameter
  if [ ${SpatialNum} -eq 4  ]
  then
    echo  "${aLayerWidth[0]}  ${aLayerHeiht[0]}  ${aLayerWidth[1]}  ${aLayerHeiht[1]}  ${aLayerWidth[2]}  ${aLayerHeiht[2]} ${aLayerWidth[3]}  ${aLayerHeiht[3]} "
  elif [ ${SpatialNum} -eq 3  ]
  then
      echo  "${aLayerWidth[1]}  ${aLayerHeiht[1]} ${aLayerWidth[2]}  ${aLayerHeiht[2]} ${aLayerWidth[3]}  ${aLayerHeiht[3]}  0  0 "
  elif [ ${SpatialNum} -eq 2  ]
  then
      echo  "${aLayerWidth[2]}  ${aLayerHeiht[2]} ${aLayerWidth[3]}  ${aLayerHeiht[3]} 0  0 0  0"
  elif [ ${SpatialNum} -eq 1  ]
  then
      echo  "${aLayerWidth[3]}  ${aLayerHeiht[3]} 0 0  0 0 0 0 "
  fi
  return 0
}

PicW=$1
PicH=$2
SpatialNum=$3
runMain  ${PicW} ${PicH}  ${SpatialNum}


