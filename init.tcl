set_param general.maxThreads 16
set partNum xc7a35tcpg236-1
set_part xc7a35tcpg236-1
set outputDir ./target

read_verilog -sv -quiet [glob -nocomplain src/*.sv]
read_verilog -quiet [glob -nocomplain src/*.v]
# read_verilog -quiet [glob -nocomplain src/ips/*.v]
read_vhdl -quiet [glob -nocomplain src/*.vhdl]
read_xdc -quiet [glob src/xdc/*.xdc]

set synth_checkpoint "$outputDir/post_synth.dcp"
set opt_checkpoint "$outputDir/post_opt.dcp"
set place_checkpoint "$outputDir/post_place.dcp"
set route_checkpoint "$outputDir/post_route.dcp"

set source_files [concat [glob -nocomplain src/*.sv] [glob -nocomplain src/*.v] [glob -nocomplain src/*.vhdl] [glob src/xdc/*.xdc] [glob src/ips/*/*.xci]]

proc files_changed {files checkpoints} {
    foreach file $files {
        set file_mtime [file mtime $file]
        if {![file exists $checkpoints]} {
            return 1
        }
        set checkpoint_mtime [file mtime $checkpoints]
        if {$file_mtime > $checkpoint_mtime} {
            return 1
        }
    }
    return 0
}
