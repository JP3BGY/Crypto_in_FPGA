#include <iostream>
#include <cstdio>
#include <verilated.h>
#include "verilated_vcd_c.h"
#include "Vaes.h"

unsigned int main_time=0;

double sc_time_stamp(){
  return main_time;
}
unsigned int aes_key[4] = {0x655f68db,0xb7e6ab3a,0x83ef87e9,0xfefd00d5,};
int main(int argc, char const* argv[])
{
  Verilated::commandArgs(argc,argv);
  Vaes *top = new Vaes();

  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC();
  top->trace(tfp,1000);
  tfp->open("sim_top.vcd");

  top->rst_n = 0;
  top->clk = 0;
  top->load=0;
  top->btn=1;
  top->btn2=1;
  top->btn3=1;

  while (!Verilated::gotFinish()) {
    if(main_time > 10)top->rst_n = 1;
    if(main_time % 5 == 0)
      top->clk = !top->clk;
    if(main_time > 20 )
      top->btn2 = 0;
    top->eval();
    tfp->dump(main_time);
    if(main_time > 1000)break;
    main_time++;
  }
  tfp->close();
  top->final();
  return 0;
}
