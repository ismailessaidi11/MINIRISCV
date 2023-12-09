-------------------------------------------------------------------------------
-- Project    : SYS808 : Circuits intégrés à très grande échelle
-- Ecole de Technologie Superieure 
-------------------------------------------------------------------------------
-- File       : compteur.vhd
-- Author     : Mickael Fiorentino <mickael.fiorentino@polymtl.ca>
-- Updated by : Hachem Bensalem <hachem.bensalem.1@ens.etsmtl.ca>
-- Created    : 2018-06-22
-- Last update: 2019-03-29
-------------------------------------------------------------------------------
-- Description: Compteur BCD à 1 chiffre (4 bits) 
-------------------------------------------------------------------------------
library ieee; 
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity compteur is
  port(
    i_clk  : in  std_logic;
    i_rstn : in  std_logic;
    i_en   : in  std_logic;
    o_cnt  : out std_logic_vector(3 downto 0));
end entity compteur;

architecture beh of compteur is

  constant MAX: unsigned(3 downto 0) := to_unsigned(9, 4);

  signal cnt       : unsigned(3 downto 0);
  signal rstn_sync : std_logic_vector(1 downto 0);
  alias rstn       : std_logic is rstn_sync(1);
  
begin

  -- Output 
  o_cnt <= std_logic_vector(cnt);

  -- Reset synchronizer
  P_rstn: process (i_clk)
  begin    
    if (i_rstn = '0') then
        rstn_sync <= (others => '0');
    elsif rising_edge(i_clk) then
      rstn_sync(0) <= '1';
      rstn_sync(1) <= rstn_sync(0);
    end if;    
  end process P_rstn;

  -- Main process with asynchronous reset 
  P_bcd: process (i_clk, rstn)
  begin
    if (rstn = '0') then
      cnt <= (others => '0');
    elsif rising_edge(i_clk) then
      if (i_en = '1') then
        if (cnt = MAX) then
          cnt <= (others => '0');
        else
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process P_bcd;
    
end architecture beh;
