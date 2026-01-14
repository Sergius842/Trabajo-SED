----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.12.2025 15:45:53
-- Design Name: 
-- Module Name: MAQUINA_EXP - Structural
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

entity MAQUINA_EXP is
    Generic(
    NUM_MONEDA: positive:= 4;
    NUM_REFRESCO: positive:= 2;
    NUM_ESTADOS: positive:= 4; 
    NUM_SEGMENTOS: positive:= 7;
    NUM_DISPLAYS: positive:= 9;
    PRESCALER_DIV:  positive := 18;
    TAM_CUENTA: positive := 5;
    TAM_CODE: positive := 5
    );
    
    Port (
    CLK: in std_logic;
    RESET: in std_logic;
    PAGO: in std_logic;
    TIPO_MONEDA: in std_logic_vector(NUM_MONEDA - 1 DOWNTO 0);
    TIPO_REFRESCO: in std_logic_vector(NUM_REFRESCO - 1 DOWNTO 0);
    PRODUCTO_OK: out std_logic;
    ESTADOS: out std_logic_vector(NUM_ESTADOS - 1 DOWNTO 0);
    SEGMENTOS: out std_logic_vector(NUM_SEGMENTOS - 1 DOWNTO 0);
    DIGCTRL: out std_logic_vector(NUM_DISPLAYS - 1 DOWNTO 0)
    );
end MAQUINA_EXP;

architecture Structural of MAQUINA_EXP is

component SYNCHRONIZER is
    Generic(
    NUM_REFRESCOS: POSITIVE;
    NUM_MONEDAS: POSITIVE
    );
    
    Port(
    clk: in std_logic;
    rst: in std_logic;
    asinc_pago: in std_logic;
    asinc_monedas: in std_logic_vector;
    asinc_refresco: in std_logic_vector;
    sinc_pago: out std_logic;
    sinc_monedas: out std_logic_vector;
    sinc_refresco: out std_logic_vector
    );
end component;

component EDGE_DETECTOR is 
    Generic(
    NUM_MONEDAS: positive:= 4
    );
    
    Port(
    clk: in std_logic;
    entrada_moneda: in std_logic_vector;
    flanco_monedas: out std_logic_vector
    );
end component;
    
component COUNTER is
    Generic( 
    NUM_MONEDAS: positive;
    NUM_REFRESCOS: positive;
    TAM_CUENTA: positive
    );
    
    Port(
    clk: in std_logic; 
    ce: in std_logic; 
    reset: in std_logic; 
    rst_fsm: in std_logic; 
    moneda: in std_logic_vector; 
    tipo_refrescos: in std_logic_vector;
    error: out std_logic; 
    ok_pago: out std_logic; 
    cuenta: out std_logic_vector;
    cambio_es_cero: out std_logic; 
    cambio: out std_logic_vector; 
    precio: out std_logic_vector; 
    actual_refresco: out std_logic_vector
    );
end component;

component PRESCALER is
    generic(
    PRESCALER_DIV: positive
    );
    
    port(
    clk: in std_logic; 
    clk_salida: out std_logic
    );
end component;

component DISPLAY_CONTROL is
    Generic(
    TAM_CUENTA: positive; 
    NUM_REFRESCOS: positive; 
    TAM_CODE: positive; 
    NUM_ESTADOS: positive; 
    NUM_DISPLAYS: positive
    );
    
    Port(
    clk : in std_logic; 
    cuenta : in std_logic_vector; 
    tipo_refrescos: in std_logic_vector; 
    precio: in std_logic_vector; 
    cambio: in std_logic_vector; 
    code_salida : out std_logic_vector; 
    control_salida : out std_logic_vector
    );
end component;

component FSM is
    Generic(
    NUM_REFRESCOS: positive; 
    NUM_ESTADOS: positive; 
    NUM_DISPLAYS: positive; 
    TAM_CODE: positive 
    );
    
    Port( 
    clk: in std_logic; 
    reset: in std_logic; 
    btn_pagar: in std_logic; 
    ok_pago: in std_logic; 
    cambio_es_cero: in std_logic; 
    tipo_refrescos: in std_logic_vector; 
    bus_control_entrada: in std_logic_vector; 
    bus_code_entrada: in std_logic_vector;
    led_refresco: out std_logic; 
    cmd_reset: out std_logic; 
    estado_debug: out std_logic_vector; 
    control_salida: out std_logic_vector; 
    code_salida: out std_logic_vector
    );
end component;

component DECODER is
    Generic(
    TAM_CODE: positive; 
    NUM_SEGMENTOS: positive
    );
    
    Port(
    code_entrada: in std_logic_vector; 
    segments_salida : out std_logic_vector
    );
end component;

signal AUX1: std_logic;
signal AUX2: std_logic_vector(NUM_MONEDA - 1 DOWNTO 0);
signal AUX3: std_logic_vector(NUM_REFRESCO - 1 DOWNTO 0);
signal AUX4: std_logic_vector(NUM_MONEDA - 1 DOWNTO 0);
signal AUX5: std_logic;
signal AUX6: std_logic_vector(NUM_REFRESCO * TAM_CUENTA - 1 DOWNTO 0);
signal AUX7: std_logic; 
signal AUX8: std_logic_vector(TAM_CUENTA - 1 DOWNTO 0);
signal AUX9: std_logic_vector(NUM_REFRESCO - 1 DOWNTO 0);
signal AUX10: std_logic_vector(TAM_CODE * NUM_ESTADOS - 1 DOWNTO 0);
signal AUX11: std_logic_vector(NUM_DISPLAYS * NUM_ESTADOS - 1 DOWNTO 0);
signal AUX12: std_logic_vector(TAM_CODE - 1 DOWNTO 0);
signal AUX13: std_logic;
signal AUX14: std_logic_vector(TAM_CUENTA - 1 DOWNTO 0); 
signal AUX15: std_logic; 
signal AUX_CLK: std_logic;

begin

SYNC: SYNCHRONIZER 
    GENERIC MAP(
    NUM_REFRESCOS => NUM_REFRESCO, 
    NUM_MONEDAS => NUM_MONEDA)
    
    PORT MAP(
    clk => CLK, 
    rst => RESET, 
    asinc_pago => PAGO, 
    asinc_monedas => TIPO_MONEDA, 
    asinc_refresco => TIPO_REFRESCO, 
    sinc_pago => AUX1, 
    sinc_monedas => AUX2, 
    sinc_refresco => AUX3
    );
    
EDGE: EDGE_DETECTOR 
    GENERIC MAP(
    NUM_MONEDAS => NUM_MONEDA)
    
    PORT MAP(
    clk => CLK, 
    entrada_moneda => AUX2, 
    flanco_monedas => AUX4
    );

CTR: COUNTER 
    GENERIC MAP(
    NUM_MONEDAS => NUM_MONEDA, 
    TAM_CUENTA => TAM_CUENTA, 
    NUM_REFRESCOS => NUM_REFRESCO)
    
    PORT MAP( 
    clk => CLK, 
    ce => '1', 
    reset => RESET, 
    rst_fsm => AUX13, 
    tipo_refrescos => AUX3, 
    moneda => AUX2, 
    ok_pago => AUX5, 
    precio => AUX6, 
    error => AUX7, 
    cuenta => AUX8, 
    cambio_es_cero => AUX15, 
    cambio => AUX14, 
    actual_refresco => AUX9 
    );

PRESC: PRESCALER
    GENERIC MAP(
    PRESCALER_DIV => PRESCALER_DIV)
    
    PORT MAP(
    clk => CLK, 
    clk_salida => AUX_CLK
    );

CONTROL: DISPLAY_CONTROL 
    GENERIC MAP(
    TAM_CUENTA => TAM_CUENTA, 
    NUM_REFRESCOS => NUM_REFRESCO, 
    NUM_ESTADOS => NUM_ESTADOS, 
    TAM_CODE => TAM_CODE, 
    NUM_DISPLAYS => NUM_DISPLAYS)
    
    PORT MAP(
    cuenta => AUX8, 
    tipo_refrescos => AUX9, 
    precio => AUX6, 
    cambio => AUX14, 
    clk => AUX_CLK, 
    code_salida => AUX10, 
    control_salida => AUX11
    );
    
MAQ_ESTADOS: FSM
    GENERIC MAP( 
    NUM_REFRESCOS => NUM_REFRESCO, 
    NUM_ESTADOS => NUM_ESTADOS, 
    NUM_DISPLAYS => NUM_DISPLAYS, 
    TAM_CODE => TAM_CODE)
    
    PORT MAP( 
    clk => CLK, 
    reset => RESET, btn_pagar => AUX1, ok_pago => AUX5, 

    cambio_es_cero => AUX15, 
    tipo_refrescos => AUX9, 
    bus_code_entrada => AUX10, 
    bus_control_entrada => AUX11, 
        
    led_refresco => PRODUCTO_OK, 
    cmd_reset => AUX13, 
    estado_debug => ESTADOS, 
    control_salida => DIGCTRL, 
    code_salida => AUX12 
    );

DECODE: DECODER 
    GENERIC MAP(
    TAM_CODE => TAM_CODE, 
    NUM_SEGMENTOS => NUM_SEGMENTOS)
    
    PORT MAP(
    code_entrada => AUX12, 
    segments_salida => SEGMENTOS
    );

end Structural;