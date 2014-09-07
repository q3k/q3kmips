#include "test_icache.h"

#include <cstdio>

#include "Vqm_icache.h"



void simulate_memory_controller(Vqm_icache *ic)
{
    static unsigned int latched_cmd_instr;
    static unsigned int latched_cmd_bl;
    static unsigned int latched_cmd_addr;
    static int previous_cmd_clock = 0;
    static int previous_rd_clock = 0;

    //printf("[mem ctrl] clk %i, ci 0x%01x, cb %i, ca %08x, ce %i\n",
    //       ic->mem_cmd_clk, ic->mem_cmd_instr, ic->mem_cmd_bl, ic->mem_cmd_addr, ic->mem_cmd_en);

    static struct {
        int instr = -1;
        unsigned int left = 0;
        unsigned int addr = 0;
    } current_command;
    if (previous_cmd_clock == 0 && ic->mem_cmd_clk == 1)
    {
        // simulate rising edge of command clock
        if (ic->mem_cmd_en)
        {
            printf("[mem ctrl] got command 0x%01x with bi %i and addres %08x\n",
                   latched_cmd_instr, latched_cmd_bl, latched_cmd_addr);
            current_command.instr = latched_cmd_instr;
            current_command.left = latched_cmd_bl + 1;
            current_command.addr = latched_cmd_addr;

            ic->mem_cmd_empty = 0;
        }

        latched_cmd_instr = ic->mem_cmd_instr;
        latched_cmd_bl = ic->mem_cmd_bl;
        latched_cmd_addr = ic->mem_cmd_addr;
    }
    if (previous_rd_clock == 0 && ic->mem_cmd_clk == 1)
    {
        // simulate read
        if (ic->mem_rd_en)
        {
            if (current_command.instr == 0x01)
            {
                if (current_command.left == 0)
                {
                    current_command.instr = -1;
                    ic->mem_rd_empty = 1;
                    printf("[mem ctrl] command end\n");
                }
                else
                {
                    printf("[mem ctrl] command word, %i left\n", current_command.left-1);
                    ic->mem_rd_data = 0xF0000000 + current_command.addr;
                    ic->mem_rd_empty = 0;
                    current_command.left--;
                }
            }
        }
    }

    previous_cmd_clock = ic->mem_cmd_clk;
    previous_rd_clock = ic->mem_rd_clk;
}

void test_icache(void)
{
    Vqm_icache *icache = new Vqm_icache;

    icache->mem_cmd_full = 0;
    icache->mem_cmd_empty = 1;
    icache->mem_rd_full = 0;
    icache->mem_rd_empty = 1;
    icache->mem_rd_count = 0;
    icache->address = 0;
    icache->enable = 0;

    // reset
    icache->reset = 1;
    icache->clk = 0;
    icache->eval();
    icache->clk = 1;
    icache->eval();
    icache->reset = 0;
    icache->clk = 0;
    icache->eval();
    icache->clk = 1;
    icache->eval();
    icache->clk = 0;
    icache->eval();

    unsigned int counter = 0;
    while (1)
    {
        if (counter == 10)
            icache->enable = 1;
            icache->address = 0x80bedead;
        if (counter > 100)
            break;
        icache->clk = !icache->clk;
        icache->eval();

        printf("[cache input] a: %08x\n", icache->address);
        printf("[cache status] hit: %i, stall: %i, data %08x\n",
               icache->hit, icache->stall, icache->data);
        simulate_memory_controller(icache);
        counter++;
    }
}
