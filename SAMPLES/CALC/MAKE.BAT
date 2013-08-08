@echo off
..\..\bin\lex calc.l calclexi.pas calclexi.skl
..\..\bin\yacc calc.y calcdefs.inc calcdefs.skl
..\..\bin\yacc calc.y calcpars.pas calcpars.skl
..\..\bin\lex calc.l lex.out
..\..\bin\yacc calc.y yacc.out
