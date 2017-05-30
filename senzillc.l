/*************************************************************************** 
Scanner for the Simple language 
Author: Anthony A. Aaby
Modified by: Jordi Planes
***************************************************************************/ 

%option nounput
%option noinput
%x comment incl string
%{ 
/*========================================================================= 
C-libraries and Token definitions 
=========================================================================*/ 
#define MAX_STRING_SIZE 16
int line_num = 1;
YY_BUFFER_STATE stack[5];
int stack_pos = 0;
char * str;
int i = 0;
void processInclude();
void begin();
#include <string.h> /* for strdup */ 
#include <stdlib.h> /* for atoi */ 
#include "senzillc.tab.h" /* for token definitions and yylval */ 
%} 

/*========================================================================= 
TOKEN Definitions 
=========================================================================*/ 
DIGIT [0-9] 
ID [a-z][a-z0-9]* 

/*========================================================================= 
REGULAR EXPRESSIONS defining the tokens for the Simple language 
=========================================================================*/ 
%% 

":="                    { return(ASSGNOP); } 
{DIGIT}+                { yylval.intval = atoi( yytext ); return(NUMBER); } 
def                     { return(DEF); } 
do                      { return(DO); } 
else                    { return(ELSE); } 
end                     { return(END); } 
fi                      { return(FI); } 
if                      { return(IF); } 
in                      { return(IN); } 
integer                 { return(INTEGER); } 
length                  { return(LENGTH); } 
let                     { return(LET); } 
read                    { return(READ); } 
return                  { return(RETURN); } 
skip                    { return(SKIP); }
string                  { return(STRING); }
then                    { return(THEN); } 
while                   { return(WHILE); } 
write                   { return(WRITE); } 
{ID}                    { yylval.id = (char *) strdup(yytext); return(IDENTIFIER); } 
"/*"                    BEGIN(comment);
<comment>[^*\n]*        
<comment>"*"+[^*/\n]*   
<comment,INITIAL>\n     ++line_num;
<comment>"*"+"/"        BEGIN(INITIAL);
\"                      { BEGIN string;str = malloc(MAX_STRING_SIZE * sizeof(char));}
<string>[^\\"\n]*       { strcat(str,yytext); i += yyleng;  }
<string>\\n             { str[i++] = '\n'; }
<string>\\t             { str[i++] = '\t'; }
<string>\\[\\"]         { str[i++] = yytext[1]; }
<string>\"              { str[i++] = '\0';yylval.id = strdup(str);i = 0; BEGIN 0; return STR; }
[ \t]+                  /* eat up whitespace */
include" "	            BEGIN(incl);
<incl>{ID}".sz"         processInclude();BEGIN(INITIAL);
<<EOF>>                 begin();
.                       { return(yytext[0]);} 

%% 

void begin(){
    stack_pos--;
    if(stack_pos >= 0){
        yy_delete_buffer(YY_CURRENT_BUFFER);
        yy_switch_to_buffer(stack[stack_pos]);
    }
    else{
        exit(0);
    }
}

void processInclude(){
    stack[stack_pos] = YY_CURRENT_BUFFER;
    stack_pos++;
    yyin = fopen(&yytext[0],"r");
    yy_switch_to_buffer(yy_create_buffer(yyin, YY_BUF_SIZE));
    BEGIN(INITIAL);
}

int yywrap(void){ 
   return 1; 
} 

/************************** End Scanner File *****************************/ 

