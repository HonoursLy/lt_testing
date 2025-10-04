-- Library and Use statements for IEEE packages
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;


entity tx_tb is
    generic (
        BITS      :     INTEGER := 10; -- Number of bits being encoded
        mlength   :     INTEGER := 11 -- Number of bits in the length message (not including the sync)
    );
    port (
        wr_clk    : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        wr_en     : in  STD_LOGIC;
        tx_length : in  std_logic_vector(mlength - 1 downto 0);
        wr_ram    : out STD_LOGIC_VECTOR(BITS - 1 downto 0);
        wr_addr   : out STD_LOGIC_VECTOR(mlength - 1 downto 0);
        tx_ready  : out STD_LOGIC
    );
end entity tx_tb;

architecture arch of tx_tb is
    -- insert local declarations here
    signal w_count : STD_LOGIC_VECTOR(mlength - 1 downto 0) := (others => '0');
begin

    process (wr_clk, reset) is
    begin
        if (reset = '0') then
            w_count          <= (others => '0');
        elsif falling_edge(wr_clk) then
            if wr_en = '1' then
                if (w_count >= tx_length) then
                elsif (w_count(1) = '1') then
                    tx_ready <= '1';
                    w_count  <= w_count + 1;
                else
                    w_count  <= w_count + 1;
                end if;
            else
                w_count      <= (others => '0');
                tx_ready     <= '0';
            end if;
        end if;
    end process;

    wr_ram                   <= '1' & w_count;
    wr_addr                  <= w_count;

end architecture arch;
