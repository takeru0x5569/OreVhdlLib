--固定遅延
--遅延カウント動作中(busyが立っている間)にアサートされた入力は無視する
library ieee;
use ieee.std_logic_1164.all;

entity FIX_DELAY_LINE is
generic(
    DELAY_CYCLE :integer := 10
    );
Port(
    i_CLK     :in  std_logic;
    i_RST_p   :in  std_logic;
    i_SOURCE_p:in  std_logic;
    o_DELAY_p :out std_logic;
    o_BUSY    :out std_logic --動作中ビジー
    );
end entity;

architecture RTL of FIX_DELAY_LINE is
    signal busy         :std_logic;
    signal counter      :integer range 0 to DELAY_CYCLE:=0;
    signal count_end    :std_logic;
begin ---------------------------------------------------------------------
count_end <= '1' when counter=DELAY_CYCLE-1 else '0';
--ビジー
process(i_CLK,i_RST_p)begin
    if(i_RST_p='1')then
        busy <='0';
    elsif(rising_edge(i_CLK))then
        if(count_end='1')then
            busy <= '0';
        elsif(i_SOURCE_p ='1')then
            busy <= '1';
        end if;
    end if;
end process;
--遅延カウンタ
process(i_CLK,i_RST_p)begin
    if(i_RST_p='1')then
        counter <=0;
    elsif(rising_edge(i_CLK))then
        if(busy='1')then
            if(count_end='1') then
                counter <= 0;
            else
                counter <= counter+1;
            end if;
        else
            counter <= 0;
        end if;
    end if;
end process;
--出力
o_DELAY_p <= count_end; --FF出しはしていない
o_BUSY <=busy;

end architecture;
