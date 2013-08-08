unit CalcParser;

interface

uses Generics, Lexical, CalcLexical, Parser, Strings;

type PSemanticProc = ^TSemanticProc;
     TSemanticProc = procedure( AParser: PParser);

     PCalcParser = ^TCalcParser;
     TCalcParser = object( TParser)
     private
        Lexical: PCalcLexical;

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
        end;

implementation

{******************************************************************}
{*                                                                *}
{******************************************************************}

{$I CALCDEFS.INC}

type PNumberAttr = ^TNumberAttr;
     TNumberAttr = object( TGeneric)
        Value: Real;
        end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

{$F+}
procedure Semantic1( AParser: PParser);
{ S -> E }
var V1: PNumberAttr;
begin
     WriteLn('S -> E');
     V1 := PNumberAttr( AParser^.PopAttribute);
     WriteLn( 'The result = ', V1^.Value);
     V1^.Free;
end;


procedure Semantic2( AParser: PParser);
{E -> E + T}
var V1, V2: PNumberAttr;
begin
     WriteLn('E -> E + T');
     V1 := PNumberAttr( AParser^.PopAttribute);
     V2 := PNumberAttr( AParser^.PopAttribute);
     V1^.Value := V1^.Value + V2^.Value;
     AParser^.PushAttribute( V1);
     V2^.Free;
end;


procedure Semantic3( AParser: PParser);
{E -> E - T}
var V1, V2: PNumberAttr;
begin
     WriteLn('E -> E - T');
     V1 := PNumberAttr( AParser^.PopAttribute);
     V2 := PNumberAttr( AParser^.PopAttribute);
     V1^.Value := V1^.Value - V2^.Value;
     AParser^.PushAttribute( V1);
     V2^.Free;
end;


procedure Semantic4( AParser: PParser);
{E -> T}
begin
     WriteLn('E -> T');
end;


procedure Semantic5( AParser: PParser);
{T -> T * F}
var V1, V2: PNumberAttr;
begin
     WriteLn('T -> T * F');
     V1 := PNumberAttr( AParser^.PopAttribute);
     V2 := PNumberAttr( AParser^.PopAttribute);
     V1^.Value := V1^.Value * V2^.Value;
     AParser^.PushAttribute( V1);
     V2^.Free;
end;


procedure Semantic6( AParser: PParser);
{E -> T / F}
var V1, V2: PNumberAttr;
begin
     WriteLn('E -> T / F');
     V1 := PNumberAttr( AParser^.PopAttribute);
     V2 := PNumberAttr( AParser^.PopAttribute);
     V1^.Value := V1^.Value / V2^.Value;
     AParser^.PushAttribute( V1);
     V2^.Free;
end;


procedure Semantic7( AParser: PParser);
{T -> F}
begin
     WriteLn('T -> F');
end;


procedure Semantic8( AParser: PParser);
{F -> Number}
begin
     WriteLn('F -> Number');
end;


procedure Semantic9( AParser: PParser);
{F -> ( E )}
begin
     WriteLn('F -> ( E )');
end;


procedure Semantic10( AParser: PParser);
{F -> -F}
var V1: PNumberAttr;
begin
     WriteLn('F -> -F');
     V1 := PNumberAttr( AParser^.PopAttribute);
     V1^.Value := - V1^.Value;
     AParser^.PushAttribute( V1);
end;




const

YACC_STATESCOUNT = 18;
YACC_TERMINALSCOUNT = 8;
YACC_NONTERMINALSCOUNT = 4;
YACC_RULESCOUNT = 10;


      ActionTable: array [1..YACC_STATESCOUNT, 1..YACC_TERMINALSCOUNT] of TActionRec =
(
{ St.   1  } (
( Action: actShift; NextState: 5),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 7),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 6),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.   2  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 8),
( Action: actShift; NextState: 9),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actAccept; Rule: 1)
),
{ St.   3  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 4),
( Action: actReduce; Rule: 4),
( Action: actShift; NextState: 10),
( Action: actShift; NextState: 11),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 4),
( Action: actReduce; Rule: 4)
),
{ St.   4  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 7),
( Action: actReduce; Rule: 7),
( Action: actReduce; Rule: 7),
( Action: actReduce; Rule: 7),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 7),
( Action: actReduce; Rule: 7)
),
{ St.   5  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 8),
( Action: actReduce; Rule: 8),
( Action: actReduce; Rule: 8),
( Action: actReduce; Rule: 8),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 8),
( Action: actReduce; Rule: 8)
),
{ St.   6  } (
( Action: actShift; NextState: 5),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 7),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 6),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.   7  } (
( Action: actShift; NextState: 5),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 7),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 6),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.   8  } (
( Action: actShift; NextState: 5),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 7),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 6),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.   9  } (
( Action: actShift; NextState: 5),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 7),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 6),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  10  } (
( Action: actShift; NextState: 5),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 7),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 6),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  11  } (
( Action: actShift; NextState: 5),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 7),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 6),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
{ St.  12  } (
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 8),
( Action: actShift; NextState: 9),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 18),
( Action: actError; ErrorCode: 0)
),
{ St.  13  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 10),
( Action: actReduce; Rule: 10),
( Action: actReduce; Rule: 10),
( Action: actReduce; Rule: 10),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 10),
( Action: actReduce; Rule: 10)
),
{ St.  14  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 2),
( Action: actReduce; Rule: 2),
( Action: actShift; NextState: 10),
( Action: actShift; NextState: 11),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 2),
( Action: actReduce; Rule: 2)
),
{ St.  15  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 3),
( Action: actReduce; Rule: 3),
( Action: actShift; NextState: 10),
( Action: actShift; NextState: 11),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 3),
( Action: actReduce; Rule: 3)
),
{ St.  16  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 5),
( Action: actReduce; Rule: 5),
( Action: actReduce; Rule: 5),
( Action: actReduce; Rule: 5),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 5),
( Action: actReduce; Rule: 5)
),
{ St.  17  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 6),
( Action: actReduce; Rule: 6),
( Action: actReduce; Rule: 6),
( Action: actReduce; Rule: 6),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 6),
( Action: actReduce; Rule: 6)
),
{ St.  18  } (
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 9),
( Action: actReduce; Rule: 9),
( Action: actReduce; Rule: 9),
( Action: actReduce; Rule: 9),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 9),
( Action: actReduce; Rule: 9)
)
);


      GotoTable: array[ 1..YACC_STATESCOUNT, 1..YACC_NONTERMINALSCOUNT] of Byte =
(
{ St.   1  } (  0,  2,  3,  4),
{ St.   2  } (  0,  0,  0,  0),
{ St.   3  } (  0,  0,  0,  0),
{ St.   4  } (  0,  0,  0,  0),
{ St.   5  } (  0,  0,  0,  0),
{ St.   6  } (  0, 12,  3,  4),
{ St.   7  } (  0,  0,  0, 13),
{ St.   8  } (  0,  0, 14,  4),
{ St.   9  } (  0,  0, 15,  4),
{ St.  10  } (  0,  0,  0, 16),
{ St.  11  } (  0,  0,  0, 17),
{ St.  12  } (  0,  0,  0,  0),
{ St.  13  } (  0,  0,  0,  0),
{ St.  14  } (  0,  0,  0,  0),
{ St.  15  } (  0,  0,  0,  0),
{ St.  16  } (  0,  0,  0,  0),
{ St.  17  } (  0,  0,  0,  0),
{ St.  18  } (  0,  0,  0,  0)
);


      RuleSizes: array[ 1..YACC_RULESCOUNT] of Byte =
(
   1,   3,   3,   1,   3,   3,   1,   1,
   3,   2
);


      RulesSymbol: array[ 1..YACC_RULESCOUNT] of Byte =
(
   1,   2,   2,   2,   3,   3,   3,   4,
   4,   4
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
Semantic10
);


{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TCalcParser.Create( AOwner: PErrGeneric; ASource: PStream);
begin
     inherited Create( AOwner);
     Lexical := New( PCalcLexical, Create( @Self, ASource));
end;

destructor TCalcParser.Destroy;
begin
     if ( Lexical <> nil)
     then Lexical^.Free;

     inherited Destroy;
end;

procedure TCalcParser.NextToken;
var Attrs: TTokenAttributes;
    Token: Word;
    TokenAttrs: PGeneric;
begin
     if Lexical^.Token( Attrs)
     then begin
          Token := Attrs.Token;
          case Token
          of YACC_NUMBER: begin
                          TokenAttrs := New( PNumberAttr, Create);
                          PNumberAttr(TokenAttrs)^.Value := Attrs.Value;
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

procedure TCalcParser.ExecuteSemantic( ARule: Byte);
begin
     if (@SemanticsTable[ARule] <> nil)
     then SemanticsTable[ ARule]( @Self);
end;

function TCalcParser.GetGoto( ATopState: Byte; ANonterminal: Byte): Byte;
begin
     if ((ATopState <> 0) and (ANonterminal <> 0))
     then GetGoto := GotoTable[ ATopState, ANonTerminal]
     else begin
          GetGoto := 0;
          StopParsing;
          end;
end;

procedure TCalcParser.GetAction( ATopState: Byte; ATerminal: Word; var AAction: TActionRec);
begin
     if ((ATerminal <> 0) and (ATopState <> 0))
     then AAction := ActionTable[ ATopState, ATerminal]
     else begin
          AAction.Action := actError;
          AAction.ErrorCode := 0;
          StopParsing;
          end;
end;

function TCalcParser.GetNonterminal( ARule: Byte): Byte;
begin
     if (ARule <> 0)
     then GetNonterminal := RulesSymbol[ ARule]
     else begin
          StopParsing;
          GetNonterminal := 0;
          end;
end;

function TCalcParser.GetRuleSize( ARule: Byte): Byte;
begin
     if (ARule <> 0)
     then GetRuleSize := RuleSizes[ ARule]
     else GetRuleSize := 0;
end;

procedure TCalcParser.Error( AErrorCode: Byte);
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

end.
