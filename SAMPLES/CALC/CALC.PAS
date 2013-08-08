uses Generics, CalcLexical, CalcParser, Crt;
var Input: PFileStream;
    Parser: PCalcParser;
begin
     ClrScr;
     Input := New( PFileStream, Create('INPUT.TXT', fstOpenRead));
     Parser := New( PCalcParser, Create( nil, Input));
     Parser^.ParsLoop;
     Parser^.Free;
     Input^.Free;
end.