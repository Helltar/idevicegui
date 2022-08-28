unit uLogger;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs;

procedure addLog(const message: string);

implementation

procedure addLog(const message: string);
begin
  ShowMessage(message);
  WriteLn(message);
end;

end.
