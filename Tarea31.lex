/* Archivo con el reconocedor léxico la calculadora */
%{
#include<stdio.h>
#include<stdlib.h>
#include<math.h>

/* Definimos algunas constantes para identificar fichas */
#define INT 1
#define FLOAT 2
#define SUMA 3
#define RESTA 4
#define MULTI 5
#define DIVIDE 6
#define PARENI 7
#define PAREND 8
#define FINEXP 9

#define ASIG 11
#define PCOMA 12
#define DOSPTO 13
#define NVPTO 14
#define COMA 15
#define IGUAL 16

#define MAIGU 17
#define MEIGU 18
#define MAYOR 19
#define MENOR 20

#define PRIF 21
#define FINIF 22
#define ELSE 23
#define PRWH 24
#define FINW 25
#define PRRET 26
#define PRUNT 27
#define PRBGN 28
#define VAR 29
#define BOOLEAN 30

#define PROGRAM 31
#define ID 32
#define BEG 33
#define END 34
#define IF 35
#define THEN 36
#define EL 37
#define WHILE 38
#define DO 39
#define REPEAT 40
#define UNTIL 41

#define	PROG 42
#define STMT 43
#define OPT_STMTS 44
#define STMT_LST 45
#define EXPR 46
#define TERM 47
#define FACTOR 48
#define EXPRESION 49
#define EXPR_PRIMA 50
#define STMT_PRIMA 51
#define STMT_LST_PRIMA 52
#define TERM_PRIMA 53
#define EXPRESSION_PRIMA 54

int yylval, lectura = 0;
char *yylval3;
%}

LETRA [A-Za-z]
IDENTIFICADOR [a-zA-Z][a-zA-Z0-9]*
DIGITO [1-9][0-9]*

%%

{DIGITO} { yylval = atoi(yytext); return INT; }

{DIGITO}+"."{DIGITO}+ {return FLOAT;}

"program" {return PROGRAM;}
"+"       {return SUMA;}
"-"       {return RESTA;}
"*"       {return MULTI;}
"/"       {return DIVIDE;}
":="      {return ASIG;} 
">"       {return MAYOR;} 
"<"       {return MENOR;} 
"="       {return IGUAL;} 
";"       {return PCOMA;}
"("       {return PARENI;}
")"       {return PAREND;}	
"if"	{return PRIF;}
"then"	{return THEN;}
"else"    {return EL;}
"while"   {return WHILE;}
"do"   {return DO;}
"repeat"  {return REPEAT;}
"until"   {return UNTIL;}
"begin"   {return BEG;}
"end"     {return END;}
"end."     {return FINEXP;}


","       {return COMA;}
":"       {return DOSPTO;} 
"."       {return NVPTO;} 

">="      {return MAIGU;} 
"<="      {return MEIGU;}

"endif"   {return FINIF;}
"endw"    {return FINW;}
"true"    {return BOOLEAN;}
"false"   {return BOOLEAN;}

{IDENTIFICADOR} {yylval3 = yytext; return ID;}
%%

int opt_stmts();
int stmt();
int stmtPrima();
int opt_stmts();
int stmt_lst();
int stmt_lstPrima();
int term();
int termPrima();
int factor();
int expresion();
int expresionPrima();
int expr();
int exprPrima();
void funcError();

int main(int argc, char * argv[]){

  if (argc < 2) {
	printf ("Error, falta el nombre de un archivo\n");
	exit(1);
  }

  yyin = fopen(argv[1], "r");

  if (yyin == NULL) {
	printf("Error: el archivo no existe\n");
	exit(1);
  }

  lectura = yylex();
  if(lectura == PROGRAM){
			lectura = yylex();
			if(lectura == ID){
				lectura = yylex();
				if(lectura == BEG){
					if(opt_stmts() == OPT_STMTS){
						if(lectura == FINEXP){
							printf("Si\n");
							exit(0);
						} else {
							funcError();
						}
					}
				}
			}
		}
}

int stmt(){
	
	if(lectura == ID){	// id := expr
		lectura = yylex();
		if(lectura == ASIG){		
			if(expr() == EXPR){
	
				return STMT;
			}	
		}
	} else if(lectura == IF){ // if expression then stmt stmt'
		if(expresion() == EXPRESION) {
			lectura = yylex();
			if(lectura == THEN){
				if(stmt() == STMT){
					if(stmtPrima() == STMT_PRIMA){
						return STMT;
					}
				}
			}
		}
	} else if(lectura == WHILE){ // while expresion do stmt
		if(expresion() == EXPRESION){
			lectura = yylex();
			if(lectura == DO){
				if(stmt() == STMT){
					return STMT;
				}
			}
		}
	} else if(lectura == REPEAT){ // repeat stmt until expression
		if(stmt() == STMT){
			lectura = yylex();
			if(lectura == UNTIL){ 
				if(expresion() == EXPRESION){
					return STMT;
				}
			}
		}
	} else if(lectura == BEG){
		lectura = yylex();
		if(opt_stmts() == OPT_STMTS){
			if(lectura == END)
				return STMT;
		}
	}
	
	return -1;
}

int stmtPrima(){
	lectura = yylex();
	if(lectura == FINEXP){
		return STMT_PRIMA;
	}
	if(lectura == ELSE){
		if(stmt() == STMT){
			return STMT_PRIMA;
		}
	}
	return -1;
}

int opt_stmts(){
	lectura = yylex();
	if(lectura == FINEXP || lectura == END){ //En caso de que exista palabra vacia
		return OPT_STMTS;
	}

	if(stmt_lst() == STMT_LST){
		return OPT_STMTS;
	}
	return -1;
}

int stmt_lst(){
	
	if(stmt() == STMT){
		
		lectura = yylex();
		if(lectura == PCOMA){
			if(stmt_lstPrima() == STMT_LST_PRIMA){
			return STMT_LST;
			}
		}
		
	}
	return -1;
}

int stmt_lstPrima(){
	
	if(lectura == PCOMA){
		
		if(stmt() == STMT){
			if(stmtPrima() == STMT_PRIMA){
				return STMT_LST_PRIMA;
			}
		}
		
	}
	return -1;
}

int expr(){
	if (term() == TERM){
		
		if( exprPrima() == EXPR_PRIMA){
			
			return EXPR;
		}
	}
	return -1;
}

int exprPrima(){
	printf("PASA - %d\n",lectura);
	lectura =  yylex();
	
	if(lectura == SUMA){
		if(term() == TERM){
			if(exprPrima() == EXPR_PRIMA){
				return EXPR_PRIMA;
			}
		}
		
	} else if(lectura == RESTA){
		if(term() == TERM){
			if(exprPrima() == EXPR_PRIMA){
				return EXPR_PRIMA;
			}
		}
	}
	return -1;
}

int term(){
	
	if(factor() == FACTOR){
		
		if(termPrima() == TERM_PRIMA){
			
			return TERM;
		}
	}
	return -1;
}

int termPrima(){
	lectura = yylex();
	if(lectura == MULTI){
		if(termPrima() == TERM_PRIMA){
			return TERM_PRIMA;
		}
	} else if(lectura == DIVIDE){
		if(termPrima() == TERM_PRIMA){
			return TERM_PRIMA;
		}
	} else if (factor() == FACTOR){
		return TERM_PRIMA;
	}
	return -1;
}

int factor(){
	
	lectura = yylex();
	
	if(lectura == PARENI){	
		if(expr() == EXPR){
			lectura = yylex();
			if(lectura == PAREND){ //? Como se resuelve esto despues del expr() ?
				return FACTOR;
			}
		}
	} else if(lectura == ID){
		
		return FACTOR;
	} else if(lectura == INT){
		return FACTOR;
	}

	return -1;
}

int expresion(){
	
	lectura = yylex();
	
	if(term() == TERM){
		if(expresionPrima() == EXPRESSION_PRIMA){
			return EXPRESION;
		}
	}
	return -1;
}

int expresionPrima(){
	lectura = yylex();
	if(lectura == SUMA){
		if(term() == TERM){
			if(expresionPrima()== EXPRESSION_PRIMA){
				return EXPRESSION_PRIMA;
			}
		}
	} else if(lectura == RESTA){
		if(term() == TERM){
			if(expresionPrima() == EXPRESSION_PRIMA){
				return EXPRESSION_PRIMA;
			}
		}
	}

	return -1;
}

void funcError(){
	printf("No\n");
	exit(1);
}