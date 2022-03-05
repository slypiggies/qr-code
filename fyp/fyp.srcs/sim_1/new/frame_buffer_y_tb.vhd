library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper.all;
use helper_tb.all;

entity frame_buffer_y_tb is
	port (clk: in std_logic);
end entity;

architecture frame_buffer_y_tb_a of frame_buffer_y_tb is
	signal addra, addrb: unsigned(ADDR_LENGTH - 1 downto 0) := (others => '0');
	signal dina: unsigned(PIXEL_LENGTH - 1 downto 0) := (others => '0');
	signal doutb: unsigned(PIXEL_LENGTH - 1 downto 0);
	
	COMPONENT frame_buffer_y
	  PORT (
		clka : IN STD_LOGIC;
		wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
		dina : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		clkb : IN STD_LOGIC;
		addrb : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
		doutb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	  );
	END COMPONENT;
begin
	frame_buffer_y_i: frame_buffer_y port map (
		clka => clk,
		wea => "1",
		addra => std_logic_vector(addra),
		dina => std_logic_vector(dina),
		clkb => clk,
		addrb => std_logic_vector(addrb),
		unsigned(doutb) => doutb
	);
	
	process (all) begin
		if rising_edge(clk) then
			addra <= addra + 1;
			dina <= dina + 1;
		end if;
	end process;
	
	process begin
		wait until addra = to_unsigned(1, addra'length);
		while true loop
			wait until rising_edge(clk);
			addrb <= addrb + 1;
		end loop;
		wait;
	end process;
end architecture;
