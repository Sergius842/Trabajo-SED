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
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity EDGE_DETECTOR_tb is

end;

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
   
    
    constant NUM_MONEDAS  : positive := 4;
    constant CLOCK_PERIOD : time := 10 ns;

    signal clk            : std_logic := '0';
    signal entrada_moneda : std_logic_vector(NUM_MONEDAS - 1 downto 0) := (others => '0');
    signal flanco_monedas : std_logic_vector(NUM_MONEDAS - 1 downto 0);

begin

    uut: EDGE_DETECTOR 
        generic map ( 
            NUM_MONEDAS => NUM_MONEDAS 
        )
        port map ( 
            clk => clk,
            entrada_moneda => entrada_moneda,
            flanco_monedas => flanco_monedas 
        );
        
    p_clk: process
    begin
        clk <= '0';
        wait for 0.5 * CLOCK_PERIOD;
        clk <= '1';
        wait for 0.5 * CLOCK_PERIOD;
    end process;

    p_stimulus: process
    begin
        
        wait for 100 ns;
        wait until falling_edge(clk); 

        entrada_moneda <= "0001"; 
        
        wait until rising_edge(clk);
        wait for 1 ns; 
        
        assert flanco_monedas = "0001"
            report "ERROR: No se detectó la moneda en el flanco de subida" severity error;

        
        wait until rising_edge(clk);
        wait for 1 ns;
        
        assert flanco_monedas = "0000"
            report "ERROR: La salida sigue activa aunque la entrada no ha cambiado (debe ser un pulso)" severity error;

        
        entrada_moneda <= "0000"; 
        wait for CLOCK_PERIOD;
        
        entrada_moneda <= "1000"; 
        wait until rising_edge(clk);
        wait for 1 ns;

        assert flanco_monedas = "1000"
            report "ERROR: No se detectó la segunda moneda" severity error;

        assert false
            report "EXITO: Test de Detector de Flancos completado."
            severity failure;

        wait;
    end process;

end;
