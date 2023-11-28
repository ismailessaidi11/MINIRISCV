													  																									 -------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-- Polytechnique Montréal
-------------------------------------------------------------------------------
-- File     memory_access.vhd
-- Author   Ismail Essaidi & Maxime Z
-- Date     2022-08-27
-------------------------------------------------------------------------------
-- Description 	ME
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	   

entity memory_access is
  generic (
    N : positive := 32
  );
  port (
  
  i_store_data  : in  std_logic_vector(N-1 downto 0);
  i_alu_result  : in  std_logic_vector(N-1 downto 0);	 --replace by XLEN
  i_rd_addr  	: in  std_logic_vector(4 downto 0);  -- replace by REG_WIDTH -1
  i_rw 		 	: in  std_logic_vector(1 downto 0);		-- WHY IS IT 2 bit		 ??????????????
  i_wb 		 	: in  std_logic;
  i_we			: in  std_logic;
  i_rstn 	 	: in  std_logic;
  i_clk 	 	: in  std_logic; 
  
  o_store_data  : out std_logic_vector(N-1 downto 0);
  o_alu_result_dmem 	: out std_logic_vector(8 downto 0);		--rename 8
  o_alu_result 	: out std_logic_vector(N-1 downto 0);
  o_wb 		 	: out std_logic;
  o_we			: out std_logic;
  o_rw 			: out std_logic_vector(1 downto 0);		-- WHY IS IT 2 bit????????????????
  o_rd_addr  	: out std_logic_vector(4 downto 0)  -- replace by REG_WIDTH
  );
end entity memory_access;



architecture beh of memory_access is 	
	
begin 		   
	
	o_store_data <=	 i_store_data;
	o_rw		 <=  i_rw;						 --check if rw if good like this !!!!!!!!!!!!!!!!!
	o_we		 <=	 i_we;
	o_alu_result_dmem <= i_alu_result(8 downto 0);
	
		
	process(i_clk, i_rstn)
	begin
	  if falling_edge(i_rstn) then
		o_rw <= "00";
		o_alu_result <= "00000000000000000000000000000000";
		o_wb <= '0';
		o_rd_addr <= "00000"; 	    
	  elsif rising_edge(i_clk) then
		o_alu_result  <= i_alu_result;
		o_wb 		  <= i_wb;
		o_rd_addr  	  <= i_rd_addr;
	  end if;
	end process;	

	
end architecture beh;
