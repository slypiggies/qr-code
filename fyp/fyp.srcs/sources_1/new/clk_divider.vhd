library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper.all;

entity clk_divider is
	generic (
		DIVIDER: positive
	);
	port (
		reset: in std_logic;
		i: in std_logic;
		o: out std_logic
	);
end entity;

architecture clk_divider_a of clk_divider is
	constant N: positive := DIVIDER / 2;
	signal cnt: unsigned(cnt_bit(N) - 1 downto 0);
	signal o_2: std_logic;
begin
	assert_synth(DIVIDER mod 2 = 0);
	
	o <= o_2;
	process (all) begin
		if reset = '1' then
			cnt <= (others => '0');
			o_2 <= '0';
		elsif rising_edge(i) then
			if cnt = to_unsigned(N - 1, cnt'length) then
				cnt <= (others => '0');
				o_2 <= not o_2;
			else
				cnt <= cnt + 1;
			end if;
		end if;
	end process;
end architecture;
