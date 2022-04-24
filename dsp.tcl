

set ProjectName  "dsp"
set PartDev      "xczu2cg-sfvc784-1-i" 

set TclPath      [file dirname [file normalize [info script]]]
set ProjectPath  $TclPath/build
put $ProjectPath

create_project $ProjectName $ProjectPath -part $PartDev




# adding dds compilers

create_ip -name dds_compiler -vendor xilinx.com -library ip -version 6.0 -module_name dds_compiler_0
set_property -dict [list CONFIG.PartsPresent {SIN_COS_LUT_only} CONFIG.Mode_of_Operation {Standard} CONFIG.Output_Selection {Sine_and_Cosine} CONFIG.S_PHASE_Has_TUSER {Not_Required} CONFIG.Has_ARESETn {true} CONFIG.Parameter_Entry {Hardware_Parameters} CONFIG.Frequency_Resolution {11111111} CONFIG.Noise_Shaping {None} CONFIG.Phase_Width {16} CONFIG.Output_Width {16} CONFIG.Has_Phase_Out {false} CONFIG.DATA_Has_TLAST {Not_Required} CONFIG.S_PHASE_Has_TUSER {Not_Required} CONFIG.M_DATA_Has_TUSER {Not_Required} CONFIG.M_PHASE_Has_TUSER {Not_Required} CONFIG.Latency {6} CONFIG.Output_Frequency1 {0} CONFIG.PINC1 {0}] [get_ips dds_compiler_0]
generate_target {instantiation_template} [get_files $ProjectPath/$ProjectName.srcs/sources_1/ip/dds_compiler_0/dds_compiler_0.xci]
update_compile_order -fileset sources_1
generate_target all [get_files  $ProjectPath/$ProjectName.srcs/sources_1/ip/dds_compiler_0/dds_compiler_0.xci]

create_ip -name dds_compiler -vendor xilinx.com -library ip -version 6.0 -module_name dds_compiler_1
set_property -dict [list CONFIG.PartsPresent {Phase_Generator_and_SIN_COS_LUT} CONFIG.Output_Width {16} CONFIG.Phase_Increment {Streaming} CONFIG.Phase_offset {None} CONFIG.Has_ARESETn {true} CONFIG.Parameter_Entry {Hardware_Parameters} CONFIG.Noise_Shaping {None} CONFIG.Phase_Width {16} CONFIG.DATA_Has_TLAST {Not_Required} CONFIG.S_PHASE_Has_TUSER {Not_Required} CONFIG.M_DATA_Has_TUSER {Not_Required} CONFIG.Latency {7} CONFIG.Output_Frequency1 {0} CONFIG.PINC1 {0}] [get_ips dds_compiler_1]
generate_target {instantiation_template} [get_files $ProjectPath/$ProjectName.srcs/sources_1/ip/dds_compiler_1/dds_compiler_1.xci]
update_compile_order -fileset sources_1
generate_target all [get_files  $ProjectPath/$ProjectName.srcs/sources_1/ip/dds_compiler_1/dds_compiler_1.xci]

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $TclPath/rtl_tb/dds_tb.v
add_files -fileset sim_1 -norecurse $TclPath/waveform/dds_tb_behav.wcfg

set_property top dds_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 -module_name fir_lowpass
set_property -dict [list CONFIG.Component_Name {fir_lowpass} CONFIG.CoefficientSource {COE_File} CONFIG.Coefficient_File $TclPath/files/LPF.coe CONFIG.Sample_Frequency {100} CONFIG.Clock_Frequency {100} CONFIG.Has_ARESETn {true} CONFIG.Coefficient_Sets {1} CONFIG.Clock_Frequency {100} CONFIG.Coefficient_Sign {Signed} CONFIG.Quantization {Integer_Coefficients} CONFIG.Coefficient_Width {16} CONFIG.Coefficient_Fractional_Bits {0} CONFIG.Coefficient_Structure {Inferred} CONFIG.Data_Width {16} CONFIG.Output_Width {32} CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} CONFIG.ColumnConfig {16}] [get_ips fir_lowpass]
generate_target {instantiation_template} [get_files $ProjectPath/$ProjectName.srcs/sources_1/ip/fir_lowpass/fir_lowpass.xci]
generate_target all [get_files  $ProjectPath/$ProjectName.srcs/sources_1/ip/fir_lowpass/fir_lowpass.xci]

create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 -module_name fir_bandpass
set_property -dict [list CONFIG.Component_Name {fir_bandpass} CONFIG.CoefficientSource {COE_File} CONFIG.Coefficient_File $TclPath/files/BPF.coe CONFIG.Sample_Frequency {100} CONFIG.Clock_Frequency {100} CONFIG.Has_ARESETn {true} CONFIG.Coefficient_Sets {1} CONFIG.Clock_Frequency {100} CONFIG.Coefficient_Sign {Signed} CONFIG.Quantization {Integer_Coefficients} CONFIG.Coefficient_Width {16} CONFIG.Coefficient_Fractional_Bits {0} CONFIG.Coefficient_Structure {Inferred} CONFIG.Data_Width {16} CONFIG.Output_Width {32} CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} CONFIG.ColumnConfig {16}] [get_ips fir_bandpass]
generate_target {instantiation_template} [get_files $ProjectPath/$ProjectName.srcs/sources_1/ip/fir_bandpass/fir_bandpass.xci]
generate_target all [get_files  $ProjectPath/$ProjectName.srcs/sources_1/ip/fir_bandpass/fir_bandpass.xci]

create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 -module_name fir_highpass
set_property -dict [list CONFIG.Component_Name {fir_highpass} CONFIG.CoefficientSource {COE_File} CONFIG.Coefficient_File $TclPath/files/HPF.coe CONFIG.Sample_Frequency {100} CONFIG.Clock_Frequency {100} CONFIG.Has_ARESETn {true} CONFIG.Coefficient_Sets {1} CONFIG.Clock_Frequency {100} CONFIG.Coefficient_Sign {Signed} CONFIG.Quantization {Integer_Coefficients} CONFIG.Coefficient_Width {16} CONFIG.Coefficient_Fractional_Bits {0} CONFIG.Coefficient_Structure {Inferred} CONFIG.Data_Width {16} CONFIG.Output_Width {32} CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} CONFIG.ColumnConfig {16}] [get_ips fir_highpass]
generate_target {instantiation_template} [get_files $ProjectPath/$ProjectName.srcs/sources_1/ip/fir_highpass/fir_highpass.xci]
generate_target all [get_files  $ProjectPath/$ProjectName.srcs/sources_1/ip/fir_highpass/fir_highpass.xci]

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $TclPath/rtl_tb/fir_tb.v
add_files -fileset sim_1 -norecurse $TclPath/waveform/fir_tb_behav.wcfg

create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 -module_name fir_decimation
set_property -dict [list CONFIG.Component_Name {fir_decimation} CONFIG.CoefficientSource {COE_File} CONFIG.Coefficient_File $TclPath/files/LPF_dec.coe CONFIG.Filter_Type {Decimation} CONFIG.Decimation_Rate {4} CONFIG.Sample_Frequency {100} CONFIG.Clock_Frequency {100} CONFIG.Has_ARESETn {true} CONFIG.Coefficient_Sets {1} CONFIG.Interpolation_Rate {1} CONFIG.Zero_Pack_Factor {1} CONFIG.Number_Channels {1} CONFIG.RateSpecification {Frequency_Specification} CONFIG.Coefficient_Sign {Signed} CONFIG.Quantization {Integer_Coefficients} CONFIG.Coefficient_Width {16} CONFIG.Coefficient_Fractional_Bits {0} CONFIG.Coefficient_Structure {Inferred} CONFIG.Data_Width {16} CONFIG.Output_Width {32} CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} CONFIG.ColumnConfig {4}] [get_ips fir_decimation]
generate_target {instantiation_template} [get_files $ProjectPath/$ProjectName.srcs/sources_1/ip/fir_decimation/fir_decimation.xci]
generate_target all [get_files  $ProjectPath/$ProjectName.srcs/sources_1/ip/fir_decimation/fir_decimation.xci]

create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 -module_name fir_interpolation
set_property -dict [list CONFIG.Component_Name {fir_interpolation} CONFIG.CoefficientSource {COE_File} CONFIG.Coefficient_File $TclPath/files/LPF_int.coe CONFIG.Filter_Type {Interpolation} CONFIG.Interpolation_Rate {4} CONFIG.Sample_Frequency {25} CONFIG.Clock_Frequency {100} CONFIG.Has_ARESETn {true} CONFIG.Coefficient_Sets {1} CONFIG.Decimation_Rate {1} CONFIG.Zero_Pack_Factor {1} CONFIG.Number_Channels {1} CONFIG.RateSpecification {Frequency_Specification} CONFIG.Clock_Frequency {100} CONFIG.Coefficient_Sign {Signed} CONFIG.Quantization {Integer_Coefficients} CONFIG.Coefficient_Width {16} CONFIG.Coefficient_Fractional_Bits {0} CONFIG.Coefficient_Structure {Inferred} CONFIG.Data_Width {16} CONFIG.Output_Width {30} CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} CONFIG.ColumnConfig {4}] [get_ips fir_interpolation]
generate_target {instantiation_template} [get_files $ProjectPath/$ProjectName.srcs/sources_1/ip/fir_interpolation/fir_interpolation.xci]
generate_target all [get_files  $ProjectPath/$ProjectName.srcs/sources_1/ip/fir_interpolation/fir_interpolation.xci]

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $TclPath/rtl_tb/fir_DecInt_tb.v
add_files -fileset sim_1 -norecurse $TclPath/waveform/fir_DecInt_tb_behav.wcfg

create_ip -name cic_compiler -vendor xilinx.com -library ip -version 4.0 -module_name cic_decimator
set_property -dict [list CONFIG.Component_Name {cic_decimator} CONFIG.Filter_Type {Decimation} CONFIG.Number_Of_Stages {4} CONFIG.Input_Sample_Frequency {100} CONFIG.Clock_Frequency {100} CONFIG.Input_Data_Width {16} CONFIG.HAS_ARESETN {true} CONFIG.SamplePeriod {1} CONFIG.Output_Data_Width {24}] [get_ips cic_decimator]
generate_target {instantiation_template} [get_files $ProjectPath/$ProjectName.srcs/sources_1/ip/cic_decimator/cic_decimator.xci]
generate_target all [get_files  $ProjectPath/$ProjectName.srcs/sources_1/ip/cic_decimator/cic_decimator.xci]

create_ip -name cic_compiler -vendor xilinx.com -library ip -version 4.0 -module_name cic_interpolator
set_property -dict [list CONFIG.Component_Name {cic_interpolator} CONFIG.Number_Of_Stages {6} CONFIG.Input_Sample_Frequency {25} CONFIG.Clock_Frequency {100} CONFIG.Input_Data_Width {16} CONFIG.HAS_ARESETN {true} CONFIG.Clock_Frequency {100} CONFIG.Output_Data_Width {26}] [get_ips cic_interpolator]
generate_target {instantiation_template} [get_files $ProjectPath/$ProjectName.srcs/sources_1/ip/cic_interpolator/cic_interpolator.xci]
generate_target all [get_files  $ProjectPath/$ProjectName.srcs/sources_1/ip/cic_interpolator/cic_interpolator.xci]

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $TclPath/rtl_tb/cic_DecInt_tb.v
add_files -fileset sim_1 -norecurse $TclPath/waveform/cic_DecInt_tb_behav.wcfg

create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 -module_name fir_hilbert
set_property -dict [list CONFIG.Component_Name {fir_hilbert} CONFIG.CoefficientSource {COE_File} CONFIG.Coefficient_File $TclPath/files/Hilbert.coe CONFIG.Sample_Frequency {100} CONFIG.Clock_Frequency {100} CONFIG.Has_ARESETn {true} CONFIG.Coefficient_Sets {1} CONFIG.Coefficient_Sign {Signed} CONFIG.Quantization {Integer_Coefficients} CONFIG.Coefficient_Width {16} CONFIG.Coefficient_Fractional_Bits {0} CONFIG.Coefficient_Structure {Inferred} CONFIG.Data_Width {16} CONFIG.Output_Width {33} CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} CONFIG.ColumnConfig {16}] [get_ips fir_hilbert]
generate_target {instantiation_template} [get_files $ProjectPath/$ProjectName.srcs/sources_1/ip/fir_hilbert/fir_hilbert.xci]
generate_target all [get_files  $ProjectPath/$ProjectName.srcs/sources_1/ip/fir_hilbert/fir_hilbert.xci]

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $TclPath/rtl_tb/hilbert_tb.v
add_files -fileset sim_1 -norecurse $TclPath/waveform/hilbert_tb_behav.wcfg


create_ip -name xfft -vendor xilinx.com -library ip -version 9.1 -module_name xfft_0
set_property -dict [list CONFIG.Component_Name {xfft_0} CONFIG.transform_length {2048} CONFIG.target_clock_frequency {100} CONFIG.implementation_options {pipelined_streaming_io} CONFIG.target_data_throughput {100} CONFIG.run_time_configurable_transform_length {true} CONFIG.input_width {16} CONFIG.phase_factor_width {24} CONFIG.aresetn {true} CONFIG.output_ordering {natural_order} CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {4}] [get_ips xfft_0]
generate_target {instantiation_template} [get_files $ProjectPath/$ProjectName.srcs/sources_1/ip/xfft_0/xfft_0.xci]
generate_target all [get_files  $ProjectPath/$ProjectName.srcs/sources_1/ip/xfft_0/xfft_0.xci]

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $TclPath/rtl_tb/fft_tb.v
add_files -fileset sim_1 -norecurse $TclPath/waveform/fft_tb_behav.wcfg
