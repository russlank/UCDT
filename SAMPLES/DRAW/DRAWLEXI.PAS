unit DrawLexical;

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

     PDrawLexical = ^TDrawLexical;
     TDrawLexical = object( TLexical)
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

{$I DrawDEFS.INC}

const LEX_STATESCOUNT = 54;
      LEX_ALPHABETSIZE = 29;
      LEX_STARTSTATE = 1;


const LexiDrawharGoupsTable: array[Char] of Byte =
(
 {    0 }   0,   3,   3,   3,   3,   3,   3,   3,
 {    8 }   3,   3,   3,   3,   3,   3,   3,   3,
 {   16 }   3,   3,   3,   3,   3,   3,   3,   3,
 {   24 }   3,   3,   3,   3,   3,   3,   3,   3,
 {   32 }   3,   0,   0,   0,   0,   0,   0,   0,
 {   40 }   9,  10,   8,   5,  11,   6,  29,   7,
 {   48 }   1,   1,   1,   1,   1,   1,   1,   1,
 {   56 }   1,   1,   0,  12,   0,   4,   0,   0,
 {   64 }   0,  28,  28,  28,  28,  28,  28,  28,
 {   72 }  28,  28,  28,  28,  28,  28,  28,  28,
 {   80 }  28,  28,  28,  28,  28,  28,  28,  28,
 {   88 }  28,  28,  28,   0,   0,   0,   0,  28,
 {   96 }   0,  24,  18,  14,  19,  16,  28,  28,
 {  104 }  28,  21,  28,  28,  13,  28,  22,  23,
 {  112 }  20,  25,  17,   2,  15,  28,  28,  27,
 {  120 }  26,  28,  28,   0,   0,   0,   0,   0,
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

const DrawLexicalAutoTable: array[ 1..LEX_STATESCOUNT, 1..LEX_ALPHABETSIZE] of Word =
(
{    1 } (   9,  10,  11,  12,  13,  14,  15,  16,  17,  18,
            19,  20,  24,  36,  37,  38,  39,  40,  46,  50,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{    2 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{    3 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{    4 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{    5 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{    6 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{    7 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{    8 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{    9 } (   9,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,  21),
{   10 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            25,  54,  54,  54,  26,  54,  54,  54,   0),
{   11 } (   0,   0,  11,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0),
{   12 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0),
{   13 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0),
{   14 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0),
{   15 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0),
{   16 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0),
{   17 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0),
{   18 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0),
{   19 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0),
{   20 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0),
{   21 } (  23,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0),
{   22 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,   2,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{   23 } (  23,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,   0,   0,   0,   0,   0,   0,   0),
{   24 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            41,   2,  54,  54,  54,  54,  54,  54,   0),
{   25 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,   2,  54,  54,  54,  54,  54,  54,   0),
{   26 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  22,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{   27 } (  54,   2,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{   28 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,   2,  54,  54,  54,  54,  54,  54,   0),
{   29 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,   2,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{   30 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,   7,  54,  54,   0),
{   31 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,   6,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{   32 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,   4,  54,   0),
{   33 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,   8,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{   34 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,   5,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{   35 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,   3,  54,   0),
{   36 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            51,  54,  27,  54,  54,  54,  54,  54,   0),
{   37 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  28,  54,  54,  54,  54,   0),
{   38 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  29,  54,  54,   0),
{   39 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  53,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{   40 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  30,  54,  54,  54,  54,  54,   0),
{   41 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  31,  54,  54,  54,  54,  54,  54,   0),
{   42 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  32,  54,  54,  54,  54,   0),
{   43 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  33,  54,  54,  54,  54,  54,  54,   0),
{   44 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  34,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{   45 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  35,  54,  54,  54,  54,   0),
{   46 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  42,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{   47 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            43,  54,  54,  54,  54,  54,  54,  54,   0),
{   48 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  44,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{   49 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  45,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{   50 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  47,  54,  54,  54,  54,  54,   0),
{   51 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  48,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{   52 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  49,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{   53 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  52,
            54,  54,  54,  54,  54,  54,  54,  54,   0),
{   54 } (  54,  54,   0,   0,   0,   0,   0,   0,   0,   0,
             0,   0,  54,  54,  54,  54,  54,  54,  54,  54,
            54,  54,  54,  54,  54,  54,  54,  54,   0)
);


{$F+}

procedure LEX_Action1( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Fun}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Fun;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action2( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
       {YACC_RepDraw}
       TTokenAttributes(AInfo).Token := YACC_RepDraw;
end;

procedure LEX_Action3( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
       {YACC_DRAW}
       TTokenAttributes(AInfo).Token := YACC_Draw;
end;

procedure LEX_Action4( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
       {YACC_Circle}
       TTokenAttributes(AInfo).Token := YACC_Circle;
end;

procedure LEX_Action5( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
       {YACC_Line}
       TTokenAttributes(AInfo).Token := YACC_Line;
end;

procedure LEX_Action6( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
       {YACC_Box}
       TTokenAttributes(AInfo).Token := YACC_Box;
end;

procedure LEX_Action7( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
       {YACC_Point}
       TTokenAttributes(AInfo).Token := YACC_Point;
end;

procedure LEX_Action8( ALex: PLexical; var AReturn: Boolean; var AInfo);
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

procedure LEX_Action9( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action10( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {BLANK}
     AReturn := False;
end;

procedure LEX_Action11( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Assign}
     TTokenAttributes(AInfo).Token := YACC_Assign;
end;

procedure LEX_Action12( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Plus}
     TTokenAttributes(AInfo).Token := YACC_Plus;
end;

procedure LEX_Action13( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Minus}
     TTokenAttributes(AInfo).Token := YACC_Minus;
end;

procedure LEX_Action14( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Plus}
     TTokenAttributes(AInfo).Token := YACC_Div;
end;

procedure LEX_Action15( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Mul}
     TTokenAttributes(AInfo).Token := YACC_Mul;
end;

procedure LEX_Action16( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_LB}
     TTokenAttributes(AInfo).Token := YACC_LB;
end;

procedure LEX_Action17( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_RB}
     TTokenAttributes(AInfo).Token := YACC_RB;
end;

procedure LEX_Action18( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
       {YACC_Coma}
       TTokenAttributes(AInfo).Token := YACC_Coma;
end;

procedure LEX_Action19( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
       {YACC_SColen}
       TTokenAttributes(AInfo).Token := YACC_SColen;
end;

procedure LEX_Action20( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Fun}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Fun;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action21( ALex: PLexical; var AReturn: Boolean; var AInfo);
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

procedure LEX_Action22( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action23( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action24( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action25( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action26( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action27( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action28( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action29( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action30( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action31( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action32( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action33( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action34( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action35( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action36( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action37( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action38( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action39( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action40( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action41( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action42( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action43( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action44( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action45( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action46( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action47( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action48( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action49( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action50( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action51( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
        end;
end;

procedure LEX_Action52( ALex: PLexical; var AReturn: Boolean; var AInfo);
begin
     {YACC_Id}
     with TTokenAttributes(AInfo)
     do begin
        Token := YACC_Id;
        LexemeLen := ALex^.GetMatchedLexeme(Lexeme, MAXLEXEMESTRLENGTH);
        Lexeme[LexemeLen] := #0;
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
LEX_Action9,
LEX_Action10,
LEX_Action11,
LEX_Action12,
LEX_Action13,
LEX_Action14,
LEX_Action15,
LEX_Action16,
LEX_Action17,
LEX_Action18,
LEX_Action19,
nil,
LEX_Action20,
LEX_Action21,
LEX_Action22,
LEX_Action23,
LEX_Action24,
LEX_Action25,
LEX_Action26,
LEX_Action27,
LEX_Action28,
LEX_Action29,
LEX_Action30,
LEX_Action31,
LEX_Action32,
LEX_Action33,
LEX_Action34,
LEX_Action35,
LEX_Action36,
LEX_Action37,
LEX_Action38,
LEX_Action39,
LEX_Action40,
LEX_Action41,
LEX_Action42,
LEX_Action43,
LEX_Action44,
LEX_Action45,
LEX_Action46,
LEX_Action47,
LEX_Action48,
LEX_Action49,
LEX_Action50,
LEX_Action51,
LEX_Action52
);


{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TDrawLexical.Create( AOwner: PErrGeneric; ASource: PStream);
begin
     inherited Create( AOwner, ASource);
     CollomnNo := 0;
     LineNo := 1;
end;

function TDrawLexical.GetNextState( AState: Word; AChar: Char): Word;
begin
     GetNextState := DrawLexicalAutoTable[ AState, LexiDrawharGoupsTable[ AChar]];
end;

function TDrawLexical.IsAcceptingState( AState: Word): Boolean;
begin
     IsAcceptingState := (@LexicalPatternsTable[AState] <> nil);
end;

procedure TDrawLexical.InputFilter( AChar: Char);
begin
     if ( AChar = #13)
     then begin
          LineNo := LineNo + 1;
          CollomnNo := 0;
          end
     else CollomnNo := CollomnNo + 1;
end;

function TDrawLexical.CallPatternProcedure( AState: Word; var ATokenInfo): Boolean;
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

procedure TDrawLexical.BadLexeme( var ATokenInfo);
var S1, S2: string;
begin
     Str( GetLineNo, S1);
     Str( GetCollomnNo, S2);
     S1 := 'LEXICAL ERROR: Bad lexeme (Line ' + S1 + ', Col ' + S2 + ').';
     AddError( New( PMessageError, Create(S1)));
     TTokenAttributes(ATokenInfo).Token := 0;
end;

function TDrawLexical.TerminateToken( var ATokenInfo): Boolean;
begin
     TTokenAttributes(ATokenInfo).Token := YACC_EOF;
     TerminateToken := True;
end;

function TDrawLexical.GetLineNo: Longint;
begin
     GetLineNo := LineNo;
end;

function TDrawLexical.GetCollomnNo: Longint;
begin
     GetCollomnNo := CollomnNo;
end;

end.
