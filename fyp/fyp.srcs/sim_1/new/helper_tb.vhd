library ieee;
use ieee.all;
use std_logic_1164.all;
use numeric_std.all;
use work.all;
use helper.all;

package helper_tb is
	constant ENABLE_OV_SCCB_TB: boolean := false;
	constant ENABLE_KERNEL3_TB: boolean := false;
	constant ENABLE_PROCESSING_TB: boolean := true;
	
	type character_array_t is array(natural range <>) of character;
	type file_t is file of character;
	
	constant H: natural := 640;
	constant V: natural := 480;
	constant ADDR_LENGTH: natural := cnt_bit(H * V);
	constant PROCESSED_PIXEL_LENGTH: natural := PIXEL_LENGTH * 3;
	constant BMP_HEADER_LENGTH: natural := 54;
	constant BMP_PATH_PREFIX: string := "C:/Data/FYP/resources/";
	constant BMP_FILE_NAME_R: string := "in.bmp";
	constant BMP_FILE_NAME_W: string := "out.bmp";
	
	constant ADDR_S: std_logic_vector(7 downto 0) := X"42";
	constant D_S: std_logic_vector(15 downto 0) := B"01010101_00110011";
	constant PIXEL_R_S: unsigned(PIXEL_LENGTH - 1 downto 0) := (others => '1');
end package;
