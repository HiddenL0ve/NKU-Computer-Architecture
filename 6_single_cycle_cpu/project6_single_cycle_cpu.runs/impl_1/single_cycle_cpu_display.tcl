proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {Common 17-41} -limit 10000000

start_step init_design
set ACTIVE_STEP init_design
set rc [catch {
  create_msg_db init_design.pb
  set_param xicom.use_bs_reader 1
  create_project -in_memory -part xc7a200tfbg676-2
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir D:/vivado_project1/memory_async/project6_single_cycle_cpu/project6_single_cycle_cpu.cache/wt [current_project]
  set_property parent.project_path D:/vivado_project1/memory_async/project6_single_cycle_cpu/project6_single_cycle_cpu.xpr [current_project]
  set_property ip_output_repo D:/vivado_project1/memory_async/project6_single_cycle_cpu/project6_single_cycle_cpu.cache/ip [current_project]
  set_property ip_cache_permissions {read write} [current_project]
  add_files -quiet D:/vivado_project1/memory_async/project6_single_cycle_cpu/project6_single_cycle_cpu.runs/synth_1/single_cycle_cpu_display.dcp
  add_files -quiet D:/vivado_project1/memory_async/project6_single_cycle_cpu/lcd_module.dcp
  read_xdc D:/vivado_project1/memory_async/project6_single_cycle_cpu/project6_single_cycle_cpu.srcs/constrs_1/new/single_cycle_cpu.xdc
  link_design -top single_cycle_cpu_display -part xc7a200tfbg676-2
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
  unset ACTIVE_STEP 
}

start_step opt_design
set ACTIVE_STEP opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design 
  write_checkpoint -force single_cycle_cpu_display_opt.dcp
  catch { report_drc -file single_cycle_cpu_display_drc_opted.rpt }
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
  unset ACTIVE_STEP 
}

start_step place_design
set ACTIVE_STEP place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design 
  write_checkpoint -force single_cycle_cpu_display_placed.dcp
  catch { report_io -file single_cycle_cpu_display_io_placed.rpt }
  catch { report_utilization -file single_cycle_cpu_display_utilization_placed.rpt -pb single_cycle_cpu_display_utilization_placed.pb }
  catch { report_control_sets -verbose -file single_cycle_cpu_display_control_sets_placed.rpt }
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
  unset ACTIVE_STEP 
}

start_step route_design
set ACTIVE_STEP route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force single_cycle_cpu_display_routed.dcp
  catch { report_drc -file single_cycle_cpu_display_drc_routed.rpt -pb single_cycle_cpu_display_drc_routed.pb -rpx single_cycle_cpu_display_drc_routed.rpx }
  catch { report_methodology -file single_cycle_cpu_display_methodology_drc_routed.rpt -rpx single_cycle_cpu_display_methodology_drc_routed.rpx }
  catch { report_power -file single_cycle_cpu_display_power_routed.rpt -pb single_cycle_cpu_display_power_summary_routed.pb -rpx single_cycle_cpu_display_power_routed.rpx }
  catch { report_route_status -file single_cycle_cpu_display_route_status.rpt -pb single_cycle_cpu_display_route_status.pb }
  catch { report_clock_utilization -file single_cycle_cpu_display_clock_utilization_routed.rpt }
  catch { report_timing_summary -warn_on_violation -max_paths 10 -file single_cycle_cpu_display_timing_summary_routed.rpt -rpx single_cycle_cpu_display_timing_summary_routed.rpx }
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  write_checkpoint -force single_cycle_cpu_display_routed_error.dcp
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
  unset ACTIVE_STEP 
}

start_step write_bitstream
set ACTIVE_STEP write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  catch { write_mem_info -force single_cycle_cpu_display.mmi }
  write_bitstream -force single_cycle_cpu_display.bit 
  catch {write_debug_probes -no_partial_ltxfile -quiet -force debug_nets}
  catch {file copy -force debug_nets.ltx single_cycle_cpu_display.ltx}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
  unset ACTIVE_STEP 
}

