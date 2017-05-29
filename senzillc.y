%{
/************************************************************************* 
Compiler for the Simple language 
Author: Anthony A. Aaby
Modified by: Jordi Planes
***************************************************************************/ 
/*========================================================================= 
C Libraries, Symbol Table, Code Generator & other C code 
=========================================================================*/ 
#include <stdio.h> /* For I/O */ 
#include <stdlib.h> /* For malloc here and in symbol table */ 
#include <string.h> /* For strcmp in symbol table */ 
#include "ST.h" /* Symbol Table */ 
#include "SM.h" /* Stack Machine */ 
#include "CG.h" /* Code Generator */ 

#define YYDEBUG 1 /* For Debugging */ 
#define MAX_STRING_SIZE 16

int yyerror(char *);
int yylex();
char *idf;
char *actual_func = "_GLOBAL";
char message[ 100 ];
int errors; /* Error Count */ 
int label = 1;
int param = 0;
params* funcparams;
Type actual_type;
extern int line_num;
/*------------------------------------------------------------------------- 
The following support backpatching 
-------------------------------------------------------------------------*/ 
struct lbs /* Labels for data, if and while */ 
{ 
  int for_goto; 
  int for_jmp_false; 
}; 

struct lbs * newlblrec() /* Allocate space for the labels */ 
{ 
   return (struct lbs *) malloc(sizeof(struct lbs)); 
}

void set_scope(char* func_name){
   actual_func = strdup(func_name);
}

/*------------------------------------------------------------------------- 
Install identifier & check if previously defined. 
-------------------------------------------------------------------------*/ 
void install ( char *sym_name,char *actual_func, int size, int param) 
{ 
  symrec *s = getsym (sym_name,actual_func);
  if (s == 0)
    s = putsym (sym_name,actual_func,size,param,actual_type); 
  else { 
    sprintf( message, "%s is already defined\n", sym_name ); 
    yyerror( message );
  } 
} 

/*------------------------------------------------------------------------- 
If identifier is defined, generate code 
-------------------------------------------------------------------------*/ 
int context_check( char *sym_name ) 
{ 
  symrec *identifier = getsym( sym_name,actual_func );
  if(identifier == 0){
    sprintf( message, "Variable %s is not defined\n", sym_name); 
    yyerror( message );
    return -1; 
  }
  else return identifier->offset;
} 

/*------------------------------------------------------------------------- 
If function identifier is defined, return label
-------------------------------------------------------------------------*/ 
int check_function(char* func_name){
  symrec *s = getsym(func_name,func_name);
  if(!s){
    return -1;
  }
  else {return s->label;}
}
/*------------------------------------------------------------------------- 
Define function return variable
-------------------------------------------------------------------------*/ 
int install_return(char* func){
  idf = strdup(func);
  sprintf(idf,"_RETURN_%s",func);
  symrec *s = putsym(idf,"_GLOBAL",1,param,Integer);
  free(idf);
  return s->offset;
}
/*------------------------------------------------------------------------- 
Return the return variable of a function
-------------------------------------------------------------------------*/ 
char* get_return_variable(char* func){
  int retval = check_function(func);
  if(retval == -1){
    sprintf( message, "Function %s is not defined\n", func ); 
    yyerror( message );
    return "";
  }
  else { 
    char* var = strdup(func);
    sprintf(var,"_RETURN_%s",func);
    return var;
  } 

}
/*------------------------------------------------------------------------- 
Check parameters of a function
-------------------------------------------------------------------------*/ 
void check_params(){
  if(param != funcparams->numParams){
    sprintf( message, "Function %s called with %d params, %d are needed\n",idf,param,funcparams->numParams ); 
    yyerror( message );
  }
}
/*------------------------------------------------------------------------- 
Store parameter of a function
-------------------------------------------------------------------------*/ 
void process_param(){
  if((param <= funcparams->numParams) & (funcparams->numParams > 0)){
    gen_code( STORE, funcparams->params[param] );
    param++; 
  }
}
/*------------------------------------------------------------------------- 
Store the value of the return variable of a function
-------------------------------------------------------------------------*/ 
void check_return(){
  if(strcmp(actual_func,"_GLOBAL")==0){
    sprintf( message, "Unnecessary return at main\n" ); 
    yyerror( message );
  }
  else{
    gen_code(STORE, install_return(actual_func));
  }
}
/*------------------------------------------------------------------------- 
Assign the value of the return variable to a variable
-------------------------------------------------------------------------*/ 
Type type(char* sym_name){
  symrec *identifier = getsym( sym_name,actual_func );
  if(identifier == 0){
    return Unknown;
  }
  else return identifier->type;
}

void check_type(char *var){
  int offset = context_check(var);
  if(offset != -1){
    if(type(var) == Integer){
      gen_code( STORE, offset);
    }
    else if(type(var) == IntArray){
      gen_code( STORE_SUB, 0 );
    }
    else{
      sprintf( message, "Var %s cannot be assigned to an expression\n", var); 
      yyerror( message );
    }
  }
}

void str_type(char* var){
  if(type(var) == String){
    int i;
    for(i=0;i!=MAX_STRING_SIZE;i++){
      int c = context_check(var);
      gen_code(STORE,c+i);
    }
  }
  else{
    sprintf( message, "Var %s cannot be assigned to an expression\n", var); 
    yyerror( message );
  }
}
/*------------------------------------------------------------------------- 
Returns the type of a function
-------------------------------------------------------------------------*/ 
void assign_return_value(char* var){
  if(strcmp(get_return_variable(idf),"") != 0){
    gen_code(LD_VAR, context_check(get_return_variable(idf)));
    gen_code(STORE, context_check(var));
  }
}

int size(char* sym_name){
  symrec *identifier = getsym( sym_name,actual_func );
  return identifier->size;
}
/*------------------------------------------------------------------------- 
Program start
-------------------------------------------------------------------------*/ 
void start_program(){
  gen_code( DATA, -1 );
  gen_code( CALL, -1 );
  gen_code( HALT, 0 );
}
/*------------------------------------------------------------------------- 
Fill data locations
-------------------------------------------------------------------------*/
void fill_data_locations(){
  back_patch(0, DATA, data_location() - 1);
  back_patch(1, CALL, gen_label());
}
/*------------------------------------------------------------------------- 
Program end
-------------------------------------------------------------------------*/ 
void end_program(){
  gen_code( RET, 0 );
}
/*========================================================================= 
SEMANTIC RECORDS 
=========================================================================*/ 
%} 

%union /* semrec - The Semantic Records */ 
 { 
   int intval; /* Integer values */ 
   char *id; /* Identifiers */ 
   struct lbs *lbls; /* For backpatching */ 
};

/*========================================================================= 
TOKENS 
=========================================================================*/ 
%start program 
%token <intval> NUMBER /* Simple integer */ 
%token <id> IDENTIFIER STR /* Simple identifier */ 
%token <lbls> IF WHILE /* For backpatching labels */ 
%token SKIP THEN ELSE FI DO END DEF RETURN
%token INTEGER READ WRITE LET IN LENGTH STRING
%token ASSGNOP 
%type <id> variable
%type <id> dec_variable
/*========================================================================= 
OPERATOR PRECEDENCE 
=========================================================================*/ 
%left '-' '+' 
%left '*' '/' 
%right '^' 

/*========================================================================= 
GRAMMAR RULES for the Simple language 
=========================================================================*/ 

%% 

/*========================================================================= 
FUNCTION RULES for the Simple language 
=========================================================================*/ 

functions : /* empty */ 
    | functions function { }
;
     
function : DEF IDENTIFIER { putfunc($2,gen_label());set_scope($2); } '(' params ')'{ param = 0; } DO body_function END { gen_code( RET, 0 ); set_scope("_GLOBAL"); }
; 

body_function : declarations commands
;

params : INTEGER { param++; }  dec_variable          
    | params ',' INTEGER { param++; } dec_variable   
;

function_call : IDENTIFIER { idf = strdup($1);funcparams = getparams($1);param = 0; }'(' function_call_params  ')' { check_params();gen_code( CALL, check_function($1) );param = 0; }
;

function_call_params : /* empty */
    | exp                           { process_param(); } 
    | function_call_params ',' exp  { process_param(); } 
;
/*========================================================================= 
PROGRAM RULES for the Simple language 
=========================================================================*/ 
program : { start_program(); }functions main { YYACCEPT; }
; 

main : LET declarations IN { fill_data_locations(); } 
          commands END { end_program(); }
;

type: INTEGER { actual_type = Integer; } 
    | STRING { actual_type = String; }
;

declarations : /* empty */ 
    | type id_seq dec_variable '.' { } 
; 

id_seq : /* empty */ 
    | id_seq dec_variable ',' { } 
; 

dec_variable : IDENTIFIER '[' NUMBER ']' { actual_type = IntArray;install( $1, actual_func, $3, param ); }
    | IDENTIFIER { if(actual_type == Integer){install( $1,actual_func, 1, param );}else install( $1,actual_func, MAX_STRING_SIZE, param ); } 
; 

variable : IDENTIFIER { gen_code( LD_INT, context_check( $1 )); } '[' exp ']' { $$ = $1; }
    | IDENTIFIER { $$ = $1; } 
; 

commands : /* empty */ 
    | commands command ';' 
    | error { yyerrok; }
; 

command : SKIP 
   | READ variable { gen_code( READ_INT, context_check( $2 ) ); } 
   | WRITE exp { gen_code( WRITE_INT, 0 ); } 
   | WRITE str_exp { gen_code( WRITE_STR, 0 ); } 
   | variable ASSGNOP exp { check_type($1); } 
   | variable ASSGNOP str_exp { str_type($1); } 
   | IF bool_exp { $1 = (struct lbs *) newlblrec(); $1->for_jmp_false = reserve_loc(); } 
   THEN commands { $1->for_goto = reserve_loc(); } ELSE { 
     back_patch( $1->for_jmp_false, JMP_FALSE, gen_label() ); 
   } commands FI { back_patch( $1->for_goto, GOTO, gen_label() ); } 
   | WHILE { $1 = (struct lbs *) newlblrec(); $1->for_goto = gen_label(); } 
   bool_exp { $1->for_jmp_false = reserve_loc(); } DO commands END { gen_code( GOTO, $1->for_goto ); 
   back_patch( $1->for_jmp_false, JMP_FALSE, gen_label() ); } 
   | function_call { }
   | variable ASSGNOP function_call { assign_return_value($1); }
   | RETURN exp { check_return(); }
;

bool_exp : exp '<' exp { gen_code( LT, 0 ); } 
   | exp '=' exp { gen_code( EQ, 0 ); } 
   | exp '>' exp { gen_code( GT, 0 ); } 
;

exp : NUMBER { gen_code( LD_INT, $1 ); } 
   | IDENTIFIER { gen_code( LD_VAR, context_check( $1 ) ); }
   | IDENTIFIER '[' exp ']' { gen_code( LD_INT, context_check( $1 ));gen_code( LD_SUB, 0 ); }
   | exp '+' exp { gen_code( ADD, 0 ); } 
   | exp '-' exp { gen_code( SUB, 0 ); } 
   | exp '*' exp { gen_code( MULT, 0 ); } 
   | exp '/' exp { gen_code( DIV, 0 ); } 
   | exp '^' exp { gen_code( PWR, 0 ); } 
   | '(' exp ')' 
   | LENGTH '(' IDENTIFIER ')' { if(context_check($3) != -1){gen_code( LD_INT, size($3));} } 
;

str_exp: STR { int i;for(i=MAX_STRING_SIZE - 1;i != -1;i--)gen_code( LD_INT, (int)$1[i] ); }
;

%% 

extern struct instruction code[ MAX_MEMORY ];

/*========================================================================= 
MAIN 
=========================================================================*/ 
int main( int argc, char *argv[] ) 
{ 
  extern FILE *yyin; 
  if ( argc < 3 ) {
    printf("usage <input-file> <output-file>\n");
    return -1;
  }
  yyin = fopen( argv[1], "r" ); 
  /*yydebug = 1;*/ 
  errors = 0; 
  printf("Senzill Compiler\n");
  yyparse (); 
  printf ( "Parse Completed\n" ); 
  if ( errors == 0 ) 
    { 
      //print_code (); 
      //fetch_execute_cycle();
      write_bytecode( argv[2] );
    } 
  return 0;
} 

/*========================================================================= 
YYERROR 
=========================================================================*/ 
int yyerror ( char *s ) /* Called by yyparse on error */ 
{ 
  errors++; 
  printf ("%s at line %d\n", s, line_num); 
  return 0;
}
/**************************** End Grammar File ***************************/ 


