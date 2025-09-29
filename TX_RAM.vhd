-- Library and Use statements for IEEE packages
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.std_logic_signed.ALL;
ENTITY TX_RAM IS
	PORT (
		-- enter port declarations here
		rd_clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		rd_en : IN STD_LOGIC;
		tx_length : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		rd_addr : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
		enc_en : OUT STD_LOGIC -- signal to stop the encoder from writing to dout
		);
END ENTITY TX_RAM;

ARCHITECTURE arch OF TX_RAM IS
	SIGNAL r_count : STD_LOGIC_VECTOR (10 DOWNTO 0) := "00000000000";
BEGIN

	PROCESS (rd_clk, reset)
	BEGIN
		IF (reset = '0') THEN
			r_count <= (OTHERS => '0');
		ELSIF falling_edge(rd_clk) THEN
			IF rd_en = '1' THEN
				IF (r_count >= tx_length) THEN
					enc_en <= '0'; -- turn off the manchester encoder
				ELSE
					r_count <= r_count + 1;
					enc_en <= '1'; -- turn on the manchester encoder
				END IF;
			else
				r_count <= (OTHERS => '0');
			END IF;
		END IF;
	END PROCESS;

	rd_addr <= r_count;
END ARCHITECTURE arch;