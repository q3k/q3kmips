#include "test_decode.h"

#include <iostream>

#include "Vqm_decode.h"

void test_decode(void)
{
    Vqm_decode *decode = new Vqm_decode;

    // set r5 to 666 and r4 to 0xdeadbeef
    decode->dbg_wa = 5;
    decode->dbg_wd = 666;
    decode->dbg_we = 1;
    decode->eval();
    decode->dbg_wa = 4;
    decode->dbg_wd = 0xdeadbeef;
    decode->eval();
    decode->dbg_we = 0;

    decode->di_IR = 0x20a40539;
    decode->eval();

    std::cout << std::hex << decode->do_IR << std::endl;
    std::cout << std::hex << decode->do_A << std::endl;
    std::cout << std::hex << decode->do_B << std::endl;
    std::cout << std::dec << decode->do_Imm << std::endl;
}
