{********************************************************}
{*                                                      *}
{*   YACC tool syntax analyzer unit                     *}
{*                                                      *}
{*   File name : YACCPARS.PAS                           *}
{*                                                      *}
{*   Programming: Russlan Kafri - 1999                  *}
{*                                                      *}
{********************************************************}

unit YaccParser;

interface

uses Strings, Generics, Lexical, YaccDefs, YaccLexical, YaccEngine, Parser;

type PYaccParser = ^TYaccParser;
     TYaccParser = object( TParser)
     private
        Database: PYaccDatabase;
        Lexical: PYaccLexical;
        CurrentRuleLeftSymbol: PParserSymbol;

        procedure Semantic1;
        procedure Semantic2;
        procedure Semantic3;
        procedure Semantic4;
        procedure Semantic5;
        procedure Semantic6;
        procedure Semantic7;
        procedure Semantic8;
        procedure Semantic9;
        procedure Semantic10;
        procedure Semantic11;
        procedure Semantic12;
        procedure Semantic13;
        procedure Semantic14;
        procedure Semantic15;
        procedure Semantic16;
        procedure Semantic17;
     public
        constructor Create( AOwner: PErrGeneric; ASource: PStream; ADatabase: PYaccDatabase);
        destructor Destroy; virtual;
        procedure ExecuteSemantic( ARule: Byte); virtual;
        procedure NextLexeme; virtual;
        function GetGoto( ATopState: Byte; ANonterminal: Byte): Byte; virtual;
        procedure GetAction( ATopState: Byte; ATerminal: Word; var AAction: TActionRec); virtual;
        function GetNonterminal( ARule: Byte): Byte; virtual;
        function GetRuleSize( ARule: Byte): Byte; virtual;
        procedure Error( AErrorCode: Byte); virtual;
        end;

    PIDAttribute = ^TIDAttribute;
    TIDAttribute = object( TGeneric)
    private
       ID: PChar;
    public
       constructor Create( AIDString: PChar);
       destructor Destroy; virtual;
       function GetString: string;
       end;

    PBlockAttribute = ^TBlockAttribute;
    TBlockAttribute = object( TGeneric)
    private
       Buffer: Pointer;
       BufferSize: Word;
    public
       constructor Create( var ABuffer; ASize: Word);
       destructor Destroy; virtual;
       function GetSize: Word;
       function GetBuffer: Pointer;
       function GetData( var ABuffer; ABufferSize: Word): Word;
       end;

implementation

{******************************************************************}
{*                                                                *}
{******************************************************************}

const STATESCOUNT       = 26;
      TERMINALCOUNT     = 8;
      NONTERMINALCOUNT  = 11;
      RULESCOUNT        = 17;


{
TERMINALS:
    1  %%
    2  declcommand
    3  id
    4  :
    5  ;
    6  |
    7  block
    8  $
}

      ActionTable: array [1..STATESCOUNT, 1..TERMINALCOUNT] of TActionRec =
(
( { St.    1 }
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 5),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.    2 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actAccept )
),
( { St.    3 }
( Action: actShift; NextState: 6),
( Action: actShift; NextState: 5),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.    4 }
( Action: actReduce; Rule: 4),
( Action: actReduce; Rule: 4),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.    5 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 9),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.    6 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 13),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.    7 }
( Action: actReduce; Rule: 3),
( Action: actReduce; Rule: 3),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.    8 }
( Action: actReduce; Rule: 5),
( Action: actReduce; Rule: 5),
( Action: actShift; NextState: 14),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.    9 }
( Action: actReduce; Rule: 7),
( Action: actReduce; Rule: 7),
( Action: actReduce; Rule: 7),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   10 }
( Action: actShift; NextState: 15),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 13),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   11 }
( Action: actReduce; Rule: 9),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 9),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   12 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   13 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 11),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   14 }
( Action: actReduce; Rule: 6),
( Action: actReduce; Rule: 6),
( Action: actReduce; Rule: 6),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   15 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 2)
),
( { St.   16 }
( Action: actReduce; Rule: 8),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 8),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   17 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 17),
( Action: actError; ErrorCode: 0)
),
( { St.   18 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 22),
( Action: actShift; NextState: 23),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   19 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 13),
( Action: actReduce; Rule: 13),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   20 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 25),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 24),
( Action: actError; ErrorCode: 0)
),
( { St.   21 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 16),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 16),
( Action: actError; ErrorCode: 0)
),
( { St.   22 }
( Action: actReduce; Rule: 10),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 10),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   23 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 17),
( Action: actError; ErrorCode: 0)
),
( { St.   24 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 14),
( Action: actReduce; Rule: 14),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   25 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 15),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 15),
( Action: actError; ErrorCode: 0)
),
( { St.   26 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 12),
( Action: actReduce; Rule: 12),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
)
);


      GotoTable: array[ 1..STATESCOUNT, 1..NONTERMINALCOUNT] of Byte =
(
{ St.   1  } (  0,  2,  3,  4,  0,  0,  0,  0,  0,  0,  0),
{ St.   2  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.   3  } (  0,  0,  0,  7,  0,  0,  0,  0,  0,  0,  0),
{ St.   4  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.   5  } (  0,  0,  0,  0,  8,  0,  0,  0,  0,  0,  0),
{ St.   6  } (  0,  0,  0,  0,  0, 10, 11, 12,  0,  0,  0),
{ St.   7  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.   8  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.   9  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  10  } (  0,  0,  0,  0,  0,  0, 16, 12,  0,  0,  0),
{ St.  11  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  12  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  13  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  14  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  15  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  16  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  17  } (  0,  0,  0,  0,  0,  0,  0,  0, 18, 19, 20),
{ St.  18  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  19  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  20  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  21  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  22  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  23  } (  0,  0,  0,  0,  0,  0,  0,  0,  0, 26, 20),
{ St.  24  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  25  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  26  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0)
);


      RuleSizes: array[ 1..RULESCOUNT] of Byte =
(1,4,2,1,2,2,1,2,1,4,1,3,1,2,2,1,0);

      RulesSymbol: array[ 1..RULESCOUNT] of Byte =
(1,2,3,3,4,5,5,6,6,7,8,9,9,10,11,11,11);

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TYaccParser.Create( AOwner: PErrGeneric; ASource: PStream; ADatabase: PYaccDatabase);
begin
     inherited Create( AOwner);
     Lexical := New( PYaccLexical, Create( @Self, ASource));
     Database := ADatabase;
     CurrentRuleLeftSymbol := nil;
end;

destructor TYaccParser.Destroy;
begin
     if ( Lexical <> nil)
     then Lexical^.Free;

     inherited Destroy;
end;

procedure TYaccParser.NextLexeme;
var Attrs: TLexemeAttributes;
    Lexeme: Word;
    LexemeAttrs: PGeneric;
begin
     if Lexical^.Lexeme( Attrs)
     then begin
          Lexeme := Attrs.Lexeme;
          case Lexeme
          of lexIdentifier: LexemeAttrs := New( PIDAttribute, Create( Attrs.LexemeStr ));
             lexBody: LexemeAttrs := New( PBlockAttribute, Create( Attrs.LexemeStr[2], Attrs.LexemeLen - 4));
             lexDeclCommand: LexemeAttrs := New( PIDAttribute, Create( @Attrs.LexemeStr[1] ));
             lexError: begin
                       LexemeAttrs := nil;
                       StopParsing;
                       end;
             lexEOF: begin
                     LexemeAttrs := nil;
                     end;
             lexNone: begin
                      LexemeAttrs := nil;
                      StopParsing;
                      end;
             else
                 LexemeAttrs := nil;
             end;
          end
     else begin
          LexemeAttrs := nil;
          StopParsing;
          end;

     SetLexeme( Lexeme, LexemeAttrs);
end;

procedure TYaccParser.ExecuteSemantic( ARule: Byte);
begin
     case ARule
     of 1: Semantic1;
        2: Semantic2;
        3: Semantic3;
        4: Semantic4;
        5: Semantic5;
        6: Semantic6;
        7: Semantic7;
        8: Semantic8;
        9: Semantic9;
        10: Semantic10;
        11: Semantic11;
        12: Semantic12;
        13: Semantic13;
        14: Semantic14;
        15: Semantic15;
        16: Semantic16;
        17: Semantic17;
        else
            Halt;
        end;
end;

function TYaccParser.GetGoto( ATopState: Byte; ANonterminal: Byte): Byte;
begin
     if ((ATopState <> 0) and (ANonterminal <> 0))
     then GetGoto := GotoTable[ ATopState, ANonTerminal]
     else begin
          GetGoto := 0;
          StopParsing;
          end;
end;

procedure TYaccParser.GetAction( ATopState: Byte; ATerminal: Word; var AAction: TActionRec);
begin
     if ((ATerminal <> 0) and (ATopState <> 0))
     then AAction := ActionTable[ ATopState, ATerminal]
     else begin
          AAction.Action := actError;
          AAction.ErrorCode := 0;
          StopParsing;
          end;
end;

function TYaccParser.GetNonterminal( ARule: Byte): Byte;
begin
     if (ARule <> 0)
     then GetNonterminal := RulesSymbol[ ARule]
     else begin
          StopParsing;
          GetNonterminal := 0;
          end;
end;

function TYaccParser.GetRuleSize( ARule: Byte): Byte;
begin
     if (ARule <> 0)
     then GetRuleSize := RuleSizes[ ARule]
     else GetRuleSize := 0;
end;

procedure TYaccParser.Error( AErrorCode: Byte);
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

procedure TYaccParser.Semantic1;
begin
     { S -> YACC }
end;

procedure TYaccParser.Semantic2;
begin
     { YACC -> DECLS %% RULES %% }
end;

procedure TYaccParser.Semantic3;
begin
     { DECLS -> DECLS DECL }
end;

procedure TYaccParser.Semantic4;
begin
     { DECLS -> DECL }
end;

procedure TYaccParser.Semantic5;
var IDList: PContainerCollection;
    ScanID: PIDAttribute;
    CommandID: PIDAttribute;
    Symbol: PParserSymbol;
    S1, S2: string;
begin
     { DECL -> dectcommand IDLIST }
     IDList := PContainerCollection( PopAttribute);
     CommandID := PIDAttribute( PopAttribute);
     if ( CommandID^.GetString = 'token')
     then begin
          ScanID := PIDAttribute( IDList^.GetFirst);
          while ( ScanID <> nil)
          do begin
             DataBase^.AddNonterminal( ScanID^.GetString);
             ScanID := PIDAttribute( IDList^.GetNext);
             end;
          end
     else if ( CommandID^.GetString = 'start')
     then begin
          ScanID := PIDAttribute( IDList^.GetFirst);
          Symbol := DataBase^.AddSymbol( ScanID^.GetString);
          DataBase^.SetStartSymbol( Symbol);
          end
     else if ( CommandID^.GetString = 'type')
     then begin
          if ( IDList^.GetItemsCount = 1)
          then begin
               ScanID := PIDAttribute( IDList^.GetFirst);
               if (ScanID <> nil)
               then begin
                    if ScanID^.GetString = 'canonical'
                    then DataBase^.SetCanonical
                    else if ScanID^.GetString = 'lalr'
                    then DataBase^.SetLALR
                    else begin
                         if (Lexical <> nil)
                         then begin
                              Str( Lexical^.GetLineNo, S1);
                              Str( Lexical^.GetCollomnNo, S2);
                              S1 := '~ (Line: ' + S1 + ', Col: ' + S2 +').';
                              AddError( New( PMessageError, Create('SYNTAX ERROR: Bad parser type ~'+ScanID^.GetString+'~')));
                              end
                         end;
                    end;
               end
          else begin
               if (Lexical <> nil)
               then begin
                    Str( Lexical^.GetLineNo, S1);
                    Str( Lexical^.GetCollomnNo, S2);
                    S1 := '~ (Line: ' + S1 + ', Col: ' + S2 +').';
                    AddError( New( PMessageError, Create('SYNTAX ERROR: Bad parser type command.')));
                    end
               end;
          end
     else begin
          if (Lexical <> nil)
          then begin
               Str( Lexical^.GetLineNo, S1);
               Str( Lexical^.GetCollomnNo, S2);
               S1 := '~ (Line: ' + S1 + ', Col: ' + S2 +').';
               AddError( New( PMessageError, Create('SYNTAX ERROR: Bad command ~'
                         + CommandID^.GetString + S1)));
               end
          else begin
               AddError( New( PMessageError, Create('SYNTAX ERROR: Bad command ~'
                         + CommandID^.GetString + '~.')));
               end;
          end;
     IDList^.Free;
     CommandID^.Free;
end;

procedure TYaccParser.Semantic6;
var IDList: PContainerCollection;
    ID: PIDAttribute;
begin
     { IDLIST -> IDLIST id }
     ID := PIDAttribute( PopAttribute);
     IDList := PContainerCollection( PopAttribute);
     IDList^.PushLast( ID);
     PushAttribute( IDList);
end;

procedure TYaccParser.Semantic7;
var IDList: PContainerCollection;
    ID: PIDAttribute;
begin
     { IDLIST -> id }
     ID := PIDAttribute( PopAttribute);
     IDList := New( PContainerCollection, Create);
     IDList^.PushLast( ID);
     PushAttribute( IDList);
end;

procedure TYaccParser.Semantic8;
begin
     { RULES -> RULES RULE }
end;

procedure TYaccParser.Semantic9;
begin
     { RULES -> RULE }
end;

procedure TYaccParser.Semantic10;
begin
     { RULE -> LSIDE : RSIDES }
     CurrentRuleLeftSymbol := nil;
end;

procedure TYaccParser.Semantic11;
var ID: PIDAttribute;
begin
     { LSIDE -> id }
     ID := PIDAttribute( PopAttribute);
     CurrentRuleLeftSymbol := DataBase^.AddSymbol( ID^.GetString);
     ID^.Free;
end;

procedure TYaccParser.Semantic12;
begin
     { RSIDES -> RSIDES | RSIDE }
end;

procedure TYaccParser.Semantic13;
begin
     { RSIDES -> RSIDE }
end;

procedure TYaccParser.Semantic14;
var IDList: PContainerCollection;
    ScanID: PIDAttribute;
    Block: PBlockAttribute;
    Rule: PRule;
    Semantic: PRuleSemantic;
begin
     { RSIDE -> SYMBOLS block }
     Block := PBlockAttribute( PopAttribute);
     IDList := PContainerCollection( PopAttribute);
     Rule := New( PRule, Create);
     ScanID := PIDAttribute( IDList^.GetFirst);
     while ( ScanID <> nil)
     do begin
        Rule^.AppendRightSymbol( DataBase^.AddSymbol( ScanID^.GetString));
        ScanID := PIDAttribute( IDList^.GetNext);
        end;
     Rule^.SetLeftSymbol( CurrentRuleLeftSymbol);
     Semantic := New(PRuleSemantic, Create( Block^.GetBuffer^, Block^.GetSize));
     Rule^.SetSemantic( Semantic);
     DataBase^.AddRule( Rule);
     IDList^.Free;
     Block^.Free;
end;

procedure TYaccParser.Semantic15;
var IDList: PContainerCollection;
    ID: PIDAttribute;
begin
     { SYMBOLS -> SYMBOLS id }
     ID := PIDAttribute( PopAttribute);
     IDList := PContainerCollection( PopAttribute);
     IDList^.PushLast( ID);
     PushAttribute( IDList);
end;

procedure TYaccParser.Semantic16;
var IDList: PContainerCollection;
    ID: PIDAttribute;
begin
     { SYMBOLS -> id }
     ID := PIDAttribute( PopAttribute);
     IDList := New( PContainerCollection, Create);
     IDList^.PushLast( ID);
     PushAttribute( IDList);
end;

procedure TYaccParser.Semantic17;
var IDList: PContainerCollection;
begin
     { SYMBOLS -> }
     IDList := New( PContainerCollection, Create);
     PushAttribute( IDList);
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TIDAttribute.Create( AIDString: PChar);
begin
     inherited Create;
     ID := StrNew( AIDString);
end;

destructor TIDAttribute.Destroy;
begin
     StrDispose( ID);
     inherited Destroy;
end;

function TIDAttribute.GetString: string;
var S: string;
begin
     S := StrPas( ID);
     GetString := S;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TBlockAttribute.Create( var ABuffer; ASize: Word);
begin
     inherited Create;
     if (ASize > 0)
     then begin
          BufferSize := ASize;
          GetMem( Buffer, ASize);
          Move( ABuffer, Buffer^, ASize);
          end
     else begin
          Buffer := nil;
          BufferSize := 0;
          end;
end;

destructor TBlockAttribute.Destroy;
begin
     if ((Buffer <> nil) and ( BufferSize > 0))
     then FreeMem( Buffer, BufferSize);
     inherited Destroy;
end;

function TBlockAttribute.GetSize: Word;
begin
     GetSize := BufferSize;
end;

function TBlockAttribute.GetBuffer: Pointer;
begin
     GetBuffer := Buffer;
end;

function TBlockAttribute.GetData( var ABuffer; ABufferSize: Word): Word;
var MoveSize: Word;
begin
     if (ABufferSize < BufferSize)
     then MoveSize := ABufferSize
     else MoveSize := BufferSize;

     if ((MoveSize > 0) and ( Buffer <> nil))
     then Move( Buffer^, ABuffer, MoveSize);

     GetData := MoveSize;
end;

end.
