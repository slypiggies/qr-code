library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper.all;
use helper_tb.all;

entity frame_buffer_y_tb is
	port (
		reset, clk100: in std_logic
	);
end entity;

architecture frame_buffer_y_tb_a of frame_buffer_y_tb is
	signal clk25: std_logic;
	signal addra, addrb: unsigned(ADDR_LENGTH - 1 downto 0) := (others => '0');
	signal dina: unsigned(PIXEL_LENGTH - 1 downto 0) := (others => '0');
	signal doutb: unsigned(PIXEL_LENGTH - 1 downto 0);
	
	component frame_buffer_y is
		port (
			clka: in std_logic;
			wea: in std_logic_vector(0 downto 0);
			addra: in std_logic_vector(ADDR_LENGTH - 1 downto 0);
			dina: in std_logic_vector(PIXEL_LENGTH - 1 downto 0);
			clkb: in std_logic;
			addrb: in std_logic_vector(ADDR_LENGTH - 1 downto 0);
			doutb: out std_logic_vector(PIXEL_LENGTH - 1 downto 0)
		);
	end component;
begin
	assert USE_Y severity failure; -- Because `frame_buffer_y` is being tested here.
	
	clk_divider_i: entity clk_divider generic map (
		DIVIDER => 4
	) port map (
		reset => reset,
		i => clk100,
		o => clk25
	);
	
	frame_buffer_y_i: frame_buffer_y port map (
		clka => clk100,
		wea => "1",
		addra => std_logic_vector(addra),
		dina => std_logic_vector(dina),
		clkb => clk25,
		addrb => std_logic_vector(addrb),
		unsigned(doutb) => doutb
	);
	
	process (all) begin
		if rising_edge(clk100) then
			addra <= addra + 1;
			dina <= dina + 1;
		end if;
	end process;
	
	process begin
		wait until addra = to_unsigned(1, addra'length); -- Avoid reading too early.
		while true loop
			wait until rising_edge(clk25);
			addrb <= addrb + 1;
		end loop;
		wait;
	end process;
end architecture;
