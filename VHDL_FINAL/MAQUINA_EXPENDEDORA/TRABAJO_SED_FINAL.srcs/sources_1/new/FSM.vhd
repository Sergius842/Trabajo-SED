----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.12.2025 11:48:28
-- Design Name: 
-- Module Name: FSM - Behavioral
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

entity FSM is
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
       
        
        cambio_es_cero  : in std_logic; 
        
        tipo_refrescos  : in std_logic_vector(NUM_REFRESCOS - 1 downto 0);
        bus_control_entrada  : in std_logic_vector(NUM_DISPLAYS * NUM_ESTADOS - 1 downto 0);
        bus_code_entrada     : in std_logic_vector(TAM_CODE * NUM_ESTADOS - 1 downto 0);

     
        led_refresco    : out std_logic;
        cmd_reset       : out std_logic; 
        estado_debug    : out std_logic_vector(NUM_ESTADOS - 1 downto 0);
        control_salida     : out std_logic_vector(NUM_DISPLAYS - 1 downto 0);
        code_salida        : out std_logic_vector(TAM_CODE - 1 downto 0)
    );
end FSM;

architecture Behavioral of FSM is
    
    type t_state is (ST_IDLE, ST_CHECK_FUNDS, ST_DISPENSING, ST_SHOW_CHANGE);
    signal current_state, next_state : t_state;

    constant IDX_IDLE     : integer := 0;
    constant IDX_CHECK    : integer := 1;
    constant IDX_DISPENSE : integer := 2;
    constant IDX_CHANGE   : integer := 3; 
    -- ELIMINADO IDX_ERROR

    constant TIEMPO_ESPERA : integer := 200000000; 
    signal timer_counter : integer range 0 to TIEMPO_ESPERA := 0;
    signal timer_done : std_logic := '0';

begin
    p_state_reg: process(reset, clk)
    begin
        if reset = '0' then 
            current_state <= ST_IDLE;
            timer_counter <= 0;
        elsif rising_edge(clk) then
            current_state <= next_state;
            
            if current_state /= next_state then
                timer_counter <= 0;
            elsif (current_state = ST_DISPENSING or current_state = ST_SHOW_CHANGE) then
                if timer_counter < TIEMPO_ESPERA then
                    timer_counter <= timer_counter + 1;
                end if;
            else
                timer_counter <= 0;
            end if;
        end if;
    end process;

    timer_done <= '1' when (timer_counter = TIEMPO_ESPERA) else '0';

    p_comb: process(current_state, btn_pagar, ok_pago, cambio_es_cero, tipo_refrescos, bus_control_entrada, bus_code_entrada, timer_done)
        variable v_mux_sel : integer range 0 to 3; 
    begin
        next_state <= current_state;
        led_refresco <= '0';
        cmd_reset <= '0'; 
        estado_debug <= "0000"; 
        v_mux_sel := 0;

        case current_state is 
            when ST_IDLE =>
                estado_debug <= "0001";
                v_mux_sel := IDX_IDLE;
                if btn_pagar = '1' and tipo_refrescos /= "00" then
                    next_state <= ST_CHECK_FUNDS;
                end if;

            when ST_CHECK_FUNDS =>
                estado_debug <= "0010";
                v_mux_sel := IDX_CHECK;
                if ok_pago = '1' then
                    next_state <= ST_DISPENSING; 
                
                end if;

            when ST_DISPENSING =>
                estado_debug <= "0100";
                led_refresco <= '1'; 
                v_mux_sel := IDX_DISPENSE; 
                
                if timer_done = '1' then
                    if cambio_es_cero = '1' then
                        cmd_reset <= '1'; 
                        next_state <= ST_IDLE;
                    else
                        next_state <= ST_SHOW_CHANGE;
                    end if;
                end if;

            when ST_SHOW_CHANGE =>
                estado_debug <= "1000";
                led_refresco <= '0'; 
                v_mux_sel := IDX_CHANGE; 
                
                if timer_done = '1' then
                    cmd_reset <= '1'; 
                    next_state <= ST_IDLE;
                end if;
        end case;
        
        control_salida <= bus_control_entrada( (NUM_DISPLAYS * (v_mux_sel + 1)) - 1 downto (NUM_DISPLAYS * v_mux_sel) );
        code_salida    <= bus_code_entrada(    (TAM_CODE     * (v_mux_sel + 1)) - 1 downto (TAM_CODE     * v_mux_sel) );
    end process;
end Behavioral;