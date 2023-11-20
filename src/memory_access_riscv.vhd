-------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-------------------------------------------------------------------------------
-- File     riscv_pc.vhd
-- Author   Maxime Pietrera-Ferrandini & Ismail Essaidi 
-- Id		2312199 & 
-- Lab      GRM - Polytechnique Montreal
-- Date     2023-11-20
-------------------------------------------------------------------------------
-- Brief    Memory Access
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;	

entity memory_access is
	generic (N : positive := 32);
	port (
		clk, rst, rw, we, wb : in std_logic;
		store_data, i_alu_result : in std_logic_vector(N-1 downto 0);
		i_rd_addr : in std_logic_vector(9 downto 0); -- Je suis pas s�r de la longueur de vecteur
		wb : out std_logic;
		load_data, o_alu_result : out std_logic_vector(N-1 downto 0);
		o_rd_addr : out std_logic_vector(9 downto 0)); -- Je suis pas s�r de la longueur de vecteur
end entity memory_access;



architecture beh of memory_access is
	component dpm is
		generic (
    		WIDTH : integer := 32;
    		DEPTH : integer := 10;
    		RESET : integer := 16#00000000#;
    		INIT  : string  := "memory.mem");
  		port (
    		-- Port A
    		i_a_clk   : in  std_logic;                               -- Clock
    		i_a_rstn  : in  std_logic;                               -- Reset Address
    		i_a_en    : in  std_logic;                               -- Port enable
		    i_a_we    : in  std_logic;                               -- Write enable
		    i_a_addr  : in  std_logic_vector(DEPTH-1 downto 0);      -- Address port
		    i_a_write : in  std_logic_vector(WIDTH-1 downto 0);      -- Data write port
		    o_a_read  : out std_logic_vector(WIDTH-1 downto 0);      -- Data read port
		    -- Port B
		    i_b_clk   : in  std_logic;                               -- Clock
		    i_b_rstn  : in  std_logic;                               -- Reset Address
		    i_b_en    : in  std_logic;                               -- Port enable
		    i_b_we    : in  std_logic;                               -- Write enable
		    i_b_addr  : in  std_logic_vector(DEPTH-1 downto 0);      -- Address port
		    i_b_write : in  std_logic_vector(WIDTH-1 downto 0);      -- Data write port
		    o_b_read  : out std_logic_vector(WIDTH-1 downto 0));     -- Data read port
	end component dpm; 
	
	--signal clk1 : std_logic;
	
	begin
		pc : component dpm
			port map(
			i_b_clk => clk;
			i_b_rst => rst;
			i_b_en => rw;
			i_b_we => we;
			i_b_addr => 
			i_b_write => store_data;
			o_b_read => load_data;
		
	
		

end architecture beh;