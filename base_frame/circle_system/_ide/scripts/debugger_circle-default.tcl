# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: E:\zedboard_experiment\circle_led\circle_system\_ide\scripts\debugger_circle-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source E:\zedboard_experiment\circle_led\circle_system\_ide\scripts\debugger_circle-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Platform Cable USB II 000018c9921901" && level==0 && jtag_device_ctx=="jsn-DLC10-000018c9921901-23727093-0"}
fpga -file E:/zedboard_experiment/circle_led/circle/_ide/bitstream/circle_led_wrapper.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw E:/zedboard_experiment/circle_led/circle_led_wrapper/export/circle_led_wrapper/hw/circle_led_wrapper.xsa -mem-ranges [list {0x40000000 0xbfffffff}] -regs
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source E:/zedboard_experiment/circle_led/circle/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow E:/zedboard_experiment/circle_led/circle/Debug/circle.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "*A9*#0"}
con
