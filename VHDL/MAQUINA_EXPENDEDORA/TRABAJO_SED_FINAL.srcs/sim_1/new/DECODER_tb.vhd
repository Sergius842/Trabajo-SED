----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.01.2026 17:53:09
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

    constant TAM_CODE_TB : POSITIVE := 5;
    constant NUM_SEGMENTOS_TB : POSITIVE := 7;

    signal code_entrada : std_logic_vector(TAM_CODE_TB - 1 downto 0) := (others => '0');
    signal segments_salida : std_logic_vector(NUM_SEGMENTOS_TB - 1 downto 0);

begin

    uut: DECODER
    generic map(
        TAM_CODE => TAM_CODE_TB,
        NUM_SEGMENTOS => NUM_SEGMENTOS_TB
    )
    port map(
        code_entrada => code_entrada,
        segments_salida => segments_salida
    );

    stim_proc: process
    begin
        code_entrada <= "00000";
        wait for 10 ns;

        code_entrada <= "00001";
        wait for 10 ns;

        code_entrada <= "00010";
        wait for 10 ns;

        code_entrada <= "01100";
        wait for 10 ns;

        code_entrada <= "11100";
        wait for 10 ns;

        code_entrada <= "10110";
        wait for 10 ns;

        code_entrada <= "11111";
        wait for 10 ns;

        wait;
    end process;

end Behavioral;
