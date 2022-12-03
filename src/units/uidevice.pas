unit uidevice;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, uregexpr;

const
  TOTAL_DATA_AVAILABLE = 'TotalDataAvailable';
  TOTAL_DATA_CAPACITY = 'TotalDataCapacity';
  TOTAL_DISK_CAPACITY = 'TotalDiskCapacity';

function getDeviceCycleCount(): string;
function getDeviceInfoByKey(const key: string): string;
function getDeviceName(): string;
function getDiskUsage(const dType: string): int64;
function isDevicePlugged(): boolean;

implementation

uses
  uUtils;

function getDiskUsage(const dType: string): int64;
begin
  Result :=
    StrToInt64(
    Trim(
    procStart(
    'ideviceinfo', '-q' + LineEnding + 'com.apple.disk_usage.factory' + LineEnding + '-k' + LineEnding + dType)
    .Output)
    );
end;

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
  Result := '-1';

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
