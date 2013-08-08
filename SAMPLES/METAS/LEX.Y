%type lalr
%token dp id equ sc colen block bar str lb rb char minus coma
%token star plus qmark lmb rmb
%start S

%%

S         : LEX                                           #{#}
          ;
LEX       : DECLS dp RULES dp                             #{#}
          ;
DECLS     : DECLS DECL                                    #{#}
          | DECL                                          #{#}
          ;
DECL      : id equ RE sc                                  #{#}
          ;
RULES     : RULES RULE                                    #{#}
          | RULE                                          #{#}
          ;
RULE      : RE colen block                                #{#}
          ;
RE        : RE SR                                         #{#}
          | RE bar SR                                     #{#}
          | SR                                            #{#}
          ;
SR        : SR star                                       #{#}
          | SR plus                                       #{#}
          | SR qmark                                      #{#}
          | char                                          #{#}
          | lmb SETCHARS rmb                              #{#}
          | id                                            #{#}
          | str                                           #{#}
          | lb RE rb                                      #{#}
          ;
SETCHARS  : SETCHARS coma SSETCHARS                       #{#}
          | SSETCHARS                                     #{#}
          ;
SSETCHARS : char                                          #{#}
          | char minus char                               #{#}
          ;
%%
