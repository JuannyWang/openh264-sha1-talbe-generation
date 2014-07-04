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
#      --copy SHA1 table from    ./FinalResult  to  ./SHA1Table
#      --usage: run_CopySHA1Table  run_CopySHA1Table.sh \$SHAFolder_from  \$SHAFolder_to
#               eg:  run_CopySHA1Table.sh   ./FinalResult   ./SHA1Table
#
#
#date:  10/06/2014 Created
#***************************************************************************************
#usage : main  \$SHAFolder_from  \$SHAFolder_to
main()
{
  if [ ! $# -eq 2  ]
  then
    echo "usage : run_CopySHA1Table.sh  \$SHAFolder_from  \$SHAFolder_to  "
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

