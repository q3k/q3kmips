# Makefile for verilator-based tests

CXXFLAGS = -I/usr/share/verilator/include -I obj_dir/ -I /usr/share/verilator/include/vltstd/ -std=c++11

obj_dir/V%.cpp: ../rtl/verilog/%.v
	verilator -Wall -cc -I../rtl/verilog/ --unroll-count 16000 $<


OBJS := /usr/share/verilator/include/verilated.cpp \
      obj_dir/Vqm_decode.o \
      obj_dir/Vqm_decode__Syms.cpp \
	  obj_dir/Vqm_fetch.o \
	  obj_dir/Vqm_fetch__Syms.cpp \
	  obj_dir/Vqm_icache.o \
	  obj_dir/Vqm_icache__Syms.cpp \
	  main.o \
	  test_decode.o \
	  test_icache.o \
	  test_fetch.o

test: $(OBJS)
	g++ $(CXXFLAGS) -o test $(OBJS)

%PHONY = clean

clean:
	rm -rf obj_dir
	rm -rf test
	rm -f *.o
