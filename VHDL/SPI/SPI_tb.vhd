-- Date: 1/12/18
-- Author: M. Cox
-- Description: SPI module test bench

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_tb is
--  Port ( );
end spi_tb;

architecture Behavioral of spi_tb is

    component spi is
        port (
              -- External interface
              SCLK        : out std_logic;
              MISO        : in std_logic;
              MOSI        : out std_logic;
              SS            : out std_logic;
              
              -- Internal interface
              SYS_CLK        : in std_logic;
              RESETN        : in std_logic;
              
              S_DATA        : in std_logic_vector(7 downto 0);
              R_DATA        : out std_logic_vector(7 downto 0);
              
              TX_EN        : in std_logic;
              RX_EN        : in std_logic;
              
              HOLD        : in std_logic;
              DONE        : out std_logic
                
            );
    end component;
    
    constant CLK100MHZ_period : time := 10 ns; 

    signal CLK100MHZ: std_logic;
    signal CPU_RESETN: std_logic;
    
    signal SCLK   : std_logic;
    signal MISO   : std_logic;
    signal MOSI   : std_logic;
    signal SS     : std_logic;
    
    signal S_DATA : std_logic_vector(7 downto 0);
    signal R_DATA : std_logic_vector(7 downto 0);
    
    signal TX_EN : std_logic;
    signal RX_EN : std_logic;
    
    signal HOLD : std_logic;
    signal DONE : std_logic;
    
begin
    
    uut : spi
    port map(
            SYS_CLK => CLK100MHZ,
            RESETN => CPU_RESETN,
            SCLK => SCLK,
            MISO => MISO,
            MOSI => MOSI,
            SS => SS,
            S_DATA => S_DATA,
            R_DATA => R_DATA,
            TX_EN => TX_EN,
            RX_EN => RX_EN,
            HOLD => HOLD,
            DONE => DONE
        );

    CLK_process : process
    begin
        CLK100MHZ <= '0';
        wait for CLK100MHZ_period/2;
        CLK100MHZ <= '1';
        wait for CLK100MHZ_period/2;
    end process;
    
    stim_proc : process
    begin
    
    CPU_RESETN <= '0';
    wait for 100 ns;
    CPU_RESETN <= '1';
    
    wait for 30 ns;
    S_DATA <= X"FF";
    TX_EN <= '1';
    
    wait for 200 ns;
    TX_EN <= '0';
    
    wait until DONE <= '1';
    
    wait for 30 ns;
    S_DATA <= X"42";
    TX_EN <= '1';
    
    wait for 200 ns;
    TX_EN <= '0';
    
    wait until DONE <= '1';
      
    wait;
    end process;

end Behavioral;

