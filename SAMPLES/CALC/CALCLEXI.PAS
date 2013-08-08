unit CalcLexical;

interface

uses Generics, Crt, Lexical;

type TTokenAttributes = record
        Token: Word;
        Lexeme: array[0..MAXLEXEMESTRLENGTH] of Char;
        LexemeLen: Word;
        Buffer: PChar; BufferSize: Word;
        Value: Real;
        end;

     PPatternProc = ^TPatternProc;
     TPatternProc = procedure( ALex: PLexical; var AReturn: Boolean; var AInfo);

{*************************************************}
{*                                               *}
{*                                               *}
{*                                               *}
{*************************************************}

     PCalcLexical = ^TCalcLexical;
     TCalcLexical = object( TLexical)
     private
         CollomnNo: Longint;
         LineNo: Longint;
     public
         constructor Create( AOwner: PErrGeneric; ASource: PStream);
         procedure InputFilter( AChar: Char); virtual;
         function GetNextState( AState: Word; AChar: Char): Word; virtual;
         function CallPatternProcedure( AState: Word; var ATokenInfo): Boolean; virtual;
         function IsAcceptingState( AState: Word): Boolean; virtual;
         procedure BadLexeme( var ATokenInfo); virtual;
         function TerminateToken( var ATokenInfo): Boolean; virtual;
         function GetLineNo: Longint;
         function GetCollomnNo: Longint;
         end;

implementation

{******************************************************************}
{*                                                                *}
{******************************************************************}

{$I CALCDEFS.INC}

const LEX_STATESCOUNT = 11;
      LEX_ALPHABETSIZE = 9;
      LEX_STARTSTATE = 1;


const LexicalCharGoupsTable: array[Char] of Byte =
(
 {    0 }   0,   8,   8,   8,   8,   8,   8,   8,
 {    8 }   8,   8,   8,   8,   8,   8,   8,   8,
 {   16 }   8,   8,   8,   8,   8,   8,   8,   8,
 {   24 }   8,   8,   8,   8,   8,   8,   8,   8,
 {   32 }   8,   0,   0,   0,   0,   0,   0,   0,
 {   40 }   6,   7,   4,   2,   0,   3,   9,   5,
 {   48 }   1,   1,   1,   1,   1,   1,   1,   1,
 {   56 }   1,   1,   0,   0,   0,   0,   0,   0,
 {   64 }   0,   0,   0,   0,   0,   0,   0,   0,
 {   72 }   0,   0,   0,   0,   0,   0,   0,   0,
 {   80 }   0,   0,   0,   0,   0,   0,   0,   0,
 {   88 }   0,   0,   0,   0,   0,   0,   0,   0,
 {   96 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  104 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  112 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  120 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  128 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  136 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  144 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  152 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  160 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  168 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  176 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  184 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  192 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  200 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  208 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  216 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  224 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  232 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  240 }   0,   0,   0,   0,   0,   0,   0,   0,
 {  248 }   0,   0,   0,   0,   0,   0,   0,   0
);

const CalcLexicalAutoTable: array[ 1..LEX_STATESCOUNT, 1..LEX_ALPHABETSIZE] of Word =
(
{    1 } (   2,   3,   4,   5,   6,   7,   8,   9,   0),
{    2 } (   2,   0,   0,   0,   0,   0,   0,   0,  10),
{    3 } (   0,   0,   0,   0,   0,   0,   0,   0,   0),
{    4 } (   0,   0,   0,   0,   0,   0,   0,   0,   0),
{    5 } (   0,   0,   0,   0,   0,   0,   0,   0,   0),
{    6 } (   0,   0,   0,   0,   0,   0,   0,   0,   0),
{    7 } (   0,   0,   0,   0,   0,   0,   0,   0,   0),
{    8 } (   0,   0,   0,   0,   0,   0,   0,   0,   0),
{    9 } (   0,   0,   0,   0,   0,   0,   0,   9,   0),
{   10 } (  11,   0,   0,   0,   0,   0,   0,   0,   0),
{   11 } (  11,   0,   0,   0,   0,   0,   0,   0,   0)
);


{$F+}

procedure LEX_Action1( ALex: PLexical; var AReturn: Boolean; var AInfo);
var
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


procedure LEX_Action2( ALex: PLexical; var AReturn: Boolean; var AInfo);

begin
     {YACC_Plus}
     TTokenAttributes(AInfo).Token := YACC_Plus;
end;


procedure LEX_Action3( ALex: PLexical; var AReturn: Boolean; var AInfo);

begin
     {YACC_Minus}
     TTokenAttributes(AInfo).Token := YACC_Minus;
end;


procedure LEX_Action4( ALex: PLexical; var AReturn: Boolean; var AInfo);

begin
     {YACC_Mul}
     TTokenAttributes(AInfo).Token := YACC_Mul;
end;


procedure LEX_Action5( ALex: PLexical; var AReturn: Boolean; var AInfo);

begin
     {YACC_Div}
     TTokenAttributes(AInfo).Token := YACC_Div;
end;


procedure LEX_Action6( ALex: PLexical; var AReturn: Boolean; var AInfo);

begin
     {YACC_LB}
     TTokenAttributes(AInfo).Token := YACC_LB;
end;


procedure LEX_Action7( ALex: PLexical; var AReturn: Boolean; var AInfo);

begin
     {YACC_RB}
     TTokenAttributes(AInfo).Token := YACC_RB;
end;


procedure LEX_Action8( ALex: PLexical; var AReturn: Boolean; var AInfo);

begin
     {BLANK}
     AReturn := False;
end;


procedure LEX_Action9( ALex: PLexical; var AReturn: Boolean; var AInfo);
var
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




const LexicalPatternsTable: array[ 1..LEX_STATESCOUNT] of TPatternProc =
(
nil,
LEX_Action1,
LEX_Action2,
LEX_Action3,
LEX_Action4,
LEX_Action5,
LEX_Action6,
LEX_Action7,
LEX_Action8,
nil,
LEX_Action9
);


{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TCalcLexical.Create( AOwner: PErrGeneric; ASource: PStream);
begin
     inherited Create( AOwner, ASource);
     CollomnNo := 0;
     LineNo := 1;
end;

function TCalcLexical.GetNextState( AState: Word; AChar: Char): Word;
begin
     GetNextState := CalcLexicalAutoTable[ AState, LexicalCharGoupsTable[ AChar]];
end;

function TCalcLexical.IsAcceptingState( AState: Word): Boolean;
begin
     IsAcceptingState := (@LexicalPatternsTable[AState] <> nil);
end;

procedure TCalcLexical.InputFilter( AChar: Char);
begin
     if ( AChar = #13)
     then begin
          LineNo := LineNo + 1;
          CollomnNo := 0;
          end
     else CollomnNo := CollomnNo + 1;
end;

function TCalcLexical.CallPatternProcedure( AState: Word; var ATokenInfo): Boolean;
var Return: Boolean;
begin
     if (@LexicalPatternsTable[AState] <> nil)
     then begin
          Return := True;
          LexicalPatternsTable[ AState]( @Self, Return, ATokenInfo);
          CallPatternProcedure := Return;
          end
     else begin
          BadLexeme( ATokenInfo);
          CallPatternProcedure := False;
          end;
end;

procedure TCalcLexical.BadLexeme( var ATokenInfo);
var S1, S2: string;
begin
     Str( GetLineNo, S1);
     Str( GetCollomnNo, S2);
     S1 := 'LEXICAL ERROR: Bad lexeme (Line ' + S1 + ', Col ' + S2 + ').';
     AddError( New( PMessageError, Create(S1)));
     TTokenAttributes(ATokenInfo).Token := 0;
end;

function TCalcLexical.TerminateToken( var ATokenInfo): Boolean;
begin
     TTokenAttributes(ATokenInfo).Token := YACC_EOF;
     TerminateToken := True;
end;

function TCalcLexical.GetLineNo: Longint;
begin
     GetLineNo := LineNo;
end;

function TCalcLexical.GetCollomnNo: Longint;
begin
     GetCollomnNo := CollomnNo;
end;

end.
