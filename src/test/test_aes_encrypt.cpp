#include <iostream>
#include <cstdio>
#include <verilated.h>
#include "verilated_vcd_c.h"
#include "Vaes_encrypt.h"

unsigned int main_time=0;

double sc_time_stamp(){
  return main_time;
}
unsigned int aes_key[4] = {0xfefd00d5,0x83ef87e9,0xb7e6ab3a,0x655f68db};
int main(int argc, char const* argv[])
{
  Verilated::commandArgs(argc,argv);
  Vaes_encrypt *top = new Vaes_encrypt();

  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC();
  top->trace(tfp,1000);
  tfp->open("sim_aes_encrypt.vcd");

  top->rst_n = 0;
  top->clk = 0;
  top->load=0;
  for (int i = 0; i < 4; i++) {
    top->pt[i] = i+5;
    top->key[i] = aes_key[i];
  }

  while (!Verilated::gotFinish()) {
    if(main_time > 10)top->rst_n = 1;
    if(main_time % 5 == 0)
      top->clk = !top->clk;
    if(main_time > 20 )
      top->load = 1;
    top->eval();
    printf("Time %d:clk = %d load = %d flag = %d", main_time,top->clk,top->load,top->valid);
    for (int i = 0; i < 4; i++) {
      printf("ct[%d] = %X ", i, top->ct[i]);
    }
    puts("");
    tfp->dump(main_time);
    if(main_time > 1000)break;
    main_time++;
  }
  tfp->close();
  top->final();
  return 0;
}
