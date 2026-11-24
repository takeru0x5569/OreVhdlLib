-- Copyright (c) 2026 takeRu0x5569
-- This software is released under the MIT License.
---------------------------------------------------------------------
-- Document : 
-- Module   :エンコーダ検出器
---------------------------------------------------------------------
--90度位相差A相B相インクリメンタルエンコーダーのUP/DOWNタイミング検出
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity ENCODER_DETECTOR is 
    port(
    i_CLK           :in  std_logic;
    i_RST_p         :in  std_logic;
    i_ENCODER_A     :in  std_logic;--エンコーダA相/B相入力
    i_ENCODER_B     :in  std_logic;--エンコーダA相/B相入力
    o_UP_p          :out std_logic;--カウントアップ
    o_DOWN_p        :out std_logic--カウントダウン
    );
end entity;

architecture RTL of ENCODER_DETECTOR is
    signal enc_ab          :std_logic_vector(0 to 1);
    signal rise_p          :std_logic_vector(0 to 1);
    signal fall_p          :std_logic_vector(0 to 1);
    signal enc_sync        :std_logic_vector(0 to 1);
    signal encoder_up      :std_logic_vector(0 to 3);
    signal encoder_down    :std_logic_vector(0 to 3);
    signal encoder_up_or   :std_logic;
    signal encoder_down_or :std_logic;
begin
enc_ab(0) <= i_ENCODER_A;
enc_ab(1) <= i_ENCODER_B;
---------------------------------------
--エッジ検出
---------------------------------------
GEN_ENC_EDGE: for i in 0 to 1 generate
u_EDGE_DETECT:entity work.EDGE_DETECT
    port map
    (i_CLK     =>i_CLK
    ,i_RST_p   =>i_RST_p
    ,i_PORT    =>enc_ab(i)
    ,o_PORT    =>enc_sync(i)
    ,o_RISE_p  =>rise_p(i)
    ,o_FALL_p  =>fall_p(i)
    );
end generate;
---------------------------------------
--UpDown方向判定
---------------------------------------
-- Up方向
-- A____________↑~~~~~~~~~~~~~~~↓_______________↑~~~~~~~~~~~~~~~↓___________
-- B:___________________↑~~~~~~~~~~~~~~↓_______________↑~~~~~~~~~~~~~~~↓_____
    encoder_up(0)<='1'when((rise_p(0)='1')and(enc_sync(1)='0'))else '0';
    encoder_up(1)<='1'when((rise_p(1)='1')and(enc_sync(0)='1'))else '0';
    encoder_up(2)<='1'when((fall_p(0)='1')and(enc_sync(1)='1'))else '0';
    encoder_up(3)<='1'when((fall_p(1)='1')and(enc_sync(0)='0'))else '0';
    encoder_up_or   <=encoder_up(0) or encoder_up(1) or encoder_up(2) or encoder_up(3);
-- Down方向
-- A:___________________↑~~~~~~~~~~~~~~↓_______________↓~~~~~~~~~~~~~~~↑_____
-- B:___________↑~~~~~~~~~~~~~~~↓_______________↑~~~~~~~~~~~~~~~↓____________
    encoder_down(0)<='1'when((rise_p(1)='1')and(enc_sync(0)='0'))else '0';
    encoder_down(1)<='1'when((rise_p(0)='1')and(enc_sync(1)='1'))else '0';
    encoder_down(2)<='1'when((fall_p(1)='1')and(enc_sync(0)='1'))else '0';
    encoder_down(3)<='1'when((fall_p(0)='1')and(enc_sync(1)='0'))else '0';
    encoder_down_or <=encoder_down(0)or encoder_down(1) or encoder_down(2)or encoder_down(3);
-- 出力
o_UP_p      <=encoder_up_or;
o_DOWN_p    <=encoder_down_or;
end architecture;