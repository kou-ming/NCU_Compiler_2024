%{
#include "smli.tab.h"    
%}

separator ([ \t\n\r])
number (0|[1-9][0-9]*|\-[1-9][0-9]*)
id ([a-z]([a-z]|[0-9]|\-)*)

%%
{separator} { 
    // printf("separator\n"); 
    }

"(" { return(yytext[0]); }
")" { return(yytext[0]); }
"+" { return(yytext[0]); }
"-" { return(yytext[0]); }
"*" { return(yytext[0]); }
"/" { return(yytext[0]); }
">" { return(yytext[0]); }
"<" { return(yytext[0]); }
"=" { return(yytext[0]); }
"#t" { yylval.ival = 1; return(BOOL); }
"#f" {  yylval.ival = 0; return(BOOL); }
"and" { return(AND); }
"or" { return(OR); }
"not" { return(NOT); }
"mod" { return(MOD); }
"if" { return(IF); }
"define" { return(DEFINE); }
"fun" { return(FUN); }
"print-num" { return(PRINT_NUM); }
"print-bool" { return(PRINT_BOOL); }
{number} { yylval.ival = atoi(yytext); return(NUM); }
{id} { yylval.word = strdup(yytext); return(ID);}

. { printf("not anyone\n");}
%%

int yywrap(void){
    return 1;
}