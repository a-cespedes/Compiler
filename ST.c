/*************************************************************************** 
Symbol Table Module 
Author: Anthony A. Aaby
Modified by: Jordi Planes
***************************************************************************/ 

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "CG.h"
#include "ST.h"

/*========================================================================= 
DECLARATIONS 
=========================================================================*/ 

/*------------------------------------------------------------------------- 
SYMBOL TABLE ENTRY 
-------------------------------------------------------------------------*/ 
symrec *identifier; 

/*------------------------------------------------------------------------- 
SYMBOL TABLE 
Implementation: a chain of records. 
------------------------------------------------------------------------*/ 
symrec *sym_table = (symrec *)0; /* The pointer to the Symbol Table */ 

/*======================================================================== 
  Operations
  ========================================================================*/ 

symrec * putfunc (char *func_name, int label) 
{ 
  symrec *ptr; 
  ptr = (symrec *) malloc (sizeof(symrec)); 
  ptr->name = (char *) malloc (strlen(func_name)+1); 
  strcpy (ptr->name,func_name); 
  ptr->function = (char *) malloc (strlen(func_name)+1); 
  strcpy (ptr->function,func_name); 
  ptr->label = label; 
  ptr->type = Function;
  ptr->next = (struct symrec *)sym_table; 
  sym_table = ptr; 
  return ptr; 
} 

symrec * putsym (char *sym_name, char *function, int size, int param,Type type) 
{ 
  symrec *ptr; 
  ptr = (symrec *) malloc (sizeof(symrec)); 
  ptr->name = (char *) malloc (strlen(sym_name)+1); 
  strcpy (ptr->name,sym_name); 
  ptr->offset = data_location();
  int i;
  for(i=1;i!=size;i++)
    data_location();
  ptr->function = (char *) malloc (strlen(function)+1); 
  strcpy (ptr->function,function); 
  ptr->size = size;
  ptr->param = param;
  ptr->type = type;
  ptr->next = (struct symrec *)sym_table; 
  sym_table = ptr; 
  return ptr; 
} 

symrec * getsym (char *sym_name,char* function) 
{ 
  symrec *ptr; 
  for ( ptr = sym_table;ptr != (symrec *) 0;ptr = (symrec *)ptr->next ){
    if (strcmp (ptr->name,sym_name) == 0 && strcmp(ptr->function,function) == 0)
      return ptr; 
  }
  return ptr;
} 

params * getparams(char *func_name){
  symrec *ptr; 
  params *p = malloc(sizeof(params));
  p->numParams = 0;
  p->params = NULL;
  for ( ptr = sym_table; ptr != (symrec *) 0;ptr = (symrec *)ptr->next ){ 
    if (strcmp (ptr->function,func_name) == 0 && ptr->param != 0){ 
      if(p->params == NULL){
        p->numParams = ptr->param;
        p->params = malloc(p->numParams * sizeof(int));
      }
	  else{
        if(ptr->param > p->numParams){
          p->numParams = ptr->param;
  		  p->params = realloc(p->params,(p->numParams * sizeof(int)));
        }
	  }
      p->params[ptr->param - 1] = ptr->offset;
    }
  }
  return p;
}
/************************** End Symbol Table **************************/ 

