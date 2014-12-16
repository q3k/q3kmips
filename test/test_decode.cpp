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
