# RWU_RV64I_AS
ip_jtag: Peripheral  
ip_uart: Peripheral  
RWU_RV64I: Single cycle version and pipelined version (without any hazard detection)  
... both without interrupt

## Single Cycle
cd RWU_RV64I  
cd RV_NoPipeline  
make doit  

## Pipeline  
cd RWU_RV64I  
cd RV_Pipeline  
make doit  
