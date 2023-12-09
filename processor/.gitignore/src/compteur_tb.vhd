-------------------------------------------------------------------------------
-- Project    : ELE8304 : Circuits intégrés à très grande échelle
-- Polytechnique Montréal
-------------------------------------------------------------------------------
-- File       : compteur_tb.vhd
-- Author     : Mickael Fiorentino <mickael.fiorentino@polymtl.ca>
-- Updated by : Théo Dupuis <theo.dupuis@polymtl.ca>
-- Created    : 2018-06-22
-- Last update: 2021-08-30
-------------------------------------------------------------------------------
-- Description: Banc d'essai du compteur BCD 
-------------------------------------------------------------------------------
library ieee; 
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library std;
use     std.textio.all;                                                      
use     std.env.all;

library work;
use     work.all;

entity compteur_tb is 
end compteur_tb;

architecture tb of compteur_tb is

  component compteur is
    port (
      i_clk  : in  std_logic;
      i_rstn : in  std_logic;
      i_en   : in  std_logic;
      o_cnt  : out std_logic_vector(3 downto 0));
  end component compteur;
  
  signal clk   : std_logic := '1';
  signal rst_n : std_logic := '0';
  signal en    : std_logic := '0';
  signal cnt   : std_logic_vector(3 downto 0);

  constant PERIOD   : time := 10 ns; 
  constant TB_LOOP  : positive := 2;
  constant COUNTER_LOOP  : positive := 12;

  
begin
  

  -- Clock
  clk <= not clk after PERIOD / 2;

  -- DUT
  dut: compteur
    port map (
      i_clk  => clk,
      i_rstn => rst_n,
      i_en   => en,
      o_cnt  => cnt);

  -- Main TB process
  P_tb : process
  
  variable EXPECTED : unsigned(3 downto 0) := (others => '0');
  
  -- Change the inital value of the expected output to see the assertion fail in modelsim
  
  begin
    report "*** Simulation Starts ***";

    for i in 0 to TB_LOOP-1 loop
      en    <= '0';
      rst_n <= '0';
      wait for 2.3 * PERIOD;
      rst_n <= '1';
      en    <= '1';
      wait for 2*PERIOD;
      
      for i in 0 to COUNTER_LOOP-1 loop
		   assert cnt = std_logic_vector(EXPECTED)
		     report " cnt = " & to_hstring(cnt) & ", should be = " & to_hstring(EXPECTED)
		     severity WARNING;
		   if(EXPECTED >= 9) then
		     	EXPECTED := to_unsigned(0, EXPECTED'length);
		   else
		   	EXPECTED := EXPECTED + to_unsigned(1, EXPECTED'length);
		   end if;
		   wait for 1*PERIOD;
		end loop;
      en    <= '0';
      
    end loop;
    
    report "*** Simulation Ends ***";
    stop;      
  end process P_tb;
  
end architecture tb;
