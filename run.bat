@echo off

bison -d -o %1.tab.c %1.y	
gcc -c -g -I.. %1.tab.c

flex -o lex.yy.c %1.l
gcc -c -g -I.. lex.yy.c

gcc -o %1 %1.tab.o lex.yy.o
