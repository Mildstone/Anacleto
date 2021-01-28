global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

## INCLUDES ##
catch {
  source -notrace $top_srcdir/fpga/vivado_socdev_env.tcl
  source -notrace $top_srcdir/fpga/vivado_socdev_listutils.tcl
}


set prj_name $project_env(project_name)
set path_bit $project_env(dir_bit)
set path_sdk $project_env(dir_sdk)

# set name of run
set synth $v::pe(synth_name)
set impl  $v::pe(impl_name)


file mkdir $path_bit
file mkdir $path_sdk
open_run $synth
set  synth_dir [get_property DIRECTORY [get_runs $synth]]
set  impl_dir  [get_property DIRECTORY [get_runs $impl ]]
set  top_name  [get_property TOP [current_design]]

file  copy -force  $impl_dir/${top_name}.hwdef $path_sdk/$prj_name.hwdef
file  copy -force  $impl_dir/${top_name}.bit   $path_sdk/$prj_name.bit
file  copy -force  $impl_dir/${top_name}.bit   $path_bit/$prj_name.bit

puts "BITSTREAM POST POST POST POST POST POST POST POST POST POST POST POST "
puts "BITSTREAM POST POST POST POST POST POST POST POST POST POST POST POST "
puts "BITSTREAM POST POST POST POST POST POST POST POST POST POST POST POST "
