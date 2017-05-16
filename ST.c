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
  Operations: Putsym, Getsym 
  ========================================================================*/ 
symrec * putsym (char *sym_name) 
{ 
  symrec *ptr; 
  ptr = (symrec *) malloc (sizeof(symrec)); 
  ptr->name = (char *) malloc (strlen(sym_name)+1); 
  strcpy (ptr->name,sym_name);
  printf("%s\n",sym_name);  
  ptr->offset = data_location(); 
  ptr->next = (struct symrec *)sym_table; 
  sym_table = ptr; 
  return ptr; 
} 

symrec * putfunc (char *func_name, int label) 
{ 
  symrec *ptr; 
  ptr = (symrec *) malloc (sizeof(symrec)); 
  ptr->name = (char *) malloc (strlen(func_name)+1); 
  strcpy (ptr->name,func_name);
  printf("%s %d\n",func_name, label); 
  ptr->function = (char *) malloc (strlen(func_name)+1); 
  strcpy (ptr->function,func_name); 
  ptr->label = label; 
  ptr->next = (struct symrec *)sym_table; 
  sym_table = ptr; 
  return ptr; 
} 

symrec * putsymfunc (char *sym_name, char *function) 
{ 
  symrec *ptr; 
  ptr = (symrec *) malloc (sizeof(symrec)); 
  ptr->name = (char *) malloc (strlen(sym_name)+1); 
  strcpy (ptr->name,sym_name); 
  printf("%s %s\n",sym_name, function);
  ptr->offset = data_location();
  ptr->function = (char *) malloc (strlen(function)+1); 
  strcpy (ptr->function,function); 
  ptr->next = (struct symrec *)sym_table; 
  sym_table = ptr; 
  return ptr; 
} 

symrec * putparam (char *sym_name, char *function,int param) 
{ 
  symrec *ptr; 
  ptr = (symrec *) malloc (sizeof(symrec)); 
  ptr->name = (char *) malloc (strlen(sym_name)+1); 
  strcpy (ptr->name,sym_name); 
  printf("%s %s %d\n",sym_name, function,param);
  ptr->offset = data_location();
  ptr->function = (char *) malloc (strlen(function)+1); 
  strcpy (ptr->function,function); 
  ptr->param = param;
  ptr->next = (struct symrec *)sym_table; 
  sym_table = ptr; 
  return ptr; 
} 

symrec * getsym (char *sym_name,char* function) 
{ 
  symrec *ptr; 
  for ( ptr = sym_table;ptr != (symrec *) 0;ptr = (symrec *)ptr->next ){
    if (strcmp (ptr->name,sym_name) == 0 && strcmp(ptr->function,function) == 0){
      return ptr; }
    else if (strcmp (ptr->name,sym_name) == 0){
      return ptr; }
  }
  return NULL;
} 

int* getparams(char *func_name){
  int *params = NULL;
  int numParams = 0;
  symrec *ptr; 
  for ( ptr = sym_table; ptr != (symrec *) 0;ptr = (symrec *)ptr->next ){ 
    if (strcmp (ptr->function,func_name) == 0 && ptr->param != 0){ 
      if(params == NULL){
        numParams = ptr->param;
        params = malloc(numParams * sizeof(int));
      }
		  else{
        if(ptr->param > numParams){
          numParams = ptr->param;
  			  params = realloc(params,(numParams * sizeof(int)));
        }
		  }
		  params[ptr->param - 1] = ptr->offset;
	  }
  }
  return params;
}
/************************** End Symbol Table **************************/ 

