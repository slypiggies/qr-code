library ieee;
use ieee.all;
use numeric_std.all;
use std_logic_1164.all;
use work.all;
use helper_tb.all;

entity filter_tb is
	port (
		reset, clk: in std_logic
	);
end entity;

architecture filter_tb_a of filter_tb is
	signal h_cnt_13, v_cnt_13, h_cnt_31, v_cnt_31: unsigned(ADDR_LENGTH - 1 downto 0);
	signal
		h_cnt_min_h, v_cnt_min_h,
		h_cnt_max_h, v_cnt_max_h,
		h_cnt_min_v, v_cnt_min_v,
		h_cnt_max_v, v_cnt_max_v
	: unsigned(h_cnt_13'range);
	signal eof: std_logic := '0';
	signal we: std_logic;
	signal i: natural := 0;
begin
	filter_i: entity filter generic map (
		ADDR_LENGTH => ADDR_LENGTH
	) port map (
		reset => reset,
		clk => clk,
		h_cnt_13 => h_cnt_13,
		v_cnt_13 => v_cnt_13,
		h_cnt_31 => h_cnt_31,
		v_cnt_31 => v_cnt_31,
		we_cnt => '1',
		h_cnt_min_h => h_cnt_min_h,
		v_cnt_min_h => v_cnt_min_h,
		h_cnt_max_h => h_cnt_max_h,
		v_cnt_max_h => v_cnt_max_h,
		h_cnt_min_v => h_cnt_min_v,
		v_cnt_min_v => v_cnt_min_v,
		h_cnt_max_v => h_cnt_max_v,
		v_cnt_max_v => v_cnt_max_v,
		eof => eof,
		we => we
	);
	
	process begin
		h_cnt_13 <= to_unsigned(H_CNT_13S_S(i), h_cnt_13'length);
		v_cnt_13 <= to_unsigned(V_CNT_13S_S(i), v_cnt_13'length);
		h_cnt_31 <= to_unsigned(H_CNT_31S_S(i), h_cnt_31'length);
		v_cnt_31 <= to_unsigned(V_CNT_31S_S(i), v_cnt_31'length);
		if i = H_CNT_13S_S'length - 1 then
			i <= 0;
			eof <= '1';
		else
			i <= i + 1;
			eof <= '0';
		end if;
		wait until rising_edge(clk);
	end process;
end architecture;
