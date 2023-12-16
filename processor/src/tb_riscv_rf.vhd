library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_riscv_rf is
end entity tb_riscv_rf;

architecture testbench of tb_riscv_rf is

  -- Test inputs
  signal i_addr_ra : std_logic_vector(4 downto 0):= "00000";
  signal i_addr_rb : std_logic_vector(4 downto 0):= "00000";
  signal i_data_w  : std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
  signal i_addr_w  : std_logic_vector(4 downto 0):= "00000";
  signal i_we	   : std_logic:='0';
  signal rstn      : std_logic:= '1';
  signal clk       : std_logic:= '0';

  -- Output signals
  signal o_data_ra : std_logic_vector(31 downto 0);
  signal o_data_rb : std_logic_vector(31 downto 0); 

  -- Clock generation process
  constant clock_period : time := 10 ns;
begin

  -- Clock generation process
  clk_process: process
  begin
    while now < 120 ns loop
      clk <= '0';
      wait for clock_period / 2;
      clk <= '1';
      wait for clock_period / 2;
    end loop;
    wait;
  end process;	  
  
  uut : entity work.riscv_rf
	  port map(
    i_clk => clk,    
    i_rstn => rstn,
    i_we  => i_we,    
    i_addr_ra => i_addr_ra,
    o_data_ra => o_data_ra,
    i_addr_rb=>	 i_addr_rb ,
    o_data_rb =>	 o_data_rb,
    i_addr_w =>	 i_addr_w ,
    i_data_w  =>	 i_data_w 
	);
	
	-- Test stimulus generation process
stimulus_process: process
begin  
	
	rstn <= '0';
    wait for 20 ns;	
	
    rstn <= '1';
	
  -- Test Case 1: write 0x00000001 in register zero and NOOOOOOOOOOOOOOOOOO read the value in register "ra"
  i_we<='1';
  i_addr_w <= "00001";
  i_data_w <= "00000000000000000000000000000001";
  i_addr_ra <= "00001";								   -- ra_data =  0x00000001
  i_addr_rb <= "00010"; 
  wait for 20 ns;

  -- Test Case 2: check that "we" works properly
  i_we<='0';
  i_addr_w <= "00001";
  i_data_w <= "00000000000000000000000000000000";	-- we expect output to be still 0x1 and not 0x0
  i_addr_ra <= "00001";								-- ra_data =  0x00000001
  i_addr_rb <= "00010"; 
  wait for 20 ns;

  -- Test Case 3: write 0x00000008 the address 0x02 
  i_we<='1';
  i_addr_w <= "00010";
  i_data_w <= "00000000000000000000000000001000";
  i_addr_ra <= "00001";								 -- ra_data =  0x00000001 
  i_addr_rb <= "00010";								 -- rb_data =  0x00000008
  wait for 20 ns;

  -- Test Case 4: write 0x00000004 the address 0x04	and read address 0x02
  i_we<='1';
  i_addr_w <= "00100";
  i_data_w <= "00000000000000000000000000000100";
  i_addr_ra <= "00010";								 -- ra_data = 0x00000008
  i_addr_rb <= "00001"	;							 -- rb_data = 0x00000001
  wait for 20 ns;

   -- Test Case 5: read data of address 0x02
  i_we<='0';
  i_addr_w <= "00100";
  i_data_w <= "00000000000001000000000000000000";
  i_addr_ra <= "00010";								 -- ra_data = 0x00000008
  i_addr_rb <= "00100"	;							 -- rb_data = 0x00000004
  wait for 20 ns;

  wait;
end process;		


end architecture testbench;