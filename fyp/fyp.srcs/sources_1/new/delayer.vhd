library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;

entity delayer is
	generic (
		DELAY: positive;
		LENGTH: positive
	);
	port (
		reset, clk: in std_logic;
		i: in unsigned(LENGTH - 1 downto 0);
		o: out unsigned(LENGTH - 1 downto 0);
		we: out std_logic
	);
end entity;

architecture delayer_a of delayer is
	type unsigned_array_t is array(natural range <>) of unsigned(LENGTH - 1 downto 0);
	signal shift_reg: unsigned_array_t(DELAY - 1 downto 0);
	type std_logic_array_t is array(natural range <>) of std_logic;
	signal shift_reg_we: std_logic_array_t(DELAY downto 0);
begin
	o <= shift_reg(shift_reg'low);
	we <= shift_reg_we(shift_reg_we'low);
	process (all) begin
		if reset = '1' then
			shift_reg_we(shift_reg_we'high) <= '1';
			for j in shift_reg_we'high - 1 downto shift_reg_we'low loop
				shift_reg_we(j) <= '0';
			end loop;
		elsif rising_edge(clk) then
			shift_reg(shift_reg'high) <= i;
			for j in shift_reg'low to shift_reg'high - 1 loop
				shift_reg(j) <= shift_reg(j + 1);
			end loop;
			for j in shift_reg_we'low to shift_reg_we'high - 1 loop
				shift_reg_we(j) <= shift_reg_we(j + 1);
			end loop;
		end if;
	end process;
end architecture;
