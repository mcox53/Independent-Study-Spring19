-- Date: 1/12/18
-- Author: M. Cox
-- Description: Basic SPI Library
-- This module only sends and receives data, control is separate

-- Some info about the design:
-- Default SCLK is 1MHz to work with most hardware by default


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi is
	port(
		-- External interface
		SCLK		: out std_logic;
		MISO		: in std_logic;
		MOSI		: out std_logic;
		SS			: out std_logic;
		
		-- Internal interface
		SYS_CLK		: in std_logic;
		RESETN		: in std_logic;
		
		S_DATA		: in std_logic_vector(7 downto 0);
		R_DATA		: out std_logic_vector(7 downto 0);
		
		TX_EN		: in std_logic;
		RX_EN		: in std_logic;
		
		HOLD		: in std_logic;
		DONE		: out std_logic
		
	);
end spi;
		
architecture behavioral of spi is

	type FSM_STATE is (IDLE, REG, EN, DATA, SENT);
	
	signal CURRENT_STATE : FSM_STATE;
	signal NEXT_STATE	 : FSM_STATE;
	

	-- 25 MHz for internal use
	signal INT_CLK	: std_logic;
	signal SPI_CLK	: std_logic;

	signal SCLK_buf : std_logic;
	signal MISO_buf : std_logic;
	signal MOSI_buf	: std_logic;
	signal SS_buf	: std_logic;
	
	signal REG_DATA_IN	: std_logic;
	
	signal DATA_IN_BUF	: std_logic_vector(7 downto 0);
	
	signal MOSI_shft_en : std_logic;
	signal MOSI_shft_com: std_logic;
	
	signal SCLK_out_en	: std_logic;
	signal SS_out_en	: std_logic;
	
	signal HOLD_buf		: std_logic;
	signal DONE_buf		: std_logic;
	
	signal shft_cnt		: integer;

begin

	shift_out : process(SPI_CLK, RESETN)
	begin
		if(RESETN = '0') then
			shft_cnt 		<= 7;
			MOSI_shft_com 	<= '0';
			MOSI_shft_en 	<= '0';
		elsif(SPI_CLK'event and SPI_CLK = '1') then
			if(MOSI_shft_en = '1') then
				if(shft_cnt >= 0) then
					MOSI_buf <= DATA_IN_BUF(shft_cnt);
					shft_cnt <= shft_cnt - 1;
				elsif(shft_cnt < 0) then
					MOSI_shft_en <= '0';
					MOSI_shft_com <= '1';
					shft_cnt <= 7;
				end if;
			else
				MOSI_buf <= '0';
		end if;
	
	IO_reg : process(SPI_CLK)
	begin
		if (SPI_CLK'event and SPI_CLK = '1') then
			
			SCLK 		<= SCLK_buf;
			MOSI 		<= MOSI_buf;
			SS 			<= SS_buf;
			MISO_buf 	<= MISO;
			
		end if;
	end process;
		
	fast_reg : process(INT_CLK)
	begin
		if(RESETN = '0') then
			SCLK_out_en <= '0';
			SS_out_en 	<= '0';
			REG_DATA_IN <= '0';
			
		elsif(INT_CLK'event and INT_CLK = '1') then
			
			HOLD_buf <= HOLD;
			DONE <= DONE_buf;
			
			if(REG_DATA_IN = '1') then
				DATA_IN_BUF <= S_DATA;
				REG_DATA_IN <= '0';
			end if;
			
			if(SCLK_out_en = '1') then
				SCLK_buf <= SPI_CLK;
			else
				SCLK_buf <= '0';
			end if;
			
			if(SS_out_en = '1') then
				SS_buf <= '0';
			else
				SS_buf <= '1';
			end if;
				
		end if;
	end process;

	state_transition : process(INT_CLK)
	begin
		if(RESETN = '0') then
			CURRENT_STATE <= IDLE;
		elsif(INT_CLK'event and INT_CLK = '1') then
			CURRENT_STATE <= NEXT_STATE;
		end if;
	end process;
	
	state_comb : process(CURRENT_STATE)
	begin
		case CURRENT_STATE is
			when IDLE =>
				if(TX_EN = '1' or RX_EN = '1') then
					NEXT_STATE <= REG;
				else
					NEXT_STATE <= IDLE;
				end if;
			when REG =>
				REG_DATA_IN <= '1';
				NEXT_STATE <= EN;
			when EN =>
				REG_DATA_IN <= '0';
				SS_out_en <= '1';
				SCLK_out_en <= '1';
			when DATA =>
				MOSI_shft_en <= '1';
				
				if(MOSI_shft_com = '1') then
					NEXT_STATE <= SENT;
					MOSI_shft_com <= '0';
				else
					NEXT_STATE <= DATA;
				end if;
			when SENT =>
				if(HOLD_buf <= '1') then
					NEXT_STATE <= REG_DATA_IN;
				else
					NEXT_STATE <= IDLE;
					SS_out_en <= '0';
					SCLK_out_en <= '0';
					DONE_buf <= '1'
				end if;
		end case;
				
	spi_clk : entity work.clock_divider
		generic map(divisor => 100)
		port map(
			clk_in => SYS_CLK,
			reset => RESETN,
			clk_out => SPI_CLK
			);
			
	buf_clk : entity work.clock_divider
		generic map(divisor => 4)
		port map(
			clk_in => SYS_CLK,
			reset => RESETN,
			clk_out => INT_CLK
			);

end behavioral;		
