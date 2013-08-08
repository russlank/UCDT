uses Generics, DrawLexical, DrawParser, Graph, Crt;

type PDrawApp = ^TDrawApp;
     TDrawApp = object( TTopErrGeneric)
     public
        constructor Create;
        destructor Destroy; virtual;
        procedure Run;
        end;

constructor TDrawApp.Create;
begin
     inherited Create;
end;

destructor TDrawApp.Destroy;
begin
     GenericsDone;
     inherited Destroy;
end;

procedure TDrawApp.Run;
var Input: TFileStream;
    Parser: TDrawParser;
    GD, GM: Integer;
    ErrorsCount: Integer;
    ErrorNo: Integer;
    Error: PMessageError;
begin
     ClrScr;
     GD := Detect;
     InitGraph( GD, GM, '');
     Input.Create( ParamStr(1), fstOpenRead);
     if ( Input.GetErrorCode = 0)
     then begin
          Parser.Create( @Self, @Input);
          Parser.ParsLoop;
          Parser.Destroy;
          end
     else AddError( New( PMessageError, Create( Input.GetErrorMessage)));
     Input.Destroy;
     if AnyError
     then begin
          CloseGraph;
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
          end
     else ReadKey;
     CloseGraph;
end;


var App: TDrawApp;
begin
     App.Create;
     App.Run;
     App.Destroy;
end.