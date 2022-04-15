library ieee; use ieee.all;
use std_logic_1164.all;

entity delayer is
	generic (DELAY: positive);
	port (
		rst, clk: in std_logic;
		i: in integer; o: out integer;
		we: out std_logic
	);
end entity;

architecture delayer of delayer is
	signal shift_reg: integer_vector(0 to DELAY - 1);
	signal shift_reg_we: std_logic_vector(0 to DELAY + 1 - 1);
begin
	o <= shift_reg(shift_reg'left);
	we <= shift_reg_we(shift_reg_we'left);
	process (all) is begin
		if rising_edge(clk) then
			if rst = '1' then
				shift_reg_we(shift_reg_we'right) <= '1';
				shift_reg_we(shift_reg_we'left to shift_reg_we'right - 1) <= (others => '0');
			else
				shift_reg <= shift_reg(shift_reg'left + 1 to shift_reg'right) & i;
				shift_reg_we <= shift_reg_we(shift_reg_we'left + 1 to shift_reg_we'right) & '1';
			end if;
		end if;
	end process;
end architecture;
