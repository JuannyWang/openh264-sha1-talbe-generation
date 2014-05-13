
#!/bin/bash



#usage : main  \$SHAFolder_from  \$SHAFolder_to 

main()
{

	if [ ! $# -eq 2  ]
	then
		echo "usage : run_CopySHA1Table.sh \$SHAFolder_from  \$SHAFolder_to  "
		exit 1
	fi

	local SHAFolderSrc=$1
	local SHA1FolderDes=$2
	local CurrentDir=`pwd`
	local TempName=""
	
	
	if [ ! -d ${SHAFolderSrc}  ]
	then
		echo "path info not right!"
	else
		cd ${SHAFolderSrc}
		SHAFolderSrc=`pwd`
		cd ${CurrentDir}
	fi
	
	if [ ! -d ${SHA1FolderDes}  ]
	then
		echo "path info not right!"
	else
		cd ${SHA1FolderDes}
		SHA1FolderDes=`pwd`
		cd ${CurrentDir}
	fi
	
	#copy fille
	for file in  ${SHAFolderSrc}/*
	do
		if [[  ${file} =~ "_AllCase_SHA1_Table.csv" ]]
		then 
			cp -p $file   ${SHA1FolderDes}/
		fi
	done

	#rename file
	
	for file in  ${SHA1FolderDes}/*
	do
		TempName=`echo $file | awk 'BEGIN {FS=".264_"}  {print $1}'`
		TempName="${TempName}.264_AllCase_SHA1_Table.csv"
		echo $file
		echo ""
		echo ${TempName}
		echo ""
		mv  ${file}  ${TempName}
	done

	
		

}



SHAFolderSrc=$1
SHA1FolderDes=$2

main  ${SHAFolderSrc}  ${SHA1FolderDes}



