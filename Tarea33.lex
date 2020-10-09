/* Archivo con el reconocedor léxico para la calculadora */
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
#define ELSE 37
#define WHILE 38
#define DO 39
#define REPEAT 40
#define UNTIL 41



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
"else"    {return ELSE;}
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


"endw"    {return FINW;}
"true"    {return BOOLEAN;}
"false"   {return BOOLEAN;}

{IDENTIFICADOR} {return ID;}
%%
void prog();
void opt_stmts();
void stmt();
void stmtPrima();
void opt_stmts();
void stmt_lst();
void stmt_lstPrima();
void term();
void termPrima();
void factor();
void expresion();
void expresionPrima();
void expr();
void exprPrima();
void error();

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
				opt_stmts();
			}
		}
	}
}

void opt_stmts(){
	lectura = yylex();
	printf("opt_stmts -> %d\n", lectura);
	//En caso de que sea palabra vacia y se encuentre al final
	//del programa o de un statement. (begin opt_stmts end)
	if(lectura == FINEXP || lectura == END){
		printf("Si\n");
		exit(0);
	} else {	//Si es que no tiene un termina END, va por la siguiente regla.
		stmt_lst();
	}
}

void stmt_lst(){
	stmt();

	if(lectura == FINEXP){ //Palabra vacia
		printf("Si\n");
		exit(0);
	}
	if(lectura == PCOMA){
		printf("PCOMA\n");
		stmt_lstPrima();
	}
}

void stmt_lstPrima(){
	lectura = yylex();
	stmt();
	stmt_lstPrima();
}

void stmt(){
	if(lectura == ID){	// id := expr
		printf("STMT -> ASIG\n");
		lectura = yylex();
		if(lectura == ASIG){ 	
			expr();
			printf("EXPR\n");
		}
	} else if(lectura == IF){
		printf("IF\n");
		lectura = yylex();
		expresion();
	}
}

void expr(){
	term();
	lectura = yylex();
	printf("EXPR: %d\n", lectura);
	if(lectura == SUMA){
		printf("PASA SUMA EXPR\n");
		exprPrima();
	} else if(lectura == RESTA){
		printf("pasa resta\n");
	} else {
		return;
	}
}

void exprPrima(){
	printf("EXPR PRIMA: %d\n", lectura);
	if(lectura == SUMA || lectura == RESTA){
		lectura = yylex();
		term();
	} else {
		return;
	}
}

void term(){
	factor();
	termPrima();
}

void termPrima(){
	lectura = yylex();
	printf("termPrima -> %d\n", lectura);
}

void factor(){
	lectura = yylex();
	printf("FACTOR -> %d\n", lectura);
	if(lectura == ID){
		printf("F\n");
		lectura = yylex();
		return;
	} else if(lectura == INT){
		lectura = yylex();
		return;
	} else if(lectura == PARENI){
		expr();
		lectura = yylex();
		if(lectura != PAREND){
			error();
		}
	}
}

void expresion(){
	expr();
	lectura = yylex();
	printf("EXPRESION %d\n", lectura);
	if(lectura == MENOR){
		lectura = yylex();
		printf("MENOR\n");
		expr();
	}
}

void error(){
	printf("No\n");
	exit(0);
}