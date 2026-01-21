----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.12.2025 17:26:37
-- Design Name: 
-- Module Name: EDGE_DETECTOR_tb - Behavioral
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

entity EDGE_DETECTOR_tb is
end EDGE_DETECTOR_tb;

architecture Behavioral of EDGE_DETECTOR_tb is

    component EDGE_DETECTOR
        Generic(
            NUM_MONEDAS: positive:= 4
        );
        Port(
            clk: in std_logic;
            entrada_moneda: in std_logic_vector(NUM_MONEDAS - 1 downto 0);
            flanco_monedas: out std_logic_vector(NUM_MONEDAS - 1 downto 0)
        );
    end component;

    constant NUM_MONEDAS_TB : positive := 4;
    constant CLK_PERIOD : time := 10 ns;

    signal clk : std_logic := '0';
    signal entrada_moneda : std_logic_vector(NUM_MONEDAS_TB - 1 downto 0) := (others => '0');
    signal flanco_monedas : std_logic_vector(NUM_MONEDAS_TB - 1 downto 0);

begin

    uut: EDGE_DETECTOR
    Generic map (
        NUM_MONEDAS => NUM_MONEDAS_TB
    )
    Port map (
        clk => clk,
        entrada_moneda => entrada_moneda,
        flanco_monedas => flanco_monedas
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
        entrada_moneda <= (others => '0');
        wait for 100 ns;

        entrada_moneda <= "0001";
        wait for CLK_PERIOD * 4;

        entrada_moneda <= "0000";
        wait for CLK_PERIOD * 4;

        entrada_moneda <= "1100";
        wait for CLK_PERIOD * 4;

        entrada_moneda <= "1110";
        wait for CLK_PERIOD * 4;
        
        entrada_moneda <= "0000";
        wait;
    end process;

end Behavioral;