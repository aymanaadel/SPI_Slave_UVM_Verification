vlib work
vlog -f src_files.list -mfcu +cover -covercells
vsim -voptargs=+acc work.top -cover -classdebug -uvmcontrol=all
add wave /top/s_if/*
coverage save top.ucdb -onexit
run -all
quit -sim
vcover report top.ucdb -details -annotate -all -output coverage_report.txt