----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.12.2025 17:45:54
-- Design Name: 
-- Module Name: FSM_tb - Behavioral
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

entity FSM_tb is
end FSM_tb;

architecture Behavioral of FSM_tb is

    component FSM
        generic(
            NUM_REFRESCOS : POSITIVE := 2;
            NUM_ESTADOS   : POSITIVE := 4;
            NUM_DISPLAYS  : POSITIVE := 9;
            TAM_CODE      : POSITIVE := 5            
        );
        port( 
            clk             : in std_logic;
            reset           : in std_logic;
            btn_pagar       : in std_logic;
            ok_pago         : in std_logic;
            error_contador  : in std_logic;
            tipo_refrescos  : in std_logic_vector(NUM_REFRESCOS - 1 downto 0);
            bus_control_entrada  : in std_logic_vector(NUM_DISPLAYS * NUM_ESTADOS - 1 downto 0);
            bus_code_entrada     : in std_logic_vector(TAM_CODE * NUM_ESTADOS - 1 downto 0);
            led_error       : out std_logic;
            led_refresco    : out std_logic;
            estado_debug    : out std_logic_vector(NUM_ESTADOS - 1 downto 0);
            control_salida     : out std_logic_vector(NUM_DISPLAYS - 1 downto 0);
            code_salida        : out std_logic_vector(TAM_CODE - 1 downto 0)
        );
    end component;

    constant NUM_REFRESCOS : POSITIVE := 2;
    constant NUM_ESTADOS   : POSITIVE := 4;
    constant NUM_DISPLAYS  : POSITIVE := 9;
    constant TAM_CODE      : POSITIVE := 5;
    constant CLK_PERIOD    : time := 10 ns;

    signal clk             : std_logic := '0';
    signal reset           : std_logic := '0';
    signal btn_pagar       : std_logic := '0';
    signal ok_pago         : std_logic := '0';
    signal error_contador  : std_logic := '0';
    signal tipo_refrescos  : std_logic_vector(NUM_REFRESCOS - 1 downto 0) := (others => '0');
    signal bus_control_in  : std_logic_vector(NUM_DISPLAYS * NUM_ESTADOS - 1 downto 0) := (others => '0');
    signal bus_code_in     : std_logic_vector(TAM_CODE * NUM_ESTADOS - 1 downto 0) := (others => '0');

    signal led_error       : std_logic;
    signal led_refresco    : std_logic;
    signal estado_debug    : std_logic_vector(NUM_ESTADOS - 1 downto 0);
    signal control_salida  : std_logic_vector(NUM_DISPLAYS - 1 downto 0);
    signal code_salida     : std_logic_vector(TAM_CODE - 1 downto 0);

begin

    uut: FSM
        generic map (
            NUM_REFRESCOS => NUM_REFRESCOS,
            NUM_ESTADOS => NUM_ESTADOS,
            NUM_DISPLAYS => NUM_DISPLAYS,
            TAM_CODE => TAM_CODE
        )
        port map (
            clk => clk,
            reset => reset,
            btn_pagar => btn_pagar,
            ok_pago => ok_pago,
            error_contador => error_contador,
            tipo_refrescos => tipo_refrescos,
            bus_control_entrada => bus_control_in,
            bus_code_entrada => bus_code_in,
            led_error => led_error,
            led_refresco => led_refresco,
            estado_debug => estado_debug,
            control_salida => control_salida,
            code_salida => code_salida
        );

    p_clk: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    p_stim: process
    begin
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for CLK_PERIOD;

        assert estado_debug = "0001" report "Error: No inicio en Reposo" severity error;
        
        tipo_refrescos <= "01"; 
        btn_pagar <= '1';
        wait for CLK_PERIOD;
 
        wait for CLK_PERIOD; 
        assert estado_debug = "0010" report "Error: No paso a Check Funds" severity error;

        ok_pago <= '1';
        wait for CLK_PERIOD;

        wait for CLK_PERIOD;
        assert estado_debug = "0100" report "Error: No paso a Dispensing" severity error;
        assert led_refresco = '1' report "Error: Led refresco apagado" severity error;

        btn_pagar <= '0';
        ok_pago <= '0';
        wait for CLK_PERIOD;

        wait for CLK_PERIOD;
        assert estado_debug = "0001" report "Error: No volvio a Reposo" severity error;

        wait for CLK_PERIOD * 5;
        
        btn_pagar <= '1';
        tipo_refrescos <= "10";
        wait for CLK_PERIOD * 2; 
        
        error_contador <= '1';
        wait for CLK_PERIOD;

        wait for CLK_PERIOD;
        assert estado_debug = "1000" report "Error: No entro en Error" severity error;
        assert led_error = '1' report "Error: Led error apagado" severity error;

        btn_pagar <= '0';
        error_contador <= '0';
        wait for CLK_PERIOD;

        wait for CLK_PERIOD;
        assert estado_debug = "0001" report "Error: No recupero del Error" severity error;

        assert false report "Simulacion terminada correctamente" severity failure;
        wait;
    end process;

end Behavioral;
