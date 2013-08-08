{********************************************************}
{*                                                      *}
{*   YACC tool engine unit                              *}
{*                                                      *}
{*   File name : YACCENGI.PAS                           *}
{*                                                      *}
{*   Programming: Russlan Kafri - 1999                  *}
{*                                                      *}
{********************************************************}

unit YaccEngine;

interface

uses Generics;

type
    PParserSymbol = ^TParserSymbol;
    TParserSymbol = object( TGeneric)
    private
        Identifier: Word;
        Title: PString;
    public
        constructor Create( AID: Word; ATitle: string);
        destructor Destroy; virtual;
        procedure SetID( AIndentifier: Word);
        function GetID: Word;
        function GetTitle: string;
        procedure Display( AStream: PStream); virtual;
        end;

    PRuleSemantic = ^TRuleSemantic;
    TRuleSemantic = object( TGeneric)
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

    PRule = ^TRule;
    TRule = object( TGeneric)
    private
       Identifier: Word;
       LeftSide: PParserSymbol;
       RightSide: TCollection;
       Semantic: PRuleSemantic;
    public
       constructor Create;
       destructor Destroy; virtual;
       procedure SetLeftSymbol( ASymbol: PParserSymbol);
       procedure AppendRightSymbol( ASymbol: PParserSymbol);
       function GetRightSide: PCollection;
       function GetLeftSymbol: PParserSymbol;
       function GetRightSymbol( AIndex:Integer):PParserSymbol;
       function GetRightSideSize: Integer;
       function GetFirstRightSymbol: PParserSymbol;
       function GetNextRightSymbol: PParserSymbol;
       procedure GetRightSideSymbols( AStartIndex: Integer; var ASymbols: TCollection);
       procedure Display( AStream: PStream); virtual;
       procedure SetID( AIdentifier: Word);
       function GetID: Word;
       procedure SetSemantic( ASemantic: PRuleSemantic);
       function GetSemantic: PRuleSemantic;
       end;

    PGrammar = ^TGrammar;
    TGrammar = object( TErrGeneric)
    private
       Symbols: TContainerCollection;
       Rules: TContainerCollection;
       NeSet: TCollection;
       Terminals: TCollection;
       Nonterminals: TCollection;
       DefinedTerminals: TCollection;
       TerminateSymbol: PParserSymbol;
       EmptySymbol: PParserSymbol;
       StartSymbol: PParserSymbol;
       procedure FindNeSet;
       procedure FindTerminalAndNonterimanls;
    public
       constructor Create( AOwner: PErrGeneric);
       destructor Destroy; virtual;
       procedure ClearRules;
       procedure Clear;
       procedure SetStartSymbol( ASymbol: PParserSymbol);
       function GetTerminateSymbol: PParserSymbol;
       function GetEmptySymbol: PParserSymbol;
       function GetStartSymbol: PParserSymbol;
       function GetStartRule: PRule;
       procedure AppendRule( ARule: PRule);
       function GetRule( AIndex: Integer): PRule;
       function GetRulesCount: Integer;
       function GetFirstRule: PRule;
       function GetNextRule: PRule;
       procedure ClasifySymbols;
       function IsNeSymbol( ASymbol: PParserSymbol): Boolean;
       function IsTerminalSymbol( ASymbol: PParserSymbol): Boolean;
       function IsNonterminalSymbol( ASymbol: PParserSymbol): Boolean;
       procedure FindDeriveRules( ASymbol: PParserSymbol; var ARules: TCollection);
       procedure FindFirstsSet( AString: PCollection; var AFirstSet: TCollection);
       procedure FindFollowSet( ASymbol: PParserSymbol; var AFollowSet: TCollection);
       function AddSymbol( ATitle: string): PParserSymbol;
       function AddSymbolAsTerminal( ATitle: string): PParserSymbol;
       function GetSymbolByIndex( AIndex: Integer): PParserSymbol;
       function GetSymbolByTitle( ATitle: string): PParserSymbol;
       function GetTerminalByID( AIdentifier: Integer): PParserSymbol;
       function GetNonterminalByID( AIdentifier: Integer): PParserSymbol;

       procedure Display( AStream: PStream); virtual;
       procedure DisplaySymbolsClasification( AStream: PStream);
       function GetTerminalsCount: Word;
       function GetNonTerminalsCount: Word;
       end;

    PPointedItem = ^TPointedItem;
    TPointedItem = object(TGeneric)
    private
       Rule: PRule;
       Cursor: Integer;
    public
       constructor Create( ARule: PRule; ACursor: Integer);
       function GetRule: PRule;
       function GetCursor: Integer;
       function GetCursorSymbol: PParserSymbol;
       function GetPreCursorSymbol: PParserSymbol;
       function IsSameAs( AItem: PPointedItem): Boolean;
       procedure Display( AStream: PStream); virtual;
       end;


    PClosureKernelItem = ^TClosureKernelItem;
    TClosureKernelItem = object( TPointedItem)
    private
       LookaheadSet: TCollection;
    public
       constructor Create( ARule: PRule; ACursor: Integer; ALookaheadSet: PCollection);
       destructor Destroy; virtual;
       procedure AddLookaheadSymbol( ASymbol: PParserSymbol);
       function IsLookaheadSymbol( ASymbol: PParserSymbol): Boolean;
       function IsSameAs( AClosureKernelItem: PClosureKernelItem): Boolean;
       function IsComprise( AClosureKernelItem: PClosureKernelItem; ATestLookAheads: Boolean): Boolean;
       procedure MergeLookaheads( AClosureKernelItem: PClosureKernelItem);
       procedure Display( AStream: PStream); virtual;
       function GetFirstLookahead: PParserSymbol;
       function GetNextLookahead: PParserSymbol;
       function GetLookaheads: PCollection;
       end;

    PClosureKernel = ^TClosureKernel;
    TClosureKernel = object( TGeneric)
    private
       ShiftSymbol: PParserSymbol;
       Items: TContainerCollection;
    public
       constructor Create;
       destructor Destroy; virtual;
       function IsSameAs( AKernel: PClosureKernel): Boolean;
       function IsComprise( AKernel: PClosureKernel; ATestLookAheads: Boolean): Boolean;
       procedure AddItem( AItem: PClosureKernelItem);
       function GetFirstItem: PClosureKernelItem;
       function GetNextItem: PClosureKernelItem;
       procedure Display( AStream: PStream); virtual;
       end;

    PClosureItem = ^TClosureItem;
    PClosure = ^TClosure;
    TClosure = object( TGeneric)
    private
       Identifier: Word;
       Kernel: PClosureKernel;
       Items: TContainerCollection;
       Expanded: Boolean;
    public
       constructor Create( AGrammar: PGrammar; AKernel: PClosureKernel);
       destructor Destroy; virtual;
       procedure ExpandFromKernel( AGrammar: PGrammar);
       function IsExpanded: Boolean;
       function IsSameKernel( AKernel: PClosureKernel): Boolean;
       function IsComprise( AKernel: PClosureKernel; ATestLookAheads: Boolean): Boolean;
       function MergeKernels( AKernel: PClosureKernel; AGrammar: PGrammar): Boolean;
       procedure SetIdentifier( AIdentifier: Word);
       function GetIdentifier: Word;
       function CreateNewKernel( var AUsedItems: TCollection): PClosureKernel;
       procedure SetGoto( AItems: PCollection; AClosure: PClosure);
       procedure Display( AStream: PStream); virtual;
       function GetFirstItem: PClosureItem;
       function GetNextItem: PClosureItem;
       end;

    TClosureItem = object( TClosureKernelItem)
    private
       Marked: Boolean;
       GotoClosure: PClosure;
    public
       constructor Create( ARule: PRule; ACursor: Integer; ALookaheadSet: PCollection);
       constructor CreateFromKernelItem( AKernelItem: PClosureKernelItem);
       destructor Destroy; virtual;
       function IsMarked: Boolean;
       procedure Mark;
       procedure Unmark;
       procedure SetGotoClosure( AClosure: PClosure);
       function GetGotoClosure: PClosure;

       function IsReduceState: Boolean;
       function IsShiftState: Boolean;

       procedure Display( AStream: PStream); virtual;
       end;

    PConflict = ^TConflict;
    TConflict = object( TGeneric)
    private
       Closure: PClosure;
    public
       constructor Create( AClosure: PClosure);
       destructor Destroy; virtual;
       function GetClosure: PClosure;
       procedure Display( AStream: PStream); virtual;
       end;

    PClosuresSet = ^TClosuresSet;
    TClosuresSet = object( TGeneric)
    private
       Closures: TContainerCollection;
       Conflicts: TContainerCollection;
       procedure Build( AGrammar: PGrammar; ACanonical: Boolean);
    public
       constructor Create( AGrammar: PGrammar; ACanonical: Boolean);
       destructor Destroy; virtual;
       procedure Display( AStream: PStream); virtual;
       function GetFirstClosure: PClosure;
       function GetNextClosure: PClosure;
       function GetClosuresCount: Word;
       function GetFirstConflict: PConflict;
       function GetNextConflict: PConflict;
       end;

    PParseError = ^TParseError;
    TParseError = object( TGeneric)
       end;

    TAction = (actError, actShift, actReduce, actAccept);

    TActionInfo = record
       case Action: TAction
       of actError: ( ErrorCode: PParseError);
          actShift: ( NextState: PClosure);
          actReduce,
          actAccept: ( ReduceRule: PRule);
       end;

    PActionsCol = ^TActionsCol;
    TActionsCol = array[1..1] of TActionInfo;

    PActionsColHeader = ^TActionsColHeader;
    TActionsColHeader = record
       Terminal: PParserSymbol;
       Col: PActionsCol;
       end;

    PActionCols = ^TActionCols;
    TActionCols = array[1..1] of TActionsColHeader;

    TGotoInfo = record
       NextState: PClosure;
       end;

    PGotosCol = ^TGotosCol;
    TGotosCol = array[1..1] of TGotoInfo;

    PGotosColHeader = ^TGotosColHeader;
    TGotosColHeader = record
       NonTerminal: PParserSymbol;
       Col: PGotosCol;
       end;

    PGotoCols = ^TGotoCols;
    TGotoCols = array[1..1] of TGotosColHeader;

    PLRTable = ^TLRTable;
    TLRTable = object( TErrGeneric)
    private
       TerminalsCount: Word;
       NonTerminalsCount: Word;
       StatesCount: Word;
       Grammar: PGrammar;
       ActionCols: PActionCols;
       GotoCols: PGotoCols;
       ClosuresSet: PClosuresSet;
       procedure Clear;
       procedure AllocateTable( ATerminalsCount, ANonTerminalsCount, AStatesCount: Word);
    public
       constructor Create( AOwner: PErrGeneric);
       destructor Destroy; virtual;
       procedure Build( AGrammar: PGrammar; ACanonical: Boolean);
       procedure Display( AStream: PStream);
       end;

    PYaccDatabase = ^TYaccDatabase;

    POutputGenerator = ^TOutputGenerator;
    TOutputGenerator = object(TErrGeneric)
    private
       DataBase: PYaccDatabase;
       Skeleton: PStream;
       Target: PStream;
       function ScanToNextCommand( var AEndOfSkeleton: Boolean): string;
       procedure GenerateAbstractOutput;
       procedure GenerateFromSkeleton;
    public
       constructor Create( AOwner: PErrGeneric; ADataBase: PYaccDatabase; ASkeleton: PStream; ATarget: PStream);
       destructor Destroy; virtual;
       procedure GenerateOutput;
       end;

    TYaccDatabase = object( TErrGeneric)
    private
        Grammar: TGrammar;
        Table: TLRTable;
        Canonical: Boolean;
    public
        constructor Create( AOwner: PErrGeneric);
        destructor Destroy; virtual;
        function AddNonterminal( ATitle: string): PParserSymbol;
        function AddSymbol( ATitle: string): PParserSymbol;
        procedure SetStartSymbol( ASymbol: PParserSymbol);
        procedure AddRule( ARule: PRule);
        procedure Build;
        procedure Display( AStream: PStream); virtual;
        procedure Clear;
        procedure SetCanonical;
        procedure SetLALR;
        end;

implementation

{******************************************************************}
{*                                                                *}
{******************************************************************}

procedure DisplayString( AStream: PStream; AString: PCollection);
var Symbol: PParserSymbol;
begin
     if (AString <> nil)
     then begin
          Symbol := PParserSymbol(AString^.GetFirst);
          while (Symbol <> nil)
          do begin
             Symbol^.Display( AStream);
             AStream^.WriteStr( ' ');
             Symbol := PParserSymbol( AString^.GetNext);
             end;
          end;
end;


{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TParserSymbol.Create( AID: Word; ATitle: string);
begin
     inherited Create;
     Identifier := AID;
     Title := AllocateString( ATitle);
end;

destructor TParserSymbol.Destroy;
begin
     FreeString( Title);
     inherited Destroy;
end;

procedure TParserSymbol.SetID( AIndentifier: Word);
begin
     Identifier := AIndentifier;
end;

function TParserSymbol.GetID: Word;
begin
     GetID := Identifier;
end;

function TParserSymbol.GetTitle: string;
begin
     if ( Title <> nil)
     then GetTitle := Title^
     else GetTitle := '';
end;

procedure TParserSymbol.Display( AStream: PStream);
begin
     if ( AStream <> nil)
     then AStream^.WriteStr( GetTitle);
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TRuleSemantic.Create( var ABuffer; ASize: Word);
begin
     inherited Create;
     if (ASize > 0)
     then begin
          BufferSize := ASize;
          GetMem( Buffer, ASize);
          Move( ABuffer, Buffer^, ASize);
          end
     else begin
          BufferSize := 0;
          Buffer := nil;
          end;
end;

destructor TRuleSemantic.Destroy;
begin
     if ((BufferSize > 0) and (Buffer <> nil))
     then FreeMem( Buffer, BufferSize);
     inherited Destroy;
end;

function TRuleSemantic.GetSize: Word;
begin
     GetSize := BufferSize;
end;

function TRuleSemantic.GetBuffer: Pointer;
begin
     GetBuffer := Buffer;
end;

function TRuleSemantic.GetData( var ABuffer; ABufferSize: Word): Word;
var MoveSize: Word;
begin
     if (ABufferSize < BufferSize)
     then MoveSize := ABufferSize
     else MoveSize := BufferSize;

     if ((MoveSize > 0) and ( Buffer <> nil))
     then Move( Buffer^, ABuffer, MoveSize);

     GetData := MoveSize;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TRule.Create;
begin
     inherited Create;
     LeftSide := nil;
     RightSide.Create;
     Identifier := 0;
     Semantic := nil;
end;

procedure TRule.SetID( AIdentifier: Word);
begin
     Identifier := AIdentifier;
end;

function TRule.GetID: Word;
begin
     GetID := Identifier;
end;

destructor TRule.Destroy;
begin
     RightSide.Destroy;
     if (Semantic <> nil)
     then Semantic^.Free;
     inherited Destroy;
end;

procedure TRule.SetLeftSymbol( ASymbol: PParserSymbol);
begin
     LeftSide := ASymbol;
end;

procedure TRule.AppendRightSymbol( ASymbol: PParserSymbol);
begin
     if ( ASymbol <> nil)
     then RightSide.PushLast( ASymbol);
end;

function TRule.GetLeftSymbol: PParserSymbol;
begin
     GetLeftSymbol := LeftSide;
end;

function TRule.GetRightSymbol( AIndex: Integer): PParserSymbol;
begin
     GetRightSymbol := PParserSymbol( RightSide.GetByIndex( AIndex));
end;

function TRule.GetRightSideSize: Integer;
begin
     GetRightSideSize := RightSide.GetItemsCount;
end;

function TRule.GetFirstRightSymbol: PParserSymbol;
begin
     GetFirstRightSymbol := PParserSymbol( RightSide.GetFirst);
end;

function TRule.GetNextRightSymbol: PParserSymbol;
begin
     GetNextRightSymbol := PParserSymbol( RightSide.GetNext);
end;

procedure TRule.GetRightSideSymbols( AStartIndex: Integer; var ASymbols: TCollection);
var ScanSymbol: PParserSymbol;
begin
     ASymbols.Clear;
     if (GetRightSideSize >= AStartIndex)
     then begin
          ScanSymbol := PParserSymbol(RightSide.GetByIndex(AStartIndex));
          while (ScanSymbol <> nil)
          do begin
             ASymbols.PushLast( ScanSymbol);
             ScanSymbol := PParserSymbol(RightSide.GetNext);
             end;
          end;
end;

procedure TRule.Display( AStream: PStream);
var ScanSym: PParserSymbol;
begin
     if ( AStream = nil) then Exit;

     AStream^.WriteIntF( Identifier, 4);
     AStream^.WriteStr(') ');
     if (LeftSide <> nil)
     then AStream^.WriteStr( LeftSide^.GetTitle)
     else AStream^.WriteStr( ' ');

     AStream^.WriteStr( ' ->');
     ScanSym := GetFirstRightSymbol;
     while (ScanSym <> nil)
     do begin
        AStream^.WriteStr( ' ');
        AStream^.WriteStr( ScanSym^.GetTitle);
        ScanSym := GetNextRightSymbol;
        end;
end;

function TRule.GetRightSide: PCollection;
begin
     GetRightSide := @RightSide;
end;

procedure TRule.SetSemantic( ASemantic: PRuleSemantic);
begin
     if ( Semantic <> nil)
     then Semantic^.Free;
     Semantic := ASemantic;
end;

function TRule.GetSemantic: PRuleSemantic;
begin
     GetSemantic := Semantic;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TGrammar.Create( AOwner: PErrGeneric);
begin
     inherited Create( AOwner);
     Rules.Create;
     NeSet.Create;
     Terminals.Create;
     NonTerminals.Create;
     Symbols.Create;
     DefinedTerminals.Create;
     TerminateSymbol := New( PParserSymbol, Create(1,'EOF'));
     EmptySymbol := New( PParserSymbol, Create(2,'e'));
     StartSymbol := nil;

     Symbols.PushLast(TerminateSymbol);
     Symbols.PushLast(EmptySymbol);
end;

destructor TGrammar.Destroy;
begin
     DefinedTerminals.Destroy;
     Rules.Destroy;
     NeSet.Destroy;
     Terminals.Destroy;
     NonTerminals.Destroy;
     Symbols.Destroy;
     inherited Destroy;
end;

procedure TGrammar.ClearRules;
begin
     Rules.Clear;
end;

procedure TGrammar.Clear;
begin
     ClearRules;
     DefinedTerminals.Clear;
     Symbols.Clear;
     TerminateSymbol := New( PParserSymbol, Create(1,'EOF'));
     EmptySymbol := New( PParserSymbol, Create(2,'e'));
     Symbols.PushLast(TerminateSymbol);
     Symbols.PushLast(EmptySymbol);
     StartSymbol := nil;
end;


procedure TGrammar.SetStartSymbol( ASymbol: PParserSymbol);
begin
     StartSymbol := ASymbol;
end;

function TGrammar.GetTerminateSymbol: PParserSymbol;
begin
     GetTerminateSymbol := TerminateSymbol;
end;

function TGrammar.GetEmptySymbol: PParserSymbol;
begin
     GetEmptySymbol := EmptySymbol;
end;

function TGrammar.GetStartSymbol: PParserSymbol;
begin
     GetStartSymbol := StartSymbol;
end;

function TGrammar.GetStartRule: PRule;
var ScanRule: PRule;
begin
     ScanRule := nil;
     if (StartSymbol <> nil)
     then begin
          ScanRule := PRule(Rules.GetFirst);
          while (ScanRule <> nil)
          do begin
             if (ScanRule^.GetLeftSymbol = StartSymbol)
             then Break;
             ScanRule := PRule(Rules.GetNext);
             end;
          end;
     if (ScanRule <> nil)
     then GetStartRule := ScanRule
     else GetStartRule := PRule(Rules.GetFirst)
end;

procedure TGrammar.AppendRule( ARule: PRule);
begin
     if ( ARule <> nil)
     then begin
          ARule^.SetID(Rules.GetItemscount + 1);
          Rules.PushLast( ARule);
          end;
end;

function TGrammar.GetRule( AIndex: Integer): PRule;
begin
     GetRule := PRule( Rules.GetByIndex( AIndex));
end;

function TGrammar.GetRulesCount: Integer;
begin
     GetRulesCount := Rules.GetItemsCount;
end;

function TGrammar.GetFirstRule: PRule;
begin
     GetFirstRule := PRule( Rules.GetFirst);
end;

function TGrammar.GetNextRule: PRule;
begin
     GetNextRule := PRule( Rules.GetNext);
end;

function TGrammar.IsNeSymbol( ASymbol: PParserSymbol): Boolean;
begin
     IsNeSymbol := NeSet.IsMember( ASymbol);
end;

function TGrammar.IsTerminalSymbol( ASymbol: PParserSymbol): Boolean;
begin
     if (ASymbol <> nil)
     then begin
          if Terminals.IsMember(ASymbol)
          then IsTerminalSymbol := True
          else if (ASymbol = TerminateSymbol)
          then IsTerminalSymbol := True
          else if (ASymbol = EmptySymbol)
          then IsTerminalSymbol := True
          else IsTerminalSymbol := False;
          end
     else IsTerminalSymbol := False;
end;

function TGrammar.IsNonterminalSymbol( ASymbol: PParserSymbol): Boolean;
begin
     IsNonterminalSymbol := Nonterminals.IsMember(ASymbol);
end;

procedure TGrammar.FindNeSet;
var Symbol: PParserSymbol;
    Rule: PRule;
    N,I: Integer;
    Added: Boolean;
begin
     NeSet.Clear;
     repeat
           Added := False;
           Rule := PRule( Rules.GetFirst);
           while (Rule <> nil)
           do begin
              if not IsNeSymbol(Rule^.GetLeftSymbol)
              then begin
                   N := Rule^.GetRightSideSize;
                   if (N = 0)
                   then begin
                        NeSet.PushLast(Rule^.GetLeftSymbol);
                        Added := True;
                        end
                   else begin
                        I := 1;
                        while I <= N
                        do begin
                           Symbol := Rule^.GetRightSymbol(I);
                           if not IsNeSymbol(Symbol)
                           then break;
                           I := I + 1;
                           end;
                        if I > N
                        then begin
                             NeSet.PushLast(Rule^.GetLeftSymbol);
                             Added := True;
                             end;
                        end;
                   end;
              Rule := PRule( Rules.GetNext);
              end;
     until (Added = False);
end;

procedure TGrammar.FindTerminalAndNonterimanls;
var ScanRule: PRule;
    TempSymbol, Symbol: PParserSymbol;
    Id: Integer;
    BadDefine: Boolean;
begin
     Terminals.Clear;
     NonTerminals.Clear;
     ScanRule := PRule( Rules.GetFirst);
     BadDefine := False;
     Id := 1;
     while (ScanRule <> nil)
     do begin
        Symbol := ScanRule^.GetLeftSymbol;
        if (Symbol <> nil)
        then if not IsNonterminalSymbol( Symbol)
             then begin
                  if DefinedTerminals.IsMember( Symbol)
                  then begin
                       BadDefine := True;
                       AddError( New( PMessageError, Create('GRAMMAR ERROR: Symbol defined as terminal ~'
                                 +  Symbol^.GetTitle + '~.')));
                       DefinedTerminals.RemoveFromCollection( Symbol);
                       end;
                  Symbol^.SetID( Id);
                  Id := Id + 1;
                  NonTerminals.PushLast(Symbol);
                  end;
        ScanRule := PRule( Rules.GetNext);
        end;

     Id := 1;
     ScanRule := PRule( Rules.GetFirst);
     while (ScanRule <> nil)
     do begin
        Symbol := ScanRule^.GetFirstRightSymbol;
        while (Symbol <> nil)
        do begin
           if not IsNonterminalSymbol(Symbol)
           then if not IsTerminalSymbol(Symbol)
                then begin
                     if not DefinedTerminals.IsMember( Symbol)
                     then begin
                          BadDefine := True;
                          AddError( New( PMessageError, Create('GRAMMAR ERROR: Not defined terminal ~'
                                 +  Symbol^.GetTitle + '~.')));
                          DefinedTerminals.PushLast( Symbol);
                          end;
                     Symbol^.SetID( Id);
                     Id := Id + 1;
                     Terminals.PushLast(Symbol);
                     end;
           Symbol := ScanRule^.GetNextRightSymbol;
           end;
        ScanRule := PRule( Rules.GetNext);
        end;

     if (TerminateSymbol <> nil)
     then begin
          TerminateSymbol^.SetID( Terminals.GetItemsCount + 1);
          Terminals.PushLast( TerminateSymbol);
          DefinedTerminals.PushLast( TerminateSymbol);
          end;

     Symbol := PParserSymbol( DefinedTerminals.GetFirst);
     while ( Symbol <> nil)
     do begin
        if not Terminals.IsMember( Symbol)
        then begin
             TempSymbol := Symbol;
             Symbol := PParserSymbol( DefinedTerminals.GetNext);
             AddError( New( PMessageError, Create('GRAMMAR ERROR: Defined and not used terminal ~'
                       +  TempSymbol^.GetTitle + '~.')));
             DefinedTerminals.RemoveFromCollection( TempSymbol);
             end
        else Symbol := PParserSymbol( DefinedTerminals.GetAfter( Symbol));
        end;

     Id := 0;
     Symbol := PParserSymbol( DefinedTerminals.GetFirst);
     while ( Symbol <> nil)
     do begin
        Id := Id + 1;
        Symbol^.SetID( Id);
        Symbol := PParserSymbol( DefinedTerminals.GetNext);
        end;
     {if (EmptySymbol <> nil)
     then Terminals.PushLast(EmptySymbol);}
end;

function TGrammar.GetTerminalsCount: Word;
begin
     GetTerminalsCount := Terminals.GetItemsCount;
end;

function TGrammar.GetNonTerminalsCount: Word;
begin
     GetNonTerminalsCount := NonTerminals.GetItemsCount;;
end;

procedure TGrammar.ClasifySymbols;
begin
     FindNeSet;
     FindTerminalAndNonterimanls;
end;

procedure TGrammar.FindDeriveRules( ASymbol: PParserSymbol; var ARules: TCollection);
var ScanRule: PRule;
begin
     ARules.Clear;
     if (ASymbol <> nil)
     then begin
          ScanRule := PRule( Rules.GetFirst);
          while (ScanRule <> nil)
          do begin
             if (ASymbol = ScanRule^.GetLeftSymbol)
             then ARules.PushLast(ScanRule);
             ScanRule := PRule( Rules.GetNext);
             end;
          end;
end;

procedure TGrammar.FindFirstsSet( AString: PCollection; var AFirstSet: TCollection);
    procedure FindFirst( AString: PCollection; AProcessedRules: PCollection);
    var TempString: TCollection;
        DeriveRules: TCollection;
        FirstSymbol: PParserSymbol;
        ProcessedRules: TCollection;
        ScanRule: PRule;
    begin
         if (AString <> nil)
         then begin
              FirstSymbol := PParserSymbol(AString^.GetFirst);
              if (FirstSymbol <> nil)
              then begin
                   if IsTerminalSymbol(FirstSymbol)
                   then begin
                        if (not AFirstSet.IsMember( FirstSymbol))
                        then AFirstSet.PushLast( FirstSymbol);
                        end
                   else begin
                        ProcessedRules.Create;
                        if (AProcessedRules <> nil)
                        then ProcessedRules.PushCollectionFirst( AProcessedRules);
                        if (IsNonterminalSymbol( FirstSymbol))
                        then begin
                             TempString.Create;
                             DeriveRules.Create;
                             FindDeriveRules( FirstSymbol, DeriveRules);
                             ScanRule := PRule(DeriveRules.GetFirst);
                             while (ScanRule <> nil)
                             do begin
                                if not ProcessedRules.IsMember(ScanRule)
                                then begin
                                     ProcessedRules.PushLast(ScanRule);
                                     TempString.Clear;
                                     TempString.PushCollectionFirst(AString);
                                     TempString.PopFirst;
                                     TempString.PushCollectionFirst(ScanRule^.GetRightSide);
                                     FindFirst(@TempString, @ProcessedRules);
                                     end;
                                ScanRule := PRule(DeriveRules.GetNext);
                                end;
                             DeriveRules.Destroy;
                             TempString.Destroy;
                             end;
                        ProcessedRules.Destroy;
                        end;
                   end
              else begin
                   if (EmptySymbol <> nil)
                   then begin
                        if not AFirstSet.IsMember( FirstSymbol)
                        then AFirstSet.PushLast( EmptySymbol);
                        end;
                   end;
              end;
    end;
begin
     AFirstSet.Clear;
     FindFirst( AString, nil);
end;

procedure TGrammar.FindFollowSet( ASymbol: PParserSymbol; var AFollowSet: TCollection);
var SymbolsToFindFollow: TCollection;
    ProcessedSymbol: TCollection;
    Positions: TContainerCollection;

    function PositionExists( ARule: PRule; APos: Integer): Boolean;
    var ScanPointedItem: PPointedItem;
    begin
         PositionExists := False;
         if (ARule <> nil)
         then begin
              ScanPointedItem := PPointedItem( Positions.GetFirst);
              while (ScanPointedItem <> nil)
              do begin
                 if ((ARule = ScanPointedItem^.GetRule) and (APos = ScanPointedItem^.GetCursor))
                 then begin
                      PositionExists := True;
                      Break;
                      end;
                 ScanPointedItem := PPointedItem( Positions.GetNext);
                 end;
              end;
    end;

    procedure AddNewPosition( ARule: PRule; APos: Integer);
    var PointedItem: PPointedItem;
    begin
         if (ARule <> nil)
         then begin
              if not PositionExists(ARule, APos)
              then begin
                   PointedItem := New(PPointedItem, Create(ARule, APos));
                   Positions.PushLast(PointedItem);
                   end;
              end;
    end;

    procedure FindPositions;
    var CurrentSymbol: PParserSymbol;
        SymbolToProcess: PParserSymbol;
        RightSymbol: PParserSymbol;
        ScanRule: PRule;
        I,N: Integer;
        LastSymbolWas: Boolean;
    begin
         CurrentSymbol := PParserSymbol( SymbolsToFindFollow.PopFirst);
         while (CurrentSymbol <> nil)
         do begin
            ProcessedSymbol.PushLast( CurrentSymbol);
            if (CurrentSymbol <> GetStartSymbol)
            then begin
                 ScanRule := PRule(Rules.GetFirst);
                 while (ScanRule <> nil)
                 do begin
                    N := ScanRule^.GetRightSideSize;
                    if N >= 1
                    then begin
                         I := 1;
                         LastSymbolWas := False;
                         while I < N
                         do begin
                            RightSymbol := ScanRule^.GetRightSymbol(I);
                            if (RightSymbol <> nil)
                            then begin
                                 if (CurrentSymbol = RightSymbol)
                                 then begin
                                      AddNewPosition(ScanRule, I + 1);
                                      LastSymbolWas := True;
                                      end
                                 else begin
                                      if (LastSymbolWas and (not NeSet.IsMember(RightSymbol)))
                                      then LastSymbolWas := False;
                                      end;
                                 end;
                            I := I + 1;
                            end;
                         RightSymbol := ScanRule^.GetRightSymbol(I);
                         if (RightSymbol <> nil)
                         then begin
                              if (CurrentSymbol = RightSymbol) or
                                 (LastSymbolWas and ( NeSet.IsMember(RightSymbol)))
                              then begin
                                   SymbolToProcess := ScanRule^.GetLeftSymbol;
                                   if (SymbolToProcess <> nil)
                                   then if (not (SymbolsToFindFollow.Ismember( SymbolToProcess))
                                           or ProcessedSymbol.IsMember(SymbolToProcess))
                                        then SymbolsToFindFollow.PushLast(SymbolToProcess);
                                   end;
                              end;
                         end;
                    ScanRule := PRule(Rules.GetNext);
                    end;
                 end
            else begin
                 if (GetTerminateSymbol <> nil)
                 then if (not AFollowSet.IsMember(GetTerminateSymbol))
                      then AFollowSet.PushLast(GetTerminateSymbol);
                 end;
            CurrentSymbol := PParserSymbol( SymbolsToFindFollow.PopFirst);
            end;
    end;

    procedure FindFollows;
    var ScanPointedItem: PPointedItem;
        procedure Process( ARule: PRule; APos: Integer);
        var Str: TCollection;
            Symbols: TCollection;
            I, N: Integer;
            ScanSymbol: PParserSymbol;
        begin
             if (ARule <> nil)
             then begin
                  N := ARule^.GetRightSideSize;
                  if APos <= N
                  then begin
                       Str.Create;
                       Symbols.Create;
                       for I := APos to N
                       do Str.PushLast(ARule^.GetRightSymbol(I));
                       if (GetStartSymbol = ARule^.GetLeftSymbol)
                       then Str.PushLast(GetTerminateSymbol);
                       FindFirstsSet( @Str, Symbols);
                       ScanSymbol := PParserSymbol(Symbols.GetFirst);
                       while (ScanSymbol <> nil)
                       do begin
                          if not AFollowSet.IsMember(ScanSymbol)
                          then AFollowSet.Pushlast(ScanSymbol);
                          ScanSymbol := PParserSymbol(Symbols.GetNext);
                          end;
                       Symbols.Destroy;
                       Str.Destroy;
                       end;
                  end;
        end;
    begin
         ScanPointedItem := PPointedItem( Positions.GetFirst);
         while (ScanPointedItem <> nil)
         do begin
            Process( ScanPointedItem^.GetRule, ScanPointedItem^.GetCursor);
            ScanPointedItem := PPointedItem( Positions.GetNext);
            end;
    end;
begin
     AFollowSet.Clear;
     if (ASymbol <> nil)
     then begin
          if IsNonterminalSymbol(ASymbol)
          then begin
               SymbolsToFindFollow.Create;
               ProcessedSymbol.Create;
               Positions.Create;
               SymbolsToFindFollow.PushLast(ASymbol);
               FindPositions;
               FindFollows;
               SymbolsToFindFollow.Destroy;
               ProcessedSymbol.Destroy;
               Positions.Destroy;
               end;
          end;
end;

procedure TGrammar.Display( AStream: PStream);
var Rule: PRule;
begin
     if ( AStream = nil) then Exit;

     Rule := GetFirstRule;
     while (Rule <> nil)
     do begin
        Rule^.Display( AStream);
        AStream^.NewLine;
        Rule := GetNextRule;
        end;
end;

function TGrammar.AddSymbol( ATitle: string): PParserSymbol;
var NewId: Integer;
    NewSymbol: PParserSymbol;
begin
     if (ATitle <> '')
     then begin
          NewSymbol := GetSymbolByTitle( ATitle);
          if (NewSymbol = nil)
          then begin
               NewId := Symbols.GetItemscount + 1;
               NewSymbol := New(PParserSymbol, Create( NewId, ATitle));
               Symbols.PushLast( NewSymbol);
               end;
          AddSymbol := NewSymbol;
          end
     else AddSymbol := nil;
end;

function TGrammar.AddSymbolAsTerminal( ATitle: string): PParserSymbol;
var NewId: Integer;
    NewSymbol: PParserSymbol;
begin
     if (ATitle <> '')
     then begin
          NewSymbol := GetSymbolByTitle( ATitle);
          if ( NewSymbol = nil)
          then begin
               NewId := Symbols.GetItemscount + 1;
               NewSymbol := New(PParserSymbol, Create( NewId, ATitle));
               Symbols.PushLast( NewSymbol);
               DefinedTerminals.PushLast( NewSymbol);
               end;
          AddSymbolAsTerminal := NewSymbol;
          end
     else AddSymbolAsTerminal := nil;
end;

function TGrammar.GetSymbolByIndex( AIndex: Integer): PParserSymbol;
begin
     GetSymbolByIndex := PParserSymbol(Symbols.GetByIndex(AIndex));
end;

function TGrammar.GetSymbolByTitle( ATitle: string): PParserSymbol;
var ScanSymbol: PParserSymbol;
begin
     ScanSymbol := PParserSymbol(Symbols.GetFirst);
     while (ScanSymbol <> nil)
     do if (ScanSymbol^.GetTitle <> ATitle)
        then ScanSymbol := PParserSymbol(Symbols.GetNext)
        else Break;
     GetSymbolByTitle := ScanSymbol;
end;

function TGrammar.GetTerminalByID( AIdentifier: Integer): PParserSymbol;
var ScanSymbol: PParserSymbol;
begin
     ScanSymbol := PParserSymbol(Terminals.GetFirst);
     while (ScanSymbol <> nil)
     do if (ScanSymbol^.GetID <> AIdentifier)
        then ScanSymbol := PParserSymbol(Terminals.GetNext)
        else Break;

     GetTerminalByID := ScanSymbol;
end;

function TGrammar.GetNonterminalByID( AIdentifier: Integer): PParserSymbol;
var ScanSymbol: PParserSymbol;
begin
     ScanSymbol := PParserSymbol(Nonterminals.GetFirst);
     while (ScanSymbol <> nil)
     do if (ScanSymbol^.GetID <> AIdentifier)
        then ScanSymbol := PParserSymbol(Nonterminals.GetNext)
        else Break;

     GetNonterminalByID := ScanSymbol;
end;

procedure TGrammar.DisplaySymbolsClasification;
var Symbol: PParserSymbol;
begin
     AStream^.WriteStr( 'Ne Set = ');
     Symbol := PParserSymbol(NeSet.GetFirst);
     while (Symbol <> nil)
     do begin
        AStream^.WriteStr( Symbol^.GetTitle);
        AStream^.WriteStr( '  ');
        Symbol := PParserSymbol(NeSet.GetNext);
        end;
     AStream^.NewLine;

     AStream^.WriteStr( 'Terminals = ');
     Symbol := PParserSymbol(Terminals.GetFirst);
     while (Symbol <> nil)
     do begin
        AStream^.WriteStr( Symbol^.GetTitle);
        AStream^.WriteStr( '  ');
        Symbol := PParserSymbol(Terminals.GetNext);
        end;
     AStream^.NewLine;

     AStream^.WriteStr( 'Nonterminals = ');
     Symbol := PParserSymbol(Nonterminals.GetFirst);
     while (Symbol <> nil)
     do begin
        AStream^.WriteStr( Symbol^.GetTitle);
        AStream^.WriteStr( '  ');
        Symbol := PParserSymbol(Nonterminals.GetNext);
        end;
     AStream^.NewLine;

     AStream^.WriteStr( 'Terminate symbol = ');
     if (Terminatesymbol <> nil)
     then AStream^.WriteStr( Terminatesymbol^.GetTitle);
     AStream^.NewLine;

     AStream^.WriteStr( 'Empty symbol = ');
     if (EmptySymbol <> nil)
     then AStream^.WriteStr( EmptySymbol^.GetTitle);
     AStream^.NewLine;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TPointedItem.Create( ARule: PRule; ACursor: Integer);
begin
     inherited Create;
     Rule := ARule;
     Cursor := ACursor;
end;

function TPointedItem.GetRule: PRule;
begin
     GetRule := Rule;
end;

function TPointedItem.GetCursor: Integer;
begin
     GetCursor := Cursor;
end;

function TPointedItem.GetCursorSymbol: PParserSymbol;
begin
     if Rule <> nil
     then GetCursorSymbol := Rule^.GetRightSymbol( Cursor)
     else GetCursorSymbol := nil;
end;

function TPointedItem.GetPreCursorSymbol: PParserSymbol;
begin
     if Rule <> nil
     then begin
          if (Cursor > 0)
          then GetPreCursorSymbol := Rule^.GetRightSymbol( Cursor - 1)
          else GetPreCursorSymbol := nil;
          end
     else GetPreCursorSymbol := nil;
end;

function TPointedItem.IsSameAs( AItem: PPointedItem): Boolean;
begin
     if (AItem <> nil)
     then IsSameAs := (( Cursor = AItem^.Cursor) and ( Rule = AItem^.Rule))
     else IsSameAs := False;
end;

procedure TPointedItem.Display( AStream: PStream);
var ScanSym: PParserSymbol;
    I,N: Integer;
begin
     if ( AStream = nil) then Exit;

     if (Rule <> nil)
     then begin
          ScanSym := Rule^.GetLeftSymbol;
          if (ScanSym <> nil)
          then AStream^.WriteStr( ScanSym^.GetTitle)
          else AStream^.WriteStr( ' ');

          AStream^.WriteStr( ' ->');
          ScanSym := Rule^.GetFirstRightSymbol;
          N := Cursor;
          I := 1;
          while (ScanSym <> nil)
          do begin
             if (N = I)
             then AStream^.WriteStr( '.')
             else AStream^.WriteStr( ' ');
             AStream^.WriteStr( ScanSym^.GetTitle);
             ScanSym := Rule^.GetNextRightSymbol;
             I := I + 1;
             end;
          if (N = I)
          then AStream^.WriteStr( '.');
          end;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TClosureKernelItem.Create( ARule: PRule; ACursor: Integer; ALookaheadSet: PCollection);
begin
     inherited Create( ARule, ACursor);
     LookaheadSet.Create;
     if (ALookaheadSet <> nil)
     then LookaheadSet.PushCollectionLast( ALookaheadSet);
end;

destructor TClosureKernelItem.Destroy;
begin
     LookaheadSet.Destroy;
     Inherited Destroy;
end;

procedure TClosureKernelItem.AddLookaheadSymbol( ASymbol: PParserSymbol);
begin
     if (ASymbol <> nil)
     then begin
          if not LookaheadSet.IsMember( ASymbol)
          then LookaheadSet.Pushlast( ASymbol);
          end;
end;

function TClosureKernelItem.IsLookaheadSymbol( ASymbol: PParserSymbol): Boolean;
begin
     if (ASymbol <> nil)
     then IsLookaheadSymbol := LookaheadSet.IsMember( ASymbol)
     else IsLookaheadSymbol := False;
end;

function TClosureKernelItem.IsSameAs( AClosureKernelItem: PClosureKernelItem): Boolean;
begin
     if (AClosureKernelItem <> nil)
     then begin
          if inherited IsSameAs( AClosureKernelItem)
          then IsSameAs := LookaheadSet.IsSameAs( @AClosureKernelItem^.LookaheadSet)
          else IsSameAs := False;
          end
     else IsSameAs := False;
end;

function TClosureKernelItem.IsComprise( AClosureKernelItem: PClosureKernelItem; ATestLookAheads: Boolean): Boolean;
begin
     if (AClosureKernelItem <> nil)
     then begin
          if inherited IsSameAs( AClosureKernelItem)
          then begin
               if ATestLookAheads
               then IsComprise := LookaheadSet.IsComprise( @AClosureKernelItem^.LookaheadSet)
               else IsComprise := True;
               end
          else IsComprise := False;
          end
     else IsComprise := False;
end;

procedure TClosureKernelItem.MergeLookaheads( AClosureKernelItem: PClosureKernelItem);
begin
     if ( AClosureKernelItem <> nil)
     then LookaheadSet.MergeWith( @AClosureKernelItem^.LookaheadSet);
end;

function TClosureKernelItem.GetFirstLookahead: PParserSymbol;
begin
     GetFirstLookahead := PParserSymbol(LookaheadSet.GetFirst);
end;

function TClosureKernelItem.GetNextLookahead: PParserSymbol;
begin
     GetNextLookahead := PParserSymbol(LookaheadSet.GetNext);
end;

function TClosureKernelItem.GetLookaheads: PCollection;
begin
     GetLookaheads := @LookaheadSet;
end;

procedure TClosureKernelItem.Display( AStream: PStream);
begin
     if ( AStream = nil) then Exit;

     inherited Display( AStream);
     AStream^.WriteStr( '  [ ');
     DisplayString( AStream, @LookaheadSet);
     AStream^.WriteStr( ']');
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TClosureKernel.Create;
begin
     inherited Create;
     Items.Create;
     ShiftSymbol := nil;
end;

destructor TClosureKernel.Destroy;
begin
     Items.Destroy;
     ShiftSymbol := nil;
     inherited Destroy;
end;

function TClosureKernel.IsSameAs( AKernel: PClosureKernel): Boolean;
var Scan1, Scan2: PClosureKernelItem;
    Found: Boolean;
begin
     IsSameAs := False;
     if ( AKernel <> nil)
     then begin
          if ( ShiftSymbol = AKernel^.ShiftSymbol)
          then begin
               if (AKernel^.Items.GetItemsCount = Items.GetItemsCount)
               then begin
                    Found := True;
                    Scan1 := PClosureKernelItem(AKernel^.Items.GetFirst);
                    while (Scan1 <> nil)
                    do begin
                       Found := False;
                       Scan2 := PClosureKernelItem(Items.GetFirst);
                       while (Scan2 <> nil)
                       do begin
                          if (Scan2^.IsSameAs( Scan1))
                          then begin
                               Found := True;
                               Scan2 := nil;
                               end
                          else Scan2 := PClosureKernelItem(Items.GetNext);
                          end;
                       if Found
                       then Scan1 := PClosureKernelItem(AKernel^.Items.GetNext)
                       else Scan1 := nil;
                       end;
                    IsSameAs := Found;
                    end;
               end;
          end;
end;

function TClosureKernel.IsComprise( AKernel: PClosureKernel; ATestLookAheads: Boolean): Boolean;
var Scan1, Scan2: PClosureKernelItem;
    Found: Boolean;
begin
     IsComprise := False;
     if (AKernel <> nil)
     then begin
          if ( ShiftSymbol = AKernel^.ShiftSymbol)
          then begin
               if (AKernel^.Items.GetItemsCount = Items.GetItemsCount)
               then begin
                    Found := True;
                    Scan1 := PClosureKernelItem(AKernel^.Items.GetFirst);
                    while (Scan1 <> nil)
                    do begin
                       Found := False;
                       Scan2 := PClosureKernelItem(Items.GetFirst);
                       while (Scan2 <> nil)
                       do begin
                          if (Scan2^.IsComprise( Scan1, ATestLookAheads))
                          then begin
                               Found := True;
                               Scan2 := nil;
                               end
                          else Scan2 := PClosureKernelItem(Items.GetNext);
                          end;
                       if Found
                       then Scan1 := PClosureKernelItem(AKernel^.Items.GetNext)
                       else Scan1 := nil;
                       end;
                    IsComprise := Found;
                    end;
               end;
          end;
end;

procedure TClosureKernel.AddItem( AItem: PClosureKernelItem);
begin
     if (AItem <> nil)
     then begin
          Items.PushLast( AItem);
          ShiftSymbol := AItem^.GetPreCursorSymbol;
          end;
end;

function TClosureKernel.GetFirstItem: PClosureKernelItem;
begin
     GetFirstItem := PClosureKernelItem(Items.GetFirst);
end;

function TClosureKernel.GetNextItem: PClosureKernelItem;
begin
     GetNextItem := PClosureKernelItem(Items.GetNext);
end;

procedure TClosureKernel.Display( AStream: PStream);
var ScanItem: PClosureKernelItem;
begin
     if ( AStream = nil) then Exit;

     ScanItem := GetFirstItem;
     while (ScanItem <> nil)
     do begin
        ScanItem^.Display( AStream);
        AStream^.NewLine;
        ScanItem := GetNextItem;
        end;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TClosure.Create( AGrammar: PGrammar; AKernel: PClosureKernel);
begin
     inherited Create;
     Expanded := False;
     Identifier := 0;
     Kernel := AKernel;
     Items.Create;
end;

destructor TClosure.Destroy;
begin
     if (Kernel <> nil)
     then Kernel^.Free;
     Items.Destroy;
     inherited Destroy;
end;

procedure TClosure.ExpandFromKernel( AGrammar: PGrammar);
   procedure FindNewLookaheads( AClosureItem: PClosureItem; var Lookaheads: TCollection);
   var Rule: PRule;
       TempStr: TCollection;
       RightSideSize: Integer;
       StartPos: Integer;
       Symbol: PParserSymbol;
       FirstSet: TCollection;
       procedure AddNonexcistingSymbols( ASymbols: PCollection);
       var ScanSymbol: PParserSymbol;
       begin
            if (ASymbols <> nil)
            then begin
                 ScanSymbol := PParserSymbol(ASymbols^.GetFirst);
                 while (ScanSymbol <> nil)
                 do begin
                    if not Lookaheads.IsMember( ScanSymbol)
                    then Lookaheads.PushLast( ScanSymbol);
                    ScanSymbol := PParserSymbol(ASymbols^.GetNext);
                    end;
                 end;
       end;
   begin
        Lookaheads.Clear;
        if (AClosureItem <> nil)
        then begin
             Rule := AClosureItem^.GetRule;
             if (Rule <> nil)
             then begin
                  RightSideSize := Rule^.GetRightSideSize;
                  StartPos := AClosureItem^.GetCursor + 1;
                  if (StartPos <= RightSideSize)
                  then begin
                       TempStr.Create;
                       FirstSet.Create;
                       Rule^.GetRightSideSymbols( StartPos, TempStr);
                       AGrammar^.FindFirstsSet( @TempStr, FirstSet);
                       Symbol := AGrammar^.GetEmptySymbol;
                       if (Symbol <> nil)
                       then if FirstSet.IsMember(Symbol)
                            then begin
                                 FirstSet.RemoveFromCollection( Symbol);
                                 AddNonexcistingSymbols( AClosureItem^.GetLookaheads);
                                 end;
                       AddNonexcistingSymbols( @FirstSet);
                       FirstSet.Destroy;
                       TempStr.Destroy;
                       end
                  else AddNonexcistingSymbols( AClosureItem^.GetLookaheads);
                  end;
             end;
   end;

   procedure AppendNewItem( ARule: PRule; ACursor: Integer; var ALookaheadSet: TCollection);
   var ScanItem: PClosureItem;
       FoundSame: Boolean;
       NewItem: PClosureitem;
       ScanItemsLookaheads: PCollection;
   begin
        if (ARule <> nil)
        then begin
             if (( ACursor > 0))
             then begin
                  FoundSame := False;
                  ScanItem := PClosureItem(Items.GetFirst);
                  while (ScanItem <> nil)
                  do begin
                     if ((ARule = ScanItem^.GetRule)
                        and (ACursor = ScanItem^.GetCursor))
                     then begin
                          ScanItemsLookaheads := ScanItem^.GetLookaheads;
                          if (ScanItemsLookaheads <> nil)
                          then ScanItemsLookaheads^.MergeWith( @ALookaheadSet);
                          FoundSame := True;
                          ScanItem := nil;
                          end
                     else ScanItem := PClosureItem(Items.GetNext);
                     end;
                  if not FoundSame
                  then begin
                       NewItem := New( PClosureItem, Create(ARule, ACursor, @ALookaheadSet));
                       NewItem^.Unmark;
                       Items.PushLast( NewItem);
                       end;
                  end
             end;
   end;
var Item: PClosureItem;
    ScanKernelItem: PClosureKernelItem;

    CursorSymbol: PParserSymbol;

    NewLookaheadSet: TCollection;
    NewItemRule: PRule;
    NewItemCursor: Integer;

    DeriveRules: TCollection;
begin
     Expanded := True;
     Items.Clear;
     if ((Kernel <> nil) and (AGrammar <> nil))
     then begin
          ScanKernelItem := Kernel^.GetFirstItem;
          while (ScanKernelItem <> nil)
          do begin
             Item := New( PClosureItem, CreateFromKernelItem(ScanKernelItem));
             Item^.Unmark;
             Items.PushLast( Item);
             ScanKernelItem := Kernel^.GetNextItem;
             end;

          DeriveRules.Create;
          NewLookaheadSet.Create;
          Item := PClosureItem(Items.GetFirst);
          while (Item <> nil)
          do begin
             FindNewLookaheads( Item, NewLookaheadSet);
             CursorSymbol := Item^.GetCursorSymbol;
             if (CursorSymbol <> nil)
             then begin
                  AGrammar^.FindDeriveRules( CursorSymbol, DeriveRules);
                  NewItemRule := PRule(DeriveRules.GetFirst);
                  NewItemCursor := 1;
                  while (NewItemRule <> nil)
                  do begin
                     AppendNewItem( NewItemRule, 1, NewLookaheadSet);
                     NewItemRule := PRule(DeriveRules.GetNext);
                     end;
                  end;
             Item := PClosureItem(Items.GetAfter( Item));
             end;
          NewLookaheadSet.Destroy;
          DeriveRules.Destroy;
          end;
end;

function TClosure.IsExpanded: Boolean;
begin
     IsExpanded := Expanded;
end;

function TClosure.IsSameKernel( AKernel: PClosureKernel): Boolean;
begin
     if ((AKernel <> nil) and (Kernel <> nil))
     then IsSameKernel := Kernel^.IsSameAs( AKernel)
     else IsSameKernel := False;
end;

function TClosure.IsComprise( AKernel: PClosureKernel; ATestLookAheads: Boolean): Boolean;
begin
     if ((AKernel <> nil) and (Kernel <> nil))
     then IsComprise := Kernel^.IsComprise( AKernel, ATestLookAheads)
     else IsComprise := False;
end;

function TClosure.MergeKernels( AKernel: PClosureKernel; AGrammar: PGrammar): Boolean;
var ScanKernelItem1, ScanKernelItem2: PClosureKernelItem;
    ChangeOcured: Boolean;
begin
     ChangeOcured := False;
     if ((AKernel <> nil) and (Kernel <> nil))
     then begin
          ScanKernelItem1 := AKernel^.GetFirstItem;
          while ( ScanKernelItem1 <> nil)
          do begin
             ScanKernelItem2 := Kernel^.GetFirstItem;
             while ( ScanKernelItem2 <> nil)
             do begin
                if ScanKernelItem2^.IsComprise( ScanKernelItem1, False)
                then begin
                     if not ScanKernelItem2^.IsComprise( ScanKernelItem1, True)
                     then begin
                          ChangeOcured := True;
                          ScanKernelItem2^.MergeLookaheads( ScanKernelItem1);
                          end;
                     ScanKernelItem2 := nil;
                     end
                else ScanKernelItem2 := Kernel^.GetNextItem;
                end;
             ScanKernelItem1 := AKernel^.GetNextItem;
             end;

          if ChangeOcured
          then begin
               Items.Clear;
               Expanded := False;
               end;
          end;
     MergeKernels := ChangeOcured;
end;

procedure TClosure.SetIdentifier( AIdentifier: Word);
begin
     Identifier := AIdentifier;
end;

function TClosure.GetIdentifier: Word;
begin
     GetIdentifier := Identifier;
end;

function TClosure.CreateNewKernel( var AUsedItems: TCollection): PClosureKernel;
var ScanItem: PClosureItem;
    Symbol: PParserSymbol;
    NewKernel: PClosureKernel;
    KenelItem: PClosureKernelItem;
begin
     AUsedItems.Clear;
     CreateNewKernel := nil;
     Symbol := nil;
     ScanItem := PClosureItem(Items.GetFirst);
     while (ScanItem <> nil)
     do begin
        if not ScanItem^.IsMarked
        then Symbol := ScanItem^.GetCursorSymbol;
        if (Symbol = nil)
        then ScanItem := PClosureItem(Items.GetNext)
        else begin
             AUsedItems.PushLast(ScanItem);
             ScanItem := nil;
             end;
        end;
     if (Symbol <> nil)
     then begin
          ScanItem := PClosureItem(Items.GetNext);
          while (ScanItem <> nil)
          do begin
             if (Symbol = ScanItem^.GetCursorSymbol)
             then AUsedItems.PushLast(ScanItem);
             ScanItem := PClosureItem(Items.GetNext);
             end;
          NewKernel := New( PClosureKernel, Create);
          ScanItem := PClosureItem(AUsedItems.GetFirst);
          while (ScanItem <> nil)
          do begin
             KenelItem := New(PClosureKernelItem, Create(ScanItem^.GetRule, ScanItem^.GetCursor + 1, ScanItem^.GetLookaheads));
             NewKernel^.AddItem( KenelItem);
             ScanItem := PClosureItem(AUsedItems.GetNext);
             end;
          CreateNewKernel := NewKernel;
          end;
end;

procedure TClosure.SetGoto( AItems: PCollection; AClosure: PClosure);
var ScanItem: PClosureItem;
begin
     if (( AItems <> nil) and ( AClosure <> nil))
     then begin
          ScanItem := PClosureItem(AItems^.GetFirst);
          while (ScanItem <> nil)
          do begin
             ScanItem^.SetGotoClosure( AClosure);
             ScanItem^.Mark;
             ScanItem := PClosureItem(AItems^.GetNext);
             end;
          end;
end;

procedure TClosure.Display( AStream: PStream);
var ScanItem: PClosureItem;
begin
     if ( AStream = nil) then Exit;

     AStream^.WriteStr( 'CLOSURE [');
     AStream^.WriteInt( GetIdentifier);
     AStream^.WriteStr( ']');
     AStream^.NewLine;
     if (Kernel <> nil)
     then begin
          AStream^.WriteStr( 'THE KERNEL:');
          AStream^.NewLine;
          Kernel^.Display( AStream)
          end
     else begin
          AStream^.WriteStr('NO KERNEL');
          AStream^.NewLine;
          end;
     AStream^.WriteStr('THE ITEMS:');
     AStream^.NewLine;
     ScanItem := PClosureItem(Items.GetFirst);
     while (ScanItem <> nil)
     do begin
        ScanItem^.Display( AStream);
        AStream^.NewLine;
        ScanItem := PClosureItem(Items.GetNext);
        end;
end;

function TClosure.GetFirstItem: PClosureItem;
begin
     GetFirstItem := PClosureItem(Items.GetFirst);
end;

function TClosure.GetNextItem: PClosureItem;
begin
     GetNextItem := PClosureItem(Items.GetNext);
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TClosureItem.Create( ARule: PRule; ACursor: Integer; ALookaheadSet: PCollection);
begin
     inherited Create( ARule, ACursor, ALookaheadSet);
     Marked := False;
     GotoClosure := nil;
end;

constructor TClosureItem.CreateFromKernelItem( AKernelItem: PClosureKernelItem);
begin
     if (AKernelItem <> nil)
     then Create( AKernelItem^.GetRule, AKernelItem^.GetCursor, AKernelItem^.GetLookaheads)
     else Create( nil, 0, nil);
end;

destructor TClosureItem.Destroy;
begin
     inherited Destroy;
end;

function TClosureItem.IsMarked: Boolean;
begin
     IsMarked := Marked;
end;

procedure TClosureItem.Mark;
begin
     Marked := True;
end;

procedure TClosureItem.Unmark;
begin
     Marked := False;
end;

procedure TClosureItem.SetGotoClosure( AClosure: PClosure);
begin
     GotoClosure := AClosure;
end;

function TClosureItem.GetGotoClosure: PClosure;
begin
     GetGotoClosure := GotoClosure;
end;

procedure TClosureItem.Display( AStream: PStream);
begin
     if ( AStream = nil) then Exit;

     Inherited Display( AStream);

     if (GotoClosure <> nil)
     then begin
          AStream^.WriteStr(' GOTO(');
          AStream^.WriteInt( GotoClosure^.GetIdentifier);
          AStream^.WriteStr(')');
          end
     else begin
          if (Rule <> nil)
          then begin
               AStream^.WriteStr( '  REDUCE[');
               AStream^.WriteInt( Rule^.GetID);
               AStream^.WriteStr( ']');
               end
          else AStream^.WriteStr( '  REDUCE[###]');
          end;
end;

function TClosureItem.IsReduceState: Boolean;
begin
     IsReduceState := (GetCursor > 0) and (GetCursorSymbol = nil);
end;

function TClosureItem.IsShiftState: Boolean;
begin
     IsShiftState := (GetCursorSymbol <> nil);
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TConflict.Create( AClosure: PClosure);
begin
     inherited Create;
     Closure := AClosure;
end;

destructor TConflict.Destroy;
begin
     inherited Destroy;
end;

function TConflict.GetClosure: PClosure;
begin
     GetClosure := Closure;
end;

procedure TConflict.Display( AStream: PStream);
begin
     if ( AStream = nil) then Exit;

     AStream^.WriteStr('CONFLICT: ');
     if ( Closure <> nil)
     then Closure^.Display( AStream);
     AStream^.NewLine;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TClosuresSet.Create( AGrammar: PGrammar; ACanonical: Boolean);
begin
     inherited Create;
     Closures.Create;
     Conflicts.Create;
     Build( AGrammar, ACanonical);
end;

destructor TClosuresSet.Destroy;
begin
     Conflicts.Destroy;
     Closures.Destroy;
     inherited Destroy;
end;

procedure TClosuresSet.Display( AStream: PStream);
var ScanItem: PClosure;
    ScanConflict: PConflict;
begin
     if ( AStream = nil) then Exit;

     ScanItem := PClosure(Closures.GetFirst);
     while (ScanItem <> nil)
     do begin
        ScanItem^.Display( AStream);
        AStream^.NewLine;
        AStream^.NewLine;
        ScanItem := PClosure( Closures.GetNext);
        end;

     ScanConflict := PConflict( Conflicts.GetFirst);
     while ( ScanConflict <> nil)
     do begin
        ScanConflict^.Display( AStream);
        ScanConflict := PConflict( Conflicts.GetNext);
        end;
end;

procedure TClosuresSet.Build( AGrammar: PGrammar; ACanonical: Boolean);

    procedure BuildFirstClosure;
    var Kernel: PClosureKernel;
        StartRule: PRule;
        Symbol: PParserSymbol;
        Lookaheads: TCollection;
    begin
         StartRule := AGrammar^.GetStartRule;
         if (StartRule <> nil)
         then begin
              Lookaheads.Create;
              Symbol := AGrammar^.GetTerminateSymbol;
              if (Symbol <> nil)
              then Lookaheads.PushLast(Symbol);
              Kernel := New( PClosureKernel, Create);
              Kernel^.AddItem(New( PClosureKernelItem, Create(StartRule, 1, @Lookaheads)));
              Closures.PushLast( New( PClosure, Create( AGrammar, Kernel)));
              Lookaheads.Destroy;
              end;
    end;

    procedure BuildNextClosures;
    var UsedItems: TCollection;
        ScanClosure: PClosure;
        ProcessedClosure: PClosure;
        NewKernel: PClosureKernel;
        NewClosure: PClosure;
        NewItemsAdded: Boolean;
        ScanKernelItem: PClosureKernelItem;
    begin
         UsedItems.Create;
         repeat
         NewItemsAdded := False;
         ProcessedClosure := PClosure(Closures.GetFirst);
         while (ProcessedClosure <> nil)
         do begin
            if not ProcessedClosure^.IsExpanded
            then begin
                 ProcessedClosure^.ExpandFromKernel( AGrammar);
                 NewKernel := ProcessedClosure^.CreateNewKernel( UsedItems);
                 while (NewKernel <> nil)
                 do begin
                    ScanClosure := PClosure(Closures.GetFirst);
                    while (ScanClosure <> nil)
                    do begin
                       if ACanonical
                       then begin
                            if ScanClosure^.IsSameKernel( NewKernel)
                            then begin
                                 ProcessedClosure^.SetGoto( @UsedItems, ScanClosure);
                                 NewKernel^.Free;
                                 NewKernel := nil;
                                 ScanClosure := nil;
                                 end
                            else ScanClosure := PClosure(Closures.GetNext);
                            end
                       else begin
                            if ScanClosure^.IsComprise( NewKernel, False)
                            then begin
                                 if ScanClosure^.MergeKernels( NewKernel, AGrammar)
                                 then begin
                                      NewItemsAdded := True;
                                      if ( ProcessedClosure <> ScanClosure)
                                      then ProcessedClosure^.SetGoto( @UsedItems, ScanClosure);
                                      end
                                 else ProcessedClosure^.SetGoto( @UsedItems, ScanClosure);
                                 NewKernel^.Free;
                                 NewKernel := nil;
                                 ScanClosure := nil;
                                 end
                            else ScanClosure := PClosure(Closures.GetNext);
                            end;
                       end;

                    if (NewKernel <> nil)
                    then begin
                         NewItemsAdded := True;
                         NewClosure := New( PClosure, Create( AGrammar, NewKernel));
                         Closures.PushLast( NewClosure);
                         ProcessedClosure^.SetGoto( @UsedItems, NewClosure);
                         NewKernel := nil;
                         end;
                    NewKernel := ProcessedClosure^.CreateNewKernel( UsedItems);
                    end;
                 end;
            ProcessedClosure := PClosure(Closures.GetAfter(ProcessedClosure));
            end;
         until (( ACanonical) or ( not NewItemsAdded));
         UsedItems.Destroy;
    end;

    procedure EnumClosures;
    var Id: Word;
        ScanClosure: PClosure;
    begin
         Id := 1;
         ScanClosure := PClosure( Closures.GetFirst);
         while (ScanClosure <> nil)
         do begin
            ScanClosure^.SetIdentifier( Id);
            Id := Id + 1;
            ScanClosure := PClosure( Closures.GetNext);
            end;
    end;

begin
     Closures.Clear;
     if (AGrammar <> nil)
     then begin
          BuildFirstClosure;
          BuildNextClosures;
          EnumClosures;
          end;
end;

function TClosuresSet.GetFirstClosure: PClosure;
begin
     GetFirstClosure := PClosure(Closures.GetFirst);
end;

function TClosuresSet.GetNextClosure: PClosure;
begin
     GetNextClosure := PClosure(Closures.GetNext);
end;

function TClosuresSet.GetClosuresCount: Word;
begin
     GetClosuresCount := Closures.GetItemsCount;
end;

function TClosuresSet.GetFirstConflict: PConflict;
begin
     GetFirstConflict := PConflict(Conflicts.GetFirst);
end;

function TClosuresSet.GetNextConflict: PConflict;
begin
     GetNextConflict := PConflict(Conflicts.GetNext);
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TLRTable.Create( AOwner: PErrGeneric);
begin
     inherited Create( AOwner);

     TerminalsCount := 0;
     NonTerminalsCount := 0;
     StatesCount := 0;

     ActionCols := nil;
     GotoCols := nil;
     ClosuresSet := nil;
     Grammar := nil;
end;

destructor TLRTable.Destroy;
begin
     Clear;
     inherited Destroy;
end;

procedure TLRTable.AllocateTable( ATerminalsCount, ANonTerminalsCount, AStatesCount: Word);
var I,J: Word;
begin
     if ((ATerminalsCount > 0) and
        (ANonTerminalsCount > 0) and
        (AStatesCount > 0))
     then begin
          TerminalsCount := ATerminalsCount;
          NonTerminalsCount := ANonTerminalsCount;
          StatesCount := AStatesCount;

          GetMem( ActionCols, SizeOf( TActionsColHeader) * TerminalsCount);
          for I := 1 to TerminalsCount
          do begin
             ActionCols^[I].Terminal := nil;

             GetMem( ActionCols^[I].Col, SizeOf( TActionInfo) * StatesCount);
             for J := 1 to StatesCount
             do begin
                ActionCols^[I].Col^[J].Action := actError;
                ActionCols^[I].Col^[J].ErrorCode := nil;
                end;
             end;

          GetMem( GotoCols, SizeOf( TGotosColHeader) * NonTerminalsCount);
          for I := 1 to NonTerminalsCount
          do begin
             GotoCols^[I].NonTerminal := nil;
             GetMem( GotoCols^[I].Col, SizeOf( TGotoInfo) * StatesCount);
             for J := 1 to StatesCount
             do GotoCols^[I].Col^[J].NextState := nil;
             end;
          end
     else begin
          TerminalsCount := 0;
          NonTerminalsCount := 0;
          StatesCount := 0;
          ActionCols := nil;
          GotoCols := nil;
          ClosuresSet := nil;
          end;

end;

procedure TLRTable.Clear;
var I,J: Word;
begin
     if ((TerminalsCount > 0) and
        (NonTerminalsCount > 0) and
        (StatesCount > 0) and
        (ActionCols <> nil) and
        (GotoCols <> nil))
     then begin
          for I := 1 to TerminalsCount
          do begin
             for J := 1 to StatesCount
             do if ((ActionCols^[I].Col^[J].Action = actError) and (ActionCols^[I].Col^[J].ErrorCode <> nil))
                then ActionCols^[I].Col^[J].ErrorCode^.Free;
             FreeMem( ActionCols^[I].Col, SizeOf( TActionInfo) * StatesCount);
             end;
          FreeMem( ActionCols, SizeOf( TActionsColHeader) * TerminalsCount);

          for I := 1 to NonTerminalsCount
          do FreeMem( GotoCols^[I].Col, SizeOf( TGotoInfo) * StatesCount);
          FreeMem( GotoCols, SizeOf( TGotosColHeader) * NonTerminalsCount);
          end;

     if (ClosuresSet <> nil)
     then begin
          ClosuresSet^.Free;
          ClosuresSet := nil;
          end;

     TerminalsCount := 0;
     NonTerminalsCount := 0;
     StatesCount := 0;

     ActionCols := nil;
     GotoCols := nil;
end;

procedure TLRTable.Build( AGrammar: PGrammar; ACanonical: Boolean);
var ScanClosure: PClosure;
    ClosureItem: PClosureItem;
    Symbol: PParserSymbol;
    ClosureItemRule: PRule;
    I: Word;
    Error: PMessageError;
    S: string;
begin
     Clear;
     Grammar := AGrammar;
     if (Grammar <> nil)
     then begin
          ClosuresSet := New( PClosuresSet, Create( Grammar, ACanonical));
          AllocateTable( Grammar^.GetTerminalsCount, Grammar^.GetNonTerminalsCount, ClosuresSet^.GetClosuresCount);
          for I := 1 to TerminalsCount
          do ActionCols^[I].Terminal := Grammar^.GetTerminalByID(I);
          for I := 1 to NonterminalsCount
          do GotoCols^[I].Nonterminal := Grammar^.GetNonterminalByID(I);

          ScanClosure := ClosuresSet^.GetFirstClosure;
          while (ScanClosure <> nil)
          do begin
             ClosureItem := ScanClosure^.GetFirstItem;
             while (ClosureItem <> nil)
             do begin
                ClosureItemRule := ClosureItem^.GetRule;
                if ClosureItem^.IsShiftState
                then begin
                     Symbol := ClosureItem^.GetCursorSymbol;
                     if (Symbol <> nil)
                     then begin
                          if Grammar^.IsNonterminalSymbol( Symbol)
                          then begin
                               if ( GotoCols^[Symbol^.GetID].Col^[ScanClosure^.GetIdentifier].NextState = nil)
                               then begin
                                    GotoCols^[Symbol^.GetID].Col^[ScanClosure^.GetIdentifier].NextState
                                       := ClosureItem^.GetGotoClosure;
                                    end
                               else if ( GotoCols^[Symbol^.GetID].Col^[ScanClosure^.GetIdentifier].NextState
                                       <> ClosureItem^.GetGotoClosure)
                                    then begin
                                         { There is a conflict }
                                         Str( ScanClosure^.GetIdentifier, S);
                                         S := 'GRAMMAR ERROR: SHIFT-SHIFT conflict in state (' + S + ').';
                                         Error := New( PMessageError, Create(S));
                                         AddError( Error);
                                         ClosuresSet^.Conflicts.PushLast( New( PConflict, Create(ScanClosure)));
                                         end;
                               end
                          else begin
                               if ( ActionCols^[Symbol^.GetID].Col^[ScanClosure^.GetIdentifier].Action <> actShift)
                               then begin
                                    if ( ActionCols^[Symbol^.GetID].Col^[ScanClosure^.GetIdentifier].Action = actReduce)
                                    then begin
                                         Str( ScanClosure^.GetIdentifier, S);
                                         S := 'GRAMMAR ERROR: SHIFT-REDUCE conflict in state ('
                                              + S + '), resolved by using SHIFT.';
                                         Error := New( PMessageError, Create(S));
                                         AddError( Error);
                                         ClosuresSet^.Conflicts.PushLast( New( PConflict, Create(ScanClosure)));
                                         end;
                                    ActionCols^[Symbol^.GetID].Col^[ScanClosure^.GetIdentifier].Action
                                      := actShift;
                                    ActionCols^[Symbol^.GetID].Col^[ScanClosure^.GetIdentifier].NextState
                                      := ClosureItem^.GetGotoClosure;
                                    end
                               else if ( ActionCols^[Symbol^.GetID].Col^[ScanClosure^.GetIdentifier].NextState
                                            <> ClosureItem^.GetGotoClosure)
                               then begin
                                    { There is a SHIFT/SHIFT conflict }
                                    Str( ScanClosure^.GetIdentifier, S);
                                    S := 'GRAMMAR ERROR: SHIFT-SHIFT conflict in state (' + S + ').';
                                    Error := New( PMessageError, Create(S));
                                    AddError( Error);
                                    ClosuresSet^.Conflicts.PushLast( New( PConflict, Create(ScanClosure)));
                                    end
                                end;
                          end;
                     end
                else if ClosureItem^.IsReduceState
                then begin
                     Symbol := ClosureItem^.GetFirstLookahead;
                     while (Symbol <> nil)
                     do begin
                        if (ActionCols^[Symbol^.GetID].Col^[ScanClosure^.GetIdentifier].Action = actError)
                        then begin
                             if not (Grammar^.GetStartSymbol = ClosureItemRule^.GetLeftSymbol)
                             then begin
                                  ActionCols^[Symbol^.GetID].Col^[ScanClosure^.GetIdentifier].Action
                                               := actReduce;
                                  ActionCols^[Symbol^.GetID].Col^[ScanClosure^.GetIdentifier].ReduceRule
                                               := ClosureItemRule;
                                  end
                             else begin
                                  ActionCols^[Symbol^.GetID].Col^[ScanClosure^.GetIdentifier].Action
                                               := actAccept;
                                  ActionCols^[Symbol^.GetID].Col^[ScanClosure^.GetIdentifier].ReduceRule
                                               := ClosureItemRule;
                                  end;
                             end
                        else begin
                             { There is a conflict }
                             Str( ScanClosure^.GetIdentifier, S);
                             S := 'GRAMMAR ERROR: Conflict in state (' + S + ').';
                             Error := New( PMessageError, Create(S));
                             AddError( Error);
                             ClosuresSet^.Conflicts.PushLast( New( PConflict, Create(ScanClosure)));
                             end;
                        Symbol := ClosureItem^.GetNextLookahead;
                        end;
                     end;
                ClosureItem := ScanClosure^.GetNextItem;
                end;
             ScanClosure := ClosuresSet^.GetNextClosure;
             end;
          end;
end;

procedure TLRTable.Display( AStream: PStream);
var I, J: Word;
    S: string;
    Symbol: PParserSymbol;
    RulesCount: Word;
    Rule: PRule;
begin
     if ( AStream = nil) then Exit;

     AStream^.NewLine;
     if (ClosuresSet <> nil)
     then ClosuresSet^.Display( AStream);
     AStream^.NewLine;
     AStream^.WriteStr( 'ACTION TABLE:');
     AStream^.NewLine;
     for J := 1 to StatesCount
     do begin
        AStream^.WriteIntF( J, 4);
        AStream^.WriteStr( ':  ');
        for I := 1 to TerminalsCount
        do begin
           case ActionCols^[I].Col^[J].Action
           of actShift: begin
                        if (ActionCols^[I].Col^[J].NextState <> nil)
                        then Str(ActionCols^[I].Col^[J].NextState^.GetIdentifier, S)
                        else S := '';
                        S := 'S' + S;
                        end;
              actError: begin
                        S := 'ERR';
                        end;
              actReduce: begin
                         if (ActionCols^[I].Col^[J].ReduceRule <> nil)
                         then Str( ActionCols^[I].Col^[J].ReduceRule^.GetID, S)
                         else S := '##';
                         S := 'R' + S;
                         end;
              actAccept: begin
                         S := 'ACC'
                         end;
              else
                  S := '';
              end;
           while (Length(S) < 5) do S := ' ' + S;
           AStream^.WriteStr( S);
           end;
        AStream^.WriteStr( '   ');
        for I := 1 to NonterminalsCount
        do begin
           if (GotoCols^[I].Col^[J].NextState <> nil)
           then Str(GotoCols^[I].Col^[J].NextState^.GetIdentifier, S)
           else S := '---';
           while (Length(S) < 5) do S := ' ' + S;
           AStream^.WriteStr( S);
           end;
        AStream^.NewLine;
        end;
     AStream^.NewLine;
     AStream^.WriteStr( 'TERMINALS:');
     AStream^.NewLine;
     for I := 1 to TerminalsCount
     do begin
        Symbol := ActionCols^[I].Terminal;
        AStream^.WriteInt( I);
        AStream^.WriteStr('  ');
        if (Symbol <> nil)
        then Symbol^.Display( AStream);
        AStream^.NewLine;
        end;

     AStream^.NewLine;
     AStream^.WriteStr( 'NONTERMINALS:');
     AStream^.NewLine;
     for I := 1 to NonterminalsCount
     do begin
        Symbol := GotoCols^[I].Nonterminal;
        AStream^.WriteInt( I);
        AStream^.WriteStr( '  ');
        if (Symbol <> nil)
        then Symbol^.Display( AStream);
        AStream^.NewLine;
        end;

     AStream^.NewLine;
     AStream^.NewLine;

     AStream^.WriteStr( 'STATESCOUNT       = ');
     AStream^.WriteInt( StatesCount);
     AStream^.NewLine;
     AStream^.WriteStr( 'TERMINALCOUNT     = ');
     AStream^.WriteInt( TerminalsCount);
     AStream^.NewLine;
     AStream^.WriteStr( 'NONTERMINALCOUNT  = ');
     AStream^.WriteInt( NonterminalsCount);
     AStream^.NewLine;

     if Grammar <> nil
     then begin
          AStream^.WriteStr( 'RULESCOUNT        = ');
          AStream^.WriteInt( Grammar^.GetRulesCount);
          end
     else AStream^.WriteStr( 'RULESCOUNT        = ?');

     AStream^.NewLine;
     AStream^.NewLine;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TOutputGenerator.Create( AOwner: PErrGeneric; ADataBase: PYaccDatabase; ASkeleton: PStream; ATarget: PStream);
begin
     inherited Create( AOwner);
     DataBase := ADataBase;
     Skeleton := ASkeleton;
     Target := ATarget;
end;

destructor TOutputGenerator.Destroy;
begin
     inherited Destroy;
end;

function TOutputGenerator.ScanToNextCommand( var AEndOfSkeleton: Boolean): string;
label EndOfCommand;
var C1, C2: Char;
    Command: string;
begin
     Command := '';
     AEndOfSkeleton := False;
     while ( Skeleton^.Read( C1, 1) = 1)
     do begin
        if ( C1 <> '%')
        then Target^.Write( C1, 1)
        else begin
             if (Skeleton^.Read( C2, 1) = 1)
             then begin
                  if ( C2 = '%')
                  then begin
                       while (Skeleton^.Read( C1, 1) = 1)
                       do begin
                          if ( C1 in [ 'A'..'Z', 'a'..'z', '0'..'1', '_'])
                          then Command := Command + C1
                          else begin
                               Skeleton^.SetPos( Skeleton^.GetPos - 1);
                               goto EndOfCommand;
                               end;
                          end;
                       AEndOfSkeleton := True;
                       end
                  else begin
                       Target^.Write( C1, 1);
                       Target^.Write( C2, 1);
                       end;
                  end
             else begin
                  Target^.Write( C1, 1);
                  Break;
                  end;
             end;
        end;
     AEndOfSkeleton := True;
EndOfCommand:
     ScanToNextCommand := Command;
end;

procedure TOutputGenerator.GenerateOutput;
begin
     if ((Target <> nil) and (DataBase <> nil))
     then begin
          if (Skeleton = nil)
          then GenerateAbstractOutput
          else begin
               Skeleton^.SetPos( 0);
               GenerateFromSkeleton;
               end;
          end;
end;

procedure TOutputGenerator.GenerateAbstractOutput;
begin
     DataBase^.Display( Target);
end;

procedure TOutputGenerator.GenerateFromSkeleton;
var Command: string;
    EOSkeleton: Boolean;

    procedure WriteGotoTablePAS;
    var I, J, K: Integer;
        S1, S2: string;
    begin
         with DataBase^.Table
         do begin
            Target^.WriteStr('(');
            Target^.NewLine;
            for J := 1 to StatesCount
            do begin
               S1 := '{ St.';
               Str( J:4, S2);
               S1 := S1 + S2 + '  } (';
               Target^.WriteStr(S1);
               K := 0;
               for I := 1 to NonTerminalsCount
               do begin
                  if (GotoCols^[I].Col^[J].NextState <> nil)
                  then Str(GotoCols^[I].Col^[J].NextState^.GetIdentifier, S1)
                  else S1 := '0';
                  while (Length(S1) < 3) do S1 := ' ' + S1;
                  Target^.WriteStr(S1);
                  if (I < NonTerminalsCount)
                  then Target^.WriteStr(',');
                  K := K + 1;
                  if K > 20
                  then begin
                       K := 0;
                       Target^.NewLine;
                       end;
                  end;
               Target^.WriteStr(')');
               if (J < StatesCount)
               then begin
                    Target^.WriteStr(',');
                    Target^.NewLine;
                    end
               else begin
                    Target^.NewLine;
                    Target^.WriteStr(');');
                    Target^.NewLine;
                    end;
               end;
            end;
    end;

    procedure WriteActionTablePAS;
    var I, J: Integer;
        S1, S2: string;
    begin
         with DataBase^.Table
         do begin
            Target^.WriteStr('(');
            Target^.NewLine;
            for J := 1 to StatesCount
            do begin
               S1 := '{ St.';
               Str( J:4, S2);
               S1 := S1 + S2 + '  } (';
               Target^.WriteStr(S1);
               Target^.NewLine;
               for I := 1 to TerminalsCount
               do begin
                  case ActionCols^[I].Col^[J].Action
                  of actShift: begin
                            if (ActionCols^[I].Col^[J].NextState <> nil)
                            then Str(ActionCols^[I].Col^[J].NextState^.GetIdentifier, S1)
                            else S1 := '###';
                            S1 := '( Action: actShift; NextState: ' + S1 + ')';
                            end;
                  actError: begin
                            S1 := '( Action: actError; ErrorCode: 0)';
                            end;
                  actReduce: begin
                             if (ActionCols^[I].Col^[J].ReduceRule <> nil)
                             then Str( ActionCols^[I].Col^[J].ReduceRule^.GetID, S1)
                             else S1 := '###';
                             S1 := '( Action: actReduce; Rule: ' + S1 + ')';
                             end;
                  actAccept: begin
                             if (ActionCols^[I].Col^[J].ReduceRule <> nil)
                             then Str( ActionCols^[I].Col^[J].ReduceRule^.GetID, S1)
                             else S1 := '###';
                             S1 := '( Action: actAccept; Rule: ' + S1 + ')';
                             end;
                  else
                      S1 := '###########';
                  end;
               Target^.WriteStr(S1);
               if (I < TerminalsCount)
               then Target^.WriteStr(',');
               Target^.NewLine;
               end;
               if (J < StatesCount)
               then begin
                    Target^.WriteStr('),');
                    Target^.NewLine;
                    end
               else begin
                    Target^.WriteStr(')');
                    Target^.NewLine;
                    Target^.WriteStr(');');
                    Target^.NewLine;
                    end;
               end;
            end;
    end;

    procedure WriteProceduresPAS;
    var ScanRule: PRule;
        ScanSemantic: PRuleSemantic;
        I: Integer;
        Header: string;
    begin
          ScanRule := DataBase^.Grammar.GetFirstRule;
          while ( ScanRule <> nil)
          do begin
             if (ScanRule <> nil)
             then begin
                  ScanSemantic := ScanRule^.GetSemantic;
                  if (ScanSemantic <> nil)
                  then begin
                       Str( ScanRule^.GetID, Header);
                       Header := 'procedure Semantic'+Header+'( AParser: PParser);';
                       Target^.WriteStr( Header);
                       Target^.NewLine;
                       if ((ScanSemantic^.GetBuffer <> nil) and (ScanSemantic^.GetSize > 0))
                       then Target^.Write( ScanSemantic^.GetBuffer^, ScanSemantic^.GetSize)
                       else Target^.WriteStr('begin end;');
                       Target^.NewLine;
                       Target^.NewLine;
                       end;
                  end;
             ScanRule := DataBase^.Grammar.GetNextRule;
             end;
    end;

    procedure WriteReductionsPAS;
    var ScanRule: PRule;
        ScanSemantic: PRuleSemantic;
        I: Integer;
        RulesCount: Integer;
        ProcName: string;
        MaxId: Integer;
    begin
          ScanRule := DataBase^.Grammar.GetFirstRule;
          MaxId := 0;
          while ( ScanRule <> nil)
          do begin
             if MaxId < ScanRule^.GetId
             then MaxId := ScanRule^.GetId;
             ScanRule := DataBase^.Grammar.GetNextRule;
             end;


          Target^.WriteStr( '(');
          Target^.NewLine;
          for I := 1 to MaxId
          do begin
             ScanRule := DataBase^.Grammar.GetFirstRule;
             while (ScanRule <> nil)
             do begin
                if ( ScanRule^.GetId = I)
                then break
                else ScanRule := DataBase^.Grammar.GetNextRule;
                end;

             if ( ScanRule <> nil)
             then begin
                  Str( I, ProcName);
                  ProcName := 'Semantic' + ProcName;
                  Target^.WriteStr( ProcName);
                  end
             else Target^.WriteStr( 'nil');

             if ( I < MaxId)
             then Target^.WriteStr( ',');
             Target^.NewLine;
             end;
          Target^.WriteStr( ');');
          Target^.NewLine;
    end;

    procedure WriteLeftSidesTablePAS;
    var ScanRule: PRule;
        ScanRuleSymbol: PParserSymbol;
        I, J: Integer;
        RulesCount: Integer;
        MaxId: Integer;
        S1: string;
    begin
          ScanRule := DataBase^.Grammar.GetFirstRule;
          MaxId := 0;
          while ( ScanRule <> nil)
          do begin
             if MaxId < ScanRule^.GetId
             then MaxId := ScanRule^.GetId;
             ScanRule := DataBase^.Grammar.GetNextRule;
             end;

          Target^.WriteStr( '(');
          Target^.NewLine;
          J := 0;
          for I := 1 to MaxId
          do begin
             ScanRule := DataBase^.Grammar.GetFirstRule;
             while (ScanRule <> nil)
             do begin
                if ( ScanRule^.GetId = I)
                then break
                else ScanRule := DataBase^.Grammar.GetNextRule;
                end;

             if ( ScanRule <> nil)
             then begin
                  ScanRuleSymbol := ScanRule^.GetLeftSymbol;
                  if ( ScanRuleSymbol <> nil)
                  then Str( ScanRuleSymbol^.GetId:4, S1)
                  else S1 := '????';
                  Target^.WriteStr( S1);
                  end
             else Target^.WriteStr( '   0');

             if ( I < MaxId)
             then Target^.WriteStr( ',');

             J := J + 1;
             if ( J >= 8)
             then begin
                  Target^.NewLine;
                  J := 0;
                  end;
             end;
          Target^.NewLine;
          Target^.WriteStr( ');');
          Target^.NewLine;
    end;

    procedure WriteRightSidesTablePAS;
    var ScanRule: PRule;
        ScanSemantic: PRuleSemantic;
        I, J: Integer;
        RulesCount: Integer;
        MaxId: Integer;
        S1: string;
    begin
          ScanRule := DataBase^.Grammar.GetFirstRule;
          MaxId := 0;
          while ( ScanRule <> nil)
          do begin
             if MaxId < ScanRule^.GetId
             then MaxId := ScanRule^.GetId;
             ScanRule := DataBase^.Grammar.GetNextRule;
             end;

          Target^.WriteStr( '(');
          Target^.NewLine;
          J := 0;
          for I := 1 to MaxId
          do begin
             ScanRule := DataBase^.Grammar.GetFirstRule;
             while (ScanRule <> nil)
             do begin
                if ( ScanRule^.GetId = I)
                then break
                else ScanRule := DataBase^.Grammar.GetNextRule;
                end;

             if ( ScanRule <> nil)
             then begin
                  Str( ScanRule^.GetRightSideSize:4, S1);
                  Target^.WriteStr( S1);
                  end
             else Target^.WriteStr( '   0');

             if ( I < MaxId)
             then Target^.WriteStr( ',');

             J := J + 1;
             if ( J >= 8)
             then begin
                  Target^.NewLine;
                  J := 0;
                  end;
             end;
          Target^.NewLine;
          Target^.WriteStr( ');');
          Target^.NewLine;
    end;


    procedure WriteDefinesPAS;
    var S1: string;
    begin
        with DataBase^.Table
        do begin
           Str( StatesCount, S1);
           S1 := 'YACC_STATESCOUNT = ' + S1 + ';';
           Target^.WriteStr( S1);
           Target^.NewLine;
           Str( TerminalsCount, S1);
           S1 := 'YACC_TERMINALSCOUNT = ' + S1 + ';';
           Target^.WriteStr( S1);
           Target^.NewLine;
           Str( NonterminalsCount, S1);
           S1 := 'YACC_NONTERMINALSCOUNT = ' + S1 + ';';
           Target^.WriteStr( S1);
           Target^.NewLine;
           if Grammar <> nil
           then Str( Grammar^.GetRulesCount, S1)
           else S1 := '?';
           S1 := 'YACC_RULESCOUNT = ' + S1 + ';';
           Target^.WriteStr( S1);
           Target^.NewLine;
           end;
    end;

    procedure WriteTokensPAS;
    var ScanSymbol: PParserSymbol;
        S1: string;
        MaxId: Integer;
        I: Integer;
    begin
         with DataBase^
         do begin
            ScanSymbol := PParserSymbol( Grammar.Terminals.GetFirst);
            MaxId := 0;
            while (ScanSymbol <> nil)
            do begin
               if (MaxId < ScanSymbol^.GetId)
               then MaxId := ScanSymbol^.GetId;
               ScanSymbol := PParserSymbol( Grammar.Terminals.GetNext);
               end;

            for I := 1 to MaxId
            do begin
               ScanSymbol := PParserSymbol( Grammar.Terminals.GetFirst);
               while (ScanSymbol <> nil)
               do begin
                  if (I = ScanSymbol^.GetId)
                  then begin
                       Str( ScanSymbol^.GetId, S1);
                       S1 := 'YACC_' + ScanSymbol^.GetTitle + ' = ' + S1 + ';';
                       Target^.WriteStr( S1);
                       Target^.NewLine;
                       ScanSymbol := nil;
                       end
                  else ScanSymbol := PParserSymbol( Grammar.Terminals.GetNext);
                  end;
               end;
            end;
    end;

begin
     repeat
           Command := ScanToNextCommand( EOSkeleton);
           if Command = 'PAS_ACTION'
           then WriteActionTablePAS
           else if Command = 'PAS_GOTO'
           then WriteGotoTablePAS
           else if Command = 'PAS_PROCEDURES'
           then WriteProceduresPAS
           else if Command = 'PAS_REDUCTIONS'
           then WriteReductionsPAS
           else if Command = 'PAS_LEFTSIDES'
           then WriteLeftSidesTablePAS
           else if Command = 'PAS_DEFINES'
           then WriteDefinesPAS
           else if Command = 'PAS_RIGHTSIDES'
           then WriteRightSidesTablePAS
           else if Command = 'PAS_TOKENS'
           then WriteTokensPAS;
     until (EOSkeleton);
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TYaccDatabase.Create( AOwner: PErrGeneric);
begin
     inherited Create( AOwner);
     Grammar.Create( @Self);
     Table.Create( @Self);
     Canonical := False;
end;

destructor TYaccDatabase.Destroy;
begin
     Table.Destroy;
     Grammar.Destroy;
     inherited Destroy;
end;

procedure TYaccDatabase.Clear;
begin
     Table.Clear;
     Grammar.Clear;
end;

function TYaccDatabase.AddNonterminal( ATitle: string): PParserSymbol;
begin
     AddNonterminal := Grammar.AddSymbolAsTerminal( ATitle);
end;

function TYaccDatabase.AddSymbol( ATitle: string): PParserSymbol;
begin
     AddSymbol := Grammar.AddSymbol( ATitle);
end;

procedure TYaccDatabase.AddRule( ARule: PRule);
begin
     Grammar.AppendRule( ARule);
end;

procedure TYaccDatabase.SetStartSymbol( ASymbol: PParserSymbol);
begin
     if ( ASymbol <> nil)
     then Grammar.SetStartSymbol( ASymbol);
end;

procedure TYaccDatabase.Build;
begin
     Grammar.ClasifySymbols;
     Table.Build( @Grammar, Canonical);
end;

procedure TYaccDatabase.Display( AStream: PStream);
begin
     if ( AStream = nil) then Exit;

     Grammar.Display( AStream);
     AStream^.NewLine;
     Grammar.DisplaySymbolsClasification( AStream);
     AStream^.NewLine;
     Table.Display( AStream);
end;

procedure TYaccDatabase.SetCanonical;
begin
     Canonical := True;
end;

procedure TYaccDatabase.SetLALR;
begin
     Canonical := False;
end;

end.