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

entity riscv_core is
  port (
  i_imem_read	: in  std_logic_vector(N-1 downto 0);
  i_dmem_read 	: in  std_logic_vector(N-1 downto 0);
  i_scan_en 	: in  std_logic_vector(5-1 downto 0);  
  i_test_mode 	: in  std_logic;	  
  i_tdi 		: in  std_logic;
  i_rstn		: in  std_logic;
  i_clk 		: in  std_logic;
	
  o_imem_en 	: out std_logic;
  o_imem_addr 	: out std_logic_vector(5-1 downto 0); 
  o_dmem_en 	: out std_logic_vector(N-1 downto 0);
  o_dmem_we		: out std_logic;
  o_dmem_addr 	: out std_logic;
  o_dmem_write  : out std_logic;
  o_tdo			: out std_logic
  ); 
  
end entity riscv_core;

architecture beh of riscv_core is 	

begin
 
  
end architecture beh;
