library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper.all;

entity kernel3_convolutor is
	generic (
		KERNEL: integer_vector(0 to 8);
		PROCESSED_PIXEL_LENGTH: natural;
		THRESHOLD: natural
	);
	port (
		clk: in std_logic;
		state: in unsigned(3 downto 0);
		pixel_r: in unsigned(PIXEL_LENGTH - 1 downto 0);
		pixel_w: out unsigned(PROCESSED_PIXEL_LENGTH - 1 downto 0)
	);
end entity;

architecture kernel3_convolutor_a of kernel3_convolutor is
	signal sum, sum_abs: signed(pixel_w'length + 1 - 1 downto 0);
begin
	assert_synth(PROCESSED_PIXEL_LENGTH >= (PIXEL_LENGTH + 1) * 2); -- This may not be enough, because the convoluted sum may still be wider than `(PIXEL_LENGTH + 1) * 2`, depending on `KERNEL`.
	assert_synth(to_unsigned(THRESHOLD, PROCESSED_PIXEL_LENGTH) <= (PROCESSED_PIXEL_LENGTH downto 1 => '1'));
	
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
		if rising_edge(clk) then
			if state = X"0" then
				sum <= product_2;
			else
				sum <= sum + product_2;
			end if; 
		end if;
	end process;
end architecture;
