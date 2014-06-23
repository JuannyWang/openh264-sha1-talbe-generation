








#***************************************************************************************
#Encoder bit stream SHA1 table generation model:
#    This model is part of Cisco openh264 project for encoder binary comparison test.
#    For Cisco openh264 project,please refer to https://github.com/cisco/openh264. 
#   
#    1.Comparison is between h264enc's reconstructed YUV file and JM decoder's decoded YUV file.
#      if there is no difference between this tow YUV files, test case is marked as passed and
#      SHA1 string of bit stream will be generated. For more detail of bit stream validate logic,
#      please refer to script file ./Scripts/run_BitStreamValidateCheck.sh.
#
#    2.Test case configure file:
#      You can configure your test case by editing configure file ./CaseConfigure/case.cfg.
#      For more detail about how to generate test cases using case.cfg, please refer to script
#      file ./Scripts/run_GenerateCase.sh 
#    
#    3.Test bit stream file:
#      --for test bit streams in ./BitStreamForTest, are used for transforming into test YUV.
#      --those test bit streams are  copied from Cisco openh264 repository under folder ./res
#      --if you want to add special test bit stream for test, you can produce bit stream via JM
#        encoder and copy it to folder ./BitStreamForTest
#      --for how to transform bit stream into test YUV, please refer to script file 
#        ./Scripts/run_BitStreamToYUV.sh
#      --if you want to used YUV directly, you can switch to branch YUVAsInput
#   4.Test result
#      --final test result will be copied to folder ./FinalResult 
#      --for SHA1 table file, will be copied to folder ./SHA1Table.
#      --for temp data generated during test, is under folder ./AllTestData/XXX.264
#   5.Branch
#      --SingleLayer branch : 1 spacial layer test (local test, SHA1 table used in Cisoc openh264 test on travis)
#      --MultuLayer  branch:  3 spacial layer test (only local conformance test)
#      --YUVAsInput  branch :  YUV as test input. (only local conformance test)
#       currently, we support single spacial layer and multiple spacial layer.
#      
#
#  
about:




current branch:


other branch:

how to use:



structure:


how does it work:


how to update you test codec:
     --you can build your private openh264, and  copied  h264enc, h264dec, layer2.cfg, welsenc.cfg files 
	to folder ./Codec manually.
	--or 



how to generate case:

how to verify  the test case:


#***************************************************************************************


