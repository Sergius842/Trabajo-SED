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
end FSM;

architecture Behavioral of FSM is

    type t_state is (ST_IDLE, ST_CHECK_FUNDS, ST_DISPENSING, ST_ERROR);
    signal current_state, next_state : t_state;

    constant IDX_IDLE     : integer := 0;
    constant IDX_CHECK    : integer := 1;
    constant IDX_DISPENSE : integer := 2;
    constant IDX_ERROR    : integer := 3;

begin

    p_state_reg: process(reset, clk)
    begin
        if reset = '0' then
            current_state <= ST_IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    p_comb: process(current_state, btn_pagar, ok_pago, error_contador, tipo_refrescos, bus_control_entrada, bus_code_entrada)
        variable v_mux_sel : integer range 0 to 3;
    begin

        next_state <= current_state;
        led_error <= '0';
        led_refresco <= '0';
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
                elsif error_contador = '1' then
                    next_state <= ST_ERROR; 
                end if;

            when ST_DISPENSING =>
                estado_debug <= "0100";
                led_refresco <= '1';
                v_mux_sel := IDX_DISPENSE;

                if btn_pagar = '0' then
                    next_state <= ST_IDLE;
                end if;

            when ST_ERROR =>
                estado_debug <= "1000";
                led_error <= '1';
                v_mux_sel := IDX_ERROR;

                if btn_pagar = '0' then
                    next_state <= ST_IDLE;
                end if;
                
        end case;
        
        control_salida <= bus_control_entrada( (NUM_DISPLAYS * (v_mux_sel + 1)) - 1 downto (NUM_DISPLAYS * v_mux_sel) );
        code_salida    <= bus_code_entrada(    (TAM_CODE     * (v_mux_sel + 1)) - 1 downto (TAM_CODE     * v_mux_sel) );

    end process;

end Behavioral;