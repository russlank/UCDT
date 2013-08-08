{********************************************************}
{*                                                      *}
{*   LEX tool lexical analyzer unit                     *}
{*                                                      *}
{*   File name : LEXLEXIC.PAS                           *}
{*                                                      *}
{*   Programming: Russlan Kafri - 1999                  *}
{*                                                      *}
{********************************************************}

unit LexLexical;

interface

uses Generics, Lexical, LexDefs;

type TLexemeAttributes = record
        Lexeme: Word;
        LexemeStr: array[0..MAXLEXEMESTRLENGTH] of Char;
        LexemeLen: Word;
        Buffer: PChar; BufferSize: Word;
        end;

     PPatternProc = ^TPatternProc;
     TPatternProc = function( ALex: PLexical; var AInfo): Boolean;

     PLexLexical = ^TLexLexical;
     TLexLexical = object( TLexical)
     private
         CollomnNo: Longint;
         LineNo: Longint;
     public
         constructor Create( AOwner: PErrGeneric; ASource: PStream);
         procedure InputFilter( AChar: Char); virtual;
         function GetNextState( AState: Word; AChar: Char): Word; virtual;
         function CallPatternProcedure( AState: Word; var ALexemeInfo): Boolean; virtual;
         function IsAcceptingState( AState: Word): Boolean; virtual;
         procedure BadLexeme( var ALexemeInfo); virtual;
         function TerminateLexeme( var ALexemeInfo): Boolean; virtual;
         function GetLineNo: Longint;
         function GetCollomnNo: Longint;
         end;

implementation

{******************************************************************}
{*                                                                *}
{******************************************************************}

const LexicalSTATESCOUNT = 32;
      LexicalALPHABETSIZE = 27;

const LexicalCharGoupsTable: array[Char] of Byte =
(
{    0 }  0,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
{   16 }  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
{   32 }  3, 26, 21, 20, 26, 22, 26, 26,  9, 10, 15, 16,  8, 17,  5, 23,
{   48 }  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  6,  7, 26, 18, 26, 13,
{   64 } 26,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,
{   80 }  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2, 11, 19, 12, 26,  2,
{   96 } 26,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,
{  112 }  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2, 24, 14, 25, 26, 26,
{  128 } 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27,
{  144 } 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27,
{  160 } 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27,
{  176 } 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27,
{  192 } 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27,
{  208 } 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27,
{  224 } 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27,
{  240 } 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27
);

const LexLexicalAutoTable: array[ 1..LexicalSTATESCOUNT, 1..LexicalALPHABETSIZE] of Word =
(
{    1 } (   2,   3,   6,   6,   8,   9,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,
  20,  21,  23,  25,  26,  27,  30,   0,   0,   0,   0),
{    2 } (   2,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_Char }
{    3 } (   3,   3,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_Identifier }
{    4 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_Body }
{    5 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_String }
{    6 } (   0,   0,   6,   6,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_Skip }
{    7 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_Comment }
{    8 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_Period }
{    9 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_Colen }
{   10 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_Semi }
{   11 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_Coma }
{   12 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_LeftB }
{   13 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_RightB }
{   14 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_LeftMB }
{   15 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_RightMB }
{   16 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_QMark }
{   17 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_Bar }
{   18 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_Start }
{   19 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_Plus }
{   20 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_Minus }
{   21 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_Equal }
{   22 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_DPercent }
{   23 } (  24,  24,  24,   0,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,
  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,   0),
{   24 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { LEX_Char }
{   25 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,  31,   0,   0,   0),
{   26 } (  26,  26,  26,  26,  26,  26,  26,  26,  26,  26,  26,  26,  26,  26,  26,  26,
  26,  26,  26,  26,   5,  26,  26,  26,  26,  26,  26),
{   27 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,  22,   0,   0,   0,   0,   0),
{   28 } (  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,
  31,  31,  31,  31,  31,  31,  31,  31,   4,  31,  31),
{   29 } (  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,
  32,  32,  32,  32,  32,  32,   7,  32,  32,  32,  32),
{   30 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  32,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0),
{   31 } (  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,
  31,  31,  31,  28,  31,  31,  31,  31,  31,  31,  31),
{   32 } (  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  29,  32,
  32,  32,  32,  32,  32,  32,  32,  32,  32,  32,  32)
);

function LEX_Char( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexChar;
     LEX_Char := True;
end;

function LEX_Identifier( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexIdentifier;
     LEX_Identifier := True;
end;

function LEX_Colen( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexColen;
     LEX_Colen := True;
end;

function LEX_Semi( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexSemi;
     LEX_Semi := True;
end;

function LEX_Coma( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexComa;
     LEX_Coma := True;
end;

function LEX_Body( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexBody;
     LEX_Body := True;
end;

function LEX_LeftB( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexLeftB;
     LEX_LeftB := True;
end;

function LEX_RightB( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexRightB;
     LEX_RightB := True;
end;

function LEX_LeftMB( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexLeftMB;
     LEX_LeftMB := True;
end;

function LEX_RightMB( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexRightMB;
     LEX_RightMB := True;
end;

function LEX_QMark( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexQMark;
     LEX_QMark := True;
end;

function LEX_Bar( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexBar;
     LEX_Bar := True;
end;

function LEX_Start( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexStar;
     LEX_Start := True;
end;

function LEX_Plus( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexPlus;
     LEX_Plus := True;
end;

function LEX_Minus( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexMinus;
     LEX_Minus := True;
end;

function LEX_Equal( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexEqual;
     LEX_Equal := True;
end;

function LEX_DPercent( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexDPercent;
     LEX_DPercent := True;
end;

function LEX_String( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexString;
     LEX_String := True;
end;

function LEX_Skip( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexNone;
     LEX_Skip := False;
end;

function LEX_Comment( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexNone;
     LEX_Comment := False;
end;

const LexicalPatternsTable: array[ 1..LexicalSTATESCOUNT] of TPatternProc =
(
{    1 } nil,
{    2 } LEX_Char,
{    3 } LEX_Identifier,
{    4 } LEX_Body,
{    5 } LEX_String,
{    6 } LEX_Skip,
{    7 } LEX_Comment,
{    8 } nil,
{    9 } LEX_Colen,
{   10 } LEX_Semi,
{   11 } LEX_Coma,
{   12 } LEX_LeftB,
{   13 } LEX_RightB,
{   14 } LEX_LeftMB,
{   15 } LEX_RightMB,
{   16 } LEX_QMark,
{   17 } LEX_Bar,
{   18 } LEX_Start,
{   19 } LEX_Plus,
{   20 } LEX_Minus,
{   21 } LEX_Equal,
{   22 } LEX_DPercent,
{   23 } nil,
{   24 } LEX_Char,
{   25 } nil,
{   26 } nil,
{   27 } nil,
{   28 } nil,
{   29 } nil,
{   30 } nil,
{   31 } nil,
{   32 } nil
);

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TLexLexical.Create( AOwner: PErrGeneric; ASource: PStream);
begin
     inherited Create( AOwner, ASource);
     CollomnNo := 0;
     LineNo := 1;
end;

function TLexLexical.GetNextState( AState: Word; AChar: Char): Word;
begin
     GetNextState := LexLexicalAutoTable[ AState, LexicalCharGoupsTable[ AChar]];
end;

function TLexLexical.IsAcceptingState( AState: Word): Boolean;
begin
     IsAcceptingState := (@LexicalPatternsTable[AState] <> nil);
end;

procedure TLexLexical.InputFilter( AChar: Char);
begin
     if ( AChar = #13)
     then begin
          LineNo := LineNo + 1;
          CollomnNo := 0;
          end
     else CollomnNo := CollomnNo + 1;
end;

function TLexLexical.CallPatternProcedure( AState: Word; var ALexemeInfo): Boolean;
begin
     if (@LexicalPatternsTable[AState] <> nil)
     then CallPatternProcedure := LexicalPatternsTable[ AState]( @Self, ALexemeInfo)
     else begin
          BadLexeme( ALexemeInfo);
          CallPatternProcedure := False;
          end;
end;

procedure TLexLexical.BadLexeme( var ALexemeInfo);
var S1, S2: string;
begin
     Str( GetLineNo, S1);
     Str( GetCollomnNo, S2);
     S1 := 'LEXICAL ERROR: Bad lexeme (Line ' + S1 + ', Col ' + S2 + ').';
     AddError( New( PMessageError, Create(S1)));
     TLexemeAttributes(ALexemeInfo).Lexeme := lexError;
end;

function TLexLexical.TerminateLexeme( var ALexemeInfo): Boolean;
begin
     TLexemeAttributes(ALexemeInfo).Lexeme := lexEOF;
     TerminateLexeme := True;
end;

function TLexLexical.GetLineNo: Longint;
begin
     GetLineNo := LineNo;
end;

function TLexLexical.GetCollomnNo: Longint;
begin
     GetCollomnNo := CollomnNo;
end;

end.
