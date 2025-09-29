library ieee;
use ieee.std_logic_1164.all;

entity top is
	port (
		tram_wr_en : in std_logic;
		reset : in std_logic;
		clk_48 : out std_logic;
		clk_
		dout : out std_logic
	);
end top;

architecture rtl of top is
	component tx_tb is
		wr_clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		wr_en : in STD_LOGIC;
		tx_length : in std_logic_vector (10 downto 0);
		wr_ram : out STD_LOGIC_VECTOR (9 downto 0);
		wr_addr : out STD_LOGIC_VECTOR (10 downto 0);
		tx_ready : out STD_LOGIC
	end component;

	component ram is
		generic (
			addr_width : natural := 9; -- 512x8
			data_width : natural := 8
		);
		port (
			write_en : in  std_logic;
			waddr    : in  std_logic_vector (addr_width - 1 downto 0);
			wclk     : in  std_logic;
			raddr    : in  std_logic_vector (addr_width - 1 downto 0);
			rclk     : in  std_logic;
			din      : in  std_logic_vector (data_width - 1 downto 0);
			dout     : out std_logic_vector (data_width - 1 downto 0)
		);
	end component;

	component TX_RAM IS
	PORT (
		-- enter port declarations here
		wr_clk : IN STD_LOGIC;
		rd_clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		wr_en : IN STD_LOGIC;
		rd_en : IN STD_LOGIC;
		tx_length : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		wr_addr : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
		rd_addr : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
	);
	END component;
	component manchester_encoder is
	generic(
		BITS : INTEGER := 10 -- Number of bits being encoded
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
	end component;

	COMPONENT SB_HFOSC IS
		GENERIC (
			CLKHF_DIV : STRING := "0b00"
		);
		PORT (
			CLKHFEN : IN STD_LOGIC;
			CLKHFPU : IN STD_LOGIC;
			CLKHF : OUT STD_LOGIC
		);
	END COMPONENT SB_HFOSC;

	COMPONENT clk_divider IS
		GENERIC (
			Freq_in : INTEGER := 48000000;
			N : INTEGER := 10; -- speed divider, equates to the number of bits (BITS)
		); 
		PORT (
			clk_in : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			clk_out : OUT STD_LOGIC
		);
	end component;

	
	component LT_controller IS
    PORT (
        fsm_clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
		-- Indicators from other blocks to trigger states
        tx_ready : IN STD_LOGIC; -- indication from EC to start reading TX_RAM and transmit
		rx_received : IN STD_LOGIC; -- indication from the RX line that a light message is incoming
		host_align : IN STD_LOGIC;
		device_align : IN STD_LOGIC;
		-- Add error signals that suggest to go to idle state?
		rx_error : OUT STD_LOGIC;
		tx_error : OUT STD_LOGIC;
		host : IN STD_LOGIC;
        ena_t : out std_logic;
        length_sent : in std_logic;
        tram_rd_en : out STD_LOGIC;
        enc_en : in std_logic
    );
	END component;

	signal tx_ready, tram_rd_en : std_logic := '0';
	signal tram_in, tram_out : std_logic_vector (9 downto 0);
	signal tx_clk : std_logic;
	signal tram_raddr_i,tram_waddr_i : std_logic_vector (9 downto 0);
	signal tx_length : std_logic_vector (9 downto 0) := "0000111111";
	signal enc_clk : std_logic;
	signal length_sent : std_logic;
	signal ena_t : std_logic;
	signal rx_received : std_logic := '0'; -- indication from the RX line that a light message is incoming
	signal host_align : std_logic := '0';
	signal device_align : std_logic := '0';
		-- Add error signals that suggest to go to idle state?
	signal rx_error : std_logic := '0';
	signal tx_error : std_logic := '0';
	signal host : std_logic := '0';


begin

ECin : tx_tb
	port map (
	wr_clk => tx_clk,
	reset => reset,
	wr_en => tram_wr_en,
	tx_length => tx_length,
	wr_ram => tram_in,
	wr_addr => tram_waddr_i,
	tx_ready => tx_ready
);

ram_tx : ram 
    generic map (
        addr_width => 11, -- 2048 x 10
        data_width => 10
    ),
    port map (
        write_en => tram_wr_en,
        waddr  => tram_waddr_i,
        wclk  => tx_clk,
        raddr  => tram_raddr_i,
        rclk   => tx_clk,
        din  => tram_in,
        dout => tram_out
    );

tx_addr : TX_RAM 
	PORT MAP (
		rd_clk => tx_clk,
		reset => reset,
		rd_en => tram_rd_en,
		tx_length => tx_length,
		rd_addr => tram_raddr_i,
		enc_en => enc_en
	);

END ENTITY TX_RAM;

man_enc : manchester_encoder
	generic map(
		BITS => 10, -- Number of bits being encoded in message 'byte'
		mlength => 11 -- Number of bits in the length message (not including the sync)
	);
	port map (
		clk => enc_clk,
		message => tram_out,
		tx_length => tx_length,
		dout => dout,
		length_sent => length_sent,
		reset => reset,
		ena_t => ena_t 
	);
end entity manchester_encoder;

u_osc : SB_HFOSC
	GENERIC MAP(
		CLKHF_DIV => "0b00"
	)
	PORT MAP(
		CLKHFEN => '1',
		CLKHFPU => '1',
		CLKHF => enc_clk
	);

clk_tx : clk_divider IS
    GENERIC map (
        Freq_in => 48000000
        N => 10 -- speed divider, equates to the number of bits (BITS)
    )
    PORT map (
        clk_in => enc_clk
        reset => reset,
        clk_out => tx_clk
    );

lt_fsm : LT_controller
    PORT MAP(
        fsm_clk => enc_clk,
        rst => reset,
		-- Indicators from other blocks to trigger states
        tx_ready => tx_ready, -- indication from EC to start reading TX_RAM and transmit
		rx_received => rx_received -- indication from the RX line that a light message is incoming
		host_align => host_align,
		device_align => device_align,
		-- Add error signals that suggest to go to idle state?
		rx_error => rx_error,
		tx_error => tx_error,
		host => host,
        ena_t => ena_t,
        length_sent => length_sent,
        tram_rd_en => tram_rd_en,
        enc_en => enc_en
    );

-- tx_clk => clock A
-- enc_clk => BITS * clock A
-- dec_clk => enc_clk * samples per bit
-- rx_clk => clock A
-- FSM needs logic to take in length_sent signal to turn on tx state latch rd_en, use enc_en from TX_enc to turn on and off the encoder.

end architecture;
