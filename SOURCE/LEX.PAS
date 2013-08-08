{********************************************************}
{*                                                      *}
{*   LEX tool main program                              *}
{*                                                      *}
{*   File name: LEX.PAS                                 *}
{*                                                      *}
{*   Programming: Russlan Kafri - 1999                  *}
{*                                                      *}
{********************************************************}

program LEX;

uses Generics, LexEngine, LexParser, LexLexical, Lexical;

type PLex = ^TLex;
     TLex = object( TTopErrGeneric)
     private
        Database: TLexDatabase;
     public
        constructor Create;
        destructor Destroy; virtual;
        procedure Run;
        end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TLex.Create;
begin
     inherited Create;
     Database.Create( @Self);
end;

destructor TLex.Destroy;
begin
     Database.Destroy;
     inherited Destroy;
end;

procedure TLex.Run;
var Source: PFileStream;
    Skeleton: PFileStream;
    Target: PFileStream;
    Parser: TLexPrgramParser;
    OutputGenerator: POutputGenerator;
    F: Text;
    ErrorsCount: Integer;
    ErrorNo: Integer;
    Error: PMessageError;
begin
     WriteLn;
     WriteLn('ULEX Tool V1.00, 1999');
     WriteLn('By: Russlan Kafri');
     WriteLn;

     Source := New( PFileStream, Create(ParamStr(1), fstOpenRead));
     if ( Source^.GetErrorCode = 0)
     then begin
          WriteLn('Parsing input file ~' + ParamStr(1) + '~ ...');
          Parser.Create( @Self, Source, @Database);
          if Parser.ParsLoop
          then begin
               Database.SeparateSymbolSets;
               WriteLn('Building DFA table ...');
               Database.BuildAuto;


               if ( ParamStr(3) <> '')
               then begin
                    WriteLn('Using file ~' + ParamStr(3) + '~ as skeleton ...');
                    Skeleton := New( PFileStream, Create( ParamStr(3), fstOpenRead))
                    end
               else Skeleton := nil;

               if ( ParamStr(2) <> '')
               then begin
                    WriteLn('Generating output to ~' + ParamStr(2) + '~...');
                    Target := New( PFileStream, Create( ParamStr(2), fstCreate));
                    end
               else begin
                    WriteLn('Generating output to ~LEX.OUT~...');
                    Target := New( PFileStream, Create( 'LEX.OUT', fstCreate));
                    end;
               OutputGenerator := New( POutputGenerator, Create( @self, @DataBase, Skeleton, Target));
               OutputGenerator^.GenerateOutput;
               OutputGenerator^.Free;
               Target^.Free;
               if ( Skeleton <> nil)
               then Skeleton^.Free;
               WriteLn('Finished ...');
               WriteLn;
               end;
          Parser.Destroy;
          end
     else AddError( New( PMessageError, Create(Source^.GetErrorMessage)));
     Source^.Free;

     if AnyError
     then begin
          ErrorsCount := GetErrorsCount;
          if (ErrorsCount > 0)
          then begin
               for ErrorNo := 1 to ErrorsCount
               do begin
                  Error := PMessageError( GetError( ErrorNo));
                  if ( Error <> nil)
                  then WriteLn( Error^.GetMessage);
                  end;
               end;
          end;
end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

var LexApplication: TLex;
begin
     LexApplication.Create;
     LexApplication.Run;
     LexApplication.Destroy;
     GenericsDone;
end.
