unit uidevice;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, uregexpr;

function getDeviceCycleCount(): string;
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

function getDeviceInfoByKey(const key: string): string;
begin
  Result := Trim(procStart('ideviceinfo', '-k' + LineEnding + key).Output);
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
