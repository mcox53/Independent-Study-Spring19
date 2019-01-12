-- Date: 1/12/18
-- Author: M. Cox
-- Description: Basic SPI Library
-- This module only sends and receives data, control is separate

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





begin




end behavioral;		
