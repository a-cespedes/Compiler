/*************************************************************************** 
  Stack Machine
***************************************************************************/ 

#ifndef __SM_H
#define __SM_H
/*========================================================================= 
DECLARATIONS 
=========================================================================*/ 
/* OPERATIONS: Internal Representation */ 
enum code_ops { HALT, STORE, JMP_FALSE, GOTO, CALL, RET,
		DATA, LD_INT, LD_VAR, 
		READ_INT, WRITE_INT, 
		LT, EQ, GT, ADD, SUB, MULT, DIV, PWR, LD_SUB, STORE_SUB, WRITE_STR }; 

struct instruction 
{ 
  enum code_ops op; 
  int arg; 
}; 

#define MAX_MEMORY 999
#define MAX_STRING_SIZE 16

void fetch_execute_cycle();

extern struct instruction code[ MAX_MEMORY ];
extern char *op_name[];

#endif
