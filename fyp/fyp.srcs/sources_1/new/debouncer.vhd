library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;

entity debouncer is
	port (
		clk: in std_logic;
		i: in std_logic;
		o: out std_logic
	);
end entity;

architecture debouncer_a of debouncer is
	signal cnt: unsigned(15 downto 0);
begin
	o <=
		'1' when cnt = (cnt'range => '1')
		else '0';
	process (all) begin
		if rising_edge(clk) then
			if i = '1' then
				if cnt < (cnt'range => '1') then
					cnt <= cnt + 1;
				end if;
			else
				cnt <= (others => '0');
			end if;
		end if;
	end process;
end architecture;
