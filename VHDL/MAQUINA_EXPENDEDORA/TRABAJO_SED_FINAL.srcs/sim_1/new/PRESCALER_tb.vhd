----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.12.2025 13:09:02
-- Design Name: 
-- Module Name: PRESCALER_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PRESCALER_tb is
end PRESCALER_tb;

architecture Behavioral of PRESCALER_tb is

    component PRESCALER
    generic(
        PRESCALER_DIV: positive := 17
    );
    port(
        clk : in std_logic;
        clk_salida : out std_logic
    );
    end component;

    constant PRESCALER_DIV_TB : positive := 4;
    constant CLK_PERIOD : time := 10 ns;

    signal clk : std_logic := '0';
    signal clk_salida : std_logic;

begin

    uut: PRESCALER
    generic map (
        PRESCALER_DIV => PRESCALER_DIV_TB
    )
    port map (
        clk => clk,
        clk_salida => clk_salida
    );

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
    begin
        wait for 1000 ns;
        wait;
    end process;

end Behavioral;