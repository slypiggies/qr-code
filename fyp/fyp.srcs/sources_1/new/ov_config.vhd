library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper.all;

entity ov_config is
	port (
		reset: in std_logic;
		clk: in std_logic;
		tx_ed: in std_logic;
		config: out std_logic_vector(15 downto 0);
		en: out std_logic
	);
end entity;

architecture ov_config_a of ov_config is
	signal cnt: unsigned(7 downto 0);
	signal ed: std_logic;
begin
	en <= not ed;
	process (all) begin
		if reset = '1' then
			ed <= '0';
			cnt <= (others => '0');
		elsif rising_edge(clk) and tx_ed = '1' and ed = '0' then
			cnt <= cnt + 1;
			if USE_RGB565 then
				if cnt < to_unsigned(CONFIG_RGB565'length, cnt'length) then
					config <= CONFIG_RGB565(to_integer(cnt));
				else
					ed <= '1';
				end if;
			elsif not USE_CONFIG then
				ed <= '1';
			else
				if cnt < to_unsigned(CONFIG_Y'length, cnt'length) then
					config <= CONFIG_Y(to_integer(cnt));
				else
					ed <= '1';
				end if;
			end if;
		end if;
	end process;
end architecture;
