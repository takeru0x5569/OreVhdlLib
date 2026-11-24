-- Copyright (c) 2026 takeRu0x5569
-- This software is released under the MIT License.
---------------------------------------------------------------------
-- Document :https://qiita.com/takeru0x5569/items/85e4e44bdb21d4aa1344
-- Module   :パルス伸張(規定パルス幅以上に引き延ばすモジュール)
---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PULSE_EXTENDER is
    generic(
    EXTEND_CYCLE    :integer := 9
    );    
    port (
    i_CLK           :in  std_logic;
    i_RST_p         :in  std_logic;
    i_SOURCE_PULSE_p:in  std_logic;
    o_EXTEND_PULSE_p:out std_logic
    );
end entity;

architecture RTL of PULSE_EXTENDER is
    --constant COUNT_FULL :integer := EXTEND_CYCLE;
    signal pulse_count  :integer range 0 to EXTEND_CYCLE;
    signal pulse_ext    :std_logic;
begin

process(i_CLK,i_RST_p)begin
    if(i_RST_p='1')then
        pulse_count <= 0;
        pulse_ext   <= '0';
    elsif(rising_edge(i_CLK))then
        if(i_SOURCE_PULSE_p='1')then
            pulse_count <= EXTEND_CYCLE;
            pulse_ext   <= '1';
        else
            if(pulse_count = 0)then
                pulse_count <= 0;
                pulse_ext   <= '0';
            else
                pulse_count <= pulse_count - 1;
                pulse_ext   <= '1';
            end if;
        end if;
    end if;
end process;

end architecture;
