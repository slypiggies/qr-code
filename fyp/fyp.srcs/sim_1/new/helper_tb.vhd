library ieee; use ieee.all, work.all;
--use std_logic_1164.all, helper.all;
use std_logic_1164.all;

package helper_tb is
	constant EN_OV_SCCB_TB: boolean := false;
	constant EN_FB_Y_TB: boolean := false;
	constant EN_DELAYER_TB: boolean := false;
	
	constant BMP_HEADER_LEN: positive := 54;
	constant BMP_PATH: string := "C:/Data/qr-code/resources/";
	constant BMP_FILENAME_R: string := "Newfolder7/20220404_224322";--"in2";
	constant BMP_FILENAME_W: string := "out";
	constant BMP_FILE_EXTENSION: string := ".bmp";
	
	type character_array_t is array(natural range <>) of character;
	type file_t is file of character;
	
	constant ADDR_S: std_logic_vector(7 downto 0) := X"42";
	constant D_S: std_logic_vector(15 downto 0) := B"01010101_00110011";
	constant DELAY_S: positive := 3;
	constant LEN_S: positive := 9;
	constant REG_S: integer_vector(0 to 6) := (11, 10, 9, 16, 5, 4, 3, others => 0);
--	constant PXS_S: px_t_array_t(0 to 6 + 7 + 13 + 2 + 1 - 1) := ( -- The last pixel of each line should be different to the first pixel of the next line.
--		PX_T_BL, PX_T_BL, PX_T_BL, PX_T_WH, PX_T_WH, PX_T_BL,
--		PX_T_WH, PX_T_BL, PX_T_WH, PX_T_WH, PX_T_WH, PX_T_BL, PX_T_WH, -- 11311.
--		PX_T_BL, PX_T_BL, PX_T_WH, PX_T_WH, PX_T_BL, PX_T_BL, PX_T_BL, PX_T_BL, PX_T_BL, PX_T_WH, PX_T_WH, PX_T_BL, PX_T_BL, -- 22522.
--		PX_T_WH, PX_T_WH,
--		PX_T_BL, -- Same as the first pixel.
--		others => PX_T_BL
--	);
end package;
