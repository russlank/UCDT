{********************************************************}
{*                                                      *}
{*   LEX tool tokens define unit                        *}
{*                                                      *}
{*   File name : LEXDEFS.PAS                            *}
{*                                                      *}
{*   Programming: Russlan Kafri - 1999                  *}
{*                                                      *}
{********************************************************}


unit LexDefs;

interface

const lexNone           = 0;
      lexError          = $FFFF;
      lexDPercent       = 1;
      lexIdentifier     = 2;
      lexEqual          = 3;
      lexSemi           = 4;
      lexColen          = 5;
      lexBody           = 6;
      lexBar            = 7;
      lexStar           = 8;
      lexPlus           = 9;
      lexQMark          = 10;
      lexChar           = 11;
      lexLeftMB         = 12;
      lexRightMB        = 13;
      lexString         = 14;
      lexLeftB          = 15;
      lexRightB         = 16;
      lexComa           = 17;
      lexMinus          = 18;
      lexEOF            = 19;

implementation

end.