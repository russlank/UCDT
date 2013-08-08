{********************************************************}
{*                                                      *}
{*   LEX tools syntax analyzer unit                     *}
{*                                                      *}
{*   File name : LEXPARSE.PAS                           *}
{*                                                      *}
{*   Programming: Russlan Kafri - 1999                  *}
{*                                                      *}
{********************************************************}

unit LexParser;

interface

uses Strings, LexEngine, LexLexical, Generics, Lexical, Parser, LexDefs;

type
    PCharSet = ^TCharSet;
    TCharSet = set of Char;

    PLexPrgramParser = ^TLexPrgramParser;
    TLexPrgramParser = object( TParser)
    private
        Database: PLexDatabase;
        Lexical: PLexLexical;

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
        procedure Semantic18;
        procedure Semantic19;
        procedure Semantic20;
        procedure Semantic21;
        procedure Semantic22;
        procedure Semantic23;
    public
        constructor Create( AOwner: PErrGeneric; ASource: PStream; ADatabase: PLexDatabase);
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

    PCharAttribute = ^TCharAttribute;
    TCharAttribute = object( TGeneric)
    private
       C: Char;
    public
       constructor Create( AChar: Char);
       destructor Destroy; virtual;
       function GetChar: Char;
       end;

    PCharSetAttribute = ^TCharSetAttribute;
    TCharSetAttribute = object( TGeneric)
    private
       CharSet: TCharSet;
    public
       constructor Create( ACharSet: TCharSet);
       destructor Destroy; virtual;
       function GetCharSet: PCharSet;
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

    PStringAttribute = ^TStringAttribute;
    TStringAttribute = object( TBlockAttribute)
       end;


implementation

{******************************************************************}
{*                                                                *}
{******************************************************************}

const
STATESCOUNT       = 39;
TERMINALCOUNT     = 19;
NONTERMINALCOUNT  = 10;
RULESCOUNT        = 23;

{
TERMINALS:
    1  %%
    2  id
    3  =
    4  ;
    5  :
    6  block
    7  |
    8  *
    9  +
   10  ?
   11  char
   12  [
   13  ]
   14  str
   15  (
   16  )
   17  ,
   18  -
   19  $
}

      ActionTable: array[1..STATESCOUNT, 1..TERMINALCOUNT] of TActionRec =
(
( { St.    1 }
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 5),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
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
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
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
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
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
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
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
( Action: actShift; NextState: 8),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.    6 }
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 15),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 13),
( Action: actShift; NextState: 14),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 16),
( Action: actShift; NextState: 17),
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
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.    8 }
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 15),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 13),
( Action: actShift; NextState: 14),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 16),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.    9 }
( Action: actShift; NextState: 19),
( Action: actShift; NextState: 15),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 13),
( Action: actShift; NextState: 14),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 16),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   10 }
( Action: actReduce; Rule: 7),
( Action: actReduce; Rule: 7),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 7),
( Action: actReduce; Rule: 7),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 7),
( Action: actReduce; Rule: 7),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   11 }
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 15),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 21),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 23),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 13),
( Action: actShift; NextState: 14),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 16),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   12 }
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 11),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 11),
( Action: actReduce; Rule: 11),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 11),
( Action: actShift; NextState: 24),
( Action: actShift; NextState: 25),
( Action: actShift; NextState: 26),
( Action: actReduce; Rule: 11),
( Action: actReduce; Rule: 11),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 11),
( Action: actReduce; Rule: 11),
( Action: actReduce; Rule: 11),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   13 }
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 15),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 15),
( Action: actReduce; Rule: 15),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 15),
( Action: actReduce; Rule: 15),
( Action: actReduce; Rule: 15),
( Action: actReduce; Rule: 15),
( Action: actReduce; Rule: 15),
( Action: actReduce; Rule: 15),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 15),
( Action: actReduce; Rule: 15),
( Action: actReduce; Rule: 15),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   14 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 29),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   15 }
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 17),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 17),
( Action: actReduce; Rule: 17),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 17),
( Action: actReduce; Rule: 17),
( Action: actReduce; Rule: 17),
( Action: actReduce; Rule: 17),
( Action: actReduce; Rule: 17),
( Action: actReduce; Rule: 17),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 17),
( Action: actReduce; Rule: 17),
( Action: actReduce; Rule: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   16 }
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 18),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 18),
( Action: actReduce; Rule: 18),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 18),
( Action: actReduce; Rule: 18),
( Action: actReduce; Rule: 18),
( Action: actReduce; Rule: 18),
( Action: actReduce; Rule: 18),
( Action: actReduce; Rule: 18),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 18),
( Action: actReduce; Rule: 18),
( Action: actReduce; Rule: 18),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   17 }
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 15),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 13),
( Action: actShift; NextState: 14),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 16),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   18 }
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 15),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 31),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 23),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 13),
( Action: actShift; NextState: 14),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 16),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   19 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 2)
),
( { St.   20 }
( Action: actReduce; Rule: 6),
( Action: actReduce; Rule: 6),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 6),
( Action: actReduce; Rule: 6),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 6),
( Action: actReduce; Rule: 6),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   21 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 32),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   22 }
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 9),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 9),
( Action: actReduce; Rule: 9),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 9),
( Action: actShift; NextState: 24),
( Action: actShift; NextState: 25),
( Action: actShift; NextState: 26),
( Action: actReduce; Rule: 9),
( Action: actReduce; Rule: 9),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 9),
( Action: actReduce; Rule: 9),
( Action: actReduce; Rule: 9),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   23 }
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 15),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 13),
( Action: actShift; NextState: 14),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 16),
( Action: actShift; NextState: 17),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   24 }
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 12),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 12),
( Action: actReduce; Rule: 12),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 12),
( Action: actReduce; Rule: 12),
( Action: actReduce; Rule: 12),
( Action: actReduce; Rule: 12),
( Action: actReduce; Rule: 12),
( Action: actReduce; Rule: 12),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 12),
( Action: actReduce; Rule: 12),
( Action: actReduce; Rule: 12),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   25 }
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 13),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 13),
( Action: actReduce; Rule: 13),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 13),
( Action: actReduce; Rule: 13),
( Action: actReduce; Rule: 13),
( Action: actReduce; Rule: 13),
( Action: actReduce; Rule: 13),
( Action: actReduce; Rule: 13),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 13),
( Action: actReduce; Rule: 13),
( Action: actReduce; Rule: 13),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   26 }
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 14),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 14),
( Action: actReduce; Rule: 14),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 14),
( Action: actReduce; Rule: 14),
( Action: actReduce; Rule: 14),
( Action: actReduce; Rule: 14),
( Action: actReduce; Rule: 14),
( Action: actReduce; Rule: 14),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 14),
( Action: actReduce; Rule: 14),
( Action: actReduce; Rule: 14),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   27 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 34),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 35),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   28 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 21),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 21),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   29 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 22),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 22),
( Action: actShift; NextState: 36),
( Action: actError; ErrorCode: 0)
),
( { St.   30 }
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 15),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 23),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 13),
( Action: actShift; NextState: 14),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 16),
( Action: actShift; NextState: 17),
( Action: actShift; NextState: 37),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   31 }
( Action: actReduce; Rule: 5),
( Action: actReduce; Rule: 5),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   32 }
( Action: actReduce; Rule: 8),
( Action: actReduce; Rule: 8),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 8),
( Action: actReduce; Rule: 8),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 8),
( Action: actReduce; Rule: 8),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   33 }
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 10),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 10),
( Action: actReduce; Rule: 10),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 10),
( Action: actShift; NextState: 24),
( Action: actShift; NextState: 25),
( Action: actShift; NextState: 26),
( Action: actReduce; Rule: 10),
( Action: actReduce; Rule: 10),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 10),
( Action: actReduce; Rule: 10),
( Action: actReduce; Rule: 10),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   34 }
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 16),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 16),
( Action: actReduce; Rule: 16),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 16),
( Action: actReduce; Rule: 16),
( Action: actReduce; Rule: 16),
( Action: actReduce; Rule: 16),
( Action: actReduce; Rule: 16),
( Action: actReduce; Rule: 16),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 16),
( Action: actReduce; Rule: 16),
( Action: actReduce; Rule: 16),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   35 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 29),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   36 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actShift; NextState: 39),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   37 }
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 19),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 19),
( Action: actReduce; Rule: 19),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 19),
( Action: actReduce; Rule: 19),
( Action: actReduce; Rule: 19),
( Action: actReduce; Rule: 19),
( Action: actReduce; Rule: 19),
( Action: actReduce; Rule: 19),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 19),
( Action: actReduce; Rule: 19),
( Action: actReduce; Rule: 19),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   38 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 20),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
),
( { St.   39 }
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 23),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0),
( Action: actReduce; Rule: 23),
( Action: actError; ErrorCode: 0),
( Action: actError; ErrorCode: 0)
)
);

      GotoTable: array[ 1..STATESCOUNT, 1..NONTERMINALCOUNT] of Byte =
(
{ St.   1  } (  0,  2,  3,  4,  0,  0,  0,  0,  0,  0),
{ St.   2  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.   3  } (  0,  0,  0,  7,  0,  0,  0,  0,  0,  0),
{ St.   4  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.   5  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.   6  } (  0,  0,  0,  0,  9, 10, 11, 12,  0,  0),
{ St.   7  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.   8  } (  0,  0,  0,  0,  0,  0, 18, 12,  0,  0),
{ St.   9  } (  0,  0,  0,  0,  0, 20, 11, 12,  0,  0),
{ St.  10  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  11  } (  0,  0,  0,  0,  0,  0,  0, 22,  0,  0),
{ St.  12  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  13  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  14  } (  0,  0,  0,  0,  0,  0,  0,  0, 27, 28),
{ St.  15  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  16  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  17  } (  0,  0,  0,  0,  0,  0, 30, 12,  0,  0),
{ St.  18  } (  0,  0,  0,  0,  0,  0,  0, 22,  0,  0),
{ St.  19  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  20  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  21  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  22  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  23  } (  0,  0,  0,  0,  0,  0,  0, 33,  0,  0),
{ St.  24  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  25  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  26  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  27  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  28  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  29  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  30  } (  0,  0,  0,  0,  0,  0,  0, 22,  0,  0),
{ St.  31  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  32  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  33  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  34  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  35  } (  0,  0,  0,  0,  0,  0,  0,  0,  0, 38),
{ St.  36  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  37  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  38  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0),
{ St.  39  } (  0,  0,  0,  0,  0,  0,  0,  0,  0,  0)
);



      RuleSizes: array[ 1..RULESCOUNT] of Byte =
(1,4,2,1,4,2,1,3,2,3,1,2,2,2,1,3,1,1,3,3,1,1,3);

      RulesSymbol: array[ 1..RULESCOUNT] of Byte =
(1,2,3,3,4,5,5,6,7,7,7,8,8,8,8,8,8,8,8,9,9,10,10);

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TLexPrgramParser.Create( AOwner: PErrGeneric; ASource: PStream; ADatabase: PLexDatabase);
begin
     inherited Create( AOwner);
     Lexical := New( PLexLexical, Create( @Self, ASource));
     Database := ADatabase;
end;

destructor TLexPrgramParser.Destroy;
begin
     if ( Lexical <> nil)
     then Lexical^.Free;
     inherited Destroy;
end;

procedure TLexPrgramParser.NextLexeme;
var Attrs: TLexemeAttributes;
    Lexeme: Word;
    LexemeAttrs: PGeneric;

    Value: Longint;
    Code: Integer;
begin
     if Lexical^.Lexeme( Attrs)
     then begin
          Lexeme := Attrs.Lexeme;
          case Lexeme
          of lexIdentifier: LexemeAttrs := New( PIDAttribute, Create( Attrs.LexemeStr ));
             lexBody: LexemeAttrs := New( PBlockAttribute, Create( Attrs.LexemeStr[2], Attrs.LexemeLen - 4));
             lexString: LexemeAttrs := New( PStringAttribute, Create( Attrs.LexemeStr[1], Attrs.LexemeLen-2));
             lexChar: begin
                      if (Attrs.LexemeStr[0] = '\')
                      then LexemeAttrs := New( PCharAttribute, Create( Attrs.LexemeStr[1]))
                      else begin
                           Val(StrPas(Attrs.LexemeStr), Value, Code);
                           if ((Value >= 0) and (Value <= 255))
                           then LexemeAttrs := New( PCharAttribute, Create( Chr(Value)))
                           else begin
                                Lexeme := lexError;
                                LexemeAttrs := nil;
                                end;
                           end;
                      end;
             lexError: begin
                       LexemeAttrs := nil;
                       Error(200);
                       StopParsing;
                       end;
             lexEOF: begin
                     LexemeAttrs := nil;
                     end;
             lexNone: begin
                      LexemeAttrs := nil;
                      Error(200);
                      StopParsing;
                      end;
             else
                 LexemeAttrs := nil;
             end;
          end
     else begin
          StopParsing;
          LexemeAttrs := nil;
          end;

     SetLexeme( Lexeme, LexemeAttrs);
end;

procedure TLexPrgramParser.ExecuteSemantic( ARule: Byte);
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
        18: Semantic18;
        19: Semantic19;
        20: Semantic20;
        21: Semantic21;
        22: Semantic22;
        23: Semantic23;
        else
            Halt;
        end;
end;

function TLexPrgramParser.GetGoto( ATopState: Byte; ANonterminal: Byte): Byte;
begin
     if ((ATopState <> 0) and (ANonterminal <> 0))
     then GetGoto := GotoTable[ ATopState, ANonTerminal]
     else begin
          GetGoto := 0;
          StopParsing;
          end;
end;

procedure TLexPrgramParser.GetAction( ATopState: Byte; ATerminal: Word; var AAction: TActionRec);
var LexemeCode: Word;
begin
     if ((LexemeCode <> 0) and (ATopState <> 0))
     then AAction := ActionTable[ ATopState, ATerminal]
     else begin
          AAction.Action := actError;
          AAction.ErrorCode := 0;
          StopParsing;
          end;
end;

function TLexPrgramParser.GetNonterminal( ARule: Byte): Byte;
begin
     if (ARule <> 0)
     then GetNonterminal := RulesSymbol[ ARule]
     else begin
          StopParsing;
          GetNonterminal := 0;
          end;
end;

function TLexPrgramParser.GetRuleSize( ARule: Byte): Byte;
begin
     if (ARule <> 0)
     then GetRuleSize := RuleSizes[ ARule]
     else GetRuleSize := 0;
end;

procedure TLexPrgramParser.Error( AErrorCode: Byte);
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

procedure TLexPrgramParser.Semantic1;
begin
     { S -> lex }
end;

procedure TLexPrgramParser.Semantic2;
begin
     { lex -> decls %% rules %% }
end;

procedure TLexPrgramParser.Semantic3;
begin
     { decls -> decls decl }
end;

procedure TLexPrgramParser.Semantic4;
begin
     { decls -> decl }
     { No thing to do ... }
end;

procedure TLexPrgramParser.Semantic5;
var Reg: PRegExp;
    Id: PIDAttribute;
begin
     { decl -> id = re ; }
     PGeneric(Reg) := PopAttribute;
     PGeneric(Id) := PopAttribute;
     Database^.AddDefine( Id^.GetString, Reg);
     Id^.Free;
end;

procedure TLexPrgramParser.Semantic6;
begin
     { rules -> rules rule }
end;

procedure TLexPrgramParser.Semantic7;
begin
     { rules -> rule }
     { No thing to do ... }
end;

procedure TLexPrgramParser.Semantic8;
var RE: PRegExp;
    Block: PBlockAttribute;
begin
     { rule -> re : block }
     PGeneric(Block) := PopAttribute;
     PGeneric(RE) := PopAttribute;
     Database^.AddProcedure( Block^.GetBuffer^, Block^.BufferSize, RE);
     Block^.Free;
end;

procedure TLexPrgramParser.Semantic9;
var Reg1, Reg2, Reg3: PRegExp;
begin
     { re -> re sr }
     PGeneric(Reg2) := PopAttribute;
     PGeneric(Reg1) := PopAttribute;
     PGeneric(Reg3) := New( PConcatExp, Create( nil, Reg1, Reg2));
     PushAttribute( Reg3);
end;

procedure TLexPrgramParser.Semantic10;
var Reg1, Reg2, Reg3: PRegExp;
begin
     { re -> re | sr }
     PGeneric(Reg2) := PopAttribute;
     PGeneric(Reg1) := PopAttribute;
     PGeneric(Reg3) := New( POrExp, Create( nil, Reg1, Reg2));
     PushAttribute( Reg3);
end;

procedure TLexPrgramParser.Semantic11;
begin
     { re -> sr }
     { No thing to do ... }
end;

procedure TLexPrgramParser.Semantic12;
var Reg1, Reg2: PRegExp;
begin
     { sr -> sr * }
     PGeneric(Reg1) := PopAttribute;
     PGeneric(Reg2) := New( PStarExp, Create( nil, Reg1));
     PushAttribute( Reg2);
end;

procedure TLexPrgramParser.Semantic13;
var Reg1, Reg2: PRegExp;
begin
     { sr -> sr + }
     PGeneric(Reg1) := PopAttribute;
     PGeneric(Reg2) := New( PPlusExp, Create( nil, Reg1));
     PushAttribute( Reg2);
end;

procedure TLexPrgramParser.Semantic14;
var Reg1, Reg2: PRegExp;
begin
     { sr -> sr ? }
     PGeneric(Reg1) := PopAttribute;
     PGeneric(Reg2) := New( PQMarkExp, Create( nil, Reg1));
     PushAttribute( Reg2);
end;

procedure TLexPrgramParser.Semantic15;
var Ch: PCharAttribute;
    SymbolSet: PSymbolSet;
    Reg1: PRegExp;
begin
     { sr -> char' }
     PGeneric(Ch) := PopAttribute;
     SymbolSet := Database^.CreateSet( [Ch^.GetChar]);
     Reg1 := New(PSymbolExp, Create( nil, SymbolSet));
     Reg1 := New(PBuffExp, Create( nil, Reg1));
     PushAttribute( Reg1);
     Ch^.Free;
end;

procedure TLexPrgramParser.Semantic16;
var CSet: PCharSetAttribute;
    SymbolSet: PSymbolSet;
    Reg1: PRegExp;
begin
     { sr -> [ set ] }
     PGeneric(CSet) := PopAttribute;
     SymbolSet := Database^.CreateSet( CSet^.GetCharSet^);
     Reg1 := New(PSymbolExp, Create( nil, SymbolSet));
     Reg1 := New(PBuffExp, Create( nil, Reg1));
     PushAttribute( Reg1);
     CSet^.Free;
end;

procedure TLexPrgramParser.Semantic17;
var Id: PIDAttribute;
    Reg1: PRegExp;
    Reg2: PRegExp;
begin
     { sr -> id }
     PGeneric(ID) := PopAttribute;
     Reg1 := Database^.GetExpresion( Id^.GetString);
     if (Reg1 <> nil)
     then begin
          Reg2 := Reg1^.Clone;
          PushAttribute( Reg2);
          end
     else Error( 100);
     Id^.Free;
end;

procedure TLexPrgramParser.Semantic18;
var Str: PStringAttribute;
    BufferSize: Word;
    Buffer: PChar;
    I: Integer;
    Reg1, Reg2: PRegExp;
begin
     { sr -> str' }
     PGeneric(Str) := PopAttribute;
     BufferSize := Str^.GetSize;
     if (BufferSize > 0)
     then begin
          Buffer := Str^.GetBuffer;
          Reg1 := New( PSymbolExp, Create( nil, Database^.CreateSet( [Buffer^])));
          I := 1;
          while I < BufferSize
          do begin
             Buffer := Buffer + 1;
             I := I + 1;
             Reg2 := New( PSymbolExp, Create( nil, Database^.CreateSet( [Buffer^])));
             Reg1 := New( PConcatExp, Create( nil, Reg1, Reg2));
             end;
          PushAttribute( Reg1);
          end
     else Error(100);
     Str^.Free;
end;

procedure TLexPrgramParser.Semantic19;
begin
     { sr -> ( re ) }
     { No thing to do ... }
end;

procedure TLexPrgramParser.Semantic20;
var CSet1, CSet2: PCharSetAttribute;
begin
     { set -> set , sset }
     PGeneric(CSet2) := PopAttribute;
     PGeneric(CSet1) := PopAttribute;
     CSet1^.GetCharSet^ := CSet1^.GetCharSet^ + CSet2^.GetCharSet^;
     PushAttribute( CSet1);
     Cset2^.Free;
end;

procedure TLexPrgramParser.Semantic21;
begin
     { set -> sset' }
     { No thing to do ... }
end;

procedure TLexPrgramParser.Semantic22;
var CSet: PCharSetAttribute;
    Ch: PCharAttribute;
begin
     { sset -> char }
     PGeneric(Ch) := PopAttribute;
     CSet := New( PCharSetAttribute, Create([Ch^.GetChar]));
     PushAttribute(CSet);
     Ch^.Free;
end;

procedure TLexPrgramParser.Semantic23;
var CSet: PCharSetAttribute;
    Ch1, Ch2: PCharAttribute;
begin
     { sset -> char - char }
     PGeneric(Ch2) := PopAttribute;
     PGeneric(Ch1) := PopAttribute;
     if Ch2^.GetChar >= Ch1^.GetChar
     then begin
          CSet := New( PCharSetAttribute, Create([Ch1^.GetChar..Ch2^.GetChar]));
          PushAttribute( CSet);
          end
     else Error(100);
     Ch1^.Free;
     Ch2^.Free;
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
begin
     GetString := StrPas( ID);
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TCharAttribute.Create( AChar: Char);
begin
     inherited Create;
     C := AChar;
end;

destructor TCharAttribute.Destroy;
begin
     inherited Destroy;
end;

function TCharAttribute.GetChar: Char;
begin
     GetChar := C;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TCharSetAttribute.Create( ACharSet: TCharSet);
begin
     inherited Create;
     CharSet := ACharSet;
end;

destructor TCharSetAttribute.Destroy;
begin
     inherited Destroy;
end;

function TCharSetAttribute.GetCharSet: PCharSet;
begin
     GetCharSet := @CharSet;
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
