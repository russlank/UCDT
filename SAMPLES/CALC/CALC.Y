%type lalr
%start S
%token Number Plus Minus Mul Div LB RB

%%

/********************************************************************/

S       : E
#{{ S -> E }
var V1: PNumberAttr;
begin
     WriteLn('S -> E');
     V1 := PNumberAttr( AParser^.PopAttribute);
     WriteLn( 'The result = ', V1^.Value);
     V1^.Free;
end;
#}
        ;

/********************************************************************/

E       : E Plus T
#{{E -> E + T}
var V1, V2: PNumberAttr;
begin
     WriteLn('E -> E + T');
     V1 := PNumberAttr( AParser^.PopAttribute);
     V2 := PNumberAttr( AParser^.PopAttribute);
     V1^.Value := V1^.Value + V2^.Value;
     AParser^.PushAttribute( V1);
     V2^.Free;
end;
#}

/********************************************************************/

        | E Minus T
#{{E -> E - T}
var V1, V2: PNumberAttr;
begin
     WriteLn('E -> E - T');
     V1 := PNumberAttr( AParser^.PopAttribute);
     V2 := PNumberAttr( AParser^.PopAttribute);
     V1^.Value := V1^.Value - V2^.Value;
     AParser^.PushAttribute( V1);
     V2^.Free;
end;
#}

/********************************************************************/

        | T
#{{E -> T}
begin
     WriteLn('E -> T');
end;
#}
        ;

/********************************************************************/

T       : T Mul F
#{{T -> T * F}
var V1, V2: PNumberAttr;
begin
     WriteLn('T -> T * F');
     V1 := PNumberAttr( AParser^.PopAttribute);
     V2 := PNumberAttr( AParser^.PopAttribute);
     V1^.Value := V1^.Value * V2^.Value;
     AParser^.PushAttribute( V1);
     V2^.Free;
end;
#}

/********************************************************************/

        | T Div F
#{{E -> T / F}
var V1, V2: PNumberAttr;
begin
     WriteLn('E -> T / F');
     V1 := PNumberAttr( AParser^.PopAttribute);
     V2 := PNumberAttr( AParser^.PopAttribute);
     V1^.Value := V1^.Value / V2^.Value;
     AParser^.PushAttribute( V1);
     V2^.Free;
end;
#}

/********************************************************************/

        | F
#{{T -> F}
begin
     WriteLn('T -> F');
end;
#}
        ;

/********************************************************************/

F       : Number
#{{F -> Number}
begin
     WriteLn('F -> Number');
end;
#}

/********************************************************************/

        | LB E RB
#{{F -> ( E )}
begin
     WriteLn('F -> ( E )');
end;
#}

/********************************************************************/

        | Minus F
#{{F -> -F}
var V1: PNumberAttr;
begin
     WriteLn('F -> -F');
     V1 := PNumberAttr( AParser^.PopAttribute);
     V1^.Value := - V1^.Value;
     AParser^.PushAttribute( V1);
end;
#}
        ;
%%
