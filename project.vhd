library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    Port ( 
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0);
        o_done : out std_logic;
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    type state_type is (
        CHOSE_OUTPUT_1,
        CHOSE_OUTPUT_2,
        ASK_MEM,
        READ_MEM,
        WAITING_FOR_DONE,
        SERIALIZE,
        WAITING_FOR_START
    );
    signal curr_state : state_type;
    signal next_state : state_type := WAITING_FOR_START;
    
    signal out_port : std_logic_vector(1 downto 0);
    signal enable_out_port : std_logic;
    
    signal mem_address_registry : std_logic_vector(16 downto 0);
    signal enable_shift_register : std_logic;
    
    signal enable_demultiplexer : std_logic;
    
    signal saved_z0 : std_logic_vector(7 downto 0);
    signal saved_z1 : std_logic_vector(7 downto 0);
    signal saved_z2 : std_logic_vector(7 downto 0);
    signal saved_z3 : std_logic_vector(7 downto 0);
    
    signal enable_saved_z0 : std_logic;
    signal enable_saved_z1 : std_logic;
    signal enable_saved_z2 : std_logic;
    signal enable_saved_z3 : std_logic;

    signal clone_o_done : std_logic;

begin

    process (i_clk, i_rst)
    begin
        if (i_rst = '1') then
            curr_state <= WAITING_FOR_START;
        elsif rising_edge(i_clk) then
            curr_state <= next_state;
        end if;
    end process;
    
    process (i_clk, i_start)
    begin
        case curr_state is
                
            when CHOSE_OUTPUT_1 =>
                if (i_start = '1') then
                    next_state <= CHOSE_OUTPUT_2;
                else
                    next_state <= CHOSE_OUTPUT_1;
                end if;
            
            when CHOSE_OUTPUT_2 =>
                next_state <= ASK_MEM;
                
            when ASK_MEM =>                
                if (i_start = '0') then
                    next_state <= READ_MEM;
                else
                    next_state <= ASK_MEM;
                end if;
            
            when READ_MEM =>                
                next_state <= WAITING_FOR_DONE;
                
            when WAITING_FOR_DONE =>
                next_state <= SERIALIZE;
                
            when SERIALIZE =>
                next_state <= WAITING_FOR_START;
                
            when WAITING_FOR_START =>
                next_state <= CHOSE_OUTPUT_1;
                
        end case;
    end process;
    
    process (i_clk)
    begin
        o_done <= '0';
        clone_o_done <= '0';
        
        o_mem_we <= '0';
        o_mem_en <= '0';
        enable_shift_register <= '0';
        enable_out_port <= '0';

        enable_demultiplexer <= '0';
        
        o_z0 <= (others => '0');
        o_z1 <= (others => '0');
        o_z2 <= (others => '0');
        o_z3 <= (others => '0');
                                
        case curr_state is 
        
            when CHOSE_OUTPUT_1 =>
                enable_out_port <= '1';
                         
            when CHOSE_OUTPUT_2 =>
                enable_out_port <= '1';

            when ASK_MEM =>
                enable_out_port <= '0';
                enable_shift_register <= '1';

            when READ_MEM =>
                enable_shift_register <= '0';
                o_mem_en <= '1';
                                
            when WAITING_FOR_DONE =>
                o_mem_en <= '0';
                enable_demultiplexer <= '1';

            when SERIALIZE =>
                enable_demultiplexer <= '0';
                clone_o_done <= '1';
                o_done <= '1';
                
                o_z0 <= saved_z0;
                o_z1 <= saved_z1;
                o_z2 <= saved_z2;
                o_z3 <= saved_z3;

                                                
            when WAITING_FOR_START =>
                o_done <= '0';
                clone_o_done <= '0';
            
        end case;
    end process;
    
    
    -- Processo per il funzionamento dello shift register di 2 bit
    process (i_clk, i_rst, i_w, enable_out_port)
    begin
        if i_rst = '1' then
            out_port <= (others => '0');
        elsif rising_edge(i_clk) then
            if (enable_out_port = '1') then
                out_port(1) <= out_port(0);
                out_port(0) <= i_w;
            end if;
        end if;
    end process;
    
    -- Processo per il funzionamento dello shift register di 16 bit
    process (i_clk, i_rst, i_w, enable_shift_register)
    begin
        if (i_rst = '1' or clone_o_done = '1') then
            mem_address_registry <= "00000000000000000";
        elsif rising_edge(i_clk) then
            if enable_shift_register = '1' then
                mem_address_registry(16 downto 1) <= mem_address_registry(15 downto 0);
                mem_address_registry(0) <= i_w; -- Aggiunge il nuovo segnale nello shift register
            end if;
        end if;
    end process;
    
    o_mem_addr <= mem_address_registry(16 downto 1);

    
    -- Processo per il controllo del demultiplexer
    process (enable_demultiplexer, out_port)
    begin
        case out_port is
            when "00" =>
                enable_saved_z0 <= enable_demultiplexer;
                enable_saved_z1 <= '0';
                enable_saved_z2 <= '0';
                enable_saved_z3 <= '0';
            
            when "01" =>
                enable_saved_z0 <= '0';
                enable_saved_z1 <= enable_demultiplexer;
                enable_saved_z2 <= '0';
                enable_saved_z3 <= '0';
            
            when "10" =>
                enable_saved_z0 <= '0';
                enable_saved_z1 <= '0';
                enable_saved_z2 <= enable_demultiplexer;
                enable_saved_z3 <= '0';

            when "11" =>
                enable_saved_z0 <= '0';
                enable_saved_z1 <= '0';
                enable_saved_z2 <= '0';
                enable_saved_z3 <= enable_demultiplexer;

            when others =>
                enable_saved_z0 <= '0';
                enable_saved_z1 <= '0';
                enable_saved_z2 <= '0';
                enable_saved_z3 <= '0';
        end case; 
    end process;
    
    -- Processo per il controllo del registro saved_z0
    process (i_clk, i_rst, enable_saved_z0)
    begin
        if (i_rst = '1') then
            saved_z0 <= (others => '0');
        elsif rising_edge(i_clk) then
            if (enable_saved_z0 = '1') then
                saved_z0 <= i_mem_data; -- Assegna i_mem_data a saved_z0
            end if;   
        end if;
    end process;
    
    
    -- Processo per il controllo del registro saved_z1
    process (i_clk, i_rst, enable_saved_z1)
    begin
        if (i_rst = '1') then
            saved_z1 <= (others => '0');
        elsif rising_edge(i_clk) then
            if (enable_saved_z1 = '1') then
                saved_z1 <= i_mem_data; -- Assegna i_mem_data a saved_z1
            end if;
        end if;
    end process;
    
    
    -- Processo per il controllo del registro saved_z2
    process (i_clk, i_rst, enable_saved_z2)
    begin
        if (i_rst = '1') then
            saved_z2 <= (others => '0');
        elsif rising_edge(i_clk) then
            if (enable_saved_z2 = '1') then
                saved_z2 <= i_mem_data; -- Assegna i_mem_data a saved_z2
            end if;   
        end if;
    end process;
    
    -- Processo per il controllo del registro saved_z3
    process (i_clk, i_rst, enable_saved_z3)
    begin
        if (i_rst = '1') then
            saved_z3 <= (others => '0');
        elsif rising_edge(i_clk) then
            if (enable_saved_z3 = '1') then
                saved_z3 <= i_mem_data; -- Assegna i_mem_data a saved_z3
            end if;   
        end if;
    end process;
    
end Behavioral;
