/****************************************************
*                                                   *
*   Lexical analyzer for LEX tool definition file   *
*   Date: 25-6-99                                   *
*                                                   *
*****************************************************/

/* Definations */

LETTER     = [\A-\Z,\_,\a-\z];
DIGIT      = [\0-\9];
INTEGER    = DIGIT+;
CHAR       = (INTEGER)|(\\[32-127]);
ID         = LETTER(LETTER|DIGIT)*;
BODY       = "#{"([1-\",\$-255]|(\#[1-\|,\~-255]))*"#}" ; /* Macros body lexeme define */
COMMENT    = "/*"([1-\),\+-255]|(\*[1-\.,\0-255]))*"*/" ; /* Macros comments lexeme define */
STRING     = \"[1-\!,\#-255]*\";                          /* String constatnt lexeme */
BLANK      = [1-32]+;                                     /* Skipped characters */

%%

/* Lexical patterns */

CHAR                           : #{LEX_Char#}
ID                             : #{LEX_Identifier#}
BODY                           : #{LEX_Body#}
STRING                         : #{LEX_String#}
BLANK                          : #{LEX_Skip#}
COMMENT                        : #{LEX_Comment#}
\:                             : #{LEX_Colen#}
\;                             : #{LEX_Semi#}
\,                             : #{LEX_Coma#}
\(                             : #{LEX_LeftB#}
\)                             : #{LEX_RightB#}
\[                             : #{LEX_LeftMB#}
\]                             : #{LEX_RightMB#}
\?                             : #{LEX_QMark#}
\|                             : #{LEX_Bar#}
\*                             : #{LEX_Start#}
\+                             : #{LEX_Plus#}
\-                             : #{LEX_Minus#}
\=                             : #{LEX_Equal#}
"%%"                           : #{LEX_DPercent#}

%%
