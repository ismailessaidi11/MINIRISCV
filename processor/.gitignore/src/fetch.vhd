															 -------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-- Polytechnique Montréal
-------------------------------------------------------------------------------
-- File     fetch_riscv.vhd
-- Author   Ismail Essaidi & Maxime Z
-- Date     2022-08-27
-------------------------------------------------------------------------------
-- Description 	fetch
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	   

entity fetch is
  generic (N : positive := 32);
  port (
  target	   : in  std_logic_vector(N-1 downto 0);
  imem_read    : in  std_logic_vector(N-1 downto 0);
  transfert	   : in  std_logic;
  stall		   : in  std_logic;
  flush		   : in  std_logic;
  rstn		   : in  std_logic;
  clk    	   : in  std_logic;  
  
  imem_en 	   : out std_logic;
  imem_addr    : out std_logic_vector(8 downto 0));	--rename 8
  instruction  : out std_logic_vector(N-1 downto 0)
  );
end entity fetch;

architecture beh of fetch is 

	component riscv_pc is
		port (
		i_clk		 : in  std_logic;
		i_rstn		 : in  std_logic;
		i_stall		 : in  std_logic;
		i_transfert  : in  std_logic;
		i_target 	 : in std_logic_vector(N-1 downto 0); 
		
		o_pc 		 : out  std_logic_vector(N-1 downto 0));	   
	end component riscv_pc ;
	
	signal clk1: std_logic;
	
	
	begin
		
	clk1 <= clk;	
	pc: component riscv_pc
		port map(
			i_clk =>  clk1,
			i_rstn => rstn, 
			i_stall => stall,
			i_transfert => transfert,
			i_target(N-1 downto 0) => target(N-1 downto 0),
			o_pc(8 downto 0) => imem_addr(8 downto 0)
			);
	process(clk1, rstn)
	begin
	  if falling_edge(rstn) then
	      instruction <= imem_read;  --reset tp first instruction in i_mem (done by the reset of PC)
	  elsif rising_edge(clk1) then
	    if flush = '0' then
			instruction <= imem_read;
		else
			instruction <= NOP;
	    end if;
	  end if;
	end process;	
	
end architecture beh;