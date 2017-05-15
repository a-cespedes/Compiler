/*------------------------------------------------------------------------- 
SYMBOL TABLE RECORD 
-------------------------------------------------------------------------*/ 

struct symrec 
{ 
  char *name; /* name of symbol */ 
  int offset; /* data offset */ 
  int label; /* function label*/ 
  char *function; /*symbol function*/ 
  int param; /*param order in function*/ 
  struct symrec *next; /* link field */ 
}; 
typedef struct symrec symrec; 

symrec * getsym (char *sym_name,char* function);
symrec * putsym (char *sym_name);
symrec * putfunc (char *func_name, int label);
symrec * putsymfunc (char *sym_name, char *function);
symrec * putparam (char *sym_name, char *function,int param);
int* getparams(char *func_name);
