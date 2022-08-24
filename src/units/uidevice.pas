unit uidevice;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, uregexpr;

function getDeviceCycleCount(): string;
function getDeviceInfo(): string;
function getDeviceInfoByKey(const key: string): string;
function getDeviceName(): string;
function isDevicePlugged(): boolean;

implementation

uses
  uUtils;

function isDevicePlugged: boolean;
begin
  Result := procStart('idevice_id').ExitStatus = 0;
end;

function getDeviceName: string;
begin
  Result := procStart('idevicename').Output;
end;

function getDeviceInfo: string;
begin
  Result := procStart('ideviceinfo').Output;
end;

function getDeviceInfoByKey(const key: string): string;
var
  sList: TStringList;
  s: string;

begin
  Result := '';

  sList := TStringList.Create;

  with sList do
    try
      sList.Text := getDeviceInfo;
      sList.Delimiter := LineEnding;

      for s in sList do
        if s.StartsWith(key) then
          Result := StringReplace(s, key + ': ', '', [rfReplaceAll]);
    finally
      FreeAndNil(sList);
    end;
end;

function getDeviceCycleCount: string;
begin
  Result := '';

  with TStringList.Create do
    try
      Text := Trim(procStart('idevicediagnostics', 'diagnostics' + LineEnding + 'GasGauge').Output);

      with TRegExpr.Create do
        try
          Expression := '<key>CycleCount</key>(.*?)<integer>(.*?)</integer>';

          if Exec(Text) then
            Result := Match[2];
        finally
          Free;
        end;
    finally
      Free;
    end;
end;

end.
