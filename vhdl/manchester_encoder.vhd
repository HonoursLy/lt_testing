library IEEE;
use IEEE.std_logic_1164.all;


entity manchester_encoder is
	generic(
		BITS : INTEGER := 10; -- Number of bits being encoded
		mlength : INTEGER := 11 -- Number of bits in the length message (not including the sync)
	);
	port (
		clk : in STD_LOGIC;
		message : in STD_LOGIC_VECTOR(BITS-1 downto 0);
		tx_length : in std_logic_vector (mlength-1 downto 0);
		dout : out STD_LOGIC;
		length_sent : out STD_LOGIC;
		reset : in STD_LOGIC;
		ena_t : in STD_LOGIC -- enc_en from TX_RAM
	);
end entity manchester_encoder;

architecture arch of manchester_encoder is
	signal internal : STD_LOGIC := '0';
	signal parallel : STD_LOGIC_VECTOR(BITS-1 downto 0) := (others => '0');
begin
	process (clk, internal) is
		variable count : INTEGER range 0 to BITS;
		variable lencount : INTEGER range 0 to mlength;
	begin
		if (reset = '0') then
			dout <= '0';
			internal <= '0';
			parallel <= (others => '0');
			count := BITS;
			lencount := mlength-1;
			length_sent <= '0';

		elsif (ena_t = '1') then
			dout <= internal xor clk;
			if (clk'event and clk = '1') then
				if (length_sent = '0') then
					if (lencount = 2) then
						internal <= tx_length(lencount);
						length_sent <= '1';
					elsif (lencount = 1) then
						parallel <= message; -- load the message so the system is ready to send the message straight away
						internal <= tx_length(lencount);
						count := BITS;
					elsif (lencount = 0) then
						internal <= tx_length(lencount);
						lencount := mlength;
					else
						internal <= tx_length(lencount);
					end if;
					lencount := lencount - 1;
				else -- once the length is sent, start sending the message
					count := count - 1;
					if (count = 0) then
						internal <= parallel(count);
						parallel <= message;
						count := BITS;
					else
						internal <= parallel(count);
					end if;

				end if;
			end if;
		else
			lencount := mlength-1;
			count := BITS;
			dout <= '0';
			length_sent <= '0';
			internal <= '0';
		end if;
	end process;

end architecture arch;
