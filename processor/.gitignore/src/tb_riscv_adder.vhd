library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_riscv_adder is
end entity tb_riscv_adder;

architecture testbench of tb_riscv_adder is
  signal clk : std_logic := '0';
  signal reset : std_logic := '0';

  -- Test inputs
  signal i_a : std_logic_vector(31 downto 0);
  signal i_b : std_logic_vector(31 downto 0);
  signal i_sign : std_logic := '0'; -- 0 for unsigned, 1 for signed
  signal i_sub : std_logic := '0';  -- 0 for addition, 1 for subtraction

  -- Output signals
  signal o_sum : std_logic_vector(32 downto 0);

  -- Clock generation process
  constant clock_period : time := 10 ns;
begin
	--o_sum <= (others=>'0');
  -- Clock generation process
  clk_process: process
  begin
    while now < 100 ns loop
      clk <= '0';
      wait for clock_period / 2;
      clk <= '1';
      wait for clock_period / 2;
    end loop;
    wait;
  end process;

  -- Instantiate the riscv_adder
  uut: entity work.riscv_adder
    generic map (N => 32)
    port map (
      i_a    => i_a,
      i_b    => i_b,
      i_sign => i_sign,
      i_sub  => i_sub,
      o_sum  => o_sum
    );

-- Test stimulus generation process
stimulus_process: process
begin         
  -- Test Case 1: Addition of positive numbers
  i_a <= "00000000000000000000000000000001";
  i_b <= "00000000000000000000000000000010";
  i_sign <= '0';  -- unsigned
  i_sub <= '0';   -- addition
  wait for 20 ns;

  -- Test Case 2: Addition of positive and negative numbers
  i_a <= "00000000000000000000000000000001";
  i_b <= "11111111111111111111111111111111";
  i_sign <= '1';  -- signed
  i_sub <= '0';   -- addition
  wait for 20 ns;

  -- Test Case 3: Subtraction of positive numbers
  i_a <= "00000000000000000000000000000100";
  i_b <= "00000000000000000000000000000001";
  i_sign <= '0';  -- unsigned
  i_sub <= '1';   -- subtraction
  wait for 20 ns;

  -- Test Case 4: Subtraction of negative numbers
  i_a <= "11111111111111111111111111111110";
  i_b <= "11111111111111111111111111111111";
  i_sign <= '1';  -- signed
  i_sub <= '1';   -- subtraction
  wait for 20 ns;

 

  wait;
end process;


  -- Monitor the output signals
  monitor_process: process
  begin
    wait for 20 ns;
    report "o_sum = " & integer'image(to_integer(unsigned(o_sum)));
    wait;
  end process;

end architecture testbench;
