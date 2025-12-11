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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MAQUINA_EXP is
  generic(
  NUM_MONEDA: positive:=4;
  NUM_REFRESCO: positive:=2;
  NUM_ESTADOS: positive:=4;
  NUM_SEGMENTOS: positive:=7;
  NUM_DISPLAYS: positive:=9
  );
  Port ( 
  CLK: in std_logic;
  RESET: in std_logic;
  PAGO: in std_logic;
  TIPO_MONEDA: in std_logic_vector(NUM_MONEDA - 1 DOWNTO 0);
  TIPO_REFRESCO: in std_logic_vector(NUM_REFRESCO - 1 DOWNTO 0);
  ERROR: out std_logic;
  PRODUCTO_OK: out std_logic;
  ESTADOS: out std_logic_vector(NUM_ESTADOS - 1 DOWNTO 0);
  SEGMENTOS: out std_logic_vector(NUM_SEGMENTOS - 1 DOWNTO 0);
  DIGCTRL: out std_logic_vector(NUM_DISPLAYS - 1 DOWNTO 0)
  );
end MAQUINA_EXP;

architecture Structural of MAQUINA_EXP is

begin


end Structural;
