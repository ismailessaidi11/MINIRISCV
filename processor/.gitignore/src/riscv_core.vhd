																									 -------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-- Polytechnique Montréal
-------------------------------------------------------------------------------
-- File     riscv_core.vhd
-- Author   Ismail Essaidi & Maxime Z
-- Date     2022-08-27
-------------------------------------------------------------------------------
-- Description 	WB
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all;

entity riscv_core is
  port ( 
  i_rstn		: in  std_logic;
  i_clk 		: in  std_logic;
 
  i_imem_read	: in  std_logic_vector(XLEN-1 downto 0);
  i_dmem_read 	: in  std_logic_vector(XLEN-1 downto 0);
	
  o_imem_en 	: out std_logic; 
  o_imem_addr 	: out std_logic_vector(XLEN-1 downto 0);
  o_dmem_en 	: out std_logic;
  o_dmem_we		: out std_logic;
  o_dmem_addr 	: out std_logic_vector(XLEN-1 downto 0);
  o_dmem_write  : out std_logic_vector(XLEN-1 downto 0);  
  -- DFT
  i_scan_en 	: in  std_logic;  
  i_test_mode 	: in  std_logic;	  
  i_tdi 		: in  std_logic;
  o_tdo			: out std_logic;
  
  --Test Bench
  tb_fetch_pc 	: out std_logic_vector(XLEN-1 downto 0); 
 
  tb_decode_rs1_data, tb_decode_rs2_data, tb_decode_pc: out std_logic_vector(XLEN-1 downto 0);
  tb_decode_branch,tb_decode_jump, tb_decode_rw, tb_decode_we : out std_logic;
  tb_decode_alu_op : out std_logic_vector(ALUOP_WIDTH-1 downto 0);
  tb_execute_pc_target : out std_logic_vector(XLEN-1 downto 0)
  ); 
  
end entity riscv_core;

architecture beh of riscv_core is 

component fetch is
  port (
  i_target	    : in  std_logic_vector(XLEN-1 downto 0);
  i_imem_read   : in  std_logic_vector(XLEN-1 downto 0);
  i_transfert   : in  std_logic;
  i_stall		: in  std_logic;
  i_flush		: in  std_logic;
  i_rstn		: in  std_logic;
  i_clk    	    : in  std_logic;  
  
  o_imem_en 	: out std_logic;
  o_pc		    : out std_logic_vector(XLEN-1 downto 0);	
  o_instruction : out std_logic_vector(XLEN-1 downto 0)
  );
end component fetch;

component decode is
  port (
  i_instr		: in  std_logic_vector(XLEN-1 downto 0);
  i_rd_data 	: in  std_logic_vector(XLEN-1 downto 0);
  i_rd_addr 	: in  std_logic_vector(REG_WIDTH -1 downto 0);  
  --i_rw 			: in  std_logic;
  --i_we			: in  std_logic;
  i_wb 			: in  std_logic;
  i_pc			: in  std_logic_vector(XLEN-1 downto 0);
  i_flush		: in  std_logic;
  i_rstn		: in  std_logic;
  i_clk 		: in  std_logic;
  
  o_rs1_data 	: out std_logic_vector(XLEN-1 downto 0);
  o_rs2_data 	: out std_logic_vector(XLEN-1 downto 0); 
  o_branch		: out std_logic;
  o_jump		: out std_logic;
  o_rw 			: out std_logic;  -- read word from d-mem
  o_we			: out std_logic;	-- write enable in d-mem
  o_wb			: out std_logic;  -- write back in rf
  o_imm			: out std_logic_vector(XLEN-1 downto 0);  
  o_src_imm		: out std_logic;
  o_rd_addr 	: out std_logic_vector(REG_WIDTH-1 downto 0);
  o_pc			: out std_logic_vector(XLEN-1 downto 0);
  -- for ALU in EX
  o_arith		: out std_logic;
  o_sign		: out std_logic;
  o_shamt		: out std_logic_vector(4 downto 0);	
  o_alu_op		: out std_logic_vector(ALUOP_WIDTH-1 downto 0)
  ); 
  
end component decode;	 


component execute is
  port ( 						
  i_jump 			: in  std_logic;
  i_branch 			: in  std_logic; 
  i_src_imm			: in  std_logic;
  i_rw 				: in  std_logic; -- read word from d-mem
  i_we				: in  std_logic; -- write enable in d-mem	
  i_wb 				: in  std_logic; -- write back in rf
  i_rs1_data 		: in  std_logic_vector(XLEN-1 downto 0);
  i_rs2_data 		: in  std_logic_vector(XLEN-1 downto 0);
  i_imm				: in  std_logic_vector(XLEN-1 downto 0);
  i_pc				: in  std_logic_vector(XLEN-1  downto 0);
  i_rd_addr 		: in  std_logic_vector(REG_WIDTH-1 downto 0);
  i_stall			: in  std_logic;
  i_rstn			: in  std_logic;
  i_clk 			: in  std_logic;
  -- ALU inputs	from ID
  i_shamt			: in  std_logic_vector(SHAMT_WIDTH-1 downto 0);
  i_alu_op			: in  std_logic_vector(ALUOP_WIDTH-1 downto 0);
  i_arith			: in  std_logic;
  i_sign			: in  std_logic;
	
  o_pc_transfert	: out std_logic;
  o_alu_result 		: out std_logic_vector(XLEN-1 downto 0);
  o_store_data 		: out std_logic_vector(XLEN-1 downto 0); 
  o_pc_target 		: out std_logic_vector(XLEN-1 downto 0);
  o_rw 				: out std_logic;  -- read word from d-mem
  o_we				: out std_logic;	-- write enable in d-mem
  o_wb				: out std_logic;  -- write back in rf
  o_rd_addr 		: out std_logic_vector(REG_WIDTH-1 downto 0)
  ); 
  
end component execute;

component memory_access is

  port (
  i_store_data  		: in  std_logic_vector(XLEN-1 downto 0);
  i_alu_result  		: in  std_logic_vector(XLEN-1 downto 0);	 
  i_rd_addr  			: in  std_logic_vector(REG_WIDTH -1 downto 0);  
  i_rw 		 			: in  std_logic;		
  i_wb 		 			: in  std_logic;
  i_we					: in  std_logic;
  i_rstn 	 			: in  std_logic;
  i_clk 	 			: in  std_logic; 
  
  o_store_data 			: out std_logic_vector(XLEN-1 downto 0);		
  o_alu_result 			: out std_logic_vector(XLEN-1 downto 0);
  o_wb 		 			: out std_logic;
  o_we					: out std_logic;
  o_rw 					: out std_logic;		
  o_rd_addr  			: out std_logic_vector(REG_WIDTH -1 downto 0)  
  );
end component memory_access;


component write_back is

  port (
  i_load_data	: in  std_logic_vector(XLEN-1 downto 0);
  i_alu_result 	: in  std_logic_vector(XLEN-1 downto 0);
  i_rd_addr 	: in  std_logic_vector(REG_WIDTH-1 downto 0);  
  i_rw 			: in  std_logic;	  
  i_wb 			: in  std_logic;
  i_rstn		: in  std_logic;
  i_clk 		: in  std_logic;
	
  o_wb 			: out std_logic;
  o_rd_addr 	: out std_logic_vector(REG_WIDTH-1 downto 0); 
  o_rd_data 	: out std_logic_vector(XLEN-1 downto 0)
  ); 
  
end component write_back; 

  
  -- fetch
  signal fetch_instruction, fetch_pc 	: std_logic_vector(XLEN-1 downto 0); 
  -- decode
  signal decode_rs1_data, decode_rs2_data, decode_pc, decode_imm	 : std_logic_vector(XLEN-1 downto 0);
  signal decode_branch, decode_jump, decode_rw, decode_we, decode_wb, decode_src_imm, decode_arith,decode_sign: std_logic;   
  signal decode_rd_addr : std_logic_vector(REG_WIDTH-1 downto 0); 
  signal decode_shamt : std_logic_vector(4 downto 0);
  signal decode_alu_op : std_logic_vector(ALUOP_WIDTH-1 downto 0);
  -- execute
  signal execute_alu_result, execute_store_data, execute_pc_target : std_logic_vector(XLEN-1 downto 0);
  signal execute_rd_addr : std_logic_vector(REG_WIDTH-1 downto 0);
  signal execute_pc_transfert, execute_rw, execute_we, execute_wb : std_logic;
  -- memory
  signal memory_store_data, memory_alu_result : std_logic_vector(XLEN-1 downto 0); 
  signal memory_wb, memory_we, memory_rw : std_logic;
  signal memory_rd_addr : std_logic_vector(REG_WIDTH -1 downto 0);
  -- write back
  signal write_back_rd_data : std_logic_vector(XLEN-1 downto 0);
  signal write_back_rd_addr : std_logic_vector(REG_WIDTH-1 downto 0);
  signal write_back_wb : std_logic;
  
  		--test bench signals
   --fetch
   --signal tb_fetch_pc 	: std_logic_vector(XLEN-1 downto 0); 
  -- decode
 -- signal tb_decode_rs1_data, tb_decode_rs2_data, tb_decode_pc, tb_decode_imm	 : std_logic_vector(XLEN-1 downto 0);
 -- signal tb_decode_branch, tb_decode_jump, tb_decode_rw, tb_decode_we, tb_decode_wb, tb_decode_src_imm, tb_decode_arith, tb_decode_sign: std_logic;   
 -- signal tb_decode_rd_addr : std_logic_vector(REG_WIDTH-1 downto 0); 
 -- signal tb_decode_shamt : std_logic_vector(4 downto 0);
 -- signal tb_decode_alu_op : std_logic_vector(ALUOP_WIDTH-1 downto 0);
  -- execute
--  signal tb_execute_alu_result, tb_execute_store_data, tb_execute_pc_target : std_logic_vector(XLEN-1 downto 0);
 -- signal tb_execute_rd_addr : std_logic_vector(REG_WIDTH-1 downto 0);
 -- signal tb_execute_pc_transfert, tb_execute_rw, tb_execute_we, tb_execute_wb : std_logic;
  -- memory
 -- signal tb_memory_store_data, tb_memory_alu_result : std_logic_vector(XLEN-1 downto 0); 
  --signal tb_memory_wb, tb_memory_we, tb_memory_rw : std_logic;
 --signal tb_memory_rd_addr : std_logic_vector(REG_WIDTH -1 downto 0);
  -- write back
  --signal tb_write_back_rd_data : std_logic_vector(XLEN-1 downto 0);
 -- signal tb_write_back_rd_addr : std_logic_vector(REG_WIDTH-1 downto 0);
  --signal tb_write_back_wb : std_logic;
  

begin
	--test bench
	tb_fetch_pc	<= fetch_pc;
	tb_decode_rs1_data <= decode_rs1_data;
	tb_decode_rs2_data <= decode_rs2_data;
	tb_decode_pc <= decode_pc;
	tb_decode_branch <= decode_branch;
	tb_decode_jump <= decode_jump;
	tb_decode_rw<= decode_rw;
	tb_decode_we<= decode_we;
	tb_decode_alu_op <= decode_alu_op;
	tb_execute_pc_target <= execute_pc_target;
	--dpm
  --o_imem_en	<= '1';
  o_imem_addr <= fetch_pc;
  o_dmem_en <= '1';
  o_dmem_we	  <= memory_we;
  o_dmem_addr <= memory_alu_result;
  o_dmem_write <= memory_store_data;
  
  -- Instantiate fetch stage
  fetch_inst : component fetch
    port map (
      i_target => execute_pc_target,
      i_imem_read => i_imem_read,
      i_transfert => execute_pc_transfert, 
      i_stall => '0', -- no stall
      i_flush => execute_pc_transfert, -- pc_transfert == flush
      i_rstn => i_rstn, 
      i_clk => i_clk, 
      o_imem_en => o_imem_en,
      o_pc => fetch_pc,
      o_instruction => fetch_instruction
    );

  -- Instantiate decode stage
  decode_inst : component decode
    port map (
      i_instr => fetch_instruction,
      i_rd_data => write_back_rd_data,
      i_rd_addr => write_back_rd_addr,
      i_wb => write_back_wb, 
      i_pc => fetch_pc,
      i_flush => execute_pc_transfert, 	 -- pc_transfert == flush 
      i_rstn => i_rstn, 
      i_clk => i_clk,
      o_rs1_data => decode_rs1_data,
      o_rs2_data => decode_rs2_data,
      o_branch => decode_branch,
      o_jump => decode_jump, 
      o_rw => decode_rw,
      o_we => decode_we,
      o_wb => decode_wb,
      o_imm => decode_imm,
      o_src_imm => decode_src_imm,
      o_rd_addr => decode_rd_addr,
      o_pc => decode_pc,
      o_arith => decode_arith, 
      o_sign => decode_sign,
      o_shamt => decode_shamt, 
      o_alu_op => decode_alu_op 
    );

  -- Instantiate execute stage
  execute_inst : component execute
    port map (
      i_jump => decode_jump,
      i_branch => decode_branch,
      i_src_imm => decode_src_imm,
      i_rw => decode_rw,
      i_we => decode_we,
      i_wb => decode_wb,
      i_rs1_data => decode_rs1_data,
      i_rs2_data => decode_rs2_data,
      i_imm => decode_imm,
      i_pc => decode_pc,
      i_rd_addr => decode_rd_addr,
      i_stall => '0', -- no stall
      i_rstn => i_rstn, 
      i_clk => i_clk, 
      i_shamt => decode_shamt, 
      i_alu_op => decode_alu_op,
      i_arith => decode_arith,
      i_sign => decode_sign,
      o_pc_transfert => execute_pc_transfert,
      o_alu_result => execute_alu_result,
      o_store_data => execute_store_data,
      o_pc_target => execute_pc_target,
      o_rw => execute_rw,
      o_we => execute_we,
      o_wb => execute_wb,
      o_rd_addr => execute_rd_addr
    );

  -- Instantiate memory access stage
  memory_access_inst : component memory_access
    port map (
      i_store_data => execute_store_data,
      i_alu_result => execute_alu_result,
      i_rd_addr => execute_rd_addr,
      i_rw => execute_rw,
      i_wb => execute_wb,
      i_we => execute_we,
      i_rstn => i_rstn, 
      i_clk => i_clk, 
      o_store_data => memory_store_data,
      o_alu_result => memory_alu_result,
      o_wb => memory_wb,
      o_we => memory_we,
      o_rw => memory_rw,
      o_rd_addr => memory_rd_addr
    );

  -- Instantiate write back stage
  write_back_inst : component write_back
    port map (
      i_load_data => i_dmem_read,
      i_alu_result => memory_alu_result,
      i_rd_addr => memory_rd_addr,
      i_rw => memory_rw,
      i_wb => memory_wb,
      i_rstn => i_rstn, 
      i_clk => i_clk, 
      o_wb => write_back_wb,
      o_rd_addr => write_back_rd_addr,
      o_rd_data => write_back_rd_data
    );


  
end architecture beh;
