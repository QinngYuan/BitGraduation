#
# This file was created by Xilinx Vitis tool.
#


#
# tools
#

RM = rm -f
RMDIR = rm -rf



#
# variables
#

SDCARD_GEN = sdcard_gen
GENERATE_BIF = ::scw::generate_bif

XPFM_PATH = E:/zedboard_experiment/circle_led/circle_led_wrapper/export/circle_led_wrapper/circle_led_wrapper.xpfm
SYS_CONFIG = circle_led_wrapper
DOMAINS = standalone_ps7_cortexa9_0
BIF_PATH = E:/zedboard_experiment/circle_led/circle_system/Debug/system.bif

BITSTREAM_PATH = E:/zedboard_experiment/circle_led/circle/_ide/bitstream/circle_led_wrapper.bit
SD_FILES = --elf E:/zedboard_experiment/circle_led/circle/Debug/circle.elf,ps7_cortexa9_0

#
# primary build targets
#

package:
	-@echo Generating bif file for the system project
	generate_system_bif.bat 14828 ${XPFM_PATH} ${DOMAINS} ${BIF_PATH}
	${SDCARD_GEN} --xpfm ${XPFM_PATH} --sys_config ${SYS_CONFIG} --bif ${BIF_PATH} --bitstream ${BITSTREAM_PATH} ${SD_FILES}

clean:
	$(RMDIR) ./_sds
	${RMDIR} package
	${RM} system.bif

.PHONY: all package clean

all: package


