{********************************************************}
{*                                                      *}
{*   LEX & YACC tools generic syntax analyzer unit      *}
{*                                                      *}
{*   File name : PARSER.PAS                             *}
{*                                                      *}
{*   Programming: Russlan Kafri - 1999                  *}
{*                                                      *}
{********************************************************}

unit Parser;

interface

uses Generics;

type TParseAction = (actShift, actReduce, actAccept, actError);

     TActionRec = record
        case Action: TParseAction
        of actError: ( ErrorCode: Byte);
           actShift: ( NextState: Byte);
           actReduce: ( Rule: Byte);
           end;

      PStatesStackItem = ^TStatesStackItem;
      TStatesStackItem = record
         State: Byte;
         Next: PStatesStackItem;
         end;

     PStatesStack = ^TStatesStack;
     TStatesStack = object( TGeneric)
     private
        States: PStatesStackItem;
     public
        constructor Create;
        destructor Destroy; virtual;
        procedure Push( AState: Word);
        function Pop: Word;
        function Top: Word;
        procedure Remove( ACount: Word);
        procedure Clear;
        procedure Display;
        end;

     PAttribStackItem = ^TAttribStackItem;
     TAttribStackItem = record
        Item: PGeneric;
        Next: PAttribStackItem;
        end;

     PAttribStack = ^TAttribStack;
     TAttribStack = object( TGeneric)
     private
        Items: PAttribStackItem;
     public
        constructor Create;
        destructor Destroy; virtual;
        procedure Push( AItem: PGeneric);
        function Pop: PGeneric;
        procedure Remove( ACount: Word);
        procedure Clear;
        end;

     PParser = ^TParser;
     TParser = object( TErrGeneric)
     private
         StatesStack: TStatesStack;
         AttribStack: TAttribStack;
         Lexeme: Word;
         LexemeAttr: PGeneric;
         Stop: Boolean;

         procedure Reduce( ARule: Byte);
         procedure Shift( AState: Byte);
         procedure Accept;
     public
         constructor Create( AOwner: PErrGeneric);
         destructor Destroy; virtual;
         function ParsLoop: Boolean;

         procedure ExecuteSemantic( ARule: Byte); virtual;
         procedure NextLexeme; virtual;
         function GetGoto( ATopState: Byte; ANonterminal: Byte): Byte; virtual;
         procedure GetAction( ATopState: Byte; ATerminal: Word; var AAction: TActionRec); virtual;
         function GetNonterminal( ARule: Byte): Byte; virtual;
         function GetRuleSize( ARule: Byte): Byte; virtual;
         procedure Error( AErrorCode: Byte); virtual;

         procedure SetLexeme( ALexeme: Word; AAttrs: PGeneric);
         function GetLexemeAttrs: PGeneric;
         procedure StopParsing;

         function PopAttribute: PGeneric;
         procedure PushAttribute( AAttributes: PGeneric);
         end;


implementation

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TStatesStack.Create;
begin
     inherited Create;
     States := nil;
end;

destructor TStatesStack.Destroy;
begin
     Clear;
     inherited Destroy;
end;

procedure TStatesStack.Push( AState: Word);
var NewItem: PStatesStackItem;
begin
     New( NewItem);
     NewItem^.State := AState;
     NewItem^.Next := States;
     States := NewItem;
end;

function TStatesStack.Pop: Word;
var PopedItem: PStatesStackItem;
begin
     if (States <> nil)
     then begin
          PopedItem := States;
          States := PopedItem^.Next;
          Pop := PopedItem^.State;
          Dispose( PopedItem);
          end
     else Halt;
end;

function TStatesStack.Top: Word;
begin
     if (States <> nil)
     then Top := States^.State
     else Halt;
end;

procedure TStatesStack.Remove( ACount: Word);
var I: Word;
    ScanItem: PStatesStackItem;
begin
     if (ACount > 0)
     then begin
          for I := 1 to ACount
          do begin
             ScanItem := States;
             if (ScanItem <> nil)
             then begin
                  States := ScanItem^.Next;
                  Dispose( ScanItem);
                  end
             else Halt;
             end;
          end;
end;

procedure TStatesStack.Clear;
var ScanItem: PStatesStackItem;
begin
     ScanItem := States;
     while (ScanItem <> nil)
     do begin
        States := ScanItem^.Next;
        Dispose( ScanItem);
        ScanItem := States;
        end;
end;

procedure TStatesStack.Display;
var ScanItem: PStatesStackItem;
begin
     Write('Stack >');
     ScanItem := States;
     while (ScanItem <> nil)
     do begin
        Write( ScanItem^.State,' ');
        ScanItem := ScanItem^.Next;
        end;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TAttribStack.Create;
begin
     inherited Create;
     Items := nil
end;

destructor TAttribStack.Destroy;
begin
     Clear;
     inherited Destroy;
end;

procedure TAttribStack.Push( AItem: PGeneric);
var NewItem: PAttribStackItem;
begin
     New( NewItem);
     NewItem^.Item := AItem;
     NewItem^.Next := Items;
     Items := NewItem;
end;

function TAttribStack.Pop: PGeneric;
var PopedItem: PAttribStackItem;
begin
     if (Items <> nil)
     then begin
          PopedItem := Items;
          Items := PopedItem^.Next;
          Pop := PopedItem^.Item;
          Dispose( PopedItem);
          end
     else Halt;
end;

procedure TAttribStack.Remove( ACount: Word);
var I: Word;
    ScanItem: PAttribStackItem;
begin
     if (ACount > 0)
     then begin
          for I := 1 to ACount
          do begin
             ScanItem := Items;
             if (ScanItem <> nil)
             then begin
                  Items := ScanItem^.Next;
                  if (ScanItem^.Item <> nil)
                  then ScanItem^.Item^.Free;
                  Dispose( ScanItem);
                  end
             else Halt;
             end;
          end;
end;

procedure TAttribStack.Clear;
var ScanItem: PAttribStackItem;
begin
     ScanItem := Items;
     while (ScanItem <> nil)
     do begin
        Items := ScanItem^.Next;
        if (ScanItem^.Item <> nil)
        then ScanItem^.Item^.Free;
        Dispose( ScanItem);
        ScanItem := Items;
        end;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TParser.Create( AOwner: PErrGeneric);
begin
     inherited Create( AOwner);
     StatesStack.Create;
     AttribStack.Create;
     Stop := False;
     Lexeme := 0;
     LexemeAttr := nil;
end;

destructor TParser.Destroy;
begin
     StatesStack.Destroy;
     AttribStack.Destroy;

     if ( LexemeAttr <> nil)
     then LexemeAttr^.Free;

     inherited Destroy;
end;

function TParser.ParsLoop: Boolean;
var ActionRec: TActionRec;
begin
     ParsLoop := False;
     Stop := False;
     StatesStack.Clear;
     AttribStack.Clear;
     StatesStack.Push(1);
     NextLexeme;
     while not Stop
     do begin
        GetAction( StatesStack.Top, Lexeme, ActionRec);
        case ActionRec.Action
        of actShift: begin
                     Shift( ActionRec.NextState);
                     NextLexeme;
                     end;
           actReduce: begin
                      Reduce( ActionRec.Rule);
                      end;
           actAccept: begin
                      Accept;
                      ParsLoop := True;
                      end;
           actError: begin
                     Error( ActionRec.ErrorCode);
                     end;
           else
               Break;
           end;
        end;
end;

procedure TParser.ExecuteSemantic( ARule: Byte);
begin
end;

procedure TParser.NextLexeme;
begin
end;

function TParser.GetGoto( ATopState: Byte; ANonterminal: Byte): Byte;
begin
     GetGoto := 0;
     Stop := True;
end;

procedure TParser.GetAction( ATopState: Byte; ATerminal: Word; var AAction: TActionRec);
begin
     AAction.Action := actError;
     AAction.ErrorCode := 0;
     Stop := True;
end;

function TParser.GetNonterminal( ARule: Byte): Byte;
begin
     Stop := True;
     GetNonterminal := 0;
end;

function TParser.GetRuleSize( ARule: Byte): Byte;
begin
     GetRuleSize := 0;
end;

procedure TParser.Error( AErrorCode: Byte);
begin
     Stop := True;
end;

procedure TParser.SetLexeme( ALexeme: Word; AAttrs: PGeneric);
begin
     if (LexemeAttr <> nil)
     then LexemeAttr^.Free;
     LexemeAttr := AAttrs;
     Lexeme := ALexeme;
end;

function TParser.GetLexemeAttrs: PGeneric;
begin
     GetLexemeAttrs := LexemeAttr;
end;

procedure TParser.StopParsing;
begin
     Stop := True;
end;

function TParser.PopAttribute: PGeneric;
begin
     PopAttribute := AttribStack.Pop;
end;

procedure TParser.PushAttribute( AAttributes: Pgeneric);
begin
     AttribStack.Push( AAttributes);
end;

procedure TParser.Reduce( ARule: Byte);
var NonTerminal: Word;
    RuleSize: Word;
    GotoState: Word;
begin
     ExecuteSemantic( ARule);
     NonTerminal := GetNonterminal( ARule);
     RuleSize :=  GetRuleSize( ARule);
     StatesStack.Remove( RuleSize);
     GotoState := GetGoto( StatesStack.Top, NonTerminal);
     StatesStack.Push( GotoState);
end;

procedure TParser.Shift( AState: Byte);
begin
     StatesStack.Push( AState);
     if ( LexemeAttr <> nil)
     then begin
          AttribStack.Push( LexemeAttr);
          LexemeAttr := nil;
          end;
end;

procedure TParser.Accept;
begin
     StatesStack.Clear;
     Stop := True;
end;

end.