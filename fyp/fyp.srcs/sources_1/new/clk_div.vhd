library ieee; use ieee.all, work.all;
use std_logic_1164.all, helper.all;

entity clk_div is
	generic (DIV: positive);
	port (
		rst: in std_logic;
		i: in std_logic; o: out std_logic
	);
end entity;

architecture clk_div of clk_div is
	constant N: positive := DIV / 2;
	signal cnt: natural;
	signal o_2: std_logic;
begin
	assert_synth(DIV mod 2 = 0);
	o <= o_2;
	process (all) is begin
		if rising_edge(i) then
			if rst = '1' then
				cnt <= 0;
				o_2 <= '0';
			else
				if cnt = N - 1 then
					cnt <= 0;
					o_2 <= not o_2;
				else
					cnt <= cnt + 1;
				end if;
			end if;
		end if;
	end process;
end architecture;
