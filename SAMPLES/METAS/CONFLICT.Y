%type canonical
%start S
%token a c d
%%
S       : A             #{#}
        ;
A       : B             #{#}
        | C             #{#}
        ;
B       : D E F         #{#}
        ;
D       : a             #{#}
        ;
E       : a c           #{#}
        ;
F       : d             #{#}
        ;
C       : G H           #{#}
        ;
G       : D D           #{#}
        ;
H       : c d           #{#}
        ;
%%