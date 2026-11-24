-- Copyright (c) 2026 takeRu0x5569
-- This software is released under the MIT License.
---------------------------------------------------------------------
-- Document : 
-- Module   :LED Dimmer for On Board LEDs
---------------------------------------------------------------------
-- オンボードLEDの調光
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity LED_DIMMER is
generic(
    FULL_CYCLE    : integer := 50000;
    ON_CYCLE      : integer :=   500
);
port(
    i_CLK       : in  std_logic;
    i_RST_p     : in  std_logic;
    o_LED_PWM   : out std_logic
);
end entity;

architecture RTL of LED_DIMMER is
    signal led_counter    :integer range 0 to FULL_CYCLE-1;
    signal base_pwm       :std_logic;
begin
process(i_CLK,i_RST_p) begin
    if(i_RST_p = '1') then
        led_counter <= 0;
        base_pwm   <= '0';
    elsif rising_edge(i_CLK) then
        if(led_counter = FULL_CYCLE) then
            led_counter <= 0;
        else
            led_counter <= led_counter + 1;
        end if;

        if(led_counter = FULL_CYCLE) then
            base_pwm <= '1';
        elsif(led_counter = ON_CYCLE) then
            base_pwm <= '0';
        end if;
    end if;
end process;
o_LED_PWM <= base_pwm;
end architecture;