-- Copyright (c) 2026 takeRu0x5569
-- This software is released under the MIT License.
---------------------------------------------------------------------
-- Document : https://qiita.com/takeru0x5569/items/66e14410f9c79c127f8a
---------------------------------------------------------------------
-- 指定回数定周期トリガ生成
-- 開始アサート
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity BURST_FIX_TRG_GEN is
    generic(
    TICK_CYCLE      :integer :=10;  --Trigger period by clock cycle(クロックサイクル数)
    BURST_COUNT     :integer :=5    --トリガが出てくる回数
    );
    port(
    i_CLK           :in  std_logic;
    i_RST_p         :in  std_logic;
    i_START_p       :in  std_logic;--Start trigger (1shot)
    o_BUSY_h        :out std_logic;--
    o_TICK_TRG_p    :out std_logic;--TICK周期で出てくるトリガ(1clock幅)
    o_FINISH_p      :out std_logic --Finish trigger(1shot)
    );
end entity;

architecture RTL of BURST_FIX_TRG_GEN is
    signal   seq_enable      :std_logic;--動作中フラグ
    signal   seq_finish      :std_logic;--シーケンス終了
    signal   tick_counter    :integer range 0 to TICK_CYCLE := 0;
    signal   tick_count_end  :std_logic;
    constant BURST_CNT_END   :integer :=BURST_COUNT-1;
    signal   burst_counter   :integer range 0 to BURST_CNT_END := 0;
    signal   burst_count_end :std_logic;
    signal   tick_trigger    :std_logic;
    signal   finish_trigger  :std_logic;
begin----------------------------------------------------------------------
--Tick周期カウンタの終端検出
tick_count_end <= '1' when(tick_counter = TICK_CYCLE)else '0';
--バーストサイクルカウンタの終端
burst_count_end <= '1' when(burst_counter = BURST_CNT_END)else '0';
--シーケンス終了
seq_finish <= tick_count_end and burst_count_end;
--動作中フラグ
process(i_CLK,i_RST_p)begin
    if(i_RST_p='1')then
        seq_enable <= '0';
    elsif(rising_edge(i_CLK))then
        if(seq_finish='1')then
            seq_enable <='0';
        elsif(i_START_p='1')then
            seq_enable<='1';
        end if;
    end if;
end process;
--Tick周期カウンタ
process(i_CLK,i_RST_p)begin
    if(i_RST_p='1')then
        tick_counter <=0;
    elsif(rising_edge(i_CLK))then
        if(tick_count_end='1')then
            tick_counter <=0;
        elsif(seq_enable='1')then
            tick_counter <=tick_counter +1;
        end if;
    end if;
end process;
--バーストサイクルカウンタ
process(i_CLK,i_RST_p)begin
    if(i_RST_p='1')then
        burst_counter <=0;
    elsif(rising_edge(i_CLK))then
        if(seq_enable='0')then
            burst_counter <=0;
        else
            if(tick_trigger='1')then
                burst_counter <=burst_counter +1;
            end if;
        end if;
    end if;
end process;
---Tickトリガ
process(i_CLK,i_RST_p)begin
    if(i_RST_p='1')then
        tick_trigger <= '0';
        finish_trigger <= '0';
    elsif(rising_edge(i_CLK))then
        if(seq_enable='1')then
            tick_trigger <= tick_count_end;
            finish_trigger <= seq_finish;
        else
            tick_trigger <= i_START_p;
            finish_trigger <= '0';
        end if;
    end if;
end process;

--出力：サブModuleでしか使用しないので、FF出してない
o_BUSY_h        <= seq_enable;
o_TICK_TRG_p    <= tick_trigger;
o_FINISH_p      <= finish_trigger;

end architecture;
