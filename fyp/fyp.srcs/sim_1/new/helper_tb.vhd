library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper.all;

package helper_tb is
	constant ENABLE_OV_SCCB_TB: boolean := false;
	constant ENABLE_KERNEL3_TB: boolean := false;
	constant ENABLE_PROCESSING_TB: boolean := false;
	constant ENABLE_FRAME_BUFFER_Y_TB: boolean := false; -- Dimension must be 640x480.
	constant ENABLE_DELAYER_TB: boolean := false;
	constant ENABLE_AGGREGATOR_TB: boolean := true;
	
	type character_array_t is array(natural range <>) of character;
	type file_t is file of character;
	type pixel_array_t is array(natural range <>) of unsigned(PIXEL_LENGTH - 1 downto 0);
	
	constant H: positive := 640;
	constant V: positive := 480;
	constant ADDR_LENGTH: positive := cnt_bit(H * V);
	constant PROCESSED_PIXEL_LENGTH: positive := PIXEL_LENGTH * 3;
	constant BMP_HEADER_LENGTH: positive := 54;
	constant BMP_PATH_PREFIX: string := "C:/Data/FYP/resources/";
	constant BMP_FILE_NAME_R: string := "in.bmp";
	constant BMP_FILE_NAME_W: string := "out.bmp";
	
	constant BL: unsigned(PIXEL_LENGTH - 1 downto 0) := (others => '0'); -- Black.
	constant WH: unsigned(PIXEL_LENGTH - 1 downto 0) := (others => '1'); -- White.
	
	constant ADDR_S: std_logic_vector(7 downto 0) := X"42";
	constant D_S: std_logic_vector(15 downto 0) := B"01010101_00110011";
	constant KERNEL_S: integer_vector(0 to 8) := (-1, -2, -1, 0, 0, 0, 0, 0, 0);
	constant THRESHOLD_S: natural := 16;
	constant PIXEL_R_S: unsigned(PIXEL_LENGTH - 1 downto 0) := WH;
	constant DELAY_S: positive := 3;
	constant LENGTH_S: positive := 9;
	constant REG_S: integer_vector(0 to 6) := (11, 10, 9, 16, 5, 4, 3);
	constant PIXELS_S: pixel_array_t(0 to 10) := (BL, BL, BL, WH, WH, BL, WH, BL, WH, WH, BL);
end package;
