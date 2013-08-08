%type lalr
%start s
%token Number Plus Minus Mul Div LB RB Assign Coma SColen Id
%token Draw Circle Line Box RepDraw Point Fun

%%

/*****************************************************************
*                                                                *
*                                                                *
*                                                                *
*****************************************************************/

s : stmts
#{var Action: PAction;
begin
     { s -> stmts }
     with PDrawParser( AParser)^
     do begin
        Action := PAction( PopAttribute);
        Action^.Execute;
        Action^.Free;
        end;
end;#}
;

/*****************************************************************
*                                                                *
*                                                                *
*                                                                *
*****************************************************************/

stmts : stmts SColen stmt
#{var Action: PAction;
    CAction: PCompAction;
begin
     { stmts -> stmts ; stmt }
     with PDrawParser( AParser)^
     do begin
        Action := PAction( PopAttribute);
        CAction := PCompAction( PopAttribute);
        CAction^.AddAction( Action);
        PushAttribute( CAction);
        end;
end;#}


| stmt
#{var Action: PAction;
    CAction: PCompAction;
begin
     { stmts -> stmt }
     with PDrawParser( AParser)^
     do begin
        Action := PAction( PopAttribute);
        CAction := New( PCompAction, Create);
        CAction^.AddAction( Action);
        PushAttribute( CAction);
        end;
end;#}
;

/*****************************************************************
*                                                                *
*                                                                *
*                                                                *
*****************************************************************/

stmt : def_stmt
#{begin
     { stmt -> def_stmt }
end;#}


| drw_stmt
#{begin
     { stmt -> drw_stmt }

end;#}
;

/*****************************************************************
*                                                                *
*                                                                *
*                                                                *
*****************************************************************/

def_stmt : Id Assign exp
#{var Exp: PExp;
     Id: PIdAttribute;
     Symbol: PSymbol;
     Value: PValue;
     Action: PAction;
begin
     { def_stmt -> Id = exp }
     with PDrawParser( AParser)^
     do begin
        Exp := PExp( PopAttribute);
        Id := PIdAttribute( PopAttribute);
        Symbol := FindSymbol( Id^.Str);

        if ( Symbol = nil)
        then begin
             Value := New( PValue, Create( 0));
             Symbol := New( PSymbol, Create( Id^.Str, symValue, Value));
             AddSymbol( Symbol);
             end
        else if ( Symbol^.GetType = symValue)
             then Value := PValue( Symbol^.GetAttributes)
             else begin
                  AddError( New( PMessageError, Create('SYMANTIC ERROR: Reuse symbol to define it as variable.')));
                  Value := nil;
                  end;

        if ( Value <> nil)
        then Action := New( PAssign, Create( Exp, Value))
        else begin
             Exp^.Free;
             Action := New( PAction, Create);
             end;

        PushAttribute( Action);
        Id^.Free;
        end;
end;#}


| Id Assign cfigure
#{var CFigure: PCompAction;
     Id: PIdAttribute;
     Symbol: PSymbol;
     Value: PValue;
     Action: PAction;
begin
     { def_stmt -> Id = cfigure }
     with PDrawParser( AParser)^
     do begin
        CFigure := PCompAction( PopAttribute);
        Id := PIdAttribute( PopAttribute);
        Symbol := FindSymbol( Id^.Str);

        if ( Symbol = nil)
        then begin
             Symbol := New( PSymbol, Create( Id^.Str, symAction, CFigure));
             AddSymbol( Symbol);
             end
        else begin
             CFigure^.Free;
             AddError( New( PMessageError, Create('SYMANTIC ERROR: Reuse variable to define it as figure.')));
             end;

        Action := New( PAction, Create);

        PushAttribute( Action);
        Id^.Free;
        end;
end;#}
;

/*****************************************************************
*                                                                *
*                                                                *
*                                                                *
*****************************************************************/

drw_stmt : Draw cfigure
#{begin
       { drw_stmt -> Draw cfigure }
end;#}

| RepDraw exp Id
#{var Id: PIdAttribute;
    NewAction: PAction;
    Symbol: PSymbol;
    Exp: PExp;
    Action : PAction;
begin
     { drw_stmt -> RepDraw exp Id }
     with PDrawParser( AParser)^
     do begin
        Id := PIdAttribute( PopAttribute);
        Exp := PExp( PopAttribute);
        Symbol := FindSymbol( Id^.Str);
        Action := nil;
        if ( Symbol <> nil)
        then begin
             if ( Symbol^.GetType = symAction)
             then begin
                  Action := PAction( Symbol^.GetAttributes);
                  Action := New( PIndAction, Create( Action));
                  end
             else AddError( New( PMessageError, Create('SYMANTIC ERROR: Using not figure symbol as figure.')));
             end
        else AddError( New( PMessageError, Create('SYMANTIC ERROR: Using not defined symbol as figure.')));
        NewAction := New( PRepAction, Create( Exp, Action));
        PushAttribute( NewAction);
        Id^.Free;
        end;
end;#}

| RepDraw exp cfigure
#{var NewAction: PAction;
    Exp: PExp;
    Action : PAction;
begin
     { drw_stmt -> RepDraw exp cfigure }
     with PDrawParser( AParser)^
     do begin
        Action := PAction( PopAttribute);
        Exp := PExp( PopAttribute);
        NewAction := New( PRepAction, Create( Exp, Action));
        PushAttribute( NewAction);
        end;
end;#}

| Draw Id
#{var Id: PIdAttribute;
    Symbol: PSymbol;
    Action: PAction;
    NewAction: PAction;
begin
     {drw_stmt -> Draw Id}
     with PDrawParser( AParser)^
     do begin
        Id := PIdAttribute( PopAttribute);
        Symbol := FindSymbol( Id^.Str);
        if ( Symbol <> nil)
        then begin
             if ( Symbol^.GetType = symAction)
             then begin
                  Action := PAction( Symbol^.GetAttributes);
                  NewAction := New( PIndAction, Create( Action));
                  end
             else begin
                  NewAction := New( PIndAction, Create( nil));
                  AddError( New( PMessageError, Create('SYMANTIC ERROR: Using not figure symbol as figure.')));
                  end;
             end
        else begin
             NewAction := New( PIndAction, Create( nil));
             AddError( New( PMessageError, Create('SYMANTIC ERROR: Using not defined symbol as figure.')));
             end;
        PushAttribute( NewAction);
        Id^.Free;
        end;
end;#}
;


/*****************************************************************
*                                                                *
*                                                                *
*                                                                *
*****************************************************************/

cfigure : LB figures SColen RB

#{begin
       { cfigure -> ( figures ) }
end;#}
;

/*****************************************************************
*                                                                *
*                                                                *
*                                                                *
*****************************************************************/

figures : figures SColen figure
#{var Action: PAction;
    CAction: PCompAction;
begin
     { figures -> cfigures ; figure }
     with PDrawParser( AParser)^
     do begin
        Action := PAction( PopAttribute);
        CAction := PCompAction( PopAttribute);
        CAction^.AddAction( Action);
        PushAttribute( CAction);
        end;
end;#}

| figure

#{var Action: PAction;
    CAction: PCompAction;
begin
     { figures -> figure }
     with PDrawParser( AParser)^
     do begin
        Action := PAction( PopAttribute);
        CAction := New( PCompAction, Create);
        CAction^.AddAction( Action);
        PushAttribute( CAction);
        end;
end;#}
;

/*****************************************************************
*                                                                *
*                                                                *
*                                                                *
*****************************************************************/

figure : Id Assign exp

#{var Exp: PExp;
     Id: PIdAttribute;
     Symbol: PSymbol;
     Value: PValue;
     Action: PAction;
begin
     { figure -> Id = exp }
     with PDrawParser( AParser)^
     do begin
        Exp := PExp( PopAttribute);
        Id := PIdAttribute( PopAttribute);
        Symbol := FindSymbol( Id^.Str);

        if ( Symbol = nil)
        then begin
             Value := New( PValue, Create( 0));
             Symbol := New( PSymbol, Create( Id^.Str, symValue, Value));
             AddSymbol( Symbol);
             end
        else if ( Symbol^.GetType = symValue)
             then Value := PValue( Symbol^.GetAttributes)
             else begin
                  AddError( New( PMessageError, Create('SYMANTIC ERROR: Reuse symbol to define it as variable.')));
                  Value := nil;
                  end;

        if ( Value <> nil)
        then Action := New( PAssign, Create( Exp, Value))
        else begin
             Exp^.Free;
             Action := New( PAction, Create);
             end;

        PushAttribute( Action);
        Id^.Free;
        end;
end;#}

| drw_stmt

#{var Id: PIdAttribute;
     Symbol: PSymbol;
     Action: PAction;
     NewAction: PIndAction;
begin
     { figure -> Id }
     {with PDrawParser( AParser)^
     do begin
        Id := PIdAttribute( PopAttribute);
        Symbol := FindSymbol( Id^.Str);
        Action := nil;
        if (Symbol <> nil)
        then begin
             if ( Symbol^.GetType = symAction)
             then Action := PAction( Symbol^.GetAttributes)
             else AddError( New( PMessageError, Create('SYMANTIC ERROR: Useing not figure symbol as figure.')));
             end
        else AddError( New( PMessageError, Create('SYMANTIC ERROR: Useing not defined symbol as figure.')));
        NewAction := New( PIndAction, Create( Action));
        PushAttribute( NewAction);
        Id^.Free;
        end;}
end;#}

| Circle exp Coma exp Coma exp

#{var Exp1, Exp2, Exp3: PExp;
    Action: PCircleDraw;
begin
     { figure -> Circle exp,exp,exp }
     with PDrawParser( AParser)^
     do begin
        Exp3 := PExp( PopAttribute);
        Exp2 := PExp( PopAttribute);
        Exp1 := PExp( PopAttribute);

        Action := New( PCircleDraw, Create( Exp1, Exp2, Exp3));
        PushAttribute( Action);
        end;
end;#}


| Box exp Coma exp Coma exp Coma exp

#{var Exp1, Exp2, Exp3, Exp4: PExp;
    Action: PBoxDraw;
begin
       { figure -> Box exp, exp, exp, exp }
     with PDrawParser( AParser)^
     do begin
        Exp4 := PExp( PopAttribute);
        Exp3 := PExp( PopAttribute);
        Exp2 := PExp( PopAttribute);
        Exp1 := PExp( PopAttribute);
        Action := New( PBoxDraw, Create( Exp1, Exp2, Exp3, Exp4));
        PushAttribute( Action);
        end;
end;#}


| Line exp Coma exp Coma exp Coma exp

#{var Exp1, Exp2, Exp3, Exp4: PExp;
    Action: PLineDraw;
begin
     {figure -> Line exp, exp, exp, exp}
     with PDrawParser( AParser)^
     do begin
        Exp4 := PExp( PopAttribute);
        Exp3 := PExp( PopAttribute);
        Exp2 := PExp( PopAttribute);
        Exp1 := PExp( PopAttribute);
        Action := New( PLineDraw, Create( Exp1, Exp2, Exp3, Exp4));
        PushAttribute( Action);
        end;
end;#}

| Point exp Coma exp

#{var Exp1, Exp2: PExp;
    Action: PPointDraw;
begin
     {figure -> Point exp, exp}
     with PDrawParser( AParser)^
     do begin
        Exp2 := PExp( PopAttribute);
        Exp1 := PExp( PopAttribute);
        Action := New( PPointDraw, Create( Exp1, Exp2));
        PushAttribute( Action);
        end;
end;#}
;


/*****************************************************************
*                                                                *
*                                                                *
*                                                                *
*****************************************************************/

exp : exp Plus trm

#{var Exp: POpExp;
    Exp1, Exp2: PExp;
begin
     {exp -> exp + trm}
     with PDrawParser( AParser)^
     do begin
        Exp2 := PExp( PopAttribute);
        Exp1 := PExp( PopAttribute);

        Exp := New( POpExp, Create( opSum, Exp1, Exp2));
        PushAttribute( Exp);
        end;
end;#}

| exp Minus trm

#{var Exp: POpExp;
    Exp1, Exp2: PExp;
begin
     {exp -> exp - trm}
     with PDrawParser( AParser)^
     do begin
        Exp2 := PExp( PopAttribute);
        Exp1 := PExp( PopAttribute);

        Exp := New( POpExp, Create( opSub, Exp1, Exp2));
        PushAttribute( Exp);
        end;
end;#}

| trm

#{begin
       { exp -> trm }
end;#}
;

/*****************************************************************
*                                                                *
*                                                                *
*                                                                *
*****************************************************************/

trm : trm Mul fct

#{var Exp: POpExp;
    Exp1, Exp2: PExp;
begin
     {trm -> trm * fct}
     with PDrawParser( AParser)^
     do begin
        Exp2 := PExp( PopAttribute);
        Exp1 := PExp( PopAttribute);

        Exp := New( POpExp, Create( opMul, Exp1, Exp2));
        PushAttribute( Exp);
        end;
end;#}


| trm Div fct

#{var Exp: POpExp;
    Exp1, Exp2: PExp;
begin
     { trm -> trm / fct }
     with PDrawParser( AParser)^
     do begin
        Exp2 := PExp( PopAttribute);
        Exp1 := PExp( PopAttribute);

        Exp := New( POpExp, Create( opDiv, Exp1, Exp2));
        PushAttribute( Exp);
        end;
end;#}

| fct

#{begin
end;#}
    ;

/*****************************************************************
*                                                                *
*                                                                *
*                                                                *
*****************************************************************/

fct : LB exp RB

#{begin
       { fct -> ( exp ) }
end;#}

| Minus fct

#{var NewExp: PNegExp;
    Exp: PExp;
begin
     { fct -> - fct }
     with PDrawParser( AParser)^
     do begin
        Exp := PExp( PopAttribute);
        NewExp := New( PNegExp, Create( Exp));
        PushAttribute( NewExp);
        end;
end;#}

| Number

#{var Value: PValue;
    Constant: PConstantExp;
begin
     {fct -> number}
     with PDrawParser( AParser)^
     do begin
        Value := PValue( PopAttribute);
        Constant := New( PConstantExp, Create( Value^.Value));
        Value^.Free;
        PushAttribute( Constant);
        end;
end;#}

| Id

#{var Value: PValue;
    Id: PIdAttribute;
    Symbol: PSymbol;
begin
     {fct -> Id}
     with PDrawParser( AParser)^
     do begin
        Id := PIdAttribute( PopAttribute);
        Symbol := FindSymbol( Id^.Str);
        if ( Symbol = nil)
        then begin
             Value := New( PValue, Create( 0));
             Symbol := New( PSymbol, Create( Id^.Str, symValue, Value));
             AddSymbol( Symbol);
             end
        else begin
             if ( Symbol^.GetType = symValue)
             then Value := PValue( Symbol^.GetAttributes)
             else AddError( New( PMessageError, Create('SYMANTIC ERROR: Use nonvariable symbol as variable.')));
             end;
        if ( Value <> nil)
        then PushAttribute( New( PVarExp, Create( Value)))
        else PushAttribute( New( PConstantExp, Create( 0)));
        Id^.Free;
        end;
end;#}


| Fun LB exp RB
#{var Exp: PExp;
    Id: PIdAttribute;
    NewExp: PFunctionExp;
    F: TFunction;

begin
     {fct -> Id( exp )}
     with PDrawParser( AParser)^
     do begin
        Exp := PExp( PopAttribute);
        Id := PIdAttribute( PopAttribute);
        if (Id^.Str = 'sin')
        then F := fnSin
        else if (Id^.Str = 'cos')
        then F := fnCos
        else if (Id^.Str = 'tan')
        then F := fnTan
        else if (Id^.Str = 'ln')
        then F := fnLn
        else if (Id^.Str = 'sqrt')
        then F := fnSqrt
        else if (Id^.Str = 'sqr')
        then F := fnSqr
        else if (Id^.Str = 'exp')
        then F := fnExp
        else F := fnNone;

        NewExp := New( PFunctionExp, Create( F, Exp));

        PushAttribute( NewExp);
        Id^.Free;
        end;
end;#}
;
%%
