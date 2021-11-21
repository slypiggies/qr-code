library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity ov_sccb is
	port (
		reset: in std_logic;
		CLK100, clk1400ns: in std_logic;
		addr: in std_logic_vector(7 downto 0);
		d: in std_logic_vector(15 downto 0);
		scl: out std_logic;
		sda: inout std_logic;
		tx_ed: out std_logic;
		en: in std_logic
	);
end entity;

architecture ov_sccb_a of ov_sccb is
	signal tx_ed_2, sda_2, o, t_2: std_logic;
	signal d_2: std_logic_vector(23 downto 0);
	type state_t is (Q_0, Q_1, Q_2, Q_3, Q_D, Q_4, Q_5, Q_6);
	signal state: state_t;
	signal clk_cnt: unsigned(1 downto 0);
	signal bit_cnt, byte_cnt: unsigned(3 downto 0);
	signal clk1400ns_prev: std_logic;
begin
	iobuf_i: iobuf port map (
		i => sda_2,
		o => o,
		io => sda,
		t => t_2
	);
	tx_ed <= tx_ed_2;
	
	process (all) begin
		t_2 <= '0';
		if reset = '1' then
			tx_ed_2 <= '0';
			state <= Q_0;
			clk_cnt <= "00";
			bit_cnt <= X"0";
			byte_cnt <= X"0";
			clk1400ns_prev <= '0';
			scl <= '1';
			sda_2 <= '1';
		elsif rising_edge(CLK100) then
			clk1400ns_prev <= clk1400ns;
			if state = Q_0 and en = '1' then
				if tx_ed_2 = '0' then
					tx_ed_2 <= '1';
				else
					tx_ed_2 <= '0';
					d_2 <= addr & d;
					state <= Q_1;
					clk_cnt <= "00";
					scl <= '1';
					sda_2 <= '1';
				end if;
			elsif clk1400ns_prev = '0' and clk1400ns = '1' then
				clk_cnt <= clk_cnt + 1;
				if state = Q_1 and clk_cnt = "11" then
					state <= Q_2;
					scl <= '1';
					sda_2 <= '0';
				elsif state = Q_2 and clk_cnt = "10" then
					state <= Q_3;
					scl <= '0';
					sda_2 <= '0';
				elsif state = Q_3 and clk_cnt = "11" then
					state <= Q_D;
					scl <= '0';
					sda_2 <= d_2(d_2'left);
					d_2 <= d_2(d_2'left - 1 downto 0) & '0';
					bit_cnt <= X"0";
					byte_cnt <= X"0";
				elsif state = Q_D then
					if clk_cnt = "00" or clk_cnt = "01" then
						scl <= '1';
					elsif clk_cnt = "10" then
						scl <= '0';
					else
						if byte_cnt < X"2" or bit_cnt < X"8" then
							scl <= '0';
							if bit_cnt /= X"7" then
								sda_2 <= d_2(d_2'left);
								d_2 <= d_2(d_2'left - 1 downto 0) & '0';
							else
								t_2 <= '1';
							end if;
						else
							state <= Q_4;
							scl <= '0';
							sda_2 <= '0';
						end if;
						
						if bit_cnt < X"8" then
							bit_cnt <= bit_cnt + 1;
						else
							bit_cnt <= X"0";
							if byte_cnt < X"2" then
								byte_cnt <= byte_cnt + 1;
							else
								byte_cnt <= X"0";
							end if;
						end if;
					end if;
				elsif state = Q_4 and clk_cnt = "00" then
					state <= Q_5;
					scl <= '1';
					sda_2 <= '0';
				elsif state = Q_5 and clk_cnt = "11" then
					state <= Q_6;
					scl <= '1';
					sda_2 <= '1';
				elsif state = Q_6 and clk_cnt = "11" then
					state <= Q_0;
				end if;
			end if;
		end if;
	end process;
end architecture;
