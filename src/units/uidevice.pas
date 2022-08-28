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
function getDiskUsage(const dType: string): string;
function isDevicePlugged(): boolean;

implementation

uses
  uUtils;

function getDiskUsage(const dType: string): string;
begin
  Result := '0';

  with TStringList.Create do
    try
      Text := Trim(procStart('ideviceinfo', '-q' + LineEnding + 'com.apple.disk_usage.factory').Output);

      with TRegExpr.Create do
        try
          Expression := dType + ': (.*?)' + LineEnding;

          if Exec(Text) then
            Result := Match[1];
        finally
          Free;
        end;
    finally
      Free;
    end;
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
