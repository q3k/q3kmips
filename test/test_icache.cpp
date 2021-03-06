// Copyright (c) 2014, Segiusz 'q3k' Bazanski <sergiusz@bazanski.pl>
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE

#include "test_icache.h"

#include <cstdio>

#include "Vqm_icache.h"

unsigned int _read_ram_at(unsigned int address)
{
    // for now, just return the address
    return address;
}

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
                    ic->mem_rd_data = _read_ram_at(current_command.addr + (4-current_command.left)*4);
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
        {
            printf("[TEST] Trying to read from 0x8bedead0...\n");
            icache->enable = 1;
            icache->address = 0x8bedead0;
        }
        if (counter > 11 && icache->stall == 0 && icache->address != 0x8bedead4)
        {
            printf("[TEST] Trying to read from 0x8bedead4 (should take one cycle...)\n");
            icache->address = 0x8bedead4;
        }
        if (counter > 40 && icache->stall == 0 && icache->address != 0x8bedead8)
        {
            printf("[TEST] Trying to read from 0x8bedead8 (should take one cycle...)\n");
            icache->address = 0x8bedead8;
        }
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
