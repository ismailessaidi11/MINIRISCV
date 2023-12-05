																									 -------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-- Polytechnique Montréal
-------------------------------------------------------------------------------
-- File     write_b_riscv.vhd
-- Author   Ismail Essaidi & Maxime Z
-- Date     2022-08-27
-------------------------------------------------------------------------------
-- Description 	WB
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	   

entity write_back is
  generic (
    N : positive := 32
  );
  port (
  i_load_data	: in  std_logic_vector(N-1 downto 0);
  i_alu_result 	: in  std_logic_vector(N-1 downto 0);
  i_rd_addr 	: in  std_logic_vector(5-1 downto 0);  
  i_rw 			: in  std_logic;	  
  i_wb 			: in  std_logic;
  i_rstn		: in  std_logic;
  i_clk 		: in  std_logic;
	
  o_wb 			: out std_logic;
  o_rd_addr 	: out std_logic_vector(5-1 downto 0); 
  o_rd_data 	: out std_logic_vector(N-1 downto 0)
  ); 
  
end entity write_back;

architecture beh of write_back is 	

begin
  o_rd_addr <= i_rd_addr;
  o_wb <= i_wb;
  
  process(i_rw, i_load_data, i_alu_result)
	  begin
	  if  i_rw = '1' then
	    o_rd_data <= i_load_data;  
	  else
	    o_rd_data <= i_alu_result;
	  end if;
  end process; 
  
end architecture beh;
