@echo off
..\..\bin\lex draw.l drawlexi.pas drawlexi.skl
..\..\bin\yacc draw.y drawdefs.inc drawdefs.skl
..\..\bin\yacc draw.y drawpars.pas drawpars.skl
..\..\bin\lex draw.l lex.out
..\..\bin\yacc draw.y yacc.out
