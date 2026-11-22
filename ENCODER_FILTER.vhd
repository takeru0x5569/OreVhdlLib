-- Copyright (c) 2026 takeRu0x5569
-- This software is released under the MIT License.
---------------------------------------------------------------------
-- エンコーダ信号のグリッジ除去フィルタ
-- クロックは50MHz(20ns)
-- Encoderの最高周波数は4MHz(250ns)なので12.5サイクルで90度分は3サイクルしかないので、
-- 1サイクルグリッジだけ除去する
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ENCODER_FILTER is
    port(
    i_CLK           :in  std_logic;--50MHz
    i_RST_p         :in  std_logic;
    i_ENC_PULSE     :in  std_logic;
    o_ENC_PULSE     :out std_logic
    );
end entity;

architecture RTL of ENCODER_FILTER is
    signal buf_ff  :std_logic_vector(0 to 2); --入力同期化バッファFF
    signal dout    :std_logic;
begin----------------------------------------------------
process(i_CLK) begin
    if(i_RST_p='1') then
        buf_ff <= (others=>i_ENC_PULSE);
    elsif( rising_edge( i_CLK) ) then
        buf_ff(0) <=i_ENC_PULSE;
        buf_ff(1) <=buf_ff(0);
        buf_ff(2) <=buf_ff(1);
    end if;
end process;
--マスクカウンタ
process(i_CLK,i_RST_p) begin
    if(i_RST_p='1') then
        dout  <= i_ENC_PULSE;
    elsif( rising_edge( i_CLK) ) then
        if(buf_ff(1 to 2) = "11") then
            dout  <='1';
        elsif(buf_ff(1 to 2) = "00") then
            dout  <='0';
        end if;
    end if;
end process;
    
o_ENC_PULSE <= dout;
end RTL;
