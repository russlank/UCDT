%type lalr
%token plus id
%start EXPR
%%
EXPR    : EXPR plus EXPR                                #{#}
        | id                                            #{#}
        ;
%%
