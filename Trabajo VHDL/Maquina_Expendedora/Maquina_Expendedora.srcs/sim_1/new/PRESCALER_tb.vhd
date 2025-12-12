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

end;

architecture Behavioral of PRESCALER_tb is

    component PRESCALER
        generic(
            PRESCALER_DIV: positive := 17      
        );
        port(
            clk        : in std_logic;
            clk_salida : out std_logic
        );
    end component;
    
    
    constant c_BITS_SIMULACION : positive := 4; 
    constant CLOCK_PERIOD      : time := 10 ns; 

    signal clk        : std_logic := '0';
    signal clk_salida : std_logic;

begin

    uut: PRESCALER 
        generic map( 
            PRESCALER_DIV => c_BITS_SIMULACION
        )
        port map( 
            clk        => clk,
            clk_salida => clk_salida 
        );
                                
    CLK_TREATMENT: process
    begin
        clk <= '0';
        wait for 0.5 * CLOCK_PERIOD;
        clk <= '1';
        wait for 0.5 * CLOCK_PERIOD;
    end process;
    
    STIMULUS: process
    begin
     
        wait for 100 ns;

        
        wait for CLOCK_PERIOD * 50;

        assert false
            report "Success: simulation finished."
            severity failure;
    
        wait;
    end process;

end Behavioral;