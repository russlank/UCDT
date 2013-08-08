/*****************************************************
*                                                    *
*   Lexical analyzer for YACC tool definition file   *
*   Date: 25-6-99                                    *
*                                                    *
******************************************************/

/* Definations */

LETTER     = [\A-\Z,\_,\a-\z];
DIGIT      = [\0-\9];
IDENTIFIER = LETTER(LETTER|DIGIT)*;
COMMAND    = \%IDENTIFIER;

/* Macros body lexeme define */
BODY       = "#{"([1-\",\$-255]|(\#[1-\|,\~-255]))*"#}" ;

/* Macros comments lexeme define */
COMMENT    = "/*"([1-\),\+-255]|(\*[1-\.,\0-255]))*"*/" ;

/* String constatnt lexeme */
STRING     = \"[1-\!,\#-255]*\";

/* Skipped characters */
BLANK      = [1-32]+;

%%

/* Lexical patterns */

IDENTIFIER          : #{YACC_Identifier#}
BLANK               : #{YACC_Blank#}
COMMENT             : #{YACC_Comment#}
BODY                : #{YACC_Body#}
COMMAND             : #{YACC_Command#}
\,                  : #{YACC_Coma#}
\|                  : #{YACC_Bar#}
\;                  : #{YACC_Semi#}
\:                  : #{YACC_Colen#}
"%%"                : #{YACC_DPercent#}

%%
