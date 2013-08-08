{********************************************************}
{*                                                      *}
{*   LEX tool engine unit                               *}
{*                                                      *}
{*   File name : LEXENGIN.PAS                           *}
{*                                                      *}
{*   Programming: Russlan Kafri - 1999                  *}
{*                                                      *}
{********************************************************}

unit LexEngine;

interface

uses Generics;

type
    PAutoInSymbol = ^TAutoInSymbol;
    TAutoInSymbol = object( TGeneric)
    private
        Identifier: Word;
    public
        constructor Create;
        destructor Destroy; virtual;
        procedure SetID( AIndentifier: Word);
        function GetID: Word;
        procedure Display( AStream: PStream); virtual;
        end;

    PTransition = ^TTransition;

    PFinalStateInfo = ^TFinalStateInfo;
    TFinalStateInfo = object( TGeneric)
    private
        Priority: Word;
    public
        constructor Create( APriority: Word);
        destructor Destroy; virtual;
        function GetPriority: Word;
        procedure SetPriority( APriority: Word);
        procedure Display( AStream: PStream); virtual;
        end;

    PAutomateState = ^TAutomateState;
    TAutomateState = object( TGeneric)
    private
        Identifier: Word;
        Transitions: TContainerCollection;
        FinalStateInfo: PFinalStateInfo;
    public
        constructor Create( AIdentifier: Word; AFinalStateInfo: PFinalStateInfo);
        destructor Destroy; virtual;
        function IsFinalState: Boolean; virtual;
        function GetFinalStateInfo: PFinalStateInfo; virtual;
        procedure SetFinalStateInfo(AInfo: PFinalStateInfo);
        procedure AddTransition( ASymbol: PAutoInSymbol; ANextState: PAutomateState);
        function GetFirstTransition: PTransition;
        function GetNextTransition: PTransition;
        procedure SetID( AIdentifier: Word);
        function GetID: Word;
        function IsHasSameTransitionsSymbols( AState: PAutomateState): Boolean;
        procedure Display( AStream: PStream); virtual;
        end;

    TTransition = object( TGeneric)
    private
        Symbol: PAutoInSymbol;
        NextState: PAutomateState;
    public
        constructor Create( ASymbol: PAutoInSymbol; ANextState: PAutomateState);
        destructor Destroy; virtual;
        function GetSymbol: PAutoInSymbol;
        function GetToState: PAutomateState;
        function IsEqual( ASymbol: PAutoInSymbol; ANextState: PAutomateState): Boolean;
        function IsSameAs( ATransition: PTransition): Boolean;
        end;

    PComplextAutoState = ^TComplextAutoState;
    TComplextAutoState = object( TAutomateState)
    private
        MyImage: PAutomateState;
        SimpleItems: TCollection;
    public
        constructor Create( AIdentifier: Word; ASimpleAutoStates: PCollection);
        destructor Destroy; virtual;
        procedure AddAutomateState( AState: PAutomateState);
        function IsEqual( AStates: PCollection): Boolean;
        function IsFinalState: Boolean; virtual;
        function GetFirstSimpleState: PAutomateState;
        function GetNextSimpleState: PAutomateState;
        procedure GetTransitionSymbols( var ASymbols: TCollection);
        procedure CreateYourImage;
        procedure ConnectYourImage;
        function LeaveYourImage: PAutomateState;
        function GetYourImage: PAutomateState;
        function GetFinalStateInfo: PFinalStateInfo; virtual;
        function GetStrangeStates( var AStates: TCollection): Boolean;
        procedure RemoveStates( AStates: PCollection);
        function IsMemberState( AState: PAutomateState): Boolean;
        procedure Display( AStream: PStream); virtual;
        end;

    PRegExp = ^TRegExp;

    PAutomate = ^TAutomate;
    TAutomate = object( TGeneric)
    private
        StartState: PAutomateState;
        Alphabet: TCollection;
        States: TContainerCollection;
        FinalStatesInfo: TCollection;
        Symbols: TCollection;
    public
        constructor Create;
        destructor Destroy; virtual;
        procedure AddState( AState: PAutomateState);
        procedure Clear;
        procedure EnumStates;
        procedure EnumAlphabet;
        function GetStatesCount: Word;
        function GetAlphabetSize: Word;
        function GetStartState: PAutomateState;
        function GetFirstState: PAutomateState;
        function GetNextState: PAutomateState;
        function GetFirstSymbol: PAutoInSymbol;
        function GetNextSymbol: PAutoInSymbol;
        procedure AddSymbol( ASymbol: PAutoInSymbol);
        procedure Display( AStream: PStream); virtual;
        procedure ConvertToDFA;
        procedure OptimizeSize;
        procedure AddMainExp( AExp: PRegExp; AFinalStateInfo: PFinalStateInfo);
        procedure Build;
        end;

    PAutoCol = ^TAutoCol;
    TAutoCol = array[1..1] of PAutomateState;

    PAutoFinals = ^TAutoFinals;
    TAutoFinals = array[1..1] of PFinalStateInfo;

    PAutoColHeader = ^TAutoColHeader;
    TAutoColHeader = record
        Symbol: PAutoInSymbol;
        Col: PAutoCol;
        end;

    PAutoColHeaders = ^TAutoColHeaders;
    TAutoColHeaders = array[1..1] of TAutoColHeader;

    PAlphabetTable = ^TAlphabetTable;
    TAlphabetTable = array[0..255] of PAutoInSymbol;

    PLexAutoTable = ^TLexAutoTable;
    TLexAutoTable = object( TGeneric)
    private
        StatesCount: Word;
        AlphabetSize: Word;
        AlphabetTable: PAlphabetTable;
        AutoCols: PAutoColHeaders;
        AutoFinals: PAutoFinals;
        StartState: Word;
        procedure Clear;
        procedure AllocateTable( AStatesCount: Word; AAlphabetSize: Word);
    public
        constructor Create;
        destructor Destroy; virtual;
        procedure SetSymbol( AIndex: Word; ASymbol: PAutoInSymbol);
        function GetSymbol( AIndex: Word): PAutoInSymbol;
        function GetSymbolsCount: Word;
        procedure SetNext;
        procedure Build( AAutomate: PAutomate);
        procedure Display( AStream: PStream); virtual;
        end;

    PCharsSet = ^TCharsSet;
    TCharsSet = set of Char;

    PSymbolSet = ^TSymbolSet;
    TSymbolSet = object( TAutoInSymbol)
        CharsSet: TCharsSet;
        constructor Create( ACharsSet: TCharsSet);
        destructor Destroy; virtual;
        procedure Display( AStream: PStream); virtual;
        end;

    TRegExp = object(TGeneric)
        Parent: PRegExp;
        constructor Create( AParent: PRegExp);
        destructor Destroy;virtual;
        procedure ProduceAuto(AAutomate:PAutomate;var AStart,AEnd:PAutomateState);virtual;
        function Message( ACommand: Word; AInfo: Pointer): Boolean; virtual;
        procedure SetParent( AParent: PRegExp);
        function ReplaceChildRequest( AOldChild, ANewChild: PRegExp): Boolean; virtual;
        function ReplaceSelf( ANewChild: PRegExp): Boolean; virtual;
        function Clone:PRegExp; virtual;
        procedure Display( AStream: PStream); virtual;
        end;

    PBuffExp = ^TBuffExp;
    TBuffExp = object( TRegExp)
        Child: PRegExp;
        constructor Create( AParent: PRegExp; AChild: PRegExp);
        destructor Destroy; virtual;
        procedure ProduceAuto(AAutomate:PAutomate;var AStart,AEnd:PAutomatestate); virtual;
        function Message( ACommand: Word; AInfo: Pointer): Boolean; virtual;
        function ReplaceChildRequest( AOldChild, ANewChild: PRegExp): Boolean; virtual;
        procedure Display( AStream: PStream); virtual;
        function Clone: PRegExp; virtual;
        end;

    PSymbolExp = ^TSymbolExp;
    TSymbolExp = object(TRegExp)
        Symbols : PSymbolSet;
        constructor Create( AParent: PRegExp; ASymbols: PSymbolSet);
        destructor Destroy; virtual;
        procedure ProduceAuto(AAutomate:PAutomate;var AStart,AEnd:PAutomatestate); virtual;
        function Message( ACommand: Word; AInfo: Pointer): Boolean; virtual;
        function Clone: PRegExp; virtual;
        procedure Display( AStream: PStream); virtual;
        end;

    PConcatExp = ^TConcatExp;
    TConcatExp = object(TRegExp)
        RegExp1, RegExp2 : PRegExp;
        constructor Create( AParent: PRegExp; R1, R2: PRegExp);
        destructor Destroy; virtual;
        procedure ProduceAuto( AAutomate:PAutomate; var AStart,AEnd:PAutomatestate); virtual;
        function Message( ACommand: Word; AInfo: Pointer): Boolean; virtual;
        function ReplaceChildRequest( AOldChild, ANewChild: PRegExp): Boolean; virtual;
        function Clone: PRegExp; virtual;
        procedure Display( AStream: PStream); virtual;
        end;

    POrExp = ^TOrExp;
    TOrExp = object(TConcatExp)
        procedure ProduceAuto(AAutomate:PAutomate; var AStart,AEnd:PAutomatestate);virtual;
        function Clone: PRegExp; virtual;
        procedure Display( AStream: PStream); virtual;
        end;

    PStarExp = ^TStarExp;
    TStarExp = object(TRegExp)
        RegExp: PRegExp;
        constructor Create( AParent: PRegExp; R: PRegExp);
        destructor Destroy; virtual;
        procedure ProduceAuto(AAutomate: PAutomate; var AStart, AEnd:PAutomatestate); virtual;
        function Message( ACommand: Word; AInfo: Pointer): Boolean; virtual;
        function ReplaceChildRequest( AOldChild, ANewChild: PRegExp): Boolean; virtual;
        function Clone: PRegExp; virtual;
        procedure Display( AStream: PStream); virtual;
        end;

    PPlusExp = ^TPlusExp;
    TPlusExp = object(TStarExp)
        procedure ProduceAuto( AAutomate: PAutomate; var AStart, AEnd:PAutomatestate);virtual;
        function Clone: PRegExp; virtual;
        procedure Display( AStream: PStream); virtual;
        end;

    PQMarkExp = ^TQMarkExp;
    TQMarkExp = object( TStarExp)
        procedure ProduceAuto( AAutomate: PAutomate; var AStart, AEnd:PAutomatestate);virtual;
        function Clone: PRegExp; virtual;
        procedure Display( AStream: PStream); virtual;
        end;

    PLexProcedure = ^TLexProcedure;
    TLexProcedure = object( TFinalStateInfo)
    private
       Buffer: Pointer;
       BufferSize: Word;
       Expresion: PRegExp;
    public
       constructor Create( APriority: Word; var ABuffer; ASize: Word; ARegExp: PRegExp);
       destructor Destroy; virtual;
       procedure Display( AStream: PStream); virtual;
       function GetExpresion: PRegExp;
       function GetSize: Word;
       function GetBuffer: Pointer;
       function GetData( var ABuffer; ABufferSize: Word): Word;
       end;

    PExpresionDef = ^TExpresionDef;
    TExpresionDef = object( TGeneric)
    private
        Name: PString;
        Expresion: PRegExp;
    public
        constructor Create( AName: string; AExp: PRegExp);
        destructor Destroy; virtual;
        function GetExpresion: PRegExp;
        function GetName: string;
        procedure Display( AStream: PStream); virtual;
        end;

    PLexDatabase = ^TLexDatabase;

    POutputGenerator = ^TOutputGenerator;
    TOutputGenerator = object(TErrGeneric)
    private
       DataBase: PLexDatabase;
       Skeleton: PStream;
       Target: PStream;
       function ScanToNextCommand( var AEndOfSkeleton: Boolean): string;
       procedure GenerateAbstractOutput;
       procedure GenerateFromSkeleton;
    public
       constructor Create( AOwner: PErrGeneric; ADataBase: PLexDatabase; ASkeleton: PStream; ATarget: PStream);
       destructor Destroy; virtual;
       procedure GenerateOutput;
       end;

    TLexDatabase = object( TErrGeneric)
    private
        SymbolSets: TContainerCollection; { Collection of ~TSymbolSet~ }
        Exepresions: TContainerCollection; { Collection of ~TRegExp~ }
        Defines: TContainerCollection; { Collection of ~TExpresionDef~ }
        Procedures: TContainerCollection; { Collection of ~TLexProcedure~ }
        Automate: TAutomate;
        Table: TLexAutoTable;
     public
        constructor Create( AOwner: PErrGeneric);
        destructor Destroy; virtual;
        procedure AddDefine( AName: string; AExpresion: PRegExp);
        procedure AddExprestion( AExpresion: PRegExp);
        procedure AddProcedure( var ABuffer; ASize: Word; AExpresion: PRegExp);
        function GetExpresion( AName: string): PRegExp;
        function CreateSet( ACharsSet: TCharsSet): PSymbolSet;
        procedure SeparateSymbolSets;
        procedure BuildAuto;
        procedure Display( AStream: PStream); virtual;
        end;


implementation

{******************************************************************}
{*                                                                *}
{******************************************************************}

const comNONE            = 0;
      comCORRECTSET      = 1;

type PCorrectSetInfo = ^TCorrectSetInfo;
     TCorrectSetInfo = record
         OriginalSet,
         SubSet1,
         SubSet2: PSymbolSet;
         end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TAutoInSymbol.Create;
begin
     inherited Create;
     Identifier := 0;
end;

destructor TAutoInSymbol.Destroy;
begin
     inherited Destroy;
end;

procedure TAutoInSymbol.SetID( AIndentifier: Word);
begin
     Identifier := AIndentifier;
end;

function TAutoInSymbol.GetID: Word;
begin
     GetID := Identifier;
end;

procedure TAutoInSymbol.Display( AStream: PStream);
begin
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TFinalStateInfo.Create( APriority: Word);
begin
     inherited Create;
     Priority := APriority;
end;

destructor TFinalStateInfo.Destroy;
begin
     inherited Destroy;
end;

function TFinalStateInfo.GetPriority: Word;
begin
     GetPriority := Priority;
end;

procedure TFinalStateInfo.SetPriority( APriority: Word);
begin
     Priority := Priority;
end;

procedure TFinalStateInfo.Display( AStream: PStream);
begin
     AStream^.WriteStr( '(');
     AStream^.WriteInt( Priority);
     AStream^.WriteStr( ')');
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TAutomateState.Create( AIdentifier: Word; AFinalStateInfo: PFinalStateInfo);
begin
     inherited Create;
     Transitions.Create;
     Identifier := AIdentifier;
     FinalStateInfo := AFinalStateInfo;
end;

destructor TAutomateState.Destroy;
begin
     Transitions.Destroy;
     inherited Destroy;
end;

procedure TAutomateState.Display( AStream: PStream);
var ScanTransition: PTransition;
begin
     AStream^.NewLine;

     if IsFinalState
     then begin
          AStream^.WriteStr( 'STATE.');
          AStream^.WriteInt( Identifier);
          AStream^.WriteStr( ' * ');
          GetFinalStateInfo^.Display( AStream);
          AStream^.NewLine;
          end
     else begin
          AStream^.WriteStr( 'STATE.');
          AStream^.WriteInt( Identifier);
          AStream^.NewLine;
          end;

     ScanTransition := PTransition( Transitions.GetFirst);
     while (ScanTransition <> nil)
     do begin
        AStream^.WriteStr( '   --');
        if (ScanTransition^.GetSymbol <> nil)
        then ScanTransition^.GetSymbol^.Display( AStream)
        else AStream^.WriteStr( '-----');
        AStream^.WriteStr( '-->');
        if (ScanTransition^.GetToState <> nil)
        then AStream^.WriteInt( ScanTransition^.GetToState^.GetID);
        AStream^.NewLine;
        ScanTransition := PTransition( Transitions.GetNext);
        end;
end;

function TAutomateState.IsFinalState: Boolean;
begin
     IsFinalState := (FinalStateInfo <> nil);
end;

function TAutomateState.GetFinalStateInfo: PFinalStateInfo;
begin
     GetFinalStateInfo := FinalStateInfo;
end;

procedure TAutomateState.SetFinalStateInfo(AInfo: PFinalStateInfo);
begin
  FinalStateInfo:=AInfo;
end;

procedure TAutomateState.AddTransition( ASymbol: PAutoInSymbol; ANextState: PAutomateState);
var ScanTransition: PTransition;
begin
     if (ANextState <> nil)
     then begin
          ScanTransition := PTransition(Transitions.GetFirst);
          while (ScanTransition <>  nil)
          do begin
             if ScanTransition^.IsEqual( ASymbol, ANextState)
             then Break;
             ScanTransition := PTransition(Transitions.GetNext);
             end;
          if (ScanTransition = nil)
          then Transitions.PushLast( New(PTransition, Create(ASymbol, ANextState)));
          end;
end;

function TAutomateState.GetFirstTransition: PTransition;
begin
     GetFirstTransition := PTransition( Transitions.GetFirst);
end;

function TAutomateState.GetNextTransition: PTransition;
begin
     GetNextTransition := PTransition( Transitions.GetNext);
end;

procedure TAutomateState.SetID( AIdentifier: Word);
begin
     Identifier := AIdentifier;
end;

function TAutomateState.GetID: Word;
begin
     GetID := Identifier;
end;

function TAutomateState.IsHasSameTransitionsSymbols( AState: PAutomateState): Boolean;
var ScanTransition1,
    ScanTransition2: PTransition;
    FoundSame: Boolean;
    Symbol1: PAutoInSymbol;
begin
     if (AState <> nil)
     then begin
          IsHasSameTransitionsSymbols := True;
          ScanTransition1 := PTransition( Transitions.GetFirst);
          while (ScanTransition1 <> nil)
          do begin
             Symbol1 := ScanTransition1^.GetSymbol;
             ScanTransition2 := PTransition( AState^.Transitions.GetFirst);
             while (ScanTransition2 <> nil)
             do begin
                if ( Symbol1 = ScanTransition2^.GetSymbol)
                then Break;
                ScanTransition2 := PTransition( AState^.Transitions.GetNext);
                end;
             if (ScanTransition2 = nil)
             then begin
                  IsHasSameTransitionsSymbols := False;
                  Break;
                  end;
             ScanTransition1 := PTransition( Transitions.GetNext);
             end;
          end
     else IsHasSameTransitionsSymbols := False;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TTransition.Create( ASymbol: PAutoInSymbol; ANextState: PAutomateState);
begin
     inherited Create;
     Symbol := ASymbol;
     NextState := ANextState;
end;

destructor TTransition.Destroy;
begin
     inherited Destroy;
end;

function TTransition.GetSymbol: PAutoInSymbol;
begin
     GetSymbol := Symbol;
end;

function TTransition.GetToState: PAutomateState;
begin
     GetToState := NextState;
end;

function TTransition.IsEqual( ASymbol: PAutoInSymbol; ANextState: PAutomateState): Boolean;
begin
     IsEqual := ((ASymbol = Symbol) and (ANextState = NextState));
end;

function TTransition.IsSameAs( ATransition: PTransition): Boolean;
begin
     if (ATransition <> nil)
     then IsSameAs := (( ATransition^.Symbol = Symbol) and ( ATransition^.NextState = NextState))
     else IsSameAs := False;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TComplextAutoState.Create( AIdentifier: Word; ASimpleAutoStates: PCollection);
begin
     inherited Create( AIdentifier, nil);
     SimpleItems.Create;
     MyImage := nil;
     if (ASimpleAutoStates <> nil)
     then SimpleItems.PushCollectionLast( ASimpleAutoStates);
end;

destructor TComplextAutoState.Destroy;
begin
     SimpleItems.Destroy;
     if (MyImage <> nil)
     then MyImage^.Free;
     inherited Destroy;
end;

procedure TComplextAutoState.AddAutomateState( AState: PAutomateState);
begin
     if (AState <> nil)
     then if not SimpleItems.IsMember( AState)
          then SimpleItems.PushLast( AState);
end;

function TComplextAutoState.IsEqual( AStates: PCollection): Boolean;
begin
     if (AStates <> nil)
     then IsEqual := SimpleItems.IsSameAs( AStates)
     else IsEqual := False;
end;

function TComplextAutoState.IsFinalState: Boolean;
var ScanNFAItem: PAutomateState;
begin
     IsFinalState := False;
     ScanNFAItem := PAutomateState( SimpleItems.GetFirst);
     while (ScanNFAItem <> nil)
     do if ScanNFAItem^.IsFinalState
        then begin
             IsFinalState := True;
             Break;
             end
        else ScanNFAItem := PAutomateState( SimpleItems.GetNext);
end;

function TComplextAutoState.GetFinalStateInfo: PFinalStateInfo;
var ScanNFAItem: PAutomateState;
    ResultInfo: PFinalStateInfo;
    TempResultInfo: PFinalStateInfo;
begin
     ResultInfo := nil;
     ScanNFAItem := PAutomateState( SimpleItems.GetFirst);
     while (ScanNFAItem <> nil)
     do begin
        TempResultInfo := ScanNFAItem^.GetFinalStateInfo;
        if (TempResultInfo <> nil)
        then begin
             if (ResultInfo = nil)
             then ResultInfo := TempResultInfo
             else if (TempResultInfo^.GetPriority < ResultInfo^.GetPriority)
                  then ResultInfo := TempResultInfo;
             end;
        ScanNFAItem := PAutomateState( SimpleItems.GetNext);
        end;
     GetFinalStateInfo := ResultInfo;
end;

function TComplextAutoState.GetFirstSimpleState: PAutomateState;
begin
     GetFirstSimpleState := PAutomateState(SimpleItems.GetFirst);
end;

function TComplextAutoState.GetNextSimpleState: PAutomateState;
begin
     GetNextSimpleState := PAutomateState(SimpleItems.GetNext);
end;

procedure TComplextAutoState.GetTransitionSymbols( var ASymbols: TCollection);
var ScanTransition: PTransition;
    TransitionSymbol: PAutoInSymbol;
    ScanSimpleState: PAutomateState;
begin
     ASymbols.Clear;
     ScanSimpleState := PAutomateState( SimpleItems.GetFirst);
     while (ScanSimpleState <> nil)
     do begin
        ScanTransition := ScanSimpleState^.GetFirstTransition;
        while (ScanTransition <> nil)
        do begin
           TransitionSymbol := ScanTransition^.GetSymbol;
           if not ASymbols.IsMember( TransitionSymbol)
           then ASymbols.PushLast( TransitionSymbol);
           ScanTransition := ScanSimpleState^.GetNextTransition;
           end;
        ScanSimpleState := PAutomateState( SimpleItems.GetNext);
        end;
end;

procedure TComplextAutoState.CreateYourImage;
begin
     if (MyImage <> nil)
     then MyImage^.Free;
     MyImage := New( PAutomateState, Create(Identifier, GetFinalStateInfo));
end;

procedure TComplextAutoState.ConnectYourImage;
var ScanTransition: PTransition;
    ReflTransition: PTransition;
    TransitionState: PComplextAutoState;
    TransitionSymbol: PAutoInSymbol;
begin
     ScanTransition := GetFirstTransition;
     while (ScanTransition <> nil)
     do begin
        TransitionState := PComplextAutoState( ScanTransition^.GetToState);
        TransitionSymbol := ScanTransition^.GetSymbol;
        if (( TransitionState <> nil) and ( TransitionSymbol <> nil))
        then if (TransitionState^.MyImage <> nil)
             then MyImage^.AddTransition( TransitionSymbol, TransitionState^.MyImage);
        ScanTransition := GetNextTransition;
        end;
end;

function TComplextAutoState.LeaveYourImage: PAutomateState;
begin
     LeaveYourImage := MyImage;
     MyImage := nil;
end;

function TComplextAutoState.GetYourImage: PAutomateState;
begin
     GetYourImage := MyImage;
end;

function TComplextAutoState.GetStrangeStates( var AStates: TCollection): Boolean;
var SimpleState: PAutomateState;
    ScanSimpleState: PAutomateState;
    ScanTransition1: PTransition;
    ScanTransition2: PTransition;
    StayedStates: Word;
    StatesCount: Word;
    States2: TCollection;
    OutSideTransitions: TCollection;
begin
     AStates.Clear;
     GetStrangeStates := False;
     StatesCount := SimpleItems.GetItemsCount;
     StayedStates := StatesCount;

     if (StatesCount <= 1)
     then Exit;

     OutSideTransitions.Create;

     ScanSimpleState := PAutomateState( SimpleItems.GetFirst);
     ScanTransition1 := ScanSimpleState^.GetFirstTransition;
     while (ScanTransition1 <> nil)
     do begin
        if not SimpleItems.IsMember( ScanTransition1^.GetToState)
        then OutSideTransitions.PushLast( ScanTransition1);
        ScanTransition1 := ScanSimpleState^.GetNextTransition;
        end;

     ScanSimpleState := PAutomateState( SimpleItems.GetAfter( ScanSimpleState));
     while ( ScanSimpleState <> nil)
     do begin
        ScanTransition1 := PTransition( OutSideTransitions.GetFirst);
        while ( ScanTransition1 <> nil)
        do begin
           ScanTransition2 := ScanSimpleState^.GetFirstTransition;
           while ( ScanTransition2 <> nil)
           do begin
              if ScanTransition2^.IsSameAs( ScanTransition1)
              then Break;
              ScanTransition2 := ScanSimpleState^.GetNextTransition;
              end;
           if ( ScanTransition2 = nil)
           then Break;
           ScanTransition1 := PTransition( OutSideTransitions.GetNext);
           end;

        if ( ScanTransition1 = nil)
        then begin
             ScanTransition1 := ScanSimpleState^.GetFirstTransition;
             while (ScanTransition1 <> nil)
             do begin
                if not SimpleItems.IsMember( ScanTransition1^.GetToState)
                then begin
                     ScanTransition2 := PTransition( OutSideTransitions.GetFirst);
                     while (ScanTransition2 <> nil)
                     do begin
                        if ScanTransition1^.IsSameAs( ScanTransition2)
                        then Break;
                        ScanTransition2 := PTransition( OutSideTransitions.GetNext);
                        end;
                     if (ScanTransition2 = nil)
                     then Break;
                     end;
                ScanTransition1 := ScanSimpleState^.GetNextTransition;
                end;
             end;
        if (ScanTransition1 <> nil)
        then begin
             AStates.PushLast( ScanSimpleState);
             StayedStates := StayedStates - 1;
             end;
        ScanSimpleState := PAutomateState( SimpleItems.GetAfter( ScanSimpleState));
        end;
     OutSideTransitions.Destroy;

     RemoveStates( @AStates);

     if (StayedStates > 1)
     then begin
          States2.Create;
          SimpleState := PAutomateState( SimpleItems.GetFirst);
          if (SimpleState <> nil)
          then begin
               ScanSimpleState := PAutomateState( SimpleItems.GetNext);
               while (ScanSimpleState  <> nil)
               do begin
                  if not SimpleState^.IsHasSameTransitionsSymbols( ScanSimpleState)
                  then begin
                       States2.PushLast( ScanSimpleState);
                       StayedStates := StayedStates - 1;
                       end;
                  ScanSimpleState := PAutomateState( SimpleItems.GetNext);
                  end;
               end;
          RemoveStates( @States2);
          AStates.PushCollectionLast( @States2);
          States2.Destroy;
          end;

     GetStrangeStates := StayedStates < StatesCount;
end;

procedure TComplextAutoState.RemoveStates( AStates: PCollection);
var ScanSimpleState: PAutomateState;
begin
     if ( AStates <> nil)
     then begin
          ScanSimpleState := PAutomateState( AStates^.GetFirst);
          while (ScanSimpleState <> nil)
          do begin
             SimpleItems.RemoveFromCollection( ScanSimpleState);
             ScanSimpleState := PAutomateState( AStates^.GetNext);
             end;
          end;
end;

function TComplextAutoState.IsMemberState( AState: PAutomateState): Boolean;
begin
     if (AState <> nil)
     then IsMemberState := SimpleItems.IsMember( AState)
     else IsMemberState := False;
end;

procedure TComplextAutoState.Display( AStream: PStream);
var ScanState: PAutomateState;
begin
     AStream^.WriteStr( '[ ');
     ScanState := PAutomateState( SimpleItems.GetFirst);
     while ( ScanState <> nil)
     do begin
        AStream^.WriteInt( ScanState^.GetID);
        AStream^.WriteStr( ' ');
        ScanState := PAutomateState( SimpleItems.GetNext);
        end;
     AStream^.WriteStr( '] ');
     AStream^.NewLine;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TSymbolSet.Create( ACharsSet: TCharsSet);
begin
     inherited Create;
     CharsSet := ACharsSet;
end;

destructor TSymbolSet.Destroy;
begin
     inherited Destroy;
end;

procedure TSymbolSet.Display( AStream: PStream);
var C1, C2, C3: Char;
begin
     AStream^.WriteStr( '[');
     C1 := #0;
     repeat
        if (C1 in CharsSet)
        then begin
             AStream^.WriteStr( '''');
             AStream^.WriteStr( C1);
             AStream^.WriteStr( '''');
             C2 := C1;
             C3 := C1;
             while ((C2 <= #254) and (C2 in CharsSet))
             do begin
                C3 := C2;
                C2 := Succ(C2);
                end;
             if (C3 <> C1)
             then begin
                  C1 := C3;
                  AStream^.WriteStr( '..''');
                  AStream^.WriteStr( C3);
                  AStream^.WriteStr( '''');
                  end;
             end;
        C1 := Succ(C1);
     until (C1 = #255);

     AStream^.WriteStr( ']');
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TRegExp.Create( AParent: PRegExp);
begin
     inherited Create;
     Parent := AParent;
end;

procedure TRegExp.SetParent( AParent: PRegExp);
begin
     Parent := AParent;
end;

destructor TRegExp.Destroy;
begin
     inherited Destroy;
end;

procedure TRegExp.ProduceAuto(AAutomate:PAutomate;var AStart,AEnd:PAutomatestate);
begin
     AStart := nil;
     AEnd := nil;
end;

function TRegExp.Message( ACommand: Word; AInfo: Pointer): Boolean;
begin
     Message := False;
end;

function TRegExp.ReplaceChildRequest( AOldChild, ANewChild: PRegExp): Boolean;
begin
     ReplaceChildRequest := False;
end;

function TRegExp.ReplaceSelf( ANewChild: PRegExp): Boolean;
begin
     if (Parent <> nil)
     then ReplaceSelf := Parent^.ReplaceChildRequest( @Self, ANewChild)
     else ReplaceSelf := False;
end;

function TRegExp.Clone: PRegExp;
var SelfClone: PRegExp;
begin
     SelfClone := New( PRegExp, Create( nil));
     Clone := SelfClone;
end;

procedure TRegExp.Display( AStream: PStream);
begin
     AStream^.WriteStr( 'Abstract RegExp');
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TBuffExp.Create( AParent: PRegExp; AChild: PRegExp);
begin
     inherited Create( AParent);
     Child := AChild;
     if (Child <> nil)
     then Child^.SetParent( @Self);
end;

destructor TBuffExp.Destroy;
begin
     if (Child <> nil)
     then Child^.Free;
     inherited Destroy;
end;

procedure TBuffExp.ProduceAuto( AAutomate:PAutomate; var AStart,AEnd:PAutomatestate);
begin
     if (Child <> nil)
     then Child^.ProduceAuto( AAutomate, AStart, AEnd)
     else begin
          AStart := nil;
          AEnd := nil;
          end;
end;

function TBuffExp.Message( ACommand: Word; AInfo: Pointer): Boolean;
begin
     if (Child <> nil)
     then Message := Child^.Message( ACommand, AInfo)
     else Message := False;
end;

function TBuffExp.ReplaceChildRequest( AOldChild, ANewChild: PRegExp): Boolean;
begin
     ReplaceChildRequest := False;

     if (ANewChild <> nil)
     then if (AOldChild = Child)
          then begin
               Child := ANewChild;
               ReplaceChildRequest := True;
               end;
end;

function TBuffExp.Clone: PRegExp;
var ChildClone: PRegExp;
    SelfClone: PBuffExp;
begin
     if (Child <> nil)
     then ChildClone := Child^.Clone
     else ChildClone := nil;

     SelfClone := New(PBuffExp, Create( nil, ChildClone));
     Clone := SelfClone;
end;

procedure TBuffExp.Display( AStream: PStream);
begin
     if (Child <> nil)
     then Child^.Display( AStream);
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TSymbolExp.Create( AParent: PRegExp; ASymbols: PSymbolSet);
begin
     inherited Create( AParent);
     Symbols := ASymbols;
end;

destructor TSymbolExp.Destroy;
begin
     inherited Destroy;
end;

procedure TSymbolExp.ProduceAuto( AAutomate: PAutomate; var AStart, AEnd: PAutoMateState);
begin
     AAutomate^.AddSymbol( Symbols);
     AStart := New( PAutomateState, Create( 0, nil));
     AAutomate^.AddState( AStart);
     AEnd := New( PAutomateState, Create( 0, nil));
     AAutomate^.AddState( AEnd);
     AStart^.AddTransition( Symbols, AEnd);
end;

function TSymbolExp.Message( ACommand: Word; AInfo: Pointer): Boolean;
var SymExp1, SymExp2: PSymbolExp;
    OrExp: POrExp;
begin
     if (ACommand = comCORRECTSET)
     then begin
          if (AInfo <> nil)
          then begin
               if (PCorrectSetInfo(AInfo)^.OriginalSet = Symbols)
               then begin
                    if ((PCorrectSetInfo(AInfo)^.SubSet1 <> nil) and (PCorrectSetInfo(AInfo)^.SubSet2 <> nil))
                    then begin
                         SymExp1 := New( PSymbolExp, Create(nil, PCorrectSetInfo(AInfo)^.SubSet1));
                         SymExp2 := New( PSymbolExp, Create(nil, PCorrectSetInfo(AInfo)^.SubSet2));
                         OrExp := New( POrExp, Create( nil, SymExp1, SymExp2));
                         if ReplaceSelf( OrExp)
                         then Free;
                         end
                    else if ((PCorrectSetInfo(AInfo)^.SubSet1 <> nil) and (PCorrectSetInfo(AInfo)^.SubSet2 = nil))
                    then Symbols := PCorrectSetInfo(AInfo)^.SubSet1
                    else if ((PCorrectSetInfo(AInfo)^.SubSet1 = nil) and (PCorrectSetInfo(AInfo)^.SubSet2 <> nil))
                    then Symbols := PCorrectSetInfo(AInfo)^.SubSet2;
                    end;
               end;
          Message := True;
          end
     else Message := True;
end;

function TSymbolExp.Clone: PRegExp;
var SelfClone: PSymbolExp;
begin
     SelfClone := New(PSymbolExp, Create( nil, Symbols));
     Clone := SelfClone;
end;

procedure TSymbolExp.Display( AStream: PStream);
begin
     if (Symbols <> nil)
     then Symbols^.Display( AStream);
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TConcatExp.Create(AParent: PRegExp; R1, R2: PRegExp);
begin
  inherited Create( AParent);
  RegExp1 := R1;
  RegExp2 := R2;

  if (RegExp1 <> nil)
  then RegExp1^.SetParent( @Self);

  if (RegExp2 <> nil)
  then RegExp2^.SetParent( @Self);
end;

destructor TConcatExp.Destroy;
begin
   if (Regexp1 <> nil) then RegExp1^.Free;
   if (Regexp2 <> nil) then RegExp2^.Free;
   inherited Destroy;
end;

function TConcatExp.Message( ACommand: Word; AInfo: Pointer): Boolean;
var Result1, Result2: Boolean;
begin
     if (RegExp1 <> nil)
     then Result1 := RegExp1^.Message( ACommand, AInfo)
     else Result1 := False;

     if (RegExp2 <> nil)
     then Result2 := RegExp2^.Message( ACommand, AInfo)
     else Result2 := False;

     Message := (Result1 or Result2);
end;

procedure TConcatExp.ProduceAuto( AAutomate: PAutomate; var AStart, AEnd: PAutomatestate);
var EndSub1, StartSub2: PAutomatestate;
begin
     if ((RegExp1 <> nil) and (RegExp2 <> nil))
     then begin
          AStart := nil;
          EndSub1 := nil;
          StartSub2 := nil;
          AEnd := nil;
          RegExp1^.ProduceAuto( AAutomate, AStart, EndSub1);
          RegExp2^.ProduceAuto( AAutomate, StartSub2, AEnd);

          if ((EndSub1 <> nil) and (StartSub2 <> nil))
          then EndSub1^.AddTransition( nil, StartSub2);
          end
     else begin
          AStart := New( PAutomateState, Create( 0, nil));
          AAutomate^.AddState( AStart);
          AEnd := New( PAutomateState, Create( 0, nil));
          AAutomate^.AddState( AEnd);
          AStart^.AddTransition( nil, AEnd);
          end;
end;

function TConcatExp.ReplaceChildRequest( AOldChild, ANewChild: PRegExp): Boolean;
begin
     ReplaceChildRequest := False;

     if (ANewChild <> nil)
     then begin
          if (AOldChild = RegExp1)
          then begin
               RegExp1 := ANewChild;
               ReplaceChildRequest := True;
               end
          else if (AOldChild = RegExp2)
          then begin
               RegExp2 := ANewChild;
               ReplaceChildRequest := True;
               end;
          end;
end;

function TConcatExp.Clone: PRegExp;
var Sub1Clone,
    Sub2Clone: PRegExp;
    SelfClone: PConcatExp;
begin
     if (RegExp1 <> nil)
     then Sub1Clone := RegExp1^.Clone
     else Sub1Clone := nil;

     if (RegExp2 <> nil)
     then Sub2Clone := RegExp2^.Clone
     else Sub2Clone := nil;

     SelfClone := New(PConcatExp, Create( nil, Sub1Clone, Sub2Clone));
     Clone := SelfClone;
end;

procedure TConcatExp.Display( AStream: PStream);
begin
     if (RegExp1 <> nil)
     then RegExp1^.Display( AStream);
     AStream^.WriteStr( ' ');
     if (RegExp2 <> nil)
     then RegExp2^.Display( AStream);
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

procedure TOrExp.ProduceAuto( AAutomate: PAutomate; var AStart, AEnd: PAutomatestate);
var SubStart1, SubEnd1, SubStart2, SubEnd2:PAutomatestate;
begin
     AStart := New( PAutomateState, Create( 0, nil));
     AAutomate^.AddState( AStart);
     AEnd := New( PAutomateState, Create( 0, nil));
     AAutoMate^.AddState( AEnd);

     SubStart1 := nil;
     SubEnd1 := nil;
     if (RegExp1 <> nil)
     then RegExp1^.ProduceAuto( AAutomate, SubStart1, SubEnd1);

     SubStart2 := nil;
     SubEnd2 := nil;
     if (RegExp2 <> nil)
     then RegExp2^.ProduceAuto( AAutomate, SubStart2, SubEnd2);

     if (SubStart1 <> nil)
     then AStart^.AddTransition( nil, SubStart1);

     if (SubStart2 <> nil)
     then AStart^.AddTransition( nil, SubStart2);

     if (SubEnd1 <> nil)
     then SubEnd1^.AddTransition( nil, AEnd);

     if (SubEnd2 <> nil)
     then SubEnd2^.AddTransition( nil, AEnd);
end;

function TOrExp.Clone: PRegExp;
var Sub1Clone,
    Sub2Clone: PRegExp;
    SelfClone: POrExp;
begin
     if (RegExp1 <> nil)
     then Sub1Clone := RegExp1^.Clone
     else Sub1Clone := nil;

     if (RegExp2 <> nil)
     then Sub2Clone := RegExp2^.Clone
     else Sub2Clone := nil;

     SelfClone := New( POrExp, Create( nil, Sub1Clone, Sub2Clone));
     Clone := SelfClone;
end;

procedure TOrExp.Display( AStream: PStream);
begin
     AStream^.WriteStr( '(');
     if (RegExp1 <> nil)
     then RegExp1^.Display( AStream);
     AStream^.WriteStr( ')|(');
     if (RegExp2 <> nil)
     then RegExp2^.Display( AStream);
     AStream^.WriteStr( ')');
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TStarExp.Create( AParent: PRegExp; R:PRegExp);
begin
  inherited Create( Aparent);
  RegExp := R;

  if (RegExp <> nil)
  then RegExp^.SetParent( @Self);
end;

destructor TStarExp.Destroy;
begin
   if Regexp<>nil then RegExp^.Free;
   inherited Destroy;
end;

procedure TStarExp.ProduceAuto( AAutomate: PAutomate; var AStart, AEnd: PAutomatestate);
begin
     AStart := nil;
     AEnd := nil;
     if (RegExp <> nil)
     then begin
          RegExp^.ProduceAuto( AAutomate, AStart, AEnd);
          if ((AStart <> nil) and (AEnd <> nil))
          then begin
               AStart^.AddTransition( nil, AEnd);
               AEnd^.AddTransition( nil, AStart);
               end;
          end;
end;

function TStarExp.Message( ACommand: Word; AInfo: Pointer): Boolean;
begin
     if (RegExp <> nil)
     then Message := RegExp^.Message( ACommand, AInfo)
     else Message := False;
end;

function TStarExp.ReplaceChildRequest( AOldChild, ANewChild: PRegExp): Boolean;
begin
     ReplaceChildRequest := False;

     if (ANewChild <> nil)
     then if (AOldChild = RegExp)
          then begin
               RegExp := ANewChild;
               ReplaceChildRequest := True;
               end;
end;

function TStarExp.Clone: PRegExp;
var SubClone: PRegExp;
    SelfClone: PStarExp;
begin
     if (RegExp <> nil)
     then SubClone := RegExp^.Clone
     else SubClone := nil;

     SelfClone := New( PStarExp, Create( nil, SubClone));
     Clone := SelfClone;
end;

procedure TStarExp.Display( AStream: PStream);
begin
     AStream^.WriteStr( '(');
     if (RegExp <> nil)
     then RegExp^.Display( AStream);
     AStream^.WriteStr( ')*');
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

procedure TPlusExp.ProduceAuto(AAutomate:PAutomate;var AStart,AEnd:PAutomatestate);
begin
     AStart := nil;
     AEnd := nil;
     if (RegExp <> nil)
     then begin
          RegExp^.ProduceAuto( AAutomate, AStart, AEnd);
          if ((AStart <> nil) and (AEnd <> nil))
          then AEnd^.AddTransition( nil, AStart);
          end;
end;

function TPlusExp.Clone: PRegExp;
var SubClone: PRegExp;
    SelfClone: PPlusExp;
begin
     if (RegExp <> nil)
     then SubClone := RegExp^.Clone
     else SubClone := nil;

     SelfClone := New( PPlusExp, Create( nil, SubClone));
     Clone := SelfClone;
end;

procedure TPlusExp.Display( AStream: PStream);
begin
     AStream^.WriteStr( '(');
     if (RegExp <> nil)
     then RegExp^.Display( AStream);
     AStream^.WriteStr( ')+');
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

procedure TQMarkExp.ProduceAuto( AAutomate: PAutomate; var AStart, AEnd:PAutomatestate);
begin
     AStart := nil;
     AEnd := nil;
     if (RegExp <> nil)
     then begin
          RegExp^.ProduceAuto( AAutomate, AStart, AEnd);
          if (AStart <> nil) and ( AEnd <> nil)
          then AStart^.AddTransition(nil, AEnd);
          end;
end;

function TQMarkExp.Clone: PRegExp;
var SubClone: PRegExp;
    SelfClone: PQMarkExp;
begin
     if (RegExp <> nil)
     then SubClone := RegExp^.Clone
     else SubClone := nil;

     SelfClone := New( PQMarkExp, Create( nil, SubClone));
     Clone := SelfClone;
end;

procedure TQMarkExp.Display( AStream: PStream);
begin
     AStream^.WriteStr( '(');
     if (RegExp <> nil)
     then RegExp^.Display( AStream);
     AStream^.WriteStr( ')?');
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TAutomate.Create;
begin
     inherited Create;
     Alphabet.Create;
     States.Create;
     Symbols.Create;
     FinalStatesInfo.Create;
     StartState := nil;
end;

destructor TAutomate.Destroy;
begin
     Alphabet.Destroy;
     States.Destroy;
     Symbols.Destroy;
     FinalStatesInfo.Destroy;
     inherited Destroy;
end;

procedure TAutomate.AddState( AState: PAutomateState);
var FinalStateInfo: PFinalStateInfo;
begin
     if (AState <> nil)
     then States.PushLast( AState);
end;

procedure TAutomate.Clear;
begin
     StartState := nil;
     Alphabet.Clear;
     States.Clear;
     Symbols.Clear;
     FinalStatesInfo.Clear;
end;

procedure TAutomate.EnumStates;
var ID: Word;
    ScanState: PAutomateState;
begin
     ID := 1;

     if (StartState <> nil)
     then StartState^.SetID(ID);

     ScanState := PAutomateState( States.GetFirst);
     while ( ScanState <> nil)
     do begin
        if ( ScanState <> StartState)
        then begin
             ID := ID + 1;
             ScanState^.SetID( ID);
             end;
        ScanState := PAutomateState( States.GetNext);
        end;
end;

procedure TAutomate.EnumAlphabet;
var ScanInSymbol: PAutoInSymbol;
    ScanAutoState: PAutomateState;
    ScanTransition: PTransition;
    Id: Word;
begin
     Alphabet.Clear;
     Id := 0;
     ScanAutoState := GetFirstState;
     while ( ScanAutoState <> nil)
     do begin
        ScanTransition := ScanAutoState^.GetFirstTransition;
        while ( ScanTransition <> nil)
        do begin
           ScanInSymbol := ScanTransition^.GetSymbol;
           if ( ScanInSymbol <> nil)
           then begin
                if not Alphabet.IsMember( ScanInSymbol)
                then begin
                     Id := Id + 1;
                     ScanInSymbol^.SetID(Id);
                     Alphabet.PushLast( ScanInSymbol);
                     end;
                end;
           ScanTransition := ScanAutoState^.GetNextTransition;
           end;
        ScanAutoState := GetNextState;
        end;
end;

function TAutomate.GetStatesCount: Word;
begin
     GetStatesCount := States.GetItemsCount;
end;

function TAutomate.GetAlphabetSize: Word;
begin
     GetAlphabetSize := Alphabet.GetItemsCount;
end;

function TAutomate.GetStartState: PAutomateState;
begin
     if (StartState = nil)
     then begin
          StartState := New( PAutomateState, Create(0,nil));
          AddState(StartState);
          end;
     GetStartState := StartState
end;

function TAutomate.GetFirstState: PAutomateState;
begin
     GetFirstState := PAutomateState(States.GetFirst);
end;

function TAutomate.GetNextState: PAutomateState;
begin
     GetNextState := PAutomateState(States.GetNext);
end;

function TAutomate.GetFirstSymbol: PAutoInSymbol;
begin
     GetFirstSymbol := PAutoInSymbol( Alphabet.GetFirst);
end;

function TAutomate.GetNextSymbol: PAutoInSymbol;
begin
     GetNextSymbol := PAutoInSymbol( Alphabet.GetNext);
end;

procedure TAutomate.AddSymbol( ASymbol: PAutoInSymbol);
var NewId: Integer;
begin
     if (ASymbol <> nil)
     then if not Symbols.IsMember( ASymbol)
          then begin
               NewId := Symbols.GetItemscount + 1;
               ASymbol^.SetID( NewId);
               Symbols.PushLast( ASymbol);
               end;
end;

procedure TAutomate.AddMainExp( AExp: PRegExp; AFinalStateInfo: PFinalStateInfo);
var S1, S2: PAutomateState;
    F: PFinalStateInfo;
    AutoStartState: PAutomateState;
Begin
     if (AFinalStateInfo <> nil)
     then if not FinalStatesInfo.IsMember( AFinalStateInfo)
          then FinalStatesInfo.PushLast( AFinalStateInfo);

     if (AExp <> nil)
     then begin
          AutoStartState := GetStartState;
          if (AutoStartState <> nil)
          then begin
               S1 := AutoStartState;
               S2 := nil;
               AExp^.ProduceAuto( @Self, S1, S2);
               if (AutoStartState <> S1)
               then AutoStartState^.AddTransition( nil, S1);
               if S2 <> nil
               then S2^.SetFinalStateInfo( AFinalStateInfo);
               end;
          end;
end;

procedure TAutomate.Display( AStream: PStream);
var ScanState: PAutomateState;
begin
     AStream^.WriteStr( 'Start state :');
     AStream^.WriteInt( GetStartState^.GetId);
     ScanState := PAutomateState( States.GetFirst);
     while ( ScanState <> nil)
     do begin
        ScanState^.Display( AStream);
        ScanState := PAutomateState( States.GetNext);
        end;
end;

procedure TAutomate.ConvertToDFA;
var DFAStates: TContainerCollection;
    DFAStart: PComplextAutoState;
    Id: Integer;

    function AddStateToSet( AState: PAutomateState; var AClosure: TCollection): Boolean;
    begin
         AddStateToSet := False;
         if (AState <> nil)
         then if not AClosure.IsMember(AState)
              then begin
                   AClosure.PushLast( AState);
                   AddStateToSet := True;
                   end;
    end;

    procedure GetShiftsForState( AState: PAutomateState; ASymbol: PAutoInSymbol; var AClosure: TCollection;
                                AReset: Boolean);
        procedure FindShiftToStates( AState: PAutomateState; ASymbol: PAutoInSymbol);
        var ScanTransition: PTransition;
            StateToAdd: PAutomateState;
        begin
             if (AState <> nil)
             then begin
                  ScanTransition := AState^.GetFirstTransition;
                  while (ScanTransition <> nil)
                  do begin
                     if (ScanTransition^.GetSymbol = ASymbol)
                     then begin
                          StateToAdd := ScanTransition^.GetToState;
                          if AddStateToSet( StateToAdd, AClosure)
                          then FindShiftToStates( StateToAdd, nil);
                          end;
                     ScanTransition := AState^.GetNextTransition;
                     end;
                  end;
        end;
    begin
         if AReset
         then AClosure.Clear;
         if (ASymbol = nil)
         then AddStateToSet( AState, AClosure);
         FindShiftToStates( AState, ASymbol);
    end;

    procedure GetShiftsForComplexState( ASymbol: PAutoInSymbol; AComplexState: PComplextAutoState; var AClosure: TCollection;
                                        AReset: Boolean);
    var ScanState: PAutomateState;
    begin
         if AReset
         then AClosure.Clear;
         if (AComplexState <> nil)
         then begin
              ScanState := AComplexState^.GetFirstSimpleState;
              while (ScanState <> nil)
              do begin
                 GetShiftsForState( ScanState, ASymbol, AClosure, False);
                 ScanState := AComplexState^.GetNextSimpleState;
                 end;
              end;
    end;

    function RetriveComplexState( AStatesSet: PCollection): PComplextAutoState;
    var ComplexState: PComplextAutoState;
    begin
         if (AStatesSet <> nil)
         then begin
              ComplexState := PComplextAutoState(DFAStates.GetFirst);
              while (ComplexState <> nil)
              do begin
                 if ComplexState^.IsEqual( AStatesSet)
                 then break;
                 ComplexState := PComplextAutoState(DFAStates.GetNext);
                 end;
              if (ComplexState = nil)
              then begin
                   ComplexState := New( PComplextAutoState, Create( Id, AStatesSet));
                   Id := Id + 1;
                   DFAStates.PushLast( ComplexState);
                   end;
              end;
         RetriveComplexState := ComplexState;
    end;

    procedure BuildComplexStatesAutomate;
    var StatesSet: TCollection;
        TransitionSymbols: TCollection;
        ScanComplexState: PComplextAutoState;
        RetrivedComplexState: PComplextAutoState;
        ScanSymbol: PAutoInSymbol;
    begin
         TransitionSymbols.Create;
         StatesSet.Create;
         GetShiftsForState( StartState, nil, StatesSet, True);
         DFAStart := RetriveComplexState( @StatesSet);
         ScanComplexState := DFAStart;
         while (ScanComplexState <> nil)
         do begin
            ScanComplexState^.GetTransitionSymbols( TransitionSymbols);
            ScanSymbol := PAutoInSymbol( TransitionSymbols.GetFirst);
            while (ScanSymbol <> nil)
            do begin
               StatesSet.Clear;
               GetShiftsForComplexState( ScanSymbol, ScanComplexState, StatesSet, True);
               RetrivedComplexState := RetriveComplexState( @StatesSet);
               if (RetrivedComplexState <> nil)
               then ScanComplexState^.AddTransition( ScanSymbol, RetrivedComplexState);
               ScanSymbol := PAutoInSymbol( TransitionSymbols.GetNext);
               end;
            ScanComplexState := PComplextAutoState( DFAStates.GetAfter( ScanComplexState));
            end;
         StatesSet.Destroy;
         TransitionSymbols.Destroy;
    end;

    procedure BuildTheResultDFA;
    var ResultStates: TCollection;
        ScanComplexState: PComplextAutoState;
        Image: PAutomateState;
        StartImage: PAutomateState;
    begin
         ResultStates.Create;
         ScanComplexState := PComplextAutoState( DFAStates.GetFirst);
         while ( ScanComplexState <> nil)
         do begin
            ScanComplexState^.CreateYourImage;
            ScanComplexState := PComplextAutoState( DFAStates.GetNext);
            end;

         ScanComplexState := PComplextAutoState( DFAStates.GetFirst);
         while ( ScanComplexState <> nil)
         do begin
            ScanComplexState^.ConnectYourImage;
            ScanComplexState := PComplextAutoState( DFAStates.GetNext);
            end;

         if (DFAStart <> nil)
         then StartState := DFAStart^.GetYourImage;

         ScanComplexState := PComplextAutoState( DFAStates.GetFirst);
         while (ScanComplexState <> nil)
         do begin
            Image := ScanComplexState^.LeaveYourImage;
            if (Image <> nil)
            then ResultStates.PushLast( Image);
            ScanComplexState := PComplextAutoState( DFAStates.GetNext);
            end;

         DFAStates.Clear;
         States.Clear;

         States.PushCollectionLast( @ResultStates);

         ResultStates.Destroy;
    end;

begin
     if (StartState <> nil)
     then begin
          Id := 1;
          DFAStates.Create;
          BuildComplexStatesAutomate;
          BuildTheResultDFA;
          DFAStates.Destroy;
          end;
end;

procedure TAutomate.OptimizeSize;
var StateGrops: TContainerCollection;
    StartGroup: PComplextAutoState;

    procedure CreateInitialSeparations;
    var States1,
        States2: TCollection;
        ScanFinalInfo: PFinalStateInfo;
        ScanState: PAutomateState;
    begin
         States1.Create;
         States2.Create;
         ScanState := PAutomateState( States.GetFirst);
         while (ScanState <> nil)
         do begin
            if ScanState^.IsFinalState
            then States1.PushLast( ScanState)
            else States2.PushLast( ScanState);
            ScanState := PAutomateState( States.GetNext);
            end;
         if ( States2.GetItemsCount > 0)
         then StateGrops.PushLast( New( PComplextAutoState, Create(0, @States2)));
         ScanFinalInfo := PFinalStateInfo( FinalStatesInfo.GetFirst);
         while (ScanFinalInfo <> nil)
         do begin
            States2.Clear;
            ScanState := PAutomateState( States1.GetFirst);
            while ( ScanState <> nil)
            do begin
               if ( ScanState^.GetFinalStateInfo = ScanFinalInfo)
               then States2.PushLast( ScanState);
               ScanState := PAutomateState( States1.GetNext);
               end;
            if ( States2.GetItemsCount > 0)
            then StateGrops.PushLast( New( PComplextAutoState, Create(0, @States2)));
            ScanFinalInfo := PFinalStateInfo( FinalStatesInfo.GetNext);
            end;
         States1.Destroy;
         States2.Destroy;
    end;

    procedure CreateNextSeparations;
    var States1: TCollection;
        ScanComplexState: PComplextAutoState;
        NoNewAdds: Boolean;
    begin
         States1.Create;
         repeat
               NoNewAdds := True;
               ScanComplexState := PComplextAutoState( StateGrops.GetFirst);
               while ( ScanComplexState <> nil)
               do begin
                  if ScanComplexState^.GetStrangeStates( States1)
                  then begin
                       StateGrops.PushLast( New( PComplextAutoState, Create(0, @States1)));
                       NoNewAdds := False;
                       end;
                  ScanComplexState := PComplextAutoState( StateGrops.GetAfter( ScanComplexState))
                  end;
         until NoNewAdds;
         States1.Destroy;
    end;

    procedure CreateTransitions;
    var ScanComplexState1,
        ScanComplexState2: PComplextAutoState;
        ScanState: PAutomateState;
        ScanTransition: PTransition;
    begin
         StartGroup := nil;
         ScanComplexState1 := PComplextAutoState( StateGrops.GetFirst);
         while ( ScanComplexState1 <> nil)
         do begin
            ScanComplexState2 := PComplextAutoState( StateGrops.GetFirst);
            while ( ScanComplexState2 <> nil)
            do begin
               ScanState := ScanComplexState1^.GetFirstSimpleState;
               while ( ScanState <> nil)
               do begin
                  if ( ScanState = StartState)
                  then StartGroup := ScanComplexState1;
                  ScanTransition := ScanState^.GetFirstTransition;
                  while ( ScanTransition <> nil)
                  do begin
                     if ScanComplexState2^.IsMemberState( ScanTransition^.GetToState)
                     then ScanComplexState1^.AddTransition( ScanTransition^.GetSymbol, ScanComplexState2);
                     ScanTransition := ScanState^.GetNextTransition;
                     end;
                  ScanState := ScanComplexState1^.GetNextSimpleState;
                  end;
               ScanComplexState2 := PComplextAutoState( StateGrops.GetNext);
               end;
            ScanComplexState1 := PComplextAutoState( StateGrops.GetAfter( ScanComplexState1));
            end;
    end;

    procedure BuildResultAutomate;
    var ResultStates: TCollection;
        ScanComplexState: PComplextAutoState;
        Image: PAutomateState;
        StartImage: PAutomateState;
    begin
         ResultStates.Create;
         ScanComplexState := PComplextAutoState( StateGrops.GetFirst);
         while ( ScanComplexState <> nil)
         do begin
            ScanComplexState^.CreateYourImage;
            ScanComplexState := PComplextAutoState( StateGrops.GetNext);
            end;

         ScanComplexState := PComplextAutoState( StateGrops.GetFirst);
         while ( ScanComplexState <> nil)
         do begin
            ScanComplexState^.ConnectYourImage;
            ScanComplexState := PComplextAutoState( StateGrops.GetNext);
            end;

         if (StartGroup <> nil)
         then StartState := StartGroup^.GetYourImage;

         ScanComplexState := PComplextAutoState( StateGrops.GetFirst);
         while (ScanComplexState <> nil)
         do begin
            Image := ScanComplexState^.LeaveYourImage;
            if (Image <> nil)
            then ResultStates.PushLast( Image);
            ScanComplexState := PComplextAutoState( StateGrops.GetNext);
            end;

         StateGrops.Clear;
         States.Clear;

         States.PushCollectionLast( @ResultStates);

         ResultStates.Destroy;
    end;

begin
     if (StartState <> nil)
     then begin
          StateGrops.Create;
          StartGroup := nil;
          CreateInitialSeparations;
          CreateNextSeparations;
          CreateTransitions;
          BuildResultAutomate;
          EnumStates;
          StateGrops.Destroy;
          end;
end;

procedure TAutomate.Build;
begin
     ConvertToDFA;
     OptimizeSize;
     EnumStates;
     EnumAlphabet;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TExpresionDef.Create( AName: string; AExp: PRegExp);
begin
     inherited Create;
     Name := AllocateString( AName);
     Expresion := AExp;
end;

destructor TExpresionDef.Destroy;
begin
     if (Name <> nil)
     then FreeString( Name);
     inherited Destroy;
end;

function TExpresionDef.GetExpresion: PRegExp;
begin
     GetExpresion := Expresion;
end;

function TExpresionDef.GetName: string;
begin
     if (Name <> nil)
     then GetName := Name^
     else GetName := '';
end;

procedure TExpresionDef.Display( AStream: PStream);
begin
     if Name <> nil
     then AStream^.WriteStr( Name^)
     else AStream^.WriteStr( '###');
     AStream^.WriteStr( '=');
     if (Expresion <> nil)
     then Expresion^.Display( AStream);
     AStream^.NewLine;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TLexProcedure.Create( APriority: Word; var ABuffer; ASize: Word; ARegExp: PRegExp);
begin
     inherited Create( APriority);
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
     Expresion := ARegExp;
end;

destructor TLexProcedure.Destroy;
begin
     if ((BufferSize > 0) and (Buffer <> nil))
     then FreeMem( Buffer, BufferSize);
     inherited Destroy;
end;

procedure TLexProcedure.Display( AStream: PStream);
var I: Word;
    P: PChar;
begin
     if ((Buffer <> nil) and (BufferSize > 0))
     then begin
          P := Buffer;
          for I := 1 to BufferSize
          do begin
             AStream^.WriteStr( P^);
             P := P + 1;
             end;
          end;
end;

function TLexProcedure.GetExpresion: PRegExp;
begin
     GetExpresion := Expresion;
end;

function TLexProcedure.GetSize: Word;
begin
     GetSize := BufferSize;
end;

function TLexProcedure.GetBuffer: Pointer;
begin
     GetBuffer := Buffer;
end;

function TLexProcedure.GetData( var ABuffer; ABufferSize: Word): Word;
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

constructor TLexAutoTable.Create;
begin
     inherited Create;

     StartState := 0;
     StatesCount := 0;
     AlphabetSize := 0;
     AlphabetTable := nil;
     AutoCols := nil;
     AutoFinals := nil;
end;

destructor TLexAutoTable.Destroy;
begin
     Clear;
     inherited Destroy;
end;

procedure TLexAutoTable.Clear;
var I: Word;
begin
     if (( StatesCount > 0) and (AlphabetSize > 0))
     then begin
          if ( AutoCols <> nil)
          then begin
               for I := 1 to AlphabetSize
               do begin
                  if (AutoCols^[I].Col <> nil)
                  then begin
                       FreeMem( AutoCols^[I].Col, SizeOf(TAutoCol) * StatesCount);
                       AutoCols^[I].Col := nil;
                       end;
                  end;
               FreeMem( AutoCols, SizeOf(TAutoColHeaders) * AlphabetSize);
               end;

          if ( AlphabetTable <> nil)
          then Dispose( AlphabetTable);

          if ( AutoFinals <> nil)
          then FreeMem( AutoFinals, SizeOf( TAutoFinals) * StatesCount);
          end;

     StartState := 0;
     StatesCount := 0;
     AlphabetSize := 0;
     AlphabetTable := nil;
     AutoCols := nil;
     AutoFinals := nil;
end;

procedure TLexAutoTable.AllocateTable( AStatesCount: Word; AAlphabetSize: Word);
var I, J: Word;
begin
     Clear;

     if (( AStatesCount > 0) and ( AAlphabetSize > 0))
     then begin
          StatesCount := AStatesCount;
          AlphabetSize := AAlphabetSize;

          New( AlphabetTable);

          for I := 0 to 255
          do AlphabetTable^[I] := nil;

          GetMem( AutoFinals, SizeOf(TAutoFinals) * StatesCount);

          for J := 1 to StatesCount
          do AutoFinals^[J] := nil;

          GetMem( AutoCols, SizeOf(TAutoColHeaders) * AlphabetSize);

          for I := 1 to AlphabetSize
          do begin
             AutoCols^[I].Symbol := nil;
             GetMem( AutoCols^[I].Col, SizeOf(TAutoCol) * StatesCount);
             for J := 1 to StatesCount
             do AutoCols^[I].Col^[J] := nil;
             end;
          end;
end;

procedure TLexAutoTable.SetSymbol( AIndex: Word; ASymbol: PAutoInSymbol);
begin
end;

function TLexAutoTable.GetSymbol( AIndex: Word): PAutoInSymbol;
begin
end;

function TLexAutoTable.GetSymbolsCount: Word;
begin
end;

procedure TLexAutoTable.SetNext;
begin
end;

procedure TLexAutoTable.Build( AAutomate: PAutomate);
var AutoStatesCount,
    AutoAlphabetSize: Word;

    ScanState,
    ToState: PAutomateState;
    ScanTransition: PTransition;
    ScanSymbol: PAutoInSymbol;

    StateId: Word;
    C: Char;
begin
     Clear;
     if ( AAutomate <> nil)
     then begin
          AAutomate^.EnumStates;
          AAutomate^.EnumAlphabet;
          AutoStatesCount := AAutomate^.GetStatesCount;
          AutoAlphabetSize := AAutomate^.GetAlphabetSize;

          if (( AutoStatesCount > 0) and ( AutoAlphabetSize > 0))
          then begin
               AllocateTable( AutoStatesCount, AutoAlphabetSize);

               ScanState := AAutomate^.GetStartState;
               if ( ScanState <> nil)
               then StartState := ScanState^.GetID
               else StartState := 0;

               for C := #0 to #255
               do AlphabetTable^[Ord(C)] := nil;

               ScanSymbol := AAutomate^.GetFirstSymbol;
               while ( ScanSymbol <> nil)
               do begin
                  AutoCols^[ ScanSymbol^.GetID].Symbol := ScanSymbol;
                  for C := #0 to #255
                  do if (C in PSymbolSet(ScanSymbol)^.CharsSet)
                     then AlphabetTable^[Ord(C)] := ScanSymbol;
                  ScanSymbol := AAutomate^.GetNextSymbol;
                  end;

               ScanState := AAutomate^.GetFirstState;
               while ( ScanState <> nil)
               do begin
                  StateId := ScanState^.GetID;
                  if ScanState^.IsFinalState
                  then AutoFinals^[ StateId] := ScanState^.GetFinalStateInfo
                  else AutoFinals^[ StateId] := nil;
                  ScanTransition := ScanState^.GetFirstTransition;
                  while ( ScanTransition <> nil)
                  do begin
                     ToState := ScanTransition^.GetToState;
                     ScanSymbol := ScanTransition^.GetSymbol;
                     if (( ScanSymbol <> nil) and ( ToState <> nil))
                     then AutoCols^[ ScanSymbol^.GetID].Col^[ StateId] := ToState;
                     ScanTransition := ScanState^.GetNextTransition;
                     end;
                  ScanState := AAutomate^.GetNextState;
                  end;
               end;
          end;
end;

procedure TLexAutoTable.Display( AStream: PStream);
var State, Symbol: Word;
    C: Byte;
    I: Integer;
begin
     AStream^.NewLine;
     for State := 1 to StatesCount
     do begin
        AStream^.WriteIntF( State, 4);
        AStream^.WriteStr( ': ');
        for Symbol := 1 to AlphabetSize
        do begin
           if ( AutoCols^[ Symbol].Col^[ State] <> nil)
           then begin
                AStream^.WriteIntF( AutoCols^[ Symbol].Col^[ State]^.GetID, 4);
                AStream^.WriteStr( ' ');
                end
           else AStream^.WriteStr( '---- ');
           end;

        AStream^.WriteStr( '      ');

        if (AutoFinals^[ State] <> nil)
        then AutoFinals^[ State]^.Display( AStream);

        AStream^.NewLine;
        end;

     AStream^.NewLine;
     for C := 0 to 255
     do begin
        if ( AlphabetTable^[C] <> nil)
        then begin
             AStream^.WriteIntF( C, 4);
             AStream^.WriteStr( ' : ');
             AStream^.WriteIntF( AlphabetTable^[C]^.GetID, 4);
             end
        else begin
             AStream^.WriteIntF( C, 4);
             AStream^.WriteStr( ' : ----');
             end;

        if (C >= 32)
        then begin
             AStream^.WriteStr( '  ~');
             AStream^.WriteStr( Char(C));
             AStream^.WriteStr( '~');
             end;
        AStream^.NewLine;
        end;
     AStream^.NewLine;

     AStream^.WriteStr( 'START STATE     = ');
     AStream^.WriteInt( StartState);
     AStream^.NewLine;
     AStream^.WriteStr( 'STATES COUNT    = ');
     AStream^.WriteInt( StatesCount);
     AStream^.NewLine;
     AStream^.WriteStr( 'ALPHABET SIZE   = ');
     AStream^.WriteInt( AlphabetSize);
     AStream^.NewLine;
     AStream^.NewLine;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TOutputGenerator.Create( AOwner: PErrGeneric; ADataBase: PLexDatabase; ASkeleton: PStream; ATarget: PStream);
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

    procedure WriteAlphabetTablePAS;
    var C: Byte;
        I: Integer;
        S1: string;
    begin
         with DataBase^.Table
         do begin
            Target^.WriteStr('(');
            Target^.NewLine;
            I := 0;
            for C := 0 to 255
            do begin
               if  I = 0
               then begin
                    Str( C:4, S1);
                    S1 := ' { ' + S1 + ' }';
                    Target^.WriteStr( S1);
                    end;
               I := I + 1;

               if ( AlphabetTable^[C] <> nil)
               then begin
                    Str( AlphabetTable^[C]^.GetId:4, S1);
                    Target^.WriteStr( S1);
                    end
               else Target^.WriteStr( '   0');

               if ( C < 255)
               then begin
                    Target^.WriteStr( ',');
                    if ( I >= 8)
                    then begin
                         I := 0;
                         Target^.NewLine;
                         end;
                    end
               else begin
                    Target^.NewLine;
                    Target^.WriteStr( ');');
                    end;
               end;
            end;
    end;

    procedure WriteDFATablePAS;
    var State: Integer;
        Symbol: Integer;
        S1: string;
        I: Integer;
    begin
         with DataBase^.Table
         do begin
            Target^.WriteStr('(');
            Target^.NewLine;
            for State := 1 to StatesCount
            do begin
               Str( State:4, S1);
               S1 := '{ ' + S1 + ' } (';
               Target^.WriteStr( S1);
               I := 0;
               for Symbol := 1 to AlphabetSize
               do begin
                  if ( AutoCols^[ Symbol].Col^[ State] <> nil)
                  then begin
                       Str( AutoCols^[ Symbol].Col^[ State]^.GetID:4, S1);
                       Target^.WriteStr( S1);
                       end
                  else Target^.WriteStr( '   0');
                  if ( Symbol < AlphabetSize)
                  then Target^.WriteStr( ',');
                  I := I + 1;
                  if ( I >= 10)
                  then begin
                       Target^.NewLine;
                       Target^.WriteStr('          ');
                       I := 0;
                       end;
                  end;
               if (State < StatesCount)
               then Target^.WriteStr( '),')
               else Target^.WriteStr( ')');
               Target^.NewLine;
               end;
            Target^.WriteStr( ');');
            Target^.NewLine;
            end;
    end;

    procedure WriteActionProceduresPAS;
    var Header: string;
        I: Integer;
        State: Integer;
    begin
        with DataBase^.Table
        do begin
           I := 1;
           for State := 1 to StatesCount
           do begin
              if (AutoFinals^[ State] <> nil)
              then begin
                   Str( I, Header);
                   Header := 'procedure LEX_Action' + Header + '( ALex: PLexical; var AReturn: Boolean; var AInfo);';
                   Target^.WriteStr( Header);
                   Target^.NewLine;
                   if (( PLexProcedure( AutoFinals^[ State])^.GetBuffer <> nil)
                      and ( PLexProcedure( AutoFinals^[ State])^.GetSize > 0))
                   then Target^.Write( PLexProcedure( AutoFinals^[ State])^.GetBuffer^,
                                       PLexProcedure( AutoFinals^[ State])^.GetSize)
                   else Target^.WriteStr('begin end;');
                   Target^.NewLine;
                   Target^.NewLine;
                   I := I + 1;
                   end;
              end;
           end;
    end;

    procedure WriteActionsTablePAS;
    var Header: string;
        I,State: Integer;
        S1: string;
    begin
        with DataBase^.Table
        do begin
           Target^.WriteStr('(');
           Target^.NewLine;
           I := 1;
           for State := 1 to StatesCount
           do begin
              if (AutoFinals^[ State] <> nil)
              then begin
                   Str( I, S1);
                   S1 := 'LEX_Action' + S1;
                   Target^.WriteStr( S1);
                   I := I + 1;
                   end
              else Target^.WriteStr( 'nil');
              if ( State < StatesCount)
              then Target^.WriteStr(',');
              Target^.NewLine;
              end;
           end;
        Target^.WriteStr(');');
        Target^.NewLine;
    end;

    procedure WriteDefinesPAS;
    var S1, S2: string;
    begin
        with DataBase^.Table
        do begin
           Str( StatesCount, S1);
           S1 := 'const LEX_STATESCOUNT = ' + S1 + ';';
           Target^.WriteStr( S1);
           Target^.NewLine;
           Str( AlphabetSize, S1);
           S1 := '      LEX_ALPHABETSIZE = ' + S1 + ';';
           Target^.WriteStr( S1);
           Target^.NewLine;
           Str( StartState, S1);
           S1 := '      LEX_STARTSTATE = ' + S1 + ';';
           Target^.WriteStr( S1);
           Target^.NewLine;
           end;
    end;

begin
     repeat
           Command := ScanToNextCommand( EOSkeleton);
           if Command = 'PAS_ALPHABET'
           then WriteAlphabetTablePAS
           else if Command = 'PAS_DFATABLE'
           then WriteDFATablePAS
           else if Command = 'PAS_ACTIONSPROCEDURES'
           then WriteActionProceduresPAS
           else if Command = 'PAS_ACTIONSTABLE'
           then WriteActionsTablePAS
           else if Command = 'PAS_DEFINES'
           then WriteDefinesPAS;
     until (EOSkeleton);
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TLexDatabase.Create( AOwner: PErrGeneric);
begin
     inherited Create( AOwner);
     SymbolSets.Create;
     Exepresions.Create;
     Defines.Create;
     Procedures.Create;
     Automate.Create;
     Table.Create;
end;

destructor TLexDatabase.Destroy;
begin
     Table.Destroy;
     SymbolSets.Destroy;
     Exepresions.Destroy;
     Defines.Destroy;
     Procedures.Destroy;
     Automate.Destroy;
     inherited Destroy;
end;

function TLexDatabase.CreateSet( ACharsSet: TCharsSet): PSymbolSet;
var ScanSet: PSymbolSet;
begin
     ScanSet := PSymbolSet( SymbolSets.GetFirst);
     while (ScanSet <> nil)
     do if (ScanSet^.CharsSet <> ACharsSet)
        then ScanSet := PSymbolSet( SymbolSets.GetNext)
        else Break;
     if (ScanSet = nil)
     then begin
          ScanSet := New( PSymbolSet, Create(ACharsSet));
          SymbolSets.PushLast( ScanSet);
          end;
     CreateSet := ScanSet;
end;

procedure TLexDatabase.AddDefine( AName: string; AExpresion: PRegExp);
var Def: PExpresionDef;
begin
     if (AExpresion <> nil)
     then begin
          Exepresions.PushLast( AExpresion);
          Def := New( PExpresionDef, Create( AName, AExpresion));
          Defines.PushLast( Def);
          end;
end;

procedure TLexDatabase.AddExprestion( AExpresion: PRegExp);
begin
     if (AExpresion <> nil)
     then Exepresions.PushLast( AExpresion);
end;

procedure TLexDatabase.AddProcedure( var ABuffer; ASize: Word; AExpresion: PRegExp);
var Proc: PLexProcedure;
begin
     if (AExpresion <> nil)
     then begin
          Exepresions.PushLast( AExpresion);
          Proc := New( PLexProcedure, Create( 0, ABuffer, ASize, AExpresion));
          Procedures.PushLast( Proc);
          end;
end;

function TLexDatabase.GetExpresion( AName: string): PRegExp;
var ScanDef: PExpresionDef;
begin
     ScanDef := PExpresionDef( Defines.GetFirst);
     while (ScanDef <> nil)
     do begin
        if (ScanDef^.GetName = AName)
        then Break;
        ScanDef := PExpresionDef( Defines.GetNext);
        end;
     if (ScanDef <> nil)
     then GetExpresion := ScanDef^.GetExpresion
     else GetExpresion := nil;
end;

procedure TLexDatabase.SeparateSymbolSets;

    function FindIntersectedSets( var ASet1, ASet2: PSymbolSet): Boolean;
    var ScanSet1, ScanSet2: PSymbolSet;
    begin
         FindIntersectedSets := False;
         ScanSet1 := PSymbolSet( SymbolSets.GetFirst);
         while (ScanSet1 <> nil)
         do begin
            ScanSet2 := PSymbolSet( SymbolSets.GetAfter(ScanSet1));
            while (ScanSet2 <> nil)
            do begin
               if ((ScanSet1^.CharsSet * ScanSet2^.CharsSet) <> [])
               then begin
                    ASet1 := ScanSet1;
                    ASet2 := ScanSet2;
                    FindIntersectedSets := True;
                    Exit;
                    end;
               ScanSet2 := PSymbolSet( SymbolSets.GetNext);
               end;
            ScanSet1 := PSymbolSet( SymbolSets.GetAfter(ScanSet1));
            end;
    end;

    procedure CorrectExpresions( AOriginalSet, ASet1, ASet2: PSymbolSet);
    var ScanExp: PRegExp;
        Info: TCorrectSetInfo;
    begin
         Info.Originalset := AOriginalSet;
         Info.SubSet1 := ASet1;
         Info.Subset2 := ASet2;
         ScanExp := PRegExp(Exepresions.GetFirst);
         while (ScanExp <> nil)
         do begin
            ScanExp^.Message( comCORRECTSET, @Info);
            ScanExp := PRegExp(Exepresions.GetNext);
            end;
    end;

var InterSet1, InterSet2: PSymbolSet;
    NewSet1, NewSet2, NewSet3: PSymbolSet;
    CharsSet: TCharsSet;
begin
     while FindIntersectedSets( InterSet1, InterSet2)
     do begin
        SymbolSets.RemoveFromCollection( InterSet1);
        SymbolSets.RemoveFromCollection( InterSet2);
        CharsSet := InterSet1^.CharsSet * InterSet2^.CharsSet;
        if (CharsSet = InterSet1^.CharsSet)
        then begin
             NewSet1 := CreateSet( CharsSet);
             NewSet2 := CreateSet( InterSet2^.CharsSet - CharsSet);
             CorrectExpresions( InterSet1, NewSet1, nil);
             CorrectExpresions( InterSet2, NewSet1, NewSet2);
             end
        else if (CharsSet = InterSet2^.CharsSet)
        then begin
             NewSet1 := CreateSet( CharsSet);
             NewSet2 := CreateSet( InterSet1^.CharsSet - CharsSet);
             CorrectExpresions( InterSet1, NewSet1, NewSet2);
             CorrectExpresions( InterSet2, NewSet1, nil);
             end
        else begin
             NewSet1 := CreateSet( CharsSet);
             NewSet2 := CreateSet( InterSet1^.CharsSet - CharsSet);
             NewSet3 := CreateSet( InterSet2^.CharsSet - CharsSet);
             CorrectExpresions( InterSet1, NewSet1, NewSet2);
             CorrectExpresions( InterSet2, NewSet1, NewSet3);
             end;
        InterSet1^.Free;
        InterSet2^.Free;
        end;
end;

procedure TLexDatabase.BuildAuto;
var ScanProc: PLexProcedure;
    RegExp: PRegExp;
begin
     Automate.Clear;
     Table.Clear;
     ScanProc := PLexProcedure( Procedures.GetFirst);
     while ( ScanProc <> nil)
     do begin
        RegExp := ScanProc^.GetExpresion;
        if (RegExp <> nil)
        then Automate.AddMainExp(RegExp, ScanProc);
        ScanProc := PLexProcedure( Procedures.GetNext);
        end;
     Automate.Build;
     Table.Build( @Automate);
end;

procedure TLexDatabase.Display( AStream: PStream);
var ScanDef: PExpresionDef;
    ScanSet: PSymbolSet;
    ScanProc: PLexProcedure;
begin
     AStream^.WriteStr( 'REGULAR EXPRESIONS:');
     AStream^.NewLine;
     AStream^.NewLine;
     ScanDef := PExpresionDef( Defines.GetFirst);
     while (ScanDef <> nil)
     do begin
        AStream^.WriteStr('> ');
        ScanDef^.Display( AStream);
        ScanDef := PExpresionDef( Defines.GetNext);
        end;
     AStream^.NewLine;
     AStream^.NewLine;
     AStream^.WriteStr( 'ALPHABET-SYMBOLS:');
     AStream^.NewLine;
     AStream^.NewLine;
     ScanSet := PSymbolSet( SymbolSets.GetFirst);
     while (ScanSet <> nil)
     do begin
        AStream^.WriteIntF( ScanSet^.GetID, 4);
        AStream^.WriteStr(' : ');
        ScanSet^.Display( AStream);
        AStream^.NewLine;
        ScanSet := PSymbolSet( SymbolSets.GetNext);
        end;
     AStream^.NewLine;
     AStream^.NewLine;
     AStream^.WriteStr( 'PROCEDURES:');
     AStream^.NewLine;
     AStream^.NewLine;
     ScanProc := PLexProcedure( Procedures.GetFirst);
     while ( ScanProc <> nil)
     do begin
        AStream^.WriteStr( '> ');
        ScanProc^.Display( AStream);
        ScanProc := PLexProcedure( Procedures.GetNext);
        end;
     AStream^.NewLine;
     AStream^.NewLine;
     AStream^.WriteStr( 'THE DFA:');
     AStream^.NewLine;
     AStream^.NewLine;
     Automate.Display( AStream);
     AStream^.NewLine;
     AStream^.NewLine;
     AStream^.WriteStr( 'THE DFA TRANSITION TABLE:');
     AStream^.NewLine;
     AStream^.NewLine;
     Table.Display( AStream);
     AStream^.NewLine;
     AStream^.NewLine;
     AStream^.NewLine;
end;

end.