{********************************************************}
{*                                                      *}
{*   YACC tool main program                             *}
{*                                                      *}
{*   File name : YACC.PAS                               *}
{*                                                      *}
{*   Programming: Russlan Kafri - 1999                  *}
{*                                                      *}
{********************************************************}

program YACC;

uses Generics, YaccEngine, YaccParser, YaccLexical, Lexical;

type PYacc = ^TYacc;
     TYacc = object( TTopErrGeneric)
     private
        Database: TYaccDatabase;
     public
        constructor Create;
        destructor Destroy; virtual;
        procedure Run;
        end;

{******************************************************************}
{*                                                                *}
{******************************************************************}

constructor TYacc.Create;
begin
     inherited Create;
     Database.Create( @Self);
end;

destructor TYacc.Destroy;
begin
     Database.Destroy;
     inherited Destroy;
end;

procedure TYacc.Run;
var Source: PFileStream;
    Skeleton: PFileStream;
    Target: PFileStream;

    Parser: TYaccParser;
    OutputGenerator: POutputGenerator;

    ErrorsCount: Integer;
    ErrorNo: Integer;
    Error: PMessageError;
begin
     DataBase.Clear;

     WriteLn;
     WriteLn('UYACC Tool V1.00, 1999');
     WriteLn('By: Russlan Kafri');
     WriteLn;

     Source := New( PFileStream, Create( ParamStr(1), fstOpenRead));

     if (Source^.GetErrorCode = 0)
     then begin
          Parser.Create( @Self, Source, @Database);
          WriteLn('Parsing input file ~' + ParamStr(1) + '~ ...');
          if Parser.ParsLoop
          then begin
               WriteLn('Building LR table ...');
               Database.Build;

               if ( ParamStr(3) <> '')
               then begin
                    WriteLn('Using file ~' + ParamStr(3) + '~ as skeleton ...');
                    Skeleton := New( PFileStream, Create( ParamStr(3), fstOpenRead));
                    end
               else Skeleton := nil;

               if ( ParamStr(2) <> '')
               then begin
                    Target := New( PFileStream, Create( ParamStr(2), fstCreate));
                    WriteLn('Generating output to ~' + ParamStr(2) + '~...');
                    end
               else begin
                    Target := New( PFileStream, Create( 'YACC.OUT', fstCreate));
                    WriteLn('Generating output to ~YACC.OUT~...');
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

var YaccApplication: TYacc;
begin
     YaccApplication.Create;
     YaccApplication.Run;
     YaccApplication.Destroy;
     GenericsDone;
end.
