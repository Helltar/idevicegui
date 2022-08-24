unit uUtils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, process;

type
  TProcessRec = record
    Completed: boolean;
    Output: string;
    ExitStatus: integer;
  end;

function procStart(const AExecutable: string; const AParameters: TProcessStrings; const waitOnExit: boolean = True): TProcessRec;
function procStart(const executable, parameters: string; const waitOnExit: boolean = True): TProcessRec;
function procStart(const executable: string): TProcessRec;
function mount(const mountPoint: string): string;
function umount(const dir: string): boolean;

implementation

uses
  uLogger;

function procStart(const executable, parameters: string; const waitOnExit: boolean): TProcessRec;
var
  sParam, listParam: TStringList;
  s: string;

begin
  sParam := TStringList.Create;
  listParam := TStringList.Create;

  sParam.Text := parameters;
  sParam.Delimiter := LineEnding;

  for s in sParam do
    listParam.Add(s);

  Result := ProcStart(executable, listParam, waitOnExit);

  FreeAndNil(listParam);
  FreeAndNil(sParam);
end;

function procStart(const executable: string): TProcessRec;
begin
  Result := procStart(executable, '');
end;

function mount(const mountPoint: string): string;
var
  p: TProcessRec;
  dir: string;

begin
  Result := '';

  dir := mountPoint + 'idevice_' + TGUID.NewGuid.ToString(True).Split('-')[0];

  if not DirectoryExists(dir) then
    if CreateDir(dir) then
    begin
      p := procStart('ifuse', dir, False);

      if p.Completed then
        if p.ExitStatus = 0 then
          Result := dir
        else
          addLog(p.Output);
    end
    else
      addLog('Failed create directory: ' + dir);
end;

function umount(const dir: string): boolean;
var
  p: TProcessRec;

begin
  Result := False;

  p := procStart('fusermount', '-u' + LineEnding + dir);

  if p.Completed then
    if p.ExitStatus = 0 then
      Result := True
    else
      addLog(p.Output);
end;

function procStart(const AExecutable: string; const AParameters: TProcessStrings; const waitOnExit: boolean): TProcessRec;
var
  p: TProcess;

begin
  Result.Completed := False;
  Result.ExitStatus := -1;

  try
    p := TProcess.Create(nil);
    p.Executable := AExecutable;
    p.Parameters := AParameters;
    p.Options := [poStderrToOutPut, poUsePipes];

    try
      p.Execute;

      Result.Completed := p.WaitOnExit();
      Result.ExitStatus := p.ExitStatus;

      if waitOnExit then
        with TStringList.Create do
          try
            LoadFromStream(p.Output);
            Result.Output := Text;
          finally
            Free;
          end;
    except
      addLog('Failed run: ' + AExecutable);
    end;
  finally
    FreeAndNil(p);
  end;
end;

end.
