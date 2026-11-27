-- Copyright (c) 2026 takeRu0x5569
-- This software is released under the MIT License.
---------------------------------------------------------------------
-- Document : 
-- Module   :エッジ検出
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity EDGE_DETECT is
    Port(
    i_CLK     :in  std_logic;
    i_RST_p   :in  std_logic;
    i_PORT    :in  std_logic;
    o_PORT    :out std_logic;
    o_RISE_p  :out std_logic;
    o_FALL_p  :out std_logic
    );
end entity;

architecture RTL of EDGE_DETECT is
    signal buf_ff :std_logic;
    signal rise   :std_logic;
    signal fall   :std_logic;
begin

--バッファFF
process(i_CLK,i_RST_p)begin
    if(i_RST_p='1')then
        buf_ff <= '0';
    elsif(rising_edge(i_CLK))then
        buf_ff <= i_PORT;
    end if;
end process;
--エッジ検出パルス：１サイクルHigh出力
rise   <= '1' when (i_PORT='1')and(buf_ff='0') else '0';
fall   <= '1' when (i_PORT='0')and(buf_ff='1') else '0';

--出力
o_PORT    <=buf_ff;
o_RISE_p  <=rise;
o_FALL_p  <=fall;

end architecture;
