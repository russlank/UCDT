{********************************************************}
{*                                                      *}
{*   LEX & YACC tools generic lexical analyzer unit     *}
{*                                                      *}
{*   File name : LEXICAL.PAS                            *}
{*                                                      *}
{*   Programming: Russlan Kafri - 1999                  *}
{*                                                      *}
{********************************************************}

unit Lexical;

interface

uses Generics;

const BUFFERBLOCKSIZE           = $FFF0;
      MAXLEXEMESTRLENGTH        = 8192;

type PBufferBlock = ^TBufferBlock;
     TBufferBlock = record
         Data: array[0..BUFFERBLOCKSIZE] of char;
         Next: PBufferBlock;
         end;

     PBufferPtr = ^TBufferPtr;
     TBufferPtr = record
         Block: PBufferBlock;
         Ptr: PChar;
         end;

     PLexical= ^TLexical;
     TLexical = object( TErrGeneric)
     private
         Source: PStream;
         FirstBlock,
         LastBlock: PBufferBlock;

         LexemeStartPtr,
         ForwardPtr,
         LastMatchPtr: TBufferPtr;
         ErrorOcured: Boolean;

         ForwardState: Word;
         LastMatchState: Word;
         procedure Initialize;
         function AllocateNewBlock: PBufferBlock;
         function ReadNewBlock: PBufferBlock;
         procedure FreePassedBlocks;
     public
         constructor Create( AOwner: PErrGeneric; ASource: PStream);
         destructor Destroy; virtual;
         function NextChar: Char;
         procedure ScanPassed;
         function GetMatchedLexeme( var ABuf; ABufferSize: Word): Word;
         procedure DisplayBlocks;
         function Lexeme( var ALexemeInfo): Boolean;
         procedure InputFilter( AChar: Char); virtual;
         function CallPatternProcedure( AState: Word; var ALexemeInfo): Boolean; virtual;
         function GetNextState( AState: Word; AChar: Char): Word; virtual;
         function IsAcceptingState( AState: Word): Boolean; virtual;
         procedure BadLexeme( var ALexemeInfo); virtual;
         function TerminateLexeme( var ALexemeInfo): Boolean; virtual;
         end;

implementation

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TLexical.Create( AOwner: PErrGeneric; ASource: PStream);
begin
     inherited Create( AOwner);

     Source := ASource;
     FirstBlock := nil;
     LastBlock := nil;

     ForwardPtr.Block := nil;
     ForwardPtr.Ptr := nil;
     LexemeStartPtr.Block := nil;
     LexemeStartPtr.Ptr := nil;
     LastMatchPtr.Block := nil;
     LastMatchPtr.Ptr := nil;

     ForwardState := 1;
     LastMatchState := 1;

     ErrorOcured := False;

     Initialize;
end;

destructor TLexical.Destroy;
var ScanBlock: PBufferBlock;
begin
     ScanBlock := FirstBlock;
     while ( ScanBlock <> nil)
     do begin
        ScanBlock := ScanBlock^.Next;
        Dispose( FirstBlock);
        FirstBlock := ScanBlock;
        end;

     inherited Destroy;
end;

procedure TLexical.Initialize;
begin
     if ErrorOcured
     then Exit;

     ForwardPtr.Block := ReadNewBlock;
     ForwardPtr.Ptr := @ForwardPtr.Block^.Data[0];

     LexemeStartPtr := ForwardPtr;
     LastMatchPtr := ForwardPtr;
end;

function TLexical.AllocateNewBlock: PBufferBlock;
var NewBlock: PBufferBlock;
begin
     New( NewBlock);
     NewBlock^.Next := nil;
     if ( FirstBlock <> nil)
     then begin
          LastBlock^.Next := NewBlock;
          LastBlock := NewBlock;
          end
     else begin
          FirstBlock := NewBlock;
          LastBlock := NewBlock;
          end;
     AllocateNewBlock := NewBlock;
end;

function TLexical.ReadNewBlock: PBufferBlock;
var NewBlock: PBufferBlock;
    Readen: Word;
begin
     if ErrorOcured
     then begin
          ReadNewBlock := nil;
          Exit;
          end;
     if ( Source <> nil)
     then begin
          NewBlock := AllocateNewBlock;
          Readen := Source^.Read( NewBlock^.Data, BUFFERBLOCKSIZE);
          NewBlock^.Data[Readen] := #0;
          ReadNewBlock := NewBlock;
          end
     else ReadNewBlock := nil;
end;

procedure TLexical.FreePassedBlocks;
var ScanBlock: PBufferBlock;
begin
     ScanBlock := FirstBlock;
     while (( ScanBlock <> nil) and ( ScanBlock <> LexemeStartPtr.Block))
     do begin
        ScanBlock := ScanBlock^.Next;
        Dispose( FirstBlock);
        FirstBlock := ScanBlock;
        end;
end;

function TLexical.NextChar: Char;
begin
     if ErrorOcured
     then begin
          NextChar := #0;
          Exit;
          end;

     if (ForwardPtr.Ptr^ <> #0)
     then begin
          NextChar := ForwardPtr.Ptr^;
          ForwardPtr.Ptr := ForwardPtr.Ptr + 1;
          end
     else begin
          if (ForwardPtr.Ptr = @ForwardPtr.Block^.Data[BUFFERBLOCKSIZE])
          then begin
               if (ForwardPtr.Block^.Next <> nil)
               then ForwardPtr.Block := ForwardPtr.Block^.Next
               else ForwardPtr.Block := ReadNewBlock;
               ForwardPtr.Ptr := @ForwardPtr.Block^.Data[0];
               if ForwardPtr.Ptr^ <> #0
               then begin
                    NextChar := ForwardPtr.Ptr^;
                    ForwardPtr.Ptr := ForwardPtr.Ptr + 1;
                    end
               else NextChar := #0;
               end
          else NextChar := #0;
          end;
end;

procedure TLexical.DisplayBlocks;
var ScanBlock: PBufferBlock;
    I: Longint;
begin
     I := 1;
     ScanBlock := FirstBlock;
     while ( ScanBlock <> nil)
     do begin
        WriteLn(I:4,'>',ScanBlock^.Data,'<');
        ScanBlock := ScanBlock^.Next;
        I := I + 1;
        end;
end;

function TLexical.GetNextState( AState: Word; AChar: Char): Word;
begin
     GetNextState := 0;
end;

function TLexical.IsAcceptingState( AState: Word): Boolean;
begin
     IsAcceptingState := False;
end;

procedure TLexical.InputFilter( AChar: Char);
begin
end;

function TLexical.CallPatternProcedure( AState: Word; var ALexemeInfo): Boolean;
begin
     CallPatternProcedure := False;
end;

procedure TLexical.BadLexeme( var ALexemeInfo);
begin
end;

function TLexical.TerminateLexeme( var ALexemeInfo): Boolean;
begin
     TerminateLexeme := False;
end;

function TLexical.Lexeme( var ALexemeInfo): Boolean;
var ForwardChar: Char;
    ThereIsAPattern: Boolean;
begin
     repeat
           ScanPassed;
           FreePassedBlocks;
           ForwardState := 1;
           LastMatchState := 1;

           ThereIsAPattern := False;

           while True
           do begin
              ForwardChar := NextChar;
              if ( ForwardChar <> #0)
              then ForwardState := GetNextState( ForwardState, ForwardChar)
              else ForwardState := 0;
              if ( ForwardState > 0)
              then begin
                   if IsAcceptingState( ForwardState)
                   then begin
	                LastMatchState := ForwardState;
		        LastMatchPtr := ForwardPtr;
                        end;
                   end
              else Break;
              end;

           if ( LastMatchPtr.Ptr = LexemeStartPtr.Ptr)
           then begin
                if (( ForwardChar = #0) and ( LexemeStartPtr.Ptr = ForwardPtr.Ptr))
                then ThereIsAPattern := TerminateLexeme( ALexemeInfo)
                else begin
                     LastMatchPtr := ForwardPtr;
                     BadLexeme( ALexemeInfo);
                     ThereIsAPattern := False;
                     end;
                Break;
                end
           else ThereIsAPattern := CallPatternProcedure( LastMatchState, ALexemeInfo);

     until ( ThereIsAPattern);

     Lexeme := ThereIsAPattern;
end;

procedure TLexical.ScanPassed;
var ScanPtr: TBufferPtr;
begin
     ScanPtr := LexemeStartPtr;
     while ( ScanPtr.Ptr <> LastMatchPtr.Ptr)
     do begin
        if (ScanPtr.Ptr^ <> #0)
        then begin
             InputFilter( ScanPtr.Ptr^);
             ScanPtr.Ptr := ScanPtr.Ptr + 1;
             end
        else begin
             if ( ScanPtr.Ptr = @ScanPtr.Block^.Data[BUFFERBLOCKSIZE])
             then begin
                  ScanPtr.Block := ScanPtr.Block^.Next;
                  if ( ScanPtr.Block <> nil)
                  then ScanPtr.Ptr := @ScanPtr.Block^.Data[0]
                  else Break;
                  end
             else Break;
             end;
        end;
     LexemeStartPtr := ScanPtr;
     ForwardPtr := ScanPtr;
end;

function TLexical.GetMatchedLexeme( var ABuf; ABufferSize: Word): Word;
var Buf: PChar;
    LexemeSize: Word;
    ScanPtr: TBufferPtr;
begin
     Buf := @ABuf;
     LexemeSize := 0;
     ScanPtr := LexemeStartPtr;
     while (( ScanPtr.Ptr <> LastMatchPtr.Ptr) and ( LexemeSize < ABufferSize))
     do begin
        if (ScanPtr.Ptr^ <> #0)
        then begin
             Buf^ := ScanPtr.Ptr^;
             Buf := Buf + 1;
             ScanPtr.Ptr := ScanPtr.Ptr + 1;
             LexemeSize := LexemeSize + 1;
             end
        else begin
             if ( ScanPtr.Ptr = @ScanPtr.Block^.Data[BUFFERBLOCKSIZE])
             then begin
                  ScanPtr.Block := ScanPtr.Block^.Next;
                  if ( ScanPtr.Block <> nil)
                  then ScanPtr.Ptr := @ScanPtr.Block^.Data[0]
                  else Break;
                  end
             else Break;
             end;
        end;

     GetMatchedLexeme := LexemeSize;
end;

end.
