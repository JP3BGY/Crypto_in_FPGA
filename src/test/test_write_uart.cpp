#include <iostream>
#include <cstdio>
#include <verilated.h>
#include "verilated_vcd_c.h"
#include "Vwrite_uart.h"

unsigned int main_time=0;

double sc_time_stamp(){
  return main_time;
}
unsigned int aes_key[4] = {0x655f68db,0xb7e6ab3a,0x83ef87e9,0xfefd00d5,};
int main(int argc, char const* argv[])
{
  Verilated::commandArgs(argc,argv);
  Vwrite_uart *top = new Vwrite_uart();

  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC();
  top->trace(tfp,100000);
  tfp->open("sim_write_uart.vcd");

  top->rst_n = 0;
  top->clk = 0;
  top->data = 0x1f;

  while (!Verilated::gotFinish()) {
    if(main_time > 200)top->rst_n = 1;
    if(main_time % 25 == 0)
      top->clk = !top->clk;
    top->eval();
    printf("Time %d:clk = %d TxD = %d flag = %d", main_time,top->clk,top->TxD,top->ready);
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
