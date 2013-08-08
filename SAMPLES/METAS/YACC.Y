%type canonical
%token dp declcommand id colen sc bar block
%start S

%%
S       : YACC                                  #{#}
        ;
YACC    : DECLS dp RULES dp                     #{#}
        ;
DECLS   : DECLS DECL                            #{#}
        | DECL                                  #{#}
        ;
DECL    : declcommand IDLIST                    #{#}
        ;
IDLIST  : IDLIST id                             #{#}
        | id                                    #{#}
        ;
RULES   : RULES RULE                            #{#}
        | RULE                                  #{#}
        ;
RULE    : LSIDE colen RSIDES sc                 #{#}
        ;
LSIDE   : id                                    #{#}
        ;
RSIDES  : RSIDES bar RSIDE                      #{#}
        | RSIDE                                 #{#}
        ;
RSIDE   : SYMBOLS block                         #{#}
        | block                                 #{#}
        ;
SYMBOLS : SYMBOLS id                            #{#}
        | id                                    #{#}
        ;
%%





