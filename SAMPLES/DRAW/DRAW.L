DIGIT           = [\0-\9];
LETTER          = [\A-\Z,\a-\z,\_];
NUMBER          = DIGIT+ (\. DIGIT+)?;
ID              = LETTER (DIGIT | LETTER)*;
BLANK           = [1-32]+; /* Skipped characters */

%%

/******************************************************/

"sin"|"cos"|"tan"|"ln"|"sqr"|"sqrt"|"exp" :
#{begin
     {YACC_Fun}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Fun;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;#}



/******************************************************/

"repdraw" :
#{begin
       {YACC_RepDraw}
       TTokenAttributes(AInfo).Token := YACC_RepDraw;
end;#}

/******************************************************/

"draw" :
#{begin
       {YACC_DRAW}
       TTokenAttributes(AInfo).Token := YACC_Draw;
end;#}

/******************************************************/

"circle" :
#{begin
       {YACC_Circle}
       TTokenAttributes(AInfo).Token := YACC_Circle;
end;#}

/******************************************************/

"line" :
#{begin
       {YACC_Line}
       TTokenAttributes(AInfo).Token := YACC_Line;
end;#}

/******************************************************/

"box" :
#{begin
       {YACC_Box}
       TTokenAttributes(AInfo).Token := YACC_Box;
end;#}

/******************************************************/

"point" :
#{begin
       {YACC_Point}
       TTokenAttributes(AInfo).Token := YACC_Point;
end;#}

/******************************************************/

NUMBER : #{var
     Value: Real;
     Code: Integer;
begin
     {YACC_Number}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Number;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        Val( Lexeme, Value, Code)
        end;
end;#}

/******************************************************/

ID : #{begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;#}

/******************************************************/

BLANK :
#{begin
     {BLANK}
     AReturn := False;
end;#}

/******************************************************/

\= :
#{begin
     {YACC_Assign}
     TTokenAttributes(AInfo).Token := YACC_Assign;
end;#}

/******************************************************/

\+ :
#{begin
     {YACC_Plus}
     TTokenAttributes(AInfo).Token := YACC_Plus;
end;#}

/******************************************************/

\- :
#{begin
     {YACC_Minus}
     TTokenAttributes(AInfo).Token := YACC_Minus;
end;#}

/******************************************************/

\/ :
#{begin
     {YACC_Plus}
     TTokenAttributes(AInfo).Token := YACC_Div;
end;#}

/******************************************************/

\* :
#{begin
     {YACC_Mul}
     TTokenAttributes(AInfo).Token := YACC_Mul;
end;#}

/******************************************************/

\( :
#{begin
     {YACC_LB}
     TTokenAttributes(AInfo).Token := YACC_LB;
end;#}

/******************************************************/

\) :
#{begin
     {YACC_RB}
     TTokenAttributes(AInfo).Token := YACC_RB;
end;#}

/******************************************************/

\, :
#{begin
       {YACC_Coma}
       TTokenAttributes(AInfo).Token := YACC_Coma;
end;#}

/******************************************************/

\; :
#{begin
       {YACC_SColen}
       TTokenAttributes(AInfo).Token := YACC_SColen;
end;#}

/******************************************************/

%%
