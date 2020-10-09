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
"if"	{return IF;}
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
void prog();
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
void error();
void acepta();

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

  prog();
}

void prog(){
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
						error();
					}
				}
			}
		}
	}
}

int opt_stmts(){
	printf("OPT_STMTS\n");
	lectura = yylex();
	printf("OPT->STMTS: DEBUG --> %d\n", lectura);
	//En caso de que sea palabra vacia
	if(lectura == FINEXP || lectura == END){
		printf("--> Retorna opt_stmts por encontrar end o end.\n");
		return OPT_STMTS;
	} else if(stmt_lst() == STMT_LST){
		return OPT_STMTS;
	}
}

int stmt_lst(){
	printf("STMT_LST\n");
	if(stmt() == STMT){
		printf("DEBUGG stmt_lst: %d\n", lectura);
		if(lectura == PCOMA){
			if(stmt_lstPrima() == STMT_LST_PRIMA){
				return STMT_LST;
			}
		} if(lectura == FINEXP){
			return STMT_LST;
		}
	}
}

int stmt_lstPrima(){
	lectura = yylex();
	printf("stmt prima prueba para terminar recursividad %d\n", lectura);
	if(stmt() == STMT){
		printf("1 DEBUGG STMT_LST': %d\n",lectura );

		if(lectura == FINEXP){
			printf("2. PASA FINEXP\n");
			return STMT_LST_PRIMA;
		}
		////////////////////////////////////////////////////
		lectura = yylex();

		if(lectura == PCOMA){ //En caso de ';' -> que aplique recursividad
			printf("DEBUG PARA END EN STMT_LST_PRIMA: %d\n", lectura);
			if(stmt_lstPrima() == STMT_LST_PRIMA){
				return STMT_LST_PRIMA;
			}
		} else if(lectura == FINEXP){ //Puede que se modique porque solo trabaja en END. para el archivo 2
			printf("PASA SEGUNDA CONDICIONAL PARA END. FINEXP\n");
			return STMT_LST_PRIMA;
		}
	} else if(lectura == FINEXP){
			printf("PASA SEGUNDA CONDICIONAL PARA END. FINEXP\n");
	}
	printf("PASA AL FINAL DE STMT_LST PRIMA : %d\n",lectura);
}

int stmt(){
	printf("STMT\n");
	printf("%d\n", lectura);
	if(lectura == ID){
		printf("ID := EXPR\n");
		lectura = yylex();
		if(lectura == ASIG){
			lectura = yylex();
			if(expr() == EXPR){
				printf("EXPR EN STMT PARA END: %d\n", lectura);
				return STMT;
				}
		}
	} else if(lectura == IF){
		printf("IF EXPRESION THE STMT STMT'\n");
		lectura = yylex();
		if(expresion() == EXPRESION){
			printf("PASA EXPRESION -->->->->->-<->\n");
			printf("Expression en lectura: %d\n", lectura);
			if(lectura == THEN){
				lectura = yylex();
					printf("ADADSAASDADS: %d\n", lectura);
				if(stmt() == STMT){
					printf("--->--->--->PASA STMT DEL IF EXPRESSION BEGIN THEN STMT\n");
				}
			}
		}
	} else if(lectura == WHILE){
		printf("ENTRA A STMT WHILE\n");
	} else if(lectura == REPEAT){

	} else if(lectura == BEG){
		printf("LLEGA A BEGIN\n");
		
		if(opt_stmts() == OPT_STMTS){
			printf("1. END BEGIN STMT %d\n", lectura);
			if(lectura == END){
				printf("SALE BEGIN\n");
				lectura = yylex();
				return STMT;
			}
		}
	}
	printf("No debe de llegar hasta aqui\n");
	return -1;
}

int stmtPrima(){

}

int expr(){
	printf("EXPR\n");
	if(term() == TERM){
		printf("REGRESA A TERM\n");
		printf("EXPR DEBBUG %d\n", lectura);
		//En base a la lectura, determina si la siguiente ficha es suma o resta
		//para determinar si se llama a expr'
		printf("--> REGRESA DE EXPR PRIMA  A EXPR\n");
		if(lectura == SUMA || lectura == RESTA){
			if(exprPrima() == EXPRESSION_PRIMA){
				printf("TERMINA EXPRPRIMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\n");
				return EXPR;
			}
		} else {
			printf("--> De EXPR a STMT?\n");
			return EXPR;
		}
	}
	
}

int exprPrima(){
	printf("EXPR' -> SUMA | RESTA\n");
	lectura = yylex();
	printf("\nexpr' lectura --> %d\n",lectura);
	if(term() == TERM){
		printf("-->EXPR PRIMA --> %d\n", lectura);
		if(lectura == SUMA || lectura == RESTA){
			if(exprPrima() == EXPR_PRIMA){
				printf("Segunda suma o resta dentro de expr prima\n");
				return EXPRESSION_PRIMA;
			}
		} else if(lectura == PCOMA || lectura == END || lectura == FINEXP){ //Palabra vacia
			printf("ENTRA CONDICIONAL EXPR PRIMA PARA END\n");
			return EXPRESSION_PRIMA;
		}
		//En caso de que coincida la palabra vacia, y creo que seria el cado en donde termina esta expresion
		// en ';', END, o END. (FINEXP)
		//if(lectura == PCOMA || lectura == END || lectura == FINEXP){
			//printf("PASA PUNTO Y COMA\n");	
			//return EXPR_PRIMA;
		//} else if(exprPrima() == EXPR_PRIMA){
			//printf("PASA SEEEEEEEEEEEEEGUNDOOOOOOOOOOOO\n");
			//return EXPR_PRIMA;
		//}
	}
}

int term(){
	printf("TERM -> LEC ACTUAL: %d\n",lectura);
	
	if(factor() == FACTOR){
		printf("TERM -> FACTOR\n");
		lectura = yylex();
		printf("DEBUGG TERM: %d\n", lectura);
		if(lectura == MULTI || lectura == DIVIDE){
			if(termPrima() == TERM_PRIMA){
				return TERM;
			}
		} else {
			printf("PALABRA VACIA EN TERM PRIMA %d\n",lectura);
			return TERM;
		}
	}
}

int termPrima(){
	printf("Term Prima -> %d\n",lectura);
	if(lectura == MULTI || lectura == DIVIDE){
		lectura = yylex();
		if(factor() == FACTOR){
				printf("-->PASA FACTOR TERM' %d\n",lectura);
			if(termPrima() == TERM_PRIMA){
				return TERM_PRIMA;
			}
		}
	} else {
		lectura = yylex();
		if(lectura == END || lectura == THEN || lectura == DO || lectura == UNTIL || lectura == FINEXP || lectura == EL){
			return TERM_PRIMA;
		}
		printf("!-Term Prima -> %d\n",lectura);
	}
	printf("No deberia de llegar hasta aqui el term' -> %d\n",lectura);
	return -1;
}

int factor(){
	printf("FACTOR -> %d %s\n",lectura,yylval3);
	if(lectura == ID || lectura == INT){
		return FACTOR;
	} else if(lectura == PARENI){
		printf("ARREGLAR PARENTESIS!\n");
		lectura = yylex();
	}
}

int expresion(){
	printf("EXPRESON: %d\n", lectura);
	if(expr() == EXPR){
		printf("lectura expr: %d\n", lectura);
		if(lectura == MENOR || lectura == MAYOR || lectura == IGUAL){
			printf("DEBUGG SIGNO EXPR: %d\n", lectura);
			lectura = yylex();
			if(expr() == EXPR){
				printf("PASA EXPR EXPRESSION !!!!!!!!!!!!!!\n");
				return EXPRESION;
			}
		}
	}
}

void error(){
	printf("No\n");
	exit(1);
}

void acepta(){
	printf("Si\n");
	exit(1);
}
