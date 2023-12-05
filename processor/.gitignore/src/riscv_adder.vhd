-------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intégrés à très grande échelle
-- Polytechnique Montréal
-------------------------------------------------------------------------------
-- File     riscv_adder.vhd
-- Author   Is 
-- Date     2022-08-27
-------------------------------------------------------------------------------
-- Description 	adder with ripple-carry
-------------------------------------------------------------------------------	 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity half_adder is	
  port (a, b       : in  std_logic;
    	sum, carry : out  std_logic);											
end entity half_adder;

architecture beh of half_adder is

begin 
	sum <= a xor b;
	carry <= a and b;
	
end architecture beh;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity riscv_adder is
  generic (N : positive := 32);
  port (i_a    : in  std_logic_vector(N-1 downto 0);
  		i_b    : in  std_logic_vector(N-1 downto 0);   
	    i_sign : in  std_logic;
	    i_sub  : in  std_logic;
	    o_sum  : out std_logic_vector(N downto 0));
end entity riscv_adder;

architecture beh of riscv_adder is
	component half_adder is
		port (a, b       : in  std_logic;
			  carry, sum : out  std_logic);
	end component half_adder;
	signal tmp_a : std_logic_vector(N downto 0);
	signal tmp_b : std_logic_vector(N downto 0);
	signal in_carry_1 : std_logic_vector(N downto 0);
	signal in_carry_2 : std_logic_vector(N downto 0);
	signal out_or : std_logic_vector(N downto 0);
	signal sum_in :	std_logic_vector(N downto 0);
	signal tmp_b_signed : std_logic_vector(N downto 0); 
	 
begin
	--sign extention
	tmp_a(N-1 downto 0) <= i_a;
	tmp_b(N-1 downto 0) <= i_b;
	tmp_a(N) <= i_a(N-1) when i_sign = '1' else '0';
	tmp_b(N) <= i_b(N-1) when i_sign = '1' else '0';   
		
	--complement � 2
	tmp_b_signed <= std_logic_vector(not(signed(tmp_b)) + 1) when i_sub = '1' else tmp_b;
	
	
	in_carry_1(0) <= '0';
	in_carry_2(0) <= '0';
	sum_in(0) <= '0';
	gen_adder:for i in 0 to N generate 
		
		gen_0:if (i = 0) generate
			u_adder:half_adder port map(a =>  tmp_a(0),
						  				b => tmp_b_signed(0),
						  				sum => o_sum(0),
						  				carry => out_or(0));
		end generate gen_0;
		
		gen_i:if (i > 0 and i <= N) generate
			
										
			adder_high:half_adder port map(a =>  tmp_a(i),
											b => tmp_b_signed(i),
											sum => sum_in(i),
											carry => in_carry_1(i));
											
			adder_low:half_adder port map(a =>  out_or(i-1),
										b => sum_in(i),
										sum => o_sum(i),
										carry => in_carry_2(i));
										
			out_or(i) <= in_carry_1(i) or in_carry_2(i);						   	
															
		end generate gen_i;	
		
	end generate gen_adder;

end architecture beh;

