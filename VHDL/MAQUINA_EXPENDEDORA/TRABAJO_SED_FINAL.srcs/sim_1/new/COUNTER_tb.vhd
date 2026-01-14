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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity COUNTER_tb is
end COUNTER_tb;

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
        rst_fsm: in std_logic;      
        
        moneda: in std_logic_vector(NUM_MONEDAS - 1 downto 0);
        tipo_refrescos: in std_logic_vector(NUM_REFRESCOS - 1 downto 0);
        error: out std_logic;
        ok_pago: out std_logic;
        cuenta: out std_logic_vector(TAM_CUENTA - 1 downto 0);
        
        cambio_es_cero: out std_logic;
        cambio: out std_logic_vector(TAM_CUENTA - 1 downto 0); 
        precio: out std_logic_vector(NUM_REFRESCOS * TAM_CUENTA - 1 downto 0);
        actual_refresco: out std_logic_vector(NUM_REFRESCOS - 1 downto 0)
    );
    end component;

    constant NUM_MONEDAS_TB : positive := 4;
    constant NUM_REFRESCOS_TB : positive := 2;
    constant TAM_CUENTA_TB : positive := 5;
    constant CLK_PERIOD : time := 10 ns;

    signal clk : std_logic := '0';
    signal ce : std_logic := '0';
    signal reset : std_logic := '0';
    signal rst_fsm : std_logic := '0';
    signal moneda : std_logic_vector(NUM_MONEDAS_TB - 1 downto 0) := (others => '0');
    signal tipo_refrescos : std_logic_vector(NUM_REFRESCOS_TB - 1 downto 0) := (others => '0');

    signal error : std_logic;
    signal ok_pago : std_logic;
    signal cuenta : std_logic_vector(TAM_CUENTA_TB - 1 downto 0);
    signal cambio_es_cero : std_logic;
    signal cambio : std_logic_vector(TAM_CUENTA_TB - 1 downto 0);
    signal precio : std_logic_vector(NUM_REFRESCOS_TB * TAM_CUENTA_TB - 1 downto 0);
    signal actual_refresco : std_logic_vector(NUM_REFRESCOS_TB - 1 downto 0);

begin

    uut: COUNTER
    generic map (
        NUM_MONEDAS => NUM_MONEDAS_TB,
        NUM_REFRESCOS => NUM_REFRESCOS_TB,
        TAM_CUENTA => TAM_CUENTA_TB
    )
    port map (
        clk => clk,
        ce => ce,
        reset => reset,
        rst_fsm => rst_fsm,
        moneda => moneda,
        tipo_refrescos => tipo_refrescos,
        error => error,
        ok_pago => ok_pago,
        cuenta => cuenta,
        cambio_es_cero => cambio_es_cero,
        cambio => cambio,
        precio => precio,
        actual_refresco => actual_refresco
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
        reset <= '0';
        ce <= '0';
        moneda <= (others => '0');
        tipo_refrescos <= (others => '0');
        wait for 100 ns;

        reset <= '1';
        ce <= '1';
        wait for CLK_PERIOD;

        tipo_refrescos <= "01";
        wait for CLK_PERIOD;

        moneda <= "1000"; 
        wait for CLK_PERIOD;
        moneda <= "0000"; 
        
        wait for CLK_PERIOD * 3;
        
        rst_fsm <= '1';
        wait for CLK_PERIOD;
        rst_fsm <= '0';
        tipo_refrescos <= "00";
        wait for CLK_PERIOD * 2;

        tipo_refrescos <= "10";
        wait for CLK_PERIOD;

        moneda <= "1000";
        wait for CLK_PERIOD;
        moneda <= "0000";
        wait for CLK_PERIOD * 2;

        moneda <= "0100";
        wait for CLK_PERIOD;
        moneda <= "0000";
        wait for CLK_PERIOD * 2;

        wait;
    end process;

end Behavioral;