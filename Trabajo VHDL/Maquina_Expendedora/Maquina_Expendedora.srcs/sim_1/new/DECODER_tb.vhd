----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.12.2025 17:43:56
-- Design Name: 
-- Module Name: DECODER_tb - Behavioral
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

entity DECODER_tb is
end DECODER_tb;

architecture Behavioral of DECODER_tb is

    component DECODER
        generic(
            TAM_CODE      : POSITIVE := 5;
            NUM_SEGMENTOS : POSITIVE := 7       
        );
        port(
            code_entrada    : in std_logic_vector(TAM_CODE - 1 downto 0);
            segments_salida : out std_logic_vector(NUM_SEGMENTOS - 1 downto 0)
        );
    end component;

    constant TAM_CODE      : positive := 5;
    constant NUM_SEGMENTOS : positive := 7;
    
    signal code_entrada    : std_logic_vector(TAM_CODE - 1 downto 0) := (others => '0');
    signal segments_salida : std_logic_vector(NUM_SEGMENTOS - 1 downto 0);
    
begin

    uut: DECODER
        generic map (
            TAM_CODE => TAM_CODE,
            NUM_SEGMENTOS => NUM_SEGMENTOS
        )
        port map (
            code_entrada    => code_entrada,
            segments_salida => segments_salida
        );

    stim_proc: process
    begin
        wait for 50 ns;
        
        code_entrada <= "00000"; 
        wait for 10 ns;
        assert segments_salida = "0000001" report "Error en 0" severity error;
        
        code_entrada <= "00001"; 
        wait for 10 ns;
        assert segments_salida = "1001111" report "Error en 1" severity error;

        code_entrada <= "10000"; 
        wait for 10 ns;
        assert segments_salida = "0001000" report "Error en A" severity error;

        code_entrada <= "10011"; 
        wait for 10 ns;
        assert segments_salida = "0111000" report "Error en F" severity error;

        code_entrada <= "11111"; 
        wait for 10 ns;
        assert segments_salida = "1111110" report "Error en Others" severity error;

        assert false report "Simulacion terminada correctamente" severity failure;
        wait;
    end process;

end Behavioral;