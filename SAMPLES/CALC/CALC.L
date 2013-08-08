
DIGIT           = [\0-\9];
NUMBER          = DIGIT+ (\. DIGIT+)?;
BLANK           = [1-32]+; /* Skipped characters */

%%

/************************************************************************/

NUMBER:
#{var
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
end;
#}

/************************************************************************/

\+:
#{
begin
     {YACC_Plus}
     TTokenAttributes(AInfo).Token := YACC_Plus;
end;
#}

/************************************************************************/

\-:
#{
begin
     {YACC_Minus}
     TTokenAttributes(AInfo).Token := YACC_Minus;
end;
#}

/************************************************************************/

\*:
#{
begin
     {YACC_Mul}
     TTokenAttributes(AInfo).Token := YACC_Mul;
end;
#}

/************************************************************************/

\/:
#{
begin
     {YACC_Div}
     TTokenAttributes(AInfo).Token := YACC_Div;
end;
#}

/************************************************************************/

\(:
#{
begin
     {YACC_LB}
     TTokenAttributes(AInfo).Token := YACC_LB;
end;
#}

/************************************************************************/

\):
#{
begin
     {YACC_RB}
     TTokenAttributes(AInfo).Token := YACC_RB;
end;
#}
/************************************************************************/

BLANK:
#{
begin
     {BLANK}
     AReturn := False;
end;
#}

/************************************************************************/

%%
