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



int yylval;
char *yylval3;
%}

LETRA [A-Za-z]
IDENTIFICADOR [a-zA-Z][a-zA-Z0-9]*
DIGITO [1-9][0-9]*

%%

{DIGITO} { yylval = atoi(yytext); return INT; }
{LETRA} {yylval3 = yytext; return VAR; }

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

{IDENTIFICADOR} {return ID;}
%%

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

int main(int argc, char * argv[]){

  int lectura;

  if (argc < 2) {
    printf ("Error, falta el nombre de un archivo\n");
    exit(1);
  }

  yyin = fopen(argv[1], "r");

  if (yyin == NULL) {
    printf("Error: el archivo no existe\n");
    exit(1);
  }

  while ((lectura = yylex()) != FINEXP) {
        if(lectura == PROGRAM){
        	lectura = yylex();
        	if(lectura == ID){
        		lectura = yylex();
        		if(lectura == BEG){
        			lectura = yylex();
        			opt_stmts();
        		}
        	}
        }
  }
}

void stmt(){
	int lectura = yylex();
	if(lectura == ID){
		lectura = yylex();
		if(lectura == ASIG){
			expr();
		}
	} else if(lectura == IF){
		lectura = yylex();
		expresion();
		if(lectura == THEN){
			stmt();
			stmtPrima();	
		}
	} else if(lectura == WHILE){
		expresion();
		lectura = yylex();
		if(lectura == DO){
			stmt();
		}
	} else if(lectura == REPEAT){
		stmt();
		lectura = yylex();
		if(lectura == UNTIL){
			expresion();
		}
	} else if(lectura == BEG){
		opt_stmts();
		lectura = yylex();
		if(lectura == END)
			return;	 //Que se tiene que retornar cuando se termina esta funcion con un terminal?
	}
}

void opt_stmts(){
	// Como se le hace cuando no hay terminales? Se tiene que captar alguna entrada? Por el OR que existe en la gramatica opt_stmts -> stmt_lst | 3
	stmt_lst();
}

void stmt_lst(){
	stmt();
	stmt_lstPrima();
}

void stmt_lstPrima(){
	int lectura = yylex();
	if(lectura == PCOMA){
		stmt();
		stmtPrima();
	} else {
		return;
	}
}

void expr(){
	term();
	exprPrima();
}

void exprPrima(){
	int lectura =  yylex();
	if(lectura == SUMA){
		term();
		exprPrima();
	} else if(lectura == RESTA){
		term();
		exprPrima();
	} else {
		return;
	}
}

void term(){
	factor();
	termPrima();
}

void termPrima(){
	int entrada = yylex();
	if(entrada == MULTI){
		termPrima();
	} else if(entrada == DIVIDE){
		termPrima();
	} else{
		factor();
	}
}

void factor(){
	int entrada = yylex();
	if(entrada == PARENI){
		expr();
		entrada = yylex();
		if(entrada == PAREND){ //? Como se resuelve esto despues del expr() ?
			return;
		}
	}
}

void expresion(){
	term();
	expresionPrima();
}

void expresionPrima(){
	int entrada = yylex();
	if(entrada == SUMA){
		term();
		expresionPrima();
	} else if(entrada == RESTA){
		term();
		expresionPrima();
	} else {
		return;
	}
}