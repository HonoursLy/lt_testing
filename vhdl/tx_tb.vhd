-- Library and Use statements for IEEE packages
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;


entity tx_tb is
	port(
	wr_clk : in STD_LOGIC;
	reset : in STD_LOGIC;
	wr_en : in STD_LOGIC;
	tx_length : in std_logic_vector (10 downto 0);
	wr_ram : out STD_LOGIC_VECTOR (9 downto 0);
	wr_addr : out STD_LOGIC_VECTOR (10 downto 0);
	tx_ready : out STD_LOGIC
	);
end entity tx_tb;

architecture arch of tx_tb is
	-- insert local declarations here
	SIGNAL w_count : STD_LOGIC_VECTOR (10 DOWNTO 0) := "00000000000";
begin

PROCESS (wr_clk, reset)
	BEGIN
		IF (reset = '0') THEN
			w_count <= (OTHERS => '0');
		ELSIF falling_edge(wr_clk) THEN
			IF wr_en = '1' THEN
				IF (w_count >= tx_length) THEN
				elsif (w_count = "00000000010") then
					tx_ready <= '1';
					w_count <= w_count + 1;
				ELSE
					w_count <= w_count + 1;
				END IF;
			else 
				w_count <= (OTHERS => '0');
				tx_ready <= '0';
			END IF;
		END IF;
	END PROCESS;

wr_ram <= w_count(9 downto 0);
wr_addr <= w_count;

end architecture arch;
