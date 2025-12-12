----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.12.2025 13:01:04
-- Design Name: 
-- Module Name: COUNTER_tb - Behavioral
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

entity COUNTER_tb is
end;

architecture Behavioral of COUNTER_tb is

    
    component COUNTER 
        generic(
            NUM_MONEDAS: positive:= 4;
            NUM_REFRESCOS: positive:= 2;
            TAM_CUENTA: positive:= 5       
        );
        port(
            clk: in std_logic;
            ce: in std_logic;
            reset: in std_logic;
            
            moneda: in std_logic_vector(NUM_MONEDAS - 1 downto 0);
            tipo_refrescos: in std_logic_vector(NUM_REFRESCOS - 1 downto 0);
            error: out std_logic;
            ok_pago: out std_logic;
            cuenta: out std_logic_vector(TAM_CUENTA - 1 downto 0);
            precio: out std_logic_vector(NUM_REFRESCOS * TAM_CUENTA - 1 downto 0);
            actual_refresco: out std_logic_vector(NUM_REFRESCOS - 1 downto 0)
        );
    end component;

    
    constant NUM_MONEDAS   : positive := 4;
    constant NUM_REFRESCOS : positive := 2;
    constant TAM_CUENTA    : positive := 5; 
    constant CLOCK_PERIOD  : time := 10 ns;
    
   
    signal clk             : std_logic := '0';
    signal ce              : std_logic := '0';
    signal reset           : std_logic := '0';
    signal moneda          : std_logic_vector(NUM_MONEDAS - 1 downto 0) := (others => '0');
    signal tipo_refrescos  : std_logic_vector(NUM_REFRESCOS - 1 downto 0) := (others => '0');
    
    -- Salidas
    signal actual_refresco : std_logic_vector(NUM_REFRESCOS - 1 downto 0);
    signal error           : std_logic;
    signal ok_pago         : std_logic;
    signal cuenta          : std_logic_vector(TAM_CUENTA - 1 downto 0);
    signal precio          : std_logic_vector(NUM_REFRESCOS * TAM_CUENTA - 1 downto 0);

begin

    
    UUT: COUNTER 
        generic map(
            NUM_MONEDAS   => NUM_MONEDAS,
            NUM_REFRESCOS => NUM_REFRESCOS,
            TAM_CUENTA    => TAM_CUENTA
        )
        port map( 
            clk             => clk,
            ce              => ce,
            reset           => reset,
            moneda          => moneda,          
            tipo_refrescos  => tipo_refrescos,  
            error           => error,
            ok_pago         => ok_pago,         
            cuenta          => cuenta,
            precio          => precio,          
            actual_refresco => actual_refresco  
        );

   
    CLK_PROCESS: process
    begin
        clk <= '0';
        wait for 0.5 * CLOCK_PERIOD;
        clk <= '1';
        wait for 0.5 * CLOCK_PERIOD;
    end process;
    
    
    STIMULUS: process
    begin
        
        reset <= '1';
        ce <= '0';
        wait for 100 ns;
        
        reset <= '0';
        ce <= '1'; 
        
        
        tipo_refrescos <= "01"; 
        wait for CLOCK_PERIOD;
        
        
        moneda <= "0100"; 
        wait for CLOCK_PERIOD;
        moneda <= "0100"; 
        wait for CLOCK_PERIOD;
        moneda <= "0000"; 
        
        wait for CLOCK_PERIOD;
        
        
        assert ok_pago = '1' report "FALLO: El pago exacto no dio OK" severity error;
        assert error = '0'   report "FALLO: El pago exacto dio Error" severity error;
        
        reset <= '1';
        wait for CLOCK_PERIOD * 2;
        reset <= '0';
        
        tipo_refrescos <= "10"; 
        wait for CLOCK_PERIOD;
        
        
        
        moneda <= "1000"; 
        wait for CLOCK_PERIOD;
        moneda <= "0100"; 
        wait for CLOCK_PERIOD;
        moneda <= "0000";
        
        wait for CLOCK_PERIOD;
        
        assert ok_pago = '1' 
            report "FALLO CRITICO: El sistema no aceptó el sobrepago (debería funcionar en tu versión nueva)" 
            severity error;
            
        assert error = '0' 
            report "FALLO CRITICO: Saltó ERROR aunque hay dinero suficiente" 
            severity error;

        assert false
            report "EXITO: Simulación completada. Puertos correctos y lógica verificada."
            severity failure;

        wait;
    end process;
end Behavioral;