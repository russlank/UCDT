{********************************************************}
{*                                                      *}
{*   YACC tool tokens define unit                       *}
{*                                                      *}
{*   File name : YACCDEFS.PAS                           *}
{*                                                      *}
{*   Programming: Russlan Kafri - 1999                  *}
{*                                                      *}
{********************************************************}

unit YaccDefs;

interface

const lexNone           = 0;
      lexError          = $FFFF;
      lexDPercent       = 1;
      lexDeclCommand    = 2;
      lexIdentifier     = 3;
      lexColen          = 4;
      lexSemi           = 5;
      lexBar            = 6;
      lexBody           = 7;
      lexEOF            = 8;

implementation

end.