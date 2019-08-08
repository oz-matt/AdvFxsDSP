# Generated by the VisualDSP++ IDDE

# Note:  Any changes made to this Makefile will be lost the next time the
# matching project file is loaded into the IDDE.  If you wish to preserve
# changes, rename this file and run it externally to the IDDE.

# The syntax of this Makefile is such that GNU Make v3.77 or higher is
# required.

# The current working directory should be the directory in which this
# Makefile resides.

# Supported targets:
#     AdvFxsDSP_Debug
#     AdvFxsDSP_Debug_clean

# Define this variable if you wish to run this Makefile on a host
# other than the host that created it and VisualDSP++ may be installed
# in a different directory.

ADI_DSP=D:\Analog Devices\VisualDSP 4.5


# $VDSP is a gmake-friendly version of ADI_DIR

empty:=
space:= $(empty) $(empty)
VDSP_INTERMEDIATE=$(subst \,/,$(ADI_DSP))
VDSP=$(subst $(space),\$(space),$(VDSP_INTERMEDIATE))

RM=cmd /C del /F /Q

#
# Begin "AdvFxsDSP_Debug" configuration
#

ifeq ($(MAKECMDGOALS),AdvFxsDSP_Debug)

AdvFxsDSP_Debug : ./Debug/AdvFxsDSP.dxe 

VDK.h VDK.cpp AdvFxsDSP.rbld :$(VDSP)/blackfin/vdk/VDK.cpp.tf $(VDSP)/blackfin/vdk/VDK.h.tf $(VDSP)/blackfin/vdk/VDKGen.exe ./AdvFxsDSP.vdk AdvFxsDSP.rbld 
	@echo ".\AdvFxsDSP.vdk"
	$(VDSP)/Blackfin\vdk\vdkgen.exe .\AdvFxsDSP.vdk -proc ADSP-BF537 -si-revision 0.3 -MM

./Debug/AdvFxsDSP_basiccrt.doj :./AdvFxsDSP_basiccrt.s $(VDSP)/Blackfin/include/defBF534.h $(VDSP)/Blackfin/include/defBF537.h $(VDSP)/Blackfin/include/def_LPBlackfin.h $(VDSP)/Blackfin/include/sys/_adi_platform.h $(VDSP)/Blackfin/include/sys/anomaly_macros_rtl.h $(VDSP)/Blackfin/include/sys/platform.h 
	@echo ".\AdvFxsDSP_basiccrt.s"
	$(VDSP)/easmblkfn.exe .\AdvFxsDSP_basiccrt.s -proc ADSP-BF537 -g -D_ADI_THREADS -si-revision 0.3 -o .\Debug\AdvFxsDSP_basiccrt.doj -MM

Debug/AdvFxsDSP_heaptab.doj :AdvFxsDSP_heaptab.c 
	@echo ".\AdvFxsDSP_heaptab.c"
	$(VDSP)/ccblkfn.exe -c .\AdvFxsDSP_heaptab.c -g -no-multiline -double-size-32 -decls-strong -warn-protos -threads -si-revision 0.3 -proc ADSP-BF537 -o .\Debug\AdvFxsDSP_heaptab.doj -MM

./Debug/ExceptionHandler-BF537.doj :./ExceptionHandler-BF537.asm ./VDK.h $(VDSP)/Blackfin/include/VDK_Public.h $(VDSP)/Blackfin/include/defBF534.h $(VDSP)/Blackfin/include/defBF537.h $(VDSP)/Blackfin/include/def_LPBlackfin.h 
	@echo ".\ExceptionHandler-BF537.asm"
	$(VDSP)/easmblkfn.exe .\ExceptionHandler-BF537.asm -proc ADSP-BF537 -g -D_ADI_THREADS -si-revision 0.3 -o .\Debug\ExceptionHandler-BF537.doj -MM

Debug/main.doj :main.c main.h VDK.h $(VDSP)/Blackfin/include/defBF537.h $(VDSP)/Blackfin/include/def_LPBlackfin.h $(VDSP)/Blackfin/include/defBF534.h $(VDSP)/Blackfin/include/VDK_Public.h $(VDSP)/Blackfin/include/limits.h $(VDSP)/Blackfin/include/yvals.h $(VDSP)/Blackfin/include/fract_math.h $(VDSP)/Blackfin/include/fract_typedef.h $(VDSP)/Blackfin/include/ccblkfn.h $(VDSP)/Blackfin/include/stdlib.h $(VDSP)/Blackfin/include/stdlib_bf.h $(VDSP)/Blackfin/include/fr2x16_math.h $(VDSP)/Blackfin/include/fr2x16_base.h $(VDSP)/Blackfin/include/fr2x16_typedef.h $(VDSP)/Blackfin/include/r2x16_typedef.h $(VDSP)/Blackfin/include/raw_typedef.h $(VDSP)/Blackfin/include/r2x16_base.h lib/uart.h $(VDSP)/Blackfin/include/cdefBF537.h $(VDSP)/Blackfin/include/cdefBF534.h $(VDSP)/Blackfin/include/cdef_LPBlackfin.h $(VDSP)/Blackfin/include/sys/exception.h 
	@echo ".\main.c"
	$(VDSP)/ccblkfn.exe -c .\main.c -g -no-multiline -double-size-32 -decls-strong -warn-protos -threads -si-revision 0.3 -proc ADSP-BF537 -o .\Debug\main.doj -MM

Debug/uart.doj :lib/uart.c lib/uart.h $(VDSP)/Blackfin/include/cdefBF537.h $(VDSP)/Blackfin/include/cdefBF534.h $(VDSP)/Blackfin/include/defBF534.h $(VDSP)/Blackfin/include/def_LPBlackfin.h $(VDSP)/Blackfin/include/cdef_LPBlackfin.h $(VDSP)/Blackfin/include/defBF537.h 
	@echo ".\lib\uart.c"
	$(VDSP)/ccblkfn.exe -c .\lib\uart.c -g -no-multiline -double-size-32 -decls-strong -warn-protos -threads -si-revision 0.3 -proc ADSP-BF537 -o .\Debug\uart.doj -MM

Debug/VDK.doj :VDK.cpp VDK.h $(VDSP)/Blackfin/include/defBF537.h $(VDSP)/Blackfin/include/def_LPBlackfin.h $(VDSP)/Blackfin/include/defBF534.h $(VDSP)/Blackfin/include/VDK_Public.h $(VDSP)/Blackfin/include/limits.h $(VDSP)/Blackfin/include/yvals.h $(VDSP)/Blackfin/include/fract_math.h $(VDSP)/Blackfin/include/fract_typedef.h $(VDSP)/Blackfin/include/ccblkfn.h $(VDSP)/Blackfin/include/stdlib.h $(VDSP)/Blackfin/include/stdlib_bf.h $(VDSP)/Blackfin/include/fr2x16_math.h $(VDSP)/Blackfin/include/fr2x16_base.h $(VDSP)/Blackfin/include/fr2x16_typedef.h $(VDSP)/Blackfin/include/r2x16_typedef.h $(VDSP)/Blackfin/include/raw_typedef.h $(VDSP)/Blackfin/include/r2x16_base.h $(VDSP)/Blackfin/include/assert.h $(VDSP)/Blackfin/include/cdefBF537.h $(VDSP)/Blackfin/include/cdefBF534.h $(VDSP)/Blackfin/include/cdef_LPBlackfin.h $(VDSP)/Blackfin/include/cplus/new $(VDSP)/Blackfin/include/cplus/exception $(VDSP)/Blackfin/include/cplus/xstddef $(VDSP)/Blackfin/include/cplus/cstddef $(VDSP)/Blackfin/include/stddef.h $(VDSP)/Blackfin/include/string.h $(VDSP)/Blackfin/include/heapinfo.h $(VDSP)/Blackfin/include/xalloc.h $(VDSP)/Blackfin/include/VDK_Internals.h $(VDSP)/Blackfin/include/sys/exception.h main.h 
	@echo ".\VDK.cpp"
	$(VDSP)/ccblkfn.exe -c .\VDK.cpp -c++ -g -ignore-std -no-multiline -double-size-32 -decls-strong -warn-protos -threads -si-revision 0.3 -proc ADSP-BF537 -o .\Debug\VDK.doj -MM

./Debug/AdvFxsDSP.dxe :AdvFxsDSP.ldf VDK.h $(VDSP)/Blackfin/lib/bf534_rev_0.3/TMK-BF532.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/vdk-CORE-BF532.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/vdk-i-BF532.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/libsmall532mty.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/libio532mty.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/libc532mty.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/libevent532mty.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/libx532mty.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/libcpp532mty.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/libcpprt532mty.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/libf64ieee532y.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/libdsp532y.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/libsftflt532y.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/libetsi532y.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/libssl537_vdky.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/libdrv537y.dlb $(VDSP)/Blackfin/lib/bf534_rev_0.3/idle532mty.doj $(VDSP)/Blackfin/lib/bf534_rev_0.3/librt_fileio532mty.dlb ./Debug/AdvFxsDSP_basiccrt.doj ./Debug/AdvFxsDSP_heaptab.doj ./Debug/ExceptionHandler-BF537.doj ./Debug/main.doj ./Debug/uart.doj ./Debug/VDK.doj $(VDSP)/Blackfin/lib/cplbtab533.doj $(VDSP)/Blackfin/lib/bf534_rev_0.3/crtn532y.doj 
	@echo "Linking..."
	$(VDSP)/ccblkfn.exe .\Debug\AdvFxsDSP_basiccrt.doj .\Debug\AdvFxsDSP_heaptab.doj .\Debug\ExceptionHandler-BF537.doj .\Debug\main.doj .\Debug\uart.doj .\Debug\VDK.doj -T .\AdvFxsDSP.ldf -L .\Debug -flags-link -MDUSER_CRT=ADI_QUOTEAdvFxsDSP_basiccrt.dojADI_QUOTE,-MDUSE_FILEIO,-MD__cplusplus -flags-link -od,.\Debug -o .\Debug\AdvFxsDSP.dxe -proc ADSP-BF537 -flags-link -MD_ADI_THREADS -si-revision 0.3 -flags-link -MM

endif

ifeq ($(MAKECMDGOALS),AdvFxsDSP_Debug_clean)

AdvFxsDSP_Debug_clean:
	-$(RM) ".\Debug\AdvFxsDSP_basiccrt.doj"
	-$(RM) "Debug\AdvFxsDSP_heaptab.doj"
	-$(RM) ".\Debug\ExceptionHandler-BF537.doj"
	-$(RM) "Debug\main.doj"
	-$(RM) "Debug\uart.doj"
	-$(RM) "Debug\VDK.doj"
	-$(RM) ".\Debug\AdvFxsDSP.dxe"
	-$(RM) ".\Debug\*.ipa"
	-$(RM) ".\Debug\*.opa"
	-$(RM) ".\Debug\*.ti"
	-$(RM) ".\*.rbld"

endif


