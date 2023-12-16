library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all;

entity tb_riscv_alu is
end entity tb_riscv_alu;

architecture testbench of tb_riscv_alu is
  type test_case is record
    arith   : std_logic;
    sign    : std_logic;
    opcode  : std_logic_vector(ALUOP_WIDTH-1 downto 0);
    shamt   : std_logic_vector(SHAMT_WIDTH-1 downto 0);
    src1    : std_logic_vector(XLEN-1 downto 0);
    src2    : std_logic_vector(XLEN-1 downto 0);
    res     : std_logic_vector(XLEN-1 downto 0);
  end record;

  constant ZERO  : std_logic_vector(XLEN-1 downto 0) := "00000000000000000000000000000000";
  constant ONE   : std_logic_vector(XLEN-1 downto 0) := "00000000000000000000000000000001";
  constant TWO   : std_logic_vector(XLEN-1 downto 0) := "00000000000000000000000000000010";
  constant THREE : std_logic_vector(XLEN-1 downto 0) := "00000000000000000000000000000011";

  constant test_case_1 : test_case := (arith => '0', sign => '0', opcode => ALUOP_ADD, shamt => (others => '0'), src1 => TWO, src2 => ONE, res => THREE);-- ADD 0x2 0x1   output 0x3
  constant test_case_2 : test_case := (arith => '1', sign => '0', opcode => ALUOP_SR, shamt => "00001", src1 => TWO, src2 => ONE, res => ONE);           -- SRA 0x2 0x1   output 0x1
  constant test_case_3 : test_case := (arith => '0', sign => '0', opcode => ALUOP_XOR, shamt => (others => '0'), src1 => ONE, src2 => ONE, res => ZERO); -- XOR 0x1 0x1   output 0x0

  type test_case_array is array (natural range <>) of test_case;
  constant test_cases: test_case_array :=
    (test_case_1, test_case_2, test_case_3);


  signal arith, sign : std_logic:='0';
  signal opcode : std_logic_vector(ALUOP_WIDTH-1 downto 0):="000";
  signal src1, src2, res : std_logic_vector(XLEN-1 downto 0):="00000000000000000000000000000000";
  signal shamt : std_logic_vector(SHAMT_WIDTH-1 downto 0):="00000";

  signal clock : std_logic := '0';


  constant clock_period : time := 10 ns;

begin
  -- Instantiate the ALU
  uut: entity work.riscv_alu
    port map (
      i_arith  => arith,
      i_sign   => sign,
      i_opcode => opcode,
      i_shamt  => shamt,
      i_src1   => src1,
      i_src2   => src2,
      o_res    => res
    );

  -- Clock process
  clock_process: process
  begin
    while now < 60 ns loop
      clock <= not clock;
      wait for clock_period / 2;
    end loop;
    wait;
  end process clock_process;

  test_process: process
  begin
    -- Test case 1
   
    arith <= test_cases(0).arith;
    sign <= test_cases(0).sign;
    opcode <= test_cases(0).opcode;
    shamt <= test_cases(0).shamt;
    src1 <= test_cases(0).src1;
    src2 <= test_cases(0).src2;

	wait for 20ns;  
		
    -- Test case 2

    arith <= test_cases(1).arith;
    sign <= test_cases(1).sign;
    opcode <= test_cases(1).opcode;
    shamt <= test_cases(1).shamt;
    src1 <= test_cases(1).src1;
    src2 <= test_cases(1).src2;

	  wait for 20ns;
	  
    -- Test case 3

    arith <= test_cases(2).arith;
    sign <= test_cases(2).sign;
    opcode <= test_cases(2).opcode;
    shamt <= test_cases(2).shamt;
    src1 <= test_cases(2).src1;
    src2 <= test_cases(2).src2;

	  wait for 20ns;
	  
    wait;
  end process test_process;

end architecture testbench;
