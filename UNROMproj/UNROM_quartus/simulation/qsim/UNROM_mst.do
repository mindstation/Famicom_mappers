onerror {quit -f}
vlib work
vlog -work work UNROM_mst.vo
vlog -work work UNROM_mst.vt
vsim -novopt -c -t 1ps -L cycloneive_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.UNROM_mst_vlg_vec_tst
vcd file -direction UNROM_mst.msim.vcd
vcd add -internal UNROM_mst_vlg_vec_tst/*
vcd add -internal UNROM_mst_vlg_vec_tst/i1/*
add wave /*
run -all
