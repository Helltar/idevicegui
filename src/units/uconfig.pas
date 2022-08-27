unit uConfig;

{$mode ObjFPC}{$H+}

interface

uses
  IniFiles, SysUtils;

type

  { TConfig }

  TConfig = class(TIniFile)
  private
    function GetMountPoint: string;
    procedure SetMountPoint(AValue: string);
  public
    property mountPoint: string read GetMountPoint write SetMountPoint;
  end;

implementation

{ TConfig }

function TConfig.GetMountPoint: string;
begin
  Result := ReadString('MAIN', 'mountPoint', GetAppConfigDir(False) + 'mnt');
end;

procedure TConfig.SetMountPoint(AValue: string);
begin
  WriteString('MAIN', 'mountPoint', AValue);
end;

end.
