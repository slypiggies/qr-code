library ieee;
use ieee.all;
use work.all;
use std_logic_1164.all;
use numeric_std.all;
use helper_tb.all;

entity tmp2 is
	port (
		reset, clk: in std_logic
	);
end entity;

architecture tmp2_a of tmp2 is
	signal addr: unsigned(ADDR_LENGTH - 1 downto 0);
	signal we_addr: std_logic;
	signal n: unsigned(ADDR_LENGTH - 1 downto 0);
	signal we_n: std_logic;
begin
	addr_generator_i: entity addr_generator generic map (
		H => H,
		V => V,
		ADDR_LENGTH => ADDR_LENGTH
	) port map (
		reset => reset,
		clk => clk,
		we => '1',
		h_cnt_begin => to_unsigned(60, ADDR_LENGTH),
		v_cnt_begin => to_unsigned(70, ADDR_LENGTH),
		d_h_x => to_signed(3, ADDR_LENGTH + 1),
		d_v_x => to_signed(2, ADDR_LENGTH + 1),
		d_h_y => to_signed(-2, ADDR_LENGTH + 1),
		d_v_y => to_signed(3, ADDR_LENGTH + 1),
		h_cnt_end_x => to_unsigned(60 + 20, ADDR_LENGTH),
		v_cnt_end_x => to_unsigned(70 + 15, ADDR_LENGTH),
		h_cnt_end_y => to_unsigned(60 - 30, ADDR_LENGTH),
		v_cnt_end_y => to_unsigned(70 - 40, ADDR_LENGTH),
		addr => addr,
		we_addr => we_addr,
		n => n,
		we_n => we_n
	);
end architecture;
