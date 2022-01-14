library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.all;
use work.helper_tb.all;

entity fyp_tb is end entity;

architecture fyp_tb_a of fyp_tb is
	constant ENABLE_OV_SCCB_TB: boolean := false;
--	constant ENABLE_OV_SCCB_TB: boolean := true;
	
	constant ENABLE_KERNEL3_TB: boolean := false;
--	constant ENABLE_KERNEL3_TB: boolean := true;
	
--	constant ENABLE_SOBEL: boolean := false;
	constant ENABLE_SOBEL: boolean := true;
	
	constant ADDR: std_logic_vector(7 downto 0) := X"42";
	constant D: std_logic_vector(15 downto 0) := B"01010101_00110011";
	
	constant H: natural := 640;
	constant V: natural := 480;
	constant ADDR_LENGTH: natural := natural(floor(log2(real(H * V)))) + 1;
	constant PIXEL_LENGTH: natural := 4;
	constant PIXEL_R: unsigned(PIXEL_LENGTH - 1 downto 0) := X"F";
	constant PROCESSED_PIXEL_LENGTH: natural := PIXEL_LENGTH * 3;
	constant BMP_HEADER_LENGTH: natural := 54;
	constant BMP_PATH: string := "C:/Data/FYP/resources/in.bmp";
	constant BMP_PATH_2: string := "C:/Data/FYP/resources/out.bmp";
	
	constant PERIOD100: time := 10 ns;
	signal clk100: std_logic := '1';
	signal reset: std_logic := '1';
	
	signal scl, sda, tx_ed: std_logic;
	signal addr_r, addr_w: unsigned(ADDR_LENGTH - 1 downto 0);
	signal pixel_w: unsigned(PROCESSED_PIXEL_LENGTH - 1 downto 0);
	signal we: std_logic;
	signal bmp_header: character_array_t(0 to BMP_HEADER_LENGTH - 1);
	signal rx_ed, processed, tx_ed_2: boolean := false;
	signal addr_2, addr_3: unsigned(ADDR_LENGTH - 1 downto 0);
	signal pixel, pixel_2: unsigned(PIXEL_LENGTH - 1 downto 0);
	signal we_2: std_logic;
	type pixel_array_t is array(natural range <>) of unsigned(PIXEL_LENGTH - 1 downto 0);
	signal pixels: pixel_array_t(0 to H * V - 1);
begin
	process begin
		wait for PERIOD100 / 2;
		clk100 <= not clk100;
	end process;
	
	process begin
		wait until falling_edge(clk100);
		reset <= '0';
		wait;
	end process;
	
	ENABLE_OV_SCCB_TB_if: if ENABLE_OV_SCCB_TB generate
		ov_sccb_tb_i: entity ov_sccb_tb port map (
			reset => reset,
			clk100 => clk100,
			addr => ADDR,
			d => D,
			scl => scl,
			sda => sda,
			tx_ed => tx_ed,
			en => '1'
		);
	end generate;
	
	ENABLE_KERNEL3_TB_if: if ENABLE_KERNEL3_TB generate
		kernel3_tb_i: entity kernel3_tb generic map (
			H => H,
			V => V,
			ADDR_LENGTH => ADDR_LENGTH,
			PIXEL_LENGTH => PIXEL_LENGTH,
			PROCESSED_PIXEL_LENGTH => PROCESSED_PIXEL_LENGTH
		) port map (
			reset => reset,
			clk100 => clk100,
			addr_r => addr_r,
			addr_w => addr_w,
			pixel_r => PIXEL_R,
			pixel_w => pixel_w,
			we => we
		);
	end generate;
	
	ENABLE_SOBEL_if: if ENABLE_SOBEL generate
		fake_frame_buffer_y_in_i: entity fake_frame_buffer_y_in generic map (
			H => H,
			V => V,
			ADDR_LENGTH => ADDR_LENGTH,
			PIXEL_LENGTH => PIXEL_LENGTH,
			BMP_HEADER_LENGTH => BMP_HEADER_LENGTH,
			BMP_PATH => BMP_PATH
		) port map (
			bmp_header => bmp_header,
			rx_ed => rx_ed,
			addr => addr_2,
			pixel => pixel
		);
		
		sobel_i: entity sobel generic map (
			H => H,
			V => V,
			ADDR_LENGTH => ADDR_LENGTH,
			PIXEL_LENGTH => PIXEL_LENGTH
		) port map (
			reset => reset,
			CLK100 => CLK100,
			addr_r => addr_2,
			addr_w => addr_3,
			pixel_r => pixel,
			pixel_w => pixel_2,
			we => we_2
		);
		
		fake_frame_buffer_y_out_i: entity fake_frame_buffer_y_out generic map (
			H => H,
			V => V,
			ADDR_LENGTH => ADDR_LENGTH,
			PIXEL_LENGTH => PIXEL_LENGTH,
			BMP_HEADER_LENGTH => BMP_HEADER_LENGTH,
			BMP_PATH => BMP_PATH_2
		) port map (
			bmp_header => bmp_header,
			processed => processed,
			addr => addr_3,
			pixel => pixel_2,
			tx_ed => tx_ed_2
		);
		
		process begin
			wait for 1 ps;
			assert rx_ed severity failure;
			for i in 1 to H * V loop
				wait until we_2 = '1';
				wait until we_2 = '0';
			end loop;
			processed <= true;
			wait for 1 ps;
			assert tx_ed_2 severity failure;
			wait;
		end process;
	end generate;
end architecture;
