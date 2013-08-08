unit DrawParser;

interface

uses Generics, Lexical, DrawLexical, Parser, Strings, Graph;

type PSemanticProc = ^TSemanticProc;
     TSemanticProc = procedure( AParser: PParser);

     Float = Double;

     PExp = ^TExp;
     TExp = object( TGeneric)
         function Value: Float; virtual;
         end;

     TOperation = ( opSum, opSub, opMul, opDiv);

     POpExp = ^TOpExp;
     TOpExp = object( TExp)
     private
         Operation: TOperation;
         Left: PExp;
         Right: PExp;
     public
         constructor Create( AOperation: TOperation; ALeft, ARight: PExp);
         destructor Destroy; virtual;
         function Value: Float; virtual;
         end;

     PNegExp = ^TNegExp;
     TNegExp = object( TExp)
     private
         Exp: PExp;
     public
         constructor Create( AExp: PExp);
         destructor Destroy; virtual;
         function Value: Float; virtual;
         end;

     PConstantExp = ^TConstantExp;
     TConstantExp = object( TExp)
     private
         Val: Float;
     public
         constructor Create( AValue: Float);
         function Value: Float; virtual;
         end;

     PValue = ^TValue;
     TValue = object( TGeneric)
     private
         Value: Float;
     public
         constructor Create( AValue: Float);
         destructor Destroy; virtual;
         function GetValue: Float;
         procedure SetValue( AValue: Float);
         end;

     PIdAttribute = ^TIdAttribute;
     TIdAttribute = object( TGeneric)
         Str: string;
         constructor Create( AIdStr: string);
         end;

     PVarExp = ^TVarExp;
     TVarExp = object( TExp)
     private
         Val: PValue;
     public
         constructor Create( AValue: PValue);
         function Value: Float; virtual;
         end;

     TFunction = ( fnNone, fnSin, fnCos, fnTan, fnLn, fnSqrt, fnSqr, fnExp);

     PFunctionExp = ^TFunctionExp;
     TFunctionExp = object( TExp)
     private
         Exp: PExp;
         TheFunction: TFunction;
     public
         constructor Create( AFun: TFunction; AExp: PExp);
         function Value: Float; virtual;
         destructor Destroy; virtual;
         end;

     TSymbolType = ( symNone, symAction, symValue);

     PSymbol = ^TSymbol;
     TSymbol = object( TGeneric)
     private
         Typ: TSymbolType;
         Title: PString;
         Attributes: PGeneric;
     public
         constructor Create( ATitle: string; AType: TSymbolType; AAttributes: PGeneric);
         destructor Destroy; virtual;
         function GetTitle: string;
         function GetType: TSymbolType;
         function GetAttributes: PGeneric;
         procedure SetAttributes( AAttributes: PGeneric);
         procedure SetType( AType: TSymbolType);
         end;

     PAction = ^TAction;
     TAction = object( TGeneric)
     public
         procedure Execute; virtual;
         function Executable: Boolean; virtual;
         end;

     PRepAction = ^TRepAction;
     TRepAction = object( TAction)
     private
         Exp: PExp;
         Action: PAction;
     public
         constructor Create( AExp: PExp; AAction: PAction);
         destructor Destroy; virtual;
         procedure Execute; virtual;
         function Executable: Boolean; virtual;
         end;


     PIndAction = ^TIndAction;
     TIndAction = object( TAction)
     private
         Action: PAction;
     public
         constructor Create( AAction: PAction);
         procedure Execute; virtual;
         function Executable: Boolean; virtual;
         end;

     PCompAction = ^TCompAction;
     TCompAction = object( TAction)
     private
         SubActions: TContainerCollection;
     public
         constructor Create;
         destructor Destroy; virtual;
         procedure Execute; virtual;
         procedure AddAction( AAction: PAction);
         function Executable: Boolean; virtual;
         end;

     PCircleDraw = ^TCircleDraw;
     TCircleDraw = object( TAction)
     private
         Exp1, Exp2, Exp3: PExp;
     public
         constructor Create( AExp1, AExp2, AExp3: PExp);
         procedure Execute; virtual;
         destructor Destroy; virtual;
         function Executable: Boolean; virtual;
         end;

     PBoxDraw = ^TBoxDraw;
     TBoxDraw = object( TAction)
     private
         Exp1, Exp2, Exp3, Exp4: PExp;
     public
         constructor Create( AExp1, AExp2, AExp3, AExp4: PExp);
         procedure Execute; virtual;
         destructor Destroy; virtual;
         function Executable: Boolean; virtual;
         end;

     PLineDraw = ^TLineDraw;
     TLineDraw = object( TAction)
     private
         Exp1, Exp2, Exp3, Exp4: PExp;
     public
         constructor Create( AExp1, AExp2, AExp3, AExp4: PExp);
         procedure Execute; virtual;
         destructor Destroy; virtual;
         function Executable: Boolean; virtual;
         end;

     PPointDraw = ^TPointDraw;
     TPointDraw = object( TAction)
     private
         Exp1, Exp2: PExp;
     public
         constructor Create( AExp1, AExp2: PExp);
         procedure Execute; virtual;
         destructor Destroy; virtual;
         function Executable: Boolean; virtual;
         end;

     PAssign = ^TAssign;
     TAssign = object( TAction)
     private
         Exp: PExp;
         Variable: PValue;
     public
         constructor Create( AExp: PExp; AVar: PValue);
         procedure Execute; virtual;
         destructor Destroy; virtual;
         function Executable: Boolean; virtual;
         end;

     PDrawParser = ^TDrawParser;
     TDrawParser = object( TParser)
     private
        Symbols: TContainerCollection;
        Variables: TContainerCollection;
        Actions: TContainerCollection;
        Lexical: PDrawLexical;
     public
        constructor Create( AOwner: PErrGeneric; ASource: PStream);
        destructor Destroy; virtual;
        procedure ExecuteSemantic( ARule: Byte); virtual;
        procedure NextToken; virtual;
        function GetGoto( ATopState: Byte; ANonterminal: Byte): Byte; virtual;
        procedure GetAction( ATopState: Byte; ATerminal: Word; var AAction: TActionRec); virtual;
        function GetNonterminal( ARule: Byte): Byte; virtual;
        function GetRuleSize( ARule: Byte): Byte; virtual;
        procedure Error( AErrorCode: Byte); virtual;
        procedure AddSymbol( ASymbol: PSymbol);
        function FindSymbol( ATitle: string): PSymbol;
        end;

implementation

function TExp.Value: Float;
begin
     Value := 0;
end;

constructor TOpExp.Create( AOperation: TOperation; ALeft, ARight: PExp);
begin
     inherited Create;
     Operation := AOperation;
     Left := ALeft;
     Right := ARight;
end;

destructor TOpExp.Destroy;
begin
     if (Left <> nil)
     then Left^.Free;
     if (Right <> nil)
     then Right^.Free;
     inherited Destroy;
end;

function TOpExp.Value: Float;
begin
     if (( Left <> nil) and (Right <> nil))
     then begin
          case Operation
          of opSum: Value := Left^.Value + Right^.Value;
             opSub: Value := Left^.Value - Right^.Value;
             opMul: Value := Left^.Value * Right^.Value;
             opDiv: Value := Left^.Value / Right^.Value;
             else
                  Value := 0;
             end;
          end;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TNegExp.Create( AExp: PExp);
begin
     inherited Create;
     Exp := AExp;
end;

destructor TNegExp.Destroy;
begin
     inherited Destroy;
end;

function TNegExp.Value: Float;
begin
     if ( Exp <> nil)
     then Value := - Exp^.Value
     else Value := 0;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TConstantExp.Create( AValue: Float);
begin
     inherited Create;
     Val := AValue;
end;

function TConstantExp.Value: Float;
begin
     Value := Val;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TVarExp.Create( AValue: PValue);
begin
     inherited Create;
     Val := AValue;
end;

function TVarExp.Value: Float;
begin
     if (Val <> nil)
     then Value := Val^.Value
     else Value := 0;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TFunctionExp.Create( AFun: TFunction; AExp: PExp);
begin
     inherited Create;
     TheFunction := AFun;
     Exp := AExp;
end;

function TFunctionExp.Value: Float;
var Val: Float;
begin
     if ( Exp <> nil)
     then begin
          Val := Exp^.Value;
          case TheFunction
          of fnSin: Val := Sin( Val);
             fnCos: Val := Cos( Val);
             fnTan: Val := Sin( Val) / Cos( Val);
             fnLn: Val := Ln( Val);
             fnSqrt: Val := Sqrt( Val);
             fnSqr: Val := Sqr( Val);
             fnExp: Val := System.Exp( Val);
             end;
          Value := Val;
          end
     else Value := 0;
end;

destructor TFunctionExp.Destroy;
begin
     if ( Exp <> nil)
     then Exp^.Free;
     inherited destroy;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TSymbol.Create( ATitle: string; AType: TSymbolType; AAttributes: PGeneric);
begin
     inherited Create;
     Typ := AType;
     Title := AllocateString( ATitle);
     Attributes := AAttributes;
end;

destructor TSymbol.Destroy;
begin
     if (Title <> nil)
     then FreeString( Title);
     if (Attributes <> nil)
     then Attributes^.Free;
     inherited Destroy;
end;

function TSymbol.GetTitle: string;
begin
     if (Title <> nil)
     then GetTitle := Title^
     else GetTitle := '';
end;

function TSymbol.GetAttributes: PGeneric;
begin
     GetAttributes := Attributes;
end;

procedure TSymbol.SetAttributes( AAttributes: PGeneric);
begin
     if (Attributes <> nil)
     then Attributes^.Free;
     Attributes := AAttributes;
end;

function TSymbol.GetType: TSymbolType;
begin
     GetType := Typ;
end;

procedure TSymbol.SetType( AType: TSymbolType);
begin
     Typ := AType;
end;


{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TValue.Create( AValue: Float);
begin
     inherited Create;
     Value := AValue;
end;

destructor TValue.Destroy;
begin
     inherited Destroy;
end;

function TValue.GetValue: Float;
begin
     GetValue := Value;
end;

procedure TValue.SetValue( AValue: Float);
begin
     Value := AValue;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TIdAttribute.Create( AIdStr: string);
begin
     inherited Create;
     Str := AIdStr;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

procedure TAction.Execute;
begin
end;

function TAction.Executable: Boolean;
begin
     Executable := False;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TRepAction.Create( AExp: PExp; AAction: PAction);
begin
     inherited Create;
     Exp := AExp;
     Action := AAction;
end;

destructor TRepAction.Destroy;
begin
     if ( Exp <> nil)
     then Exp^.Free;
     if ( Action <> nil)
     then Action^.Free;
end;

procedure TRepAction.Execute;
var Count: Longint;
    I: Longint;
begin
     if (( Exp <> nil) and (Action <> nil))
     then begin
          Count := Round( Exp^.Value);
          if ( Count > 0)
          then for I := 1 to Count
               do Action^.Execute;
          end;
end;

function TRepAction.Executable: Boolean;
begin
     Executable := True;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TIndAction.Create( AAction: PAction);
begin
     inherited Create;
     Action := AAction;
end;
procedure TIndAction.Execute;
begin
     if ( Action <> nil)
     then Action^.Execute;
end;

function TIndAction.Executable: Boolean;
begin
     Executable := True;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TCompAction.Create;
begin
     inherited Create;
     SubActions.Create;
end;

destructor TCompAction.Destroy;
begin
     SubActions.Destroy;
     inherited Destroy;
end;

procedure TCompAction.Execute;
var ScanAction: PAction;
begin
     ScanAction := PAction( SubActions.GetFirst);
     while ( ScanAction <> nil)
     do begin
        ScanAction^.Execute;
        ScanAction := PAction( SubActions.GetNext);
        end;
end;

procedure TCompAction.AddAction( AAction: PAction);
begin
     if ( AAction <> nil)
     then SubActions.PushLast( AAction);
end;

function TCompAction.Executable: Boolean;
begin
     Executable := True;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TCircleDraw.Create( AExp1, AExp2, AExp3: PExp);
begin
     inherited Create;
     Exp1 := AExp1;
     Exp2 := AExp2;
     Exp3 := AExp3;
end;

procedure TCircleDraw.Execute;
var V1, V2, V3: Integer;
begin
     if (( Exp1 <> nil) and ( Exp2 <> nil) and ( Exp3 <> nil))
     then begin
          V1 := Round( Exp1^.Value);
          V2 := Round( Exp2^.Value);
          V3 := Round( Exp3^.Value);
          Circle( V1, V2, V3);
          end;
end;

destructor TCircleDraw.Destroy;
begin
     if ( Exp1 <> nil)
     then Exp1^.Free;

     if ( Exp2 <> nil)
     then Exp2^.Free;

     if ( Exp3 <> nil)
     then Exp3^.Free;

     inherited Destroy;
end;

function TCircleDraw.Executable: Boolean;
begin
     Executable := True;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TBoxDraw.Create( AExp1, AExp2, AExp3, AExp4: PExp);
begin
     inherited Create;
     Exp1 := AExp1;
     Exp2 := AExp2;
     Exp3 := AExp3;
     Exp4 := AExp4;
end;

procedure TBoxDraw.Execute;
var V1, V2, V3, V4: Integer;
begin
     if (( Exp1 <> nil) and ( Exp2 <> nil) and ( Exp3 <> nil) and (Exp4 <> nil))
     then begin
          V1 := Round( Exp1^.Value);
          V2 := Round( Exp2^.Value);
          V3 := Round( Exp3^.Value);
          V4 := Round( Exp4^.Value);
          Line( V1, V2, V1, V4);
          Line( V1, V4, V3, V4);
          Line( V3, V4, V3, V2);
          Line( V3, V2, V1, V2);
          end;
end;

destructor TBoxDraw.Destroy;
begin
     if ( Exp1 <> nil)
     then Exp1^.Free;

     if ( Exp2 <> nil)
     then Exp2^.Free;

     if ( Exp3 <> nil)
     then Exp3^.Free;

     if ( Exp4 <> nil)
     then Exp4^.Free;

     inherited Destroy;
end;

function TBoxDraw.Executable: Boolean;
begin
     Executable := True;
end;


{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TLineDraw.Create( AExp1, AExp2, AExp3, AExp4: PExp);
begin
     inherited Create;
     Exp1 := AExp1;
     Exp2 := AExp2;
     Exp3 := AExp3;
     Exp4 := AExp4;
end;

procedure TLineDraw.Execute;
var V1, V2, V3, V4: Integer;
begin
     if (( Exp1 <> nil) and ( Exp2 <> nil) and ( Exp3 <> nil) and (Exp4 <> nil))
     then begin
          V1 := Round( Exp1^.Value);
          V2 := Round( Exp2^.Value);
          V3 := Round( Exp3^.Value);
          V4 := Round( Exp4^.Value);
          Line( V1, V2, V3, V4);
          end;
end;

destructor TLineDraw.Destroy;
begin
     if ( Exp1 <> nil)
     then Exp1^.Free;

     if ( Exp2 <> nil)
     then Exp2^.Free;

     if ( Exp3 <> nil)
     then Exp3^.Free;

     if ( Exp4 <> nil)
     then Exp4^.Free;

     inherited Destroy;
end;

function TLineDraw.Executable: Boolean;
begin
     Executable := True;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TPointDraw.Create( AExp1, AExp2: PExp);
begin
     inherited Create;
     Exp1 := AExp1;
     Exp2 := AExp2;
end;

procedure TPointDraw.Execute;
var V1, V2: Integer;
begin
     if (( Exp1 <> nil) and ( Exp2 <> nil))
     then begin
          V1 := Round( Exp1^.Value);
          V2 := Round( Exp2^.Value);
          PutPixel( V1, V2, 15);
          end;
end;

destructor TPointDraw.Destroy;
begin
     if ( Exp1 <> nil)
     then Exp1^.Free;

     if ( Exp2 <> nil)
     then Exp2^.Free;

     inherited Destroy;
end;

function TPointDraw.Executable: Boolean;
begin
     Executable := True;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TAssign.Create( AExp: PExp; AVar: PValue);
begin
     inherited Create;
     Exp := AExp;
     Variable := AVar;
end;

procedure TAssign.Execute;
begin
     if (( Exp <> nil) and (Variable <> nil))
     then Variable^.SetValue( Exp^.Value);
end;

destructor TAssign.Destroy;
begin
     if (Exp <> nil)
     then Exp^.Free;
     inherited Destroy;
end;

function TAssign.Executable: Boolean;
begin
     Executable := True;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

{$F+}
procedure Semantic1( AParser: PParser);
var Action: PAction;
begin
     { s -> stmts }
     with PDrawParser( AParser)^
     do begin
        Action := PAction( PopAttribute);
        Action^.Execute;
        Action^.Free;
        end;
end;

procedure Semantic2( AParser: PParser);
var Action: PAction;
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
end;

procedure Semantic3( AParser: PParser);
var Action: PAction;
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
end;

procedure Semantic4( AParser: PParser);
begin
     { stmt -> def_stmt }
end;

procedure Semantic5( AParser: PParser);
begin
     { stmt -> drw_stmt }

end;

procedure Semantic6( AParser: PParser);
var Exp: PExp;
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
end;

procedure Semantic7( AParser: PParser);
var CFigure: PCompAction;
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
end;

procedure Semantic8( AParser: PParser);
begin
       { drw_stmt -> Draw cfigure }
end;

procedure Semantic9( AParser: PParser);
var Id: PIdAttribute;
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
end;

procedure Semantic10( AParser: PParser);
var NewAction: PAction;
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
end;

procedure Semantic11( AParser: PParser);
var Id: PIdAttribute;
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
end;

procedure Semantic12( AParser: PParser);
begin
       { cfigure -> ( figures ) }
end;

procedure Semantic13( AParser: PParser);
var Action: PAction;
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
end;

procedure Semantic14( AParser: PParser);
var Action: PAction;
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
end;

procedure Semantic15( AParser: PParser);
var Exp: PExp;
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
end;

procedure Semantic16( AParser: PParser);
var Id: PIdAttribute;
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
end;

procedure Semantic17( AParser: PParser);
var Exp1, Exp2, Exp3: PExp;
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
end;

procedure Semantic18( AParser: PParser);
var Exp1, Exp2, Exp3, Exp4: PExp;
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
end;

procedure Semantic19( AParser: PParser);
var Exp1, Exp2, Exp3, Exp4: PExp;
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
end;

procedure Semantic20( AParser: PParser);
var Exp1, Exp2: PExp;
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
end;

procedure Semantic21( AParser: PParser);
var Exp: POpExp;
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
end;

procedure Semantic22( AParser: PParser);
var Exp: POpExp;
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
end;

procedure Semantic23( AParser: PParser);
begin
       { exp -> trm }
end;

procedure Semantic24( AParser: PParser);
var Exp: POpExp;
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
end;

procedure Semantic25( AParser: PParser);
var Exp: POpExp;
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
end;

procedure Semantic26( AParser: PParser);
begin
end;

procedure Semantic27( AParser: PParser);
begin
       { fct -> ( exp ) }
end;

procedure Semantic28( AParser: PParser);
var NewExp: PNegExp;
    Exp: PExp;
begin
     { fct -> - fct }
     with PDrawParser( AParser)^
     do begin
        Exp := PExp( PopAttribute);
        NewExp := New( PNegExp, Create( Exp));
        PushAttribute( NewExp);
        end;
end;

procedure Semantic29( AParser: PParser);
var Value: PValue;
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
end;

procedure Semantic30( AParser: PParser);
var Value: PValue;
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
end;

procedure Semantic31( AParser: PParser);
var Exp: PExp;
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
end;



const

{******************************************************************}
{*                                                                *}
{******************************************************************}

YACC_STATESCOUNT = 77;
YACC_TERMINALSCOUNT = 19;
YACC_NONTERMINALSCOUNT = 11;
YACC_RULESCOUNT = 31;


{******************************************************************}
{*                                                                *}
{******************************************************************}

      ActionTable: array [1..YACC_STATESCOUNT, 1..YACC_TERMINALSCOUNT] of TActionRec =
(
{ St.   1  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 6),
( Action: actShift; NextState: 7),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 8),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.   2  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 9),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actAccept; Rule: 1)
),
{ St.   3  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 3),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 3)
),
{ St.   4  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 4),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 4)
),
{ St.   5  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 5),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 5)
),
{ St.   6  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 10),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.   7  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 13),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 12),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.   8  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.   9  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 6),
( Action: actShift; NextState: 7),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 8),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  10  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 25),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  11  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 8),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 8)
),
{ St.  12  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 11),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 11)
),
{ St.  13  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 28),
( Action: actShift; NextState: 7),
( Action: actShift; NextState: 30),
( Action: actShift; NextState: 32),
( Action: actShift; NextState: 31),
( Action: actShift; NextState: 8),
( Action: actShift; NextState: 33),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  14  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 13),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 34),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  15  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 23),
( Action: actReduce; Rule: 23),
( Action: actShift; NextState: 38),
( Action: actShift; NextState: 39),
( Action: actReduce; Rule: 23),
( Action: actReduce; Rule: 23),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 23),
( Action: actReduce; Rule: 23),
( Action: actReduce; Rule: 23),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 23)
),
{ St.  16  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 26),
( Action: actReduce; Rule: 26),
( Action: actReduce; Rule: 26),
( Action: actReduce; Rule: 26),
( Action: actReduce; Rule: 26),
( Action: actReduce; Rule: 26),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 26),
( Action: actReduce; Rule: 26),
( Action: actReduce; Rule: 26),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 26)
),
{ St.  17  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  18  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  19  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 29),
( Action: actReduce; Rule: 29),
( Action: actReduce; Rule: 29),
( Action: actReduce; Rule: 29),
( Action: actReduce; Rule: 29),
( Action: actReduce; Rule: 29),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 29),
( Action: actReduce; Rule: 29),
( Action: actReduce; Rule: 29),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 29)
),
{ St.  20  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 30),
( Action: actReduce; Rule: 30),
( Action: actReduce; Rule: 30),
( Action: actReduce; Rule: 30),
( Action: actReduce; Rule: 30),
( Action: actReduce; Rule: 30),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 30),
( Action: actReduce; Rule: 30),
( Action: actReduce; Rule: 30),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 30)
),
{ St.  21  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 42),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  22  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 2),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 2)
),
{ St.  23  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 6),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 6)
),
{ St.  24  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 7),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 7)
),
{ St.  25  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 43),
( Action: actShift; NextState: 7),
( Action: actShift; NextState: 30),
( Action: actShift; NextState: 32),
( Action: actShift; NextState: 31),
( Action: actShift; NextState: 8),
( Action: actShift; NextState: 33),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  26  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 44),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  27  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 14),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  28  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 45),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  29  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 16),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  30  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  31  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  32  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  33  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  34  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 9),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 9)
),
{ St.  35  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 10),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 10)
),
{ St.  36  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  37  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  38  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  39  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  40  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 54),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  41  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 28),
( Action: actReduce; Rule: 28),
( Action: actReduce; Rule: 28),
( Action: actReduce; Rule: 28),
( Action: actReduce; Rule: 28),
( Action: actReduce; Rule: 28),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 28),
( Action: actReduce; Rule: 28),
( Action: actReduce; Rule: 28),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 28)
),
{ St.  42  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  43  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 30),
( Action: actReduce; Rule: 30),
( Action: actReduce; Rule: 30),
( Action: actReduce; Rule: 30),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 30),
( Action: actShift; NextState: 45),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  44  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 56),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 28),
( Action: actShift; NextState: 7),
( Action: actShift; NextState: 30),
( Action: actShift; NextState: 32),
( Action: actShift; NextState: 31),
( Action: actShift; NextState: 8),
( Action: actShift; NextState: 33),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  45  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  46  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 59),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  47  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 60),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  48  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 61),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  49  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 62),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  50  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 21),
( Action: actReduce; Rule: 21),
( Action: actShift; NextState: 38),
( Action: actShift; NextState: 39),
( Action: actReduce; Rule: 21),
( Action: actReduce; Rule: 21),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 21),
( Action: actReduce; Rule: 21),
( Action: actReduce; Rule: 21),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 21)
),
{ St.  51  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 22),
( Action: actReduce; Rule: 22),
( Action: actShift; NextState: 38),
( Action: actShift; NextState: 39),
( Action: actReduce; Rule: 22),
( Action: actReduce; Rule: 22),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 22),
( Action: actReduce; Rule: 22),
( Action: actReduce; Rule: 22),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 22)
),
{ St.  52  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 24),
( Action: actReduce; Rule: 24),
( Action: actReduce; Rule: 24),
( Action: actReduce; Rule: 24),
( Action: actReduce; Rule: 24),
( Action: actReduce; Rule: 24),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 24),
( Action: actReduce; Rule: 24),
( Action: actReduce; Rule: 24),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 24)
),
{ St.  53  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 25),
( Action: actReduce; Rule: 25),
( Action: actReduce; Rule: 25),
( Action: actReduce; Rule: 25),
( Action: actReduce; Rule: 25),
( Action: actReduce; Rule: 25),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 25),
( Action: actReduce; Rule: 25),
( Action: actReduce; Rule: 25),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 25)
),
{ St.  54  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 27),
( Action: actReduce; Rule: 27),
( Action: actReduce; Rule: 27),
( Action: actReduce; Rule: 27),
( Action: actReduce; Rule: 27),
( Action: actReduce; Rule: 27),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 27),
( Action: actReduce; Rule: 27),
( Action: actReduce; Rule: 27),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 27)
),
{ St.  55  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 63),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  56  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 12),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 12)
),
{ St.  57  } (
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 13),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  58  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 15),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  59  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  60  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  61  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  62  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  63  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 31),
( Action: actReduce; Rule: 31),
( Action: actReduce; Rule: 31),
( Action: actReduce; Rule: 31),
( Action: actReduce; Rule: 31),
( Action: actReduce; Rule: 31),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 31),
( Action: actReduce; Rule: 31),
( Action: actReduce; Rule: 31),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 31)
),
{ St.  64  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 68),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  65  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 69),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  66  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 70),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  67  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  68  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  69  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  70  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  71  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  72  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 74),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  73  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 75),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  74  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  75  } (
( Action: actShift; NextState: 19),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0)
),
{ St.  76  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  77  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 36),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 19),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
)
);


{******************************************************************}
{*                                                                *}
{******************************************************************}

      GotoTable: array[ 1..YACC_STATESCOUNT, 1..YACC_NONTERMINALSCOUNT] of Byte =
(
{ St.   1  } (  0,  2,  3,  4,  5,  0,  0,  0,  0,  0,  0),
{ St.   2  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.   3  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.   4  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.   5  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.   6  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.   7  } (  0,  0,  0,  0,  0, 11,  0,  0,  0,  0,  0),
{ St.   8  } (  0,  0,  0,  0,  0,  0,  0,  0, 14, 15, 16),
{ St.   9  } (  0,  0, 22,  4,  5,  0,  0,  0,  0,  0,  0),
{ St.  10  } (  0,  0,  0,  0,  0, 24,  0,  0, 23, 15, 16),
{ St.  11  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  12  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  13  } (  0,  0,  0,  0, 29,  0, 26, 27,  0,  0,  0),
{ St.  14  } (  0,  0,  0,  0,  0, 35,  0,  0,  0,  0,  0),
{ St.  15  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  16  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  17  } (  0,  0,  0,  0,  0,  0,  0,  0, 40, 15, 16),
{ St.  18  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 41),
{ St.  19  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  20  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  21  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  22  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  23  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  24  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  25  } (  0,  0,  0,  0, 29,  0, 26, 27, 40, 15, 16),
{ St.  26  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  27  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  28  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  29  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  30  } (  0,  0,  0,  0,  0,  0,  0,  0, 46, 15, 16),
{ St.  31  } (  0,  0,  0,  0,  0,  0,  0,  0, 47, 15, 16),
{ St.  32  } (  0,  0,  0,  0,  0,  0,  0,  0, 48, 15, 16),
{ St.  33  } (  0,  0,  0,  0,  0,  0,  0,  0, 49, 15, 16),
{ St.  34  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  35  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  36  } (  0,  0,  0,  0,  0,  0,  0,  0,  0, 50, 16),
{ St.  37  } (  0,  0,  0,  0,  0,  0,  0,  0,  0, 51, 16),
{ St.  38  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 52),
{ St.  39  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 53),
{ St.  40  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  41  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  42  } (  0,  0,  0,  0,  0,  0,  0,  0, 55, 15, 16),
{ St.  43  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  44  } (  0,  0,  0,  0, 29,  0,  0, 57,  0,  0,  0),
{ St.  45  } (  0,  0,  0,  0,  0,  0,  0,  0, 58, 15, 16),
{ St.  46  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  47  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  48  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  49  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  50  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  51  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  52  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  53  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  54  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  55  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  56  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  57  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  58  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  59  } (  0,  0,  0,  0,  0,  0,  0,  0, 64, 15, 16),
{ St.  60  } (  0,  0,  0,  0,  0,  0,  0,  0, 65, 15, 16),
{ St.  61  } (  0,  0,  0,  0,  0,  0,  0,  0, 66, 15, 16),
{ St.  62  } (  0,  0,  0,  0,  0,  0,  0,  0, 67, 15, 16),
{ St.  63  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  64  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  65  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  66  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  67  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  68  } (  0,  0,  0,  0,  0,  0,  0,  0, 71, 15, 16),
{ St.  69  } (  0,  0,  0,  0,  0,  0,  0,  0, 72, 15, 16),
{ St.  70  } (  0,  0,  0,  0,  0,  0,  0,  0, 73, 15, 16),
{ St.  71  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  72  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  73  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  74  } (  0,  0,  0,  0,  0,  0,  0,  0, 76, 15, 16),
{ St.  75  } (  0,  0,  0,  0,  0,  0,  0,  0, 77, 15, 16),
{ St.  76  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  77  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0)
);


{******************************************************************}
{*                                                                *}
{******************************************************************}

      RuleSizes: array[ 1..YACC_RULESCOUNT] of Byte =
(
   1,   3,   1,   1,   1,   3,   3,   2,
   3,   3,   2,   4,   3,   1,   3,   1,
   6,   8,   8,   4,   3,   3,   1,   3,
   3,   1,   3,   2,   1,   1,   4
);


{******************************************************************}
{*                                                                *}
{******************************************************************}

      RulesSymbol: array[ 1..YACC_RULESCOUNT] of Byte =
(
   1,   2,   2,   3,   3,   4,   4,   5,
   5,   5,   5,   6,   7,   7,   8,   8,
   8,   8,   8,   8,   9,   9,   9,  10,
  10,  10,  11,  11,  11,  11,  11
);


      SemanticsTable: array[ 1..YACC_RULESCOUNT] of TSemanticProc =
(
Semantic1,
Semantic2,
Semantic3,
Semantic4,
Semantic5,
Semantic6,
Semantic7,
Semantic8,
Semantic9,
Semantic10,
Semantic11,
Semantic12,
Semantic13,
Semantic14,
Semantic15,
Semantic16,
Semantic17,
Semantic18,
Semantic19,
Semantic20,
Semantic21,
Semantic22,
Semantic23,
Semantic24,
Semantic25,
Semantic26,
Semantic27,
Semantic28,
Semantic29,
Semantic30,
Semantic31
);


{$I DRAWDEFS.INC}

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TDrawParser.Create( AOwner: PErrGeneric; ASource: PStream);
begin
     inherited Create( AOwner);
     Lexical := New( PDrawLexical, Create( @Self, ASource));

     Symbols.Create;
     Variables.Create;
     Actions.Create;
end;

destructor TDrawParser.Destroy;
begin
     if ( Lexical <> nil)
     then Lexical^.Free;

     Symbols.Destroy;
     Variables.Destroy;
     Actions.Destroy;

     inherited Destroy;
end;

procedure TDrawParser.NextToken;
var Attrs: TTokenAttributes;
    Token: Word;
    TokenAttrs: PGeneric;
begin
     if Lexical^.Token( Attrs)
     then begin
          Token := Attrs.Token;
          case Token
          of YACC_Number: begin
                          TokenAttrs := New( PValue, Create( Attrs.Value));
                          end;
             YACC_Id: begin
                      TokenAttrs := New( PIdAttribute, Create( StrPas(Attrs.Lexeme)));
                      end;
             YACC_Fun: begin
                       TokenAttrs := New( PIdAttribute, Create( StrPas(Attrs.Lexeme)));
                       end;
          0: begin
             TokenAttrs := nil;
             StopParsing;
             end
          else
              TokenAttrs := nil;
              end;
          end
     else begin
          TokenAttrs := nil;
          StopParsing;
          end;

     SetToken( Token, TokenAttrs);
end;

procedure TDrawParser.ExecuteSemantic( ARule: Byte);
begin
     if (@SemanticsTable[ARule] <> nil)
     then SemanticsTable[ ARule]( @Self);
end;

function TDrawParser.GetGoto( ATopState: Byte; ANonterminal: Byte): Byte;
begin
     if ((ATopState <> 0) and (ANonterminal <> 0))
     then GetGoto := GotoTable[ ATopState, ANonTerminal]
     else begin
          GetGoto := 0;
          StopParsing;
          end;
end;

procedure TDrawParser.GetAction( ATopState: Byte; ATerminal: Word; var AAction: TActionRec);
begin
     if ((ATerminal <> 0) and (ATopState <> 0))
     then AAction := ActionTable[ ATopState, ATerminal]
     else begin
          AAction.Action := actError;
          AAction.ErrorCode := 0;
          StopParsing;
          end;
end;

function TDrawParser.GetNonterminal( ARule: Byte): Byte;
begin
     if (ARule <> 0)
     then GetNonterminal := RulesSymbol[ ARule]
     else begin
          StopParsing;
          GetNonterminal := 0;
          end;
end;

function TDrawParser.GetRuleSize( ARule: Byte): Byte;
begin
     if (ARule <> 0)
     then GetRuleSize := RuleSizes[ ARule]
     else GetRuleSize := 0;
end;

procedure TDrawParser.Error( AErrorCode: Byte);
var S1, S2: string;
begin
     inherited Error( AErrorCode);
     if ( Lexical <> nil)
     then begin
          Str( Lexical^.GetLineNo, S1);
          Str( Lexical^.GetCollomnNo, S2);
          S1 := 'PARSER ERROR: Syntax error (Line ' + S1 + ', Col ' + S2 + ').';
          AddError( New( PMessageError, Create( S1)));
          end
     else begin
          AddError( New( PMessageError, Create( 'PARSER ERROR: Syntax error')));
          end;
end;

procedure TDrawParser.AddSymbol( ASymbol: PSymbol);
var OldSymbol: PSymbol;
begin
     if (ASymbol <> nil)
     then begin
          OldSymbol := FindSymbol( ASymbol^.GetTitle);
          if ( OldSymbol <> nil)
          then begin
               Symbols.RemoveFromCollection( OldSymbol);
               OldSymbol^.Free;
               end;
          Symbols.PushFirst( ASymbol);
          end;
end;

function TDrawParser.FindSymbol( ATitle: string): PSymbol;
var ScanSymbol: PSymbol;
begin
     ScanSymbol := PSymbol( Symbols.GetFirst);
     while ( ScanSymbol <> nil)
     do begin
        if ScanSymbol^.GetTitle = ATitle
        then begin
             FindSymbol := ScanSymbol;
             exit;
             end
        else ScanSymbol := PSymbol( Symbols.GetNext);
        end;
     FindSymbol := ScanSymbol;
end;

end.
