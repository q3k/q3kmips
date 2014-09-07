#include "test_icache.h"

#include <cstdio>

#include "Vqm_icache.h"

void test_icache(void)
{
    Vqm_icache *icache = new Vqm_icache;

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

    icache->address = 0xdeadbeef;
    icache->clk = 0;
    icache->eval();
    icache->clk = 1;
    icache->eval();

    printf("Cache hit: %i Pipeline stall: %i\n", icache->hit, icache->stall);
}
