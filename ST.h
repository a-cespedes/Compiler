/*------------------------------------------------------------------------- 
SYMBOL TABLE RECORD 
-------------------------------------------------------------------------*/ 

typedef enum { IntArray, Integer, Function } Type;

struct symrec 
{ 
  char *name; /* name of symbol */ 
  int offset; /* data offset */ 
  int label; /* function label*/ 
  char *function; /*symbol function*/ 
  int param; /*param order in function*/
  Type type; /*symbol type*/
  struct symrec *next; /* link field */ 
}; 
typedef struct symrec symrec; 

struct params 
{ 
  int numParams;
  int* params;
}; 
typedef struct params params; 

symrec * getsym (char *sym_name,char* function);
symrec * putfunc (char *func_name, int label);
symrec * putsym (char *sym_name, char *function, int size, int param);
params * getparams(char *func_name);
