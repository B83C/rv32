onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib clk_mcmm_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {clk_mcmm.udo}

run 1000ns

quit -force
