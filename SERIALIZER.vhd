-- パラシリ変換用シフトレジスタ
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SERIALIZER is
generic(
    BIT_LENGTH : integer := 10;    --bit数
    LSB_FIRST  : boolean := true;  --シフト方向選択
    INIT_VAL   : std_logic:= '0'
);
port(
    i_CLK       : in std_logic;
    i_RST_p     : in std_logic;
    i_SET_p     : in std_logic;
    i_DATA      : in std_logic_vector(BIT_LENGTH-1 downto 0);
    i_SHIFT_p   : in std_logic;
    o_SHIFT_OUT : out std_logic
);
end entity;

architecture RTL of SERIALIZER is
    signal frame        : std_logic_vector(BIT_LENGTH-1 downto 0);
begin------------------------------------------------
process(i_CLK,i_RST_p)begin
    if(i_RST_p='1')then
        frame <= (others=>INIT_VAL);
    elsif(rising_edge(i_CLK))then
        if(i_SET_p='1')then --データセット
            frame <= i_DATA;
        else
            if(i_SHIFT_p='1')then
                if(LSB_FIRST)then
                    frame <= INIT_VAL & frame(frame'high downto 1);
                else
                    frame <= frame(frame'high-1 downto 0) & INIT_VAL;
                end if;
            end if;
        end if;
    end if;
end process;

o_SHIFT_OUT <= frame(0) when LSB_FIRST else frame(frame'high);
end architecture;