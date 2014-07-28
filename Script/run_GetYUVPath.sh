#!/bin/bash
#get YUV file's full path 
#usage: runGetYUVPath  ${YUVName}  ${FindScope}
runGetYUVPath()
{
	if [ ! $# -eq 2 ]
	then
		echo "runGetYUVPath  \${YUVName}  \${FindScope} "
		return 1
	fi
	local YUVName=$1
	local FindScope=$2
	local YUVFullPath="" 
	local Log="find.result"
	local CurrentDir=`pwd`
	if [ ! -d ${FindScope} ]
	then
		echo "find scope is not right..."
		exit 1
	else
	cd ${FindScope}
	FindScope=`pwd`
	cd ${CurrentDir}
	fi
	find   ${FindScope}  -name  ${YUVName}>${Log}	
	let "Flag=1"
	while read line 
	do
		YUVFullPath=${line}
		if [ -f ${YUVFullPath} ]
		then
			let "Flag=0"
			break
		fi
	done <${Log}
	echo ${YUVFullPath}
	if [ ${Flag} -eq 1  ]
	then
		echo ""
		echo  -e "\033[31m can not find file ${YUVName} under ${FindScope} \033[0m"
		echo ""
	fi
	return ${Flag}
	
}
YUVName=$1
FindScope=$2
runGetYUVPath  ${YUVName}  ${FindScope}


