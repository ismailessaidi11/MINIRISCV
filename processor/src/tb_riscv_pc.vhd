					   library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all;

entity tb_riscv_pc is
end entity tb_riscv_pc;

architecture testbench of tb_riscv_pc is

  signal i_stall, i_transfert : std_logic := '0';
  
  signal o_pc ,i_target: std_logic_vector(XLEN-1 downto 0):= "00000000000000000000000000000000";


  signal clock : std_logic := '0';
  signal rstn : std_logic;

  constant clock_period : time := 10 ns;

begin
  -- Instantiate the ALU
  uut: entity work.riscv_pc
    port map (
      i_clk  => clock,
      i_rstn   => rstn,
      i_stall => '0',
      i_transfert  => i_transfert,
      i_target   => i_target,
      o_pc    => o_pc
    );

  -- Clock process
  clock_process: process
  begin
    while now < 100 ns loop
      clock <= not clock;
      wait for clock_period / 2;
    end loop;
    wait;
  end process clock_process;

  test_process: process
  begin
    -- Test case 1
   
    rstn <= '0';
    wait for 20 ns;	
	
    rstn <= '1';

    i_target <= "00000000000000000000000000000100";
    i_transfert <= '0';


	wait for 40ns;  
		
    -- Test case 2


    i_target <= "00000000000000000000000000000100";
    i_transfert <= '1';

	wait for 40ns;
	  

	  
    wait;
  end process test_process;

end architecture testbench;
