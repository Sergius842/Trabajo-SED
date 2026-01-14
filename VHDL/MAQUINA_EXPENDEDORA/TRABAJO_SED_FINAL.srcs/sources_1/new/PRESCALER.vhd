----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.12.2025 12:29:58
-- Design Name: 
-- Module Name: PRESCALER - Behavioral
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
use IEEE.NUMERIC_STD.ALL; 

entity PRESCALER is
    generic(
        PRESCALER_DIV: positive := 17      
    );
    port(
        clk     : in std_logic;
        clk_salida : out std_logic
    );
end PRESCALER;

architecture Behavioral of PRESCALER is
    signal s_counter : unsigned(PRESCALER_DIV - 1 downto 0) := (others => '0');

begin
    process (clk)
    begin
        if rising_edge (clk) then
            s_counter <= s_counter + 1;
        end if;
    end process;
    clk_salida <= std_logic(s_counter(s_counter'high));

end Behavioral;