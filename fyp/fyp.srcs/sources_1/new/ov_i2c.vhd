library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ov_i2c is
	port (
		reset: in std_logic;
		clk50: in std_logic;
		OV_SIOC: out std_logic;
		OV_SIOD: inout std_logic;
		tx_ed: out std_logic;
		en: in std_logic;
		cmd: in std_logic_vector(15 downto 0)
	);
end entity;

architecture ov_i2c_a of ov_i2c is
	constant OV_ADDR: std_logic_vector(7 downto 0) := x"42";
	signal cnt: unsigned(7 downto 0);
	signal busy, data: std_logic_vector(31 downto 0);
begin
	OV_SIOD <=
		'Z' when busy(29 downto 28) = "10" or busy(20 downto 19) = "10" or busy(11 downto 10) = "10"
		else data(data'left);
	
	process (all) begin
		if reset = '1' then
			cnt <= (cnt'left downto cnt'right + 1 => '0') & '1';
			busy <= (others => '0');
			data <= (others => '1');
		elsif rising_edge(clk50) then
			tx_ed <= '0';
			if busy(busy'left) = '0' then
				OV_SIOC <= '1';
				if en = '1' then
					if cnt = (cnt'range => '0') then
						data <= "100" & OV_ADDR & '0' & cmd(15 downto 8) & '0' & cmd(7 downto 0) & '0' & "01";
						busy <= (others => '1');
						tx_ed <= '1';
					else
						cnt <= cnt + 1;
					end if;
				end if;
			else
				case busy(31 downto 29) & busy(2 downto 0) is
					when "111" & "111" => -- start sequence 1
						OV_SIOC <= '1';
					when "111" & "110" => -- start sequence 2
						OV_SIOC <= '1';
					when "111" & "100" => -- start sequence 3
						OV_SIOC <= '0';
					when "110" & "000" => -- end sequence 1
						case cnt(7 downto 6) is
							when "00" =>
								OV_SIOC <= '0';
							when others =>
								OV_SIOC <= '1';
						end case;
					when "100" & "000" => -- end sequence 2
						OV_SIOC <= '1';
					when "000" & "000" => -- idle
						OV_SIOC <= '1';
					when others =>
						case cnt(7 downto 6) is
							when "01" =>
								OV_SIOC <= '1';
							when "10" =>
								OV_SIOC <= '1';
							when others =>
								OV_SIOC <= '0';
						end case;
				end case;
				
				if cnt = (cnt'range => '1') then
					busy <= busy(busy'left - 1 downto 0) & '0';
					data <= data(data'left - 1 downto 0) & '1';
					cnt <= (others => '0');
				else
					cnt <= cnt + 1;
				end if;
			end if;
		end if;
	end process;
end architecture;
