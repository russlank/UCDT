%token plus minus mul div lb rb number
%start EXPR
%%
EXPR    : EXPR plus TERM                                #{#}
        | EXPR minus TERM                               #{#}
        | TERM                                          #{#}
        ;
TERM    : TERM mul FACT                                 #{#}
        | TERM div FACT                                 #{#}
        | FACT                                          #{#}
        ;
FACT    : lb EXPR rb                                    #{#}
        | number                                        #{#}
        ;
%%
