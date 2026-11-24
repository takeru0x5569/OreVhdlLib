-- Copyright (c) 2026 takeRu0x5569
-- This software is released under the MIT License.
---------------------------------------------------------------------
-- Document : 
-- Module   :Clock Divider
---------------------------------------------------------------------
-- 固定周期のClock enable を出力する分周器
library ieee;
use ieee.std_logic_1164.all;

entity CLOCK_DIVIDER is
generic(
    DIVIDE_CYCLE :integer := 10
    );
Port(
    i_CLK       :in  std_logic;
    i_RST_p     :in  std_logic;
    o_CLK_ENA_p :out std_logic --Clock enable
    );
end entity;

architecture RTL of CLOCK_DIVIDER is
    signal counter      :integer range 0 to DIVIDE_CYCLE:=0;
    signal count_end    :std_logic;
    signal clock_ena_p  :std_logic;
begin ---------------------------------------------------------------------
count_end <= '1' when counter=DIVIDE_CYCLE-1 else '0';
-- 分周カウンタ
process(i_CLK,i_RST_p)begin
    if(i_RST_p='1')then
        counter <=0;
    elsif(rising_edge(i_CLK))then
        if(count_end='0') then
            counter <= counter+1;
        else
            counter <= 0;
        end if;
    end if;
end process;
-- Clock enable FF
process(i_CLK,i_RST_p)begin
    if(i_RST_p='1')then
        clock_ena_p <= '0';
    elsif(rising_edge(i_CLK))then
        clock_ena_p <= count_end;
    end if;
end process;
--出力
o_CLK_ENA_p <= clock_ena_p;

end architecture;
