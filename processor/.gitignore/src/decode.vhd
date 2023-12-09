							  																									 -------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-- Polytechnique Montréal
-------------------------------------------------------------------------------
-- File     decode.vhd
-- Author   Ismail Essaidi & Maxime Z
-- Date     2022-08-27
-------------------------------------------------------------------------------
-- Description 	ID
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	   
use work.riscv_pkg.all;

entity decode is

  port (
  i_instr		: in  std_logic_vector(XLEN-1 downto 0);
  i_rd_data 		: in  std_logic_vector(XLEN-1 downto 0);
  i_rd_addr 		: in  std_logic_vector(REG_WIDTH -1 downto 0);  
  i_wb 			: in  std_logic;
  i_pc			: in  std_logic_vector(XLEN-1 downto 0);
  i_flush		: in  std_logic;
  i_rstn			: in  std_logic;
  i_clk 			: in  std_logic;
  
  
  
  o_rs1_data 		: out std_logic_vector(XLEN-1 downto 0);
  o_rs2_data 		: out std_logic_vector(XLEN-1 downto 0); 
  o_branch		: out std_logic;
  o_jump			: out std_logic;
  o_rw 			: out std_logic;  -- read word from d-mem
  o_we			: out std_logic;	-- write enable in d-mem
  o_wb			: out std_logic;  -- write back in rf
  o_imm			: out std_logic_vector(XLEN-1 downto 0);  
  o_src_imm		: out std_logic;
  o_rd_addr 		: out std_logic_vector(REG_WIDTH-1 downto 0);
  o_pc			: out std_logic_vector(XLEN-1 downto 0);
  -- for ALU in EX
  o_arith		: out std_logic;
  o_sign			: out std_logic;
  o_shamt		: out std_logic_vector(4 downto 0);	
  o_alu_op		: out std_logic_vector(ALUOP_WIDTH-1 downto 0)
  ); 
  
end entity decode;


architecture beh of decode is 	
	
	signal opcode				: std_logic_vector(6 downto 0); 
	signal funct3				: std_logic_vector(2 downto 0);
	signal funct7				: std_logic_vector(6 downto 0);	
	signal opcode_and_funct3 	: std_logic_vector(9 downto 0);
	signal rs1_addr			: std_logic_vector(REG_WIDTH -1 downto 0);	 
	signal rs2_addr			: std_logic_vector(REG_WIDTH -1 downto 0);
	signal branch				: std_logic;
  	signal jump				: std_logic;
	signal rw 				: std_logic;
	signal we				: std_logic;
	signal wb				: std_logic;  
	signal arith				: std_logic;
	signal sign				: std_logic;
	signal imm				: std_logic_vector(XLEN-1 downto 0);
	signal src_imm			: std_logic;
	signal pc				: std_logic_vector(XLEN-1 downto 0);
	signal alu_op				: std_logic_vector(ALUOP_WIDTH-1 downto 0);
	signal rs1_data_rf		: std_logic_vector(XLEN-1 downto 0);
	signal rs2_data_rf		: std_logic_vector(XLEN-1 downto 0);
  	signal u_imm				: std_logic_vector(XLEN-1 downto 0);
	signal j_imm				: std_logic_vector(XLEN-1 downto 0);
	signal i_imm				: std_logic_vector(XLEN-1 downto 0);	
	signal s_imm				: std_logic_vector(XLEN-1 downto 0);
	signal b_imm				: std_logic_vector(XLEN-1 downto 0);
	signal shamt				: std_logic_vector(5-1 downto 0);

	
	component riscv_rf is

		port (
		    i_clk     : in  std_logic;
		    i_rstn    : in  std_logic;
		    i_we      : in  std_logic;
		    i_addr_ra : in  std_logic_vector(REG_WIDTH-1 downto 0);
		    o_data_ra : out std_logic_vector(XLEN-1 downto 0);
		    i_addr_rb : in  std_logic_vector(REG_WIDTH-1 downto 0);
		    o_data_rb : out std_logic_vector(XLEN-1 downto 0);
		    i_addr_w  : in  std_logic_vector(REG_WIDTH-1 downto 0);
		    i_data_w  : in  std_logic_vector(XLEN-1 downto 0));	   
	end component riscv_rf ;  
	
	begin 
		
	
	-- predecode	 	
	opcode	 		  <=  i_instr(6 downto 0);
	funct3	 		  <=  i_instr(14 downto 12);
	rs1_addr	 		  <=  i_instr(19 downto 15);
	rs2_addr	 		  <=  i_instr(24 downto 20);
	funct7	 		  <=  i_instr(31 downto 25);
	opcode_and_funct3   <=  opcode&funct3;
	u_imm 	 		  <=  i_instr(31 downto 12)&"000000000000";
	j_imm(31 downto 20) <=  (others => i_instr(31));
	j_imm(19 downto 0)  <=  i_instr(19 downto 12)&i_instr(20)&i_instr(30 downto 25)&i_instr(24 downto 21)&'0';
	i_imm(31 downto 11) <=  (others => i_instr(31));
	i_imm(10 downto 0)  <=  i_instr(30 downto 20);
	s_imm(31 downto 11) <=  (others => i_instr(31));
	s_imm(10 downto 0)  <=  i_instr(30 downto 25)&i_instr(11 downto 8)&i_instr(7);
	b_imm(31 downto 12) <=  (others => i_instr(31));
	b_imm(11 downto 0)  <=  i_instr(7)&i_instr(30 downto 25)&i_instr(11 downto 8)&'0';

	
	-- decode 
	 
	 	--branch
	 with opcode select branch <=
	 '1' 	  when "1100011",		-- BEQ
	 '0'		  when others;

	 	-- jump
	 with opcode select jump <=
	 '1'		  when "1101111",	  	-- JAL
	 '1'		  when "1100111",		-- JALR
	 '0'		  when others;	   
	 
	 
	 -- treating the jump case
	 with jump select o_rs1_data <= 
	 pc			when '1',
	 rs1_data_rf	when others; 
	 
	 with jump select o_rs2_data <= 
	 std_logic_vector(to_unsigned(ADDR_INCR, 32))	when '1',
	 rs2_data_rf  								when others;
	 
	 with opcode select o_pc <= 
	 rs1_data_rf  when "1100111", -- JALR
	 pc			when others;
	 	--we
	 with opcode	select we <= 
	 '1'		when "0100011",	 -- SW
	 '0'		when others;
	 
	 	-- rw
	 with opcode select rw <=
	 '1'	  	when "0000011",   -- LW
	 '0'	 	when others;
	 
	 	-- wb
	 with opcode select wb <=
	 '0'		  when "1100011",	-- BEQ
	 '0'		  when "0100011",	-- SW
	 '1'		  when others; 
	 
		--arith
	 with opcode_and_funct3 select arith <=
	 funct7(5) when "0110011000",		-- SUB
	 funct7(5) when "0110011101",	     -- SRA
	 funct7(5) when "0010011101",		-- SRAI
	 '1'		  when "1100011000",	  	-- BEQ 
	 '1'		  when "0110011010",		-- SLT
	 '1'	  	  when "0110011011",		-- SLTU
	 '1'	  	  when "0010011010",		-- SLTI
	 '1'	  	  when "0010011011",		-- SLTIU
	 '0'  	  when others;	
	 
	 -- sign
	with opcode_and_funct3 select sign <= 
	'0'		  when "0110011011",		-- SLTU
	'0'	  	  when "0010011011",		-- SLTIU
	'1'		  when others;
	
	 --shamt
	with opcode_and_funct3 select shamt <= 					 
	i_instr(24 downto 20)	  when "0010011001",	-- SLLI 
	i_instr(24 downto 20)	  when "0010011101",	-- SRLI  SRAI	
	"00000"	  			  when others;
	
		-- imm
	with opcode select imm <=
	u_imm	when "0110111", 	-- LUI
	j_imm	when "1101111",	-- JAL
	i_imm	when "1100111",   -- JALR
	b_imm	when "1100011",	-- BEQ
	i_imm	when "0000011",	-- LW																			
	i_imm	when "0010011",	-- I-Type	
	s_imm	when "0100011",	-- SW 	   
	imm 		when others;
	
		--src_imm
	with opcode select src_imm <=
	'1' 		when "0010011",	 -- I-Type
	'1'		when "0110111",	 -- LUI
	'1' 		when "0100011",	 -- SW
	'1' 		when "0000011",	 -- LW
	'0' 		when others;
		 																								
	-- alu_op 
process (opcode_and_funct3, opcode)
begin
  if opcode = "0110111"  then
    alu_op <= ALUOP_ADD; -- LUI
  elsif opcode = "1101111" then
    alu_op <= ALUOP_ADD; -- JAL
  else
    case opcode_and_funct3 is
      when "1100111000" => alu_op <= ALUOP_ADD; -- JALR
      when "1100011000" => alu_op <= ALUOP_ADD; -- BEQ
      when "0000011010" => alu_op <= ALUOP_ADD; -- LW
      when "0100011010" => alu_op <= ALUOP_ADD; -- SW
      when "0010011000" => alu_op <= ALUOP_ADD; -- ADDI
      when "0110011000" => alu_op <= ALUOP_ADD; -- ADD, SUB
      when "0010011010" => alu_op <= ALUOP_SLT; -- SLTI
      when "0010011011" => alu_op <= ALUOP_SLT; -- SLTIU
      when "0110011010" => alu_op <= ALUOP_SLT; -- SLT
      when "0110011011" => alu_op <= ALUOP_SLT; -- SLTU
      when "0010011001" => alu_op <= ALUOP_SL; -- SLLI
      when "0110011001" => alu_op <= ALUOP_SL; -- SLL
      when "0010011101" => alu_op <= ALUOP_SR; -- SRLI, SRAI
      when "0110011101" => alu_op <= ALUOP_SR; -- SRL, SRA
      when "0010011100" => alu_op <= ALUOP_XOR; -- XORI
      when "0110011100" => alu_op <= ALUOP_XOR; -- XOR
      when "0010011110" => alu_op <= ALUOP_OR; -- ORI
      when "0110011110" => alu_op <= ALUOP_OR; -- OR
      when "0010011111" => alu_op <= ALUOP_AND; -- ANDI
      when "0110011111" => alu_op <= ALUOP_AND; -- AND
      when others 	  => alu_op <= ALUOP_OTHER;
    end case;
  end if;
end process;

	
	rf: component riscv_rf																								 
		port map(
			i_clk 	 => i_clk,
			i_rstn 	 => i_rstn, 
			i_we 	 => i_wb,
			i_addr_ra => rs1_addr,
			o_data_ra => rs1_data_rf,
			i_addr_rb => rs2_addr,
			o_data_rb => rs2_data_rf,
			i_addr_w  => i_rd_addr,
			i_data_w  => i_rd_data
			);  
	  
	process(i_clk, i_rstn, i_flush)
	begin
	  if i_rstn = '0' then
		o_branch <= '0';
		o_jump <= '0';
		o_rw <= '0';
		o_we <= '0';
		o_wb <= '0';
		o_arith <= '0';
		o_sign <= '0';
		o_imm <= (others => '0');
		o_src_imm <= '0';
		o_alu_op <= "000";
		o_shamt	<= "00000";
		pc <= i_pc;	    		   -- will be reset by the PC
		o_rd_addr <= 	i_instr(11 downto 7); --won't be written (handeled by rf)
	  elsif i_flush = '1' then
	  	o_branch <= '0';
		o_jump <= '0';
		o_rw <= '0';
		o_we <= '0';
		o_wb <= '0';
		o_arith <= '0';
		o_sign <= '0';
		o_imm <= (others => '0');
		o_src_imm <= '0';
		o_alu_op <= "000";
		o_shamt	<= "00000";
		pc <= i_pc;	    		   -- will be reset by the PC
		o_rd_addr <= 	i_instr(11 downto 7); --won't be written
	  elsif rising_edge(i_clk) then
		o_branch <= branch;
		o_jump <= jump;
		o_rw <= rw;
		o_we <= we;
		o_wb <= wb;
		o_imm <= imm;
		o_src_imm <= src_imm;
		pc <= i_pc;
		o_rd_addr <= i_instr(11 downto 7); 
		
		--ALU
		o_arith <= arith;
		o_sign <= sign;
		o_shamt <= shamt;
		o_alu_op <= alu_op;
		
	  end if;
	end process;	
	  
end architecture beh;
