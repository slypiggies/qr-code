library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity kernel3_convolutor is
	generic (
		PIXEL_LENGTH: natural;
		KERNEL: integer_vector(0 to 8);
		PROCESSED_PIXEL_LENGTH: natural;
		THRESHOLD: natural
	);
	port (
		CLK100: in std_logic;
		state: in unsigned(3 downto 0);
		pixel_r: in unsigned(PIXEL_LENGTH - 1 downto 0);
		pixel_w: out unsigned(PROCESSED_PIXEL_LENGTH - 1 downto 0)
	);
end entity;

architecture kernel3_convolutor_a of kernel3_convolutor is
	signal sum, sum_abs: signed(pixel_w'length + 1 - 1 downto 0);
begin
	sum_abs <=
		sum when sum >= to_signed(0, sum'length)
		else -sum;
	pixel_w <=
		(others => '0') when sum_abs < to_signed(THRESHOLD, sum_abs'length)
		else unsigned(sum_abs(pixel_w'range));
	
	process (all)
		variable product: signed((pixel_r'length + 1) * 2 - 1 downto 0);
		variable product_2: signed(sum'range);
	begin
		product := signed("0" & pixel_r) * to_signed(KERNEL(to_integer(state)), pixel_r'length + 1);
		product_2 := (product_2'left downto product'left + 1 => product(product'left)) & product;
		if rising_edge(CLK100) then
			if state = X"0" then
				sum <= product_2;
			else
				sum <= sum + product_2;
			end if; 
		end if;
	end process;
end architecture;
