{********************************************************}
{*                                                      *}
{*   YACC tool lexical analyzer unit                    *}
{*                                                      *}
{*   File name : YACCLEXI.PAS                           *}
{*                                                      *}
{*   Programming: Russlan Kafri - 1999                  *}
{*                                                      *}
{********************************************************}

unit YaccLexical;

interface

uses Generics, Lexical, YaccDefs;

type TLexemeAttributes = record
        Lexeme: Word;
        LexemeStr: array[0..MAXLEXEMESTRLENGTH] of Char;
        LexemeLen: Word;
        Buffer: PChar; BufferSize: Word;
        end;

     PPatternProc = ^TPatternProc;
     TPatternProc = function( ALex: PLexical; var AInfo): Boolean;

{*************************************************}
{*                                               *}
{*                                               *}
{*                                               *}
{*************************************************}

     PYaccLexical = ^TYaccLexical;
     TYaccLexical = object( TLexical)
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

const LexicalSTATESCOUNT = 17;
      LexicalALPHABETSIZE = 14;

const LexicalCharGoupsTable: array[Char] of Byte =
(
{    0 }  0,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,
{   16 }  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,
{   32 }  2, 14, 13,  8, 14,  7, 14, 14, 14, 14, 10, 14, 14, 14, 14,  6,
{   48 }  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  5,  4, 14, 14, 14, 14,
{   64 } 14,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
{   80 }  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1, 14, 14, 14, 14,  1,
{   96 } 14,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
{  112 }  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1, 11,  3, 12, 14, 14,
{  128 } 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
{  144 } 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
{  160 } 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
{  176 } 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
{  192 } 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
{  208 } 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
{  224 } 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
{  240 } 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14
);


const YaccLexicalAutoTable: array[ 1..LexicalSTATESCOUNT, 1..LexicalALPHABETSIZE] of Word =
(
{    1 } (   2,   3,   7,   8,   9,  11,  12,  15,   0,   0,   0,   0,   0,   0),
{    2 } (   2,   0,   0,   0,   0,   0,   0,   0,   2,   0,   0,   0,   0,   0), { YACC_Identifier }
{    3 } (   0,   3,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { YACC_Blank }
{    4 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { YACC_Comment }
{    5 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { YACC_Body }
{    6 } (   6,   0,   0,   0,   0,   0,   0,   0,   6,   0,   0,   0,   0,   0), { YACC_Command }
{    7 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { YACC_Bar }
{    8 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { YACC_Semi }
{    9 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { YACC_Colen }
{   10 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0), { YACC_DPercent }
{   11 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,  16,   0,   0,   0,   0),
{   12 } (   6,   0,   0,   0,   0,   0,  10,   0,   0,   0,   0,   0,   0,   0),
{   13 } (  16,  16,  16,  16,  16,   4,  16,  16,  16,  16,  16,  16,  16,  16),
{   14 } (  17,  17,  17,  17,  17,  17,  17,  17,  17,  17,  17,   5,  17,  17),
{   15 } (   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  17,   0,   0,   0),
{   16 } (  16,  16,  16,  16,  16,  16,  16,  16,  16,  13,  16,  16,  16,  16),
{   17 } (  17,  17,  17,  17,  17,  17,  17,  14,  17,  17,  17,  17,  17,  17)
);

function YACC_Identifier( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexIdentifier;
     YACC_Identifier := True;
end;

function YACC_Command( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexDeclCommand;
     YACC_Command := True;
end;

function YACC_Colen( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexColen;
     YACC_Colen := True;
end;

function YACC_Semi( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexSemi;
     YACC_Semi := True;
end;

function YACC_Body( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexBody;
     YACC_Body := True;
end;

function YACC_Bar( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexBar;
     YACC_Bar := True;
end;

function YACC_DPercent( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexDPercent;
     YACC_DPercent := True;
end;

function YACC_Blank( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexNone;
     YACC_Blank := False;
end;

function YACC_Comment( ALex: PLexical; var AInfo): Boolean; far;
begin
     TLexemeAttributes(AInfo).LexemeLen :=
        ALex^.GetMatchedLexeme(TLexemeAttributes(AInfo).LexemeStr, MAXLEXEMESTRLENGTH);
     TLexemeAttributes(AInfo).LexemeStr[TLexemeAttributes(AInfo).LexemeLen] := #0;
     TLexemeAttributes(AInfo).Lexeme := lexNone;
     YACC_Comment := False;
end;

const LexicalPatternsTable: array[ 1..LexicalSTATESCOUNT] of TPatternProc =
(
{    1 } nil,
{    2 } YACC_Identifier,
{    3 } YACC_Blank,
{    4 } YACC_Comment,
{    5 } YACC_Body,
{    6 } YACC_Command,
{    7 } YACC_Bar,
{    8 } YACC_Semi,
{    9 } YACC_Colen,
{   10 } YACC_DPercent,
{   11 } nil,
{   12 } nil,
{   13 } nil,
{   14 } nil,
{   15 } nil,
{   16 } nil,
{   17 } nil
);

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TYaccLexical.Create( AOwner: PErrGeneric; ASource: PStream);
begin
     inherited Create( AOwner, ASource);
     CollomnNo := 0;
     LineNo := 1;
end;

function TYaccLexical.GetNextState( AState: Word; AChar: Char): Word;
begin
     GetNextState := YaccLexicalAutoTable[ AState, LexicalCharGoupsTable[ AChar]];
end;

function TYaccLexical.IsAcceptingState( AState: Word): Boolean;
begin
     IsAcceptingState := (@LexicalPatternsTable[AState] <> nil);
end;

procedure TYaccLexical.InputFilter( AChar: Char);
begin
     if ( AChar = #13)
     then begin
          LineNo := LineNo + 1;
          CollomnNo := 0;
          end
     else CollomnNo := CollomnNo + 1;
end;

function TYaccLexical.CallPatternProcedure( AState: Word; var ALexemeInfo): Boolean;
begin
     if (@LexicalPatternsTable[AState] <> nil)
     then CallPatternProcedure := LexicalPatternsTable[ AState]( @Self, ALexemeInfo)
     else begin
          BadLexeme( ALexemeInfo);
          CallPatternProcedure := False;
          end;
end;

procedure TYaccLexical.BadLexeme( var ALexemeInfo);
var S1, S2: string;
begin
     Str( GetLineNo, S1);
     Str( GetCollomnNo, S2);
     S1 := 'LEXICAL ERROR: Bad lexeme (Line ' + S1 + ', Col ' + S2 + ').';
     AddError( New( PMessageError, Create(S1)));
     TLexemeAttributes(ALexemeInfo).Lexeme := lexError;
end;

function TYaccLexical.TerminateLexeme( var ALexemeInfo): Boolean;
begin
     TLexemeAttributes(ALexemeInfo).Lexeme := lexEOF;
     TerminateLexeme := True;
end;

function TYaccLexical.GetLineNo: Longint;
begin
     GetLineNo := LineNo;
end;

function TYaccLexical.GetCollomnNo: Longint;
begin
     GetCollomnNo := CollomnNo;
end;

end.
