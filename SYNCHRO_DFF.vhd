-- Copyright (c) 2026 takeRu0x5569
-- This software is released under the MIT License.
---------------------------------------------------------------------
-- Document : 
-- Module   :同期化DFF＆エッジ検出
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity SYNCHRO_DFF is
    Port(
    i_CLK     :in  std_logic;
    i_RST_p   :in  std_logic;
    i_PORT    :in  std_logic;
    o_SYNCHRO :out std_logic;
    o_RISE_p  :out std_logic;
    o_FALL_p  :out std_logic
    );
end entity;

architecture RTL of SYNCHRO_DFF is
    signal buf_ff :std_logic_vector(0 to 2);
    signal rise   :std_logic;
    signal fall   :std_logic;
begin

--入力同期化バッファFF
process(i_CLK,i_RST_p)begin
    if(i_RST_p='1')then
        buf_ff(0) <= '0';
        buf_ff(1) <= '0';
        buf_ff(2) <= '0';
    elsif(rising_edge(i_CLK))then
        buf_ff(0) <= i_PORT;
        buf_ff(1) <= buf_ff(0);
        buf_ff(2) <= buf_ff(1);
    end if;
end process;
--エッジ検出パルス：１サイクルHigh出力
rise   <= '1' when ((buf_ff(1)='1')and(buf_ff(2)='0')) else '0';
fall   <= '1' when ((buf_ff(1)='0')and(buf_ff(2)='1')) else '0';

--出力
o_SYNCHRO <=buf_ff(1);
o_RISE_p  <=rise;
o_FALL_p  <=fall;

end architecture;
