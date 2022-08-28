unit uMainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Graphics, Dialogs, StdCtrls, ExtCtrls, ActnList, LCLIntf,
  //------
  uConfig;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    actMount: TAction;
    actUmount: TAction;
    actlMain: TActionList;
    btnMount: TButton;
    btnUmount: TButton;
    btnSettings: TButton;
    btnExit: TButton;
    btnAbout: TButton;
    gbInfo: TGroupBox;
    lblSpaceUsed: TLabel;
    lblDataCapacity: TLabel;
    lblDiskCapacity: TLabel;
    lblModelNumber: TLabel;
    lbliOSVersion: TLabel;
    lblSerialNumber: TLabel;
    lblCycleCount: TLabel;
    pnlButtons: TPanel;
    tmMain: TTimer;
    procedure actMountExecute(Sender: TObject);
    procedure actMountUpdate(Sender: TObject);
    procedure actUmountExecute(Sender: TObject);
    procedure actUmountUpdate(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmMainTimer(Sender: TObject);
  private
    mountDir: string;
    procedure updateControls();
  public
    config: TConfig;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uSettingsForm, uAboutForm,
  uUtils, uidevice;

resourcestring
  {$I strings.inc}

const
  CONFIG_FILE = 'config';
  DIR_DCIM = 'DCIM';

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
var
  configDir: string;

begin
  configDir := GetAppConfigDir(False);

  if not DirectoryExists(configDir) then
    mkDir(configDir);

  config := TConfig.Create(configDir + CONFIG_FILE);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(config);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
  Constraints.MaxHeight := Height;
  Constraints.MaxWidth := Width;
end;

procedure TfrmMain.tmMainTimer(Sender: TObject);
begin
  updateControls();
end;

procedure TfrmMain.actUmountUpdate(Sender: TObject);
begin
  actUmount.Enabled := not mountDir.IsEmpty;
end;

procedure TfrmMain.btnAboutClick(Sender: TObject);
begin
  with TfrmAbout.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnSettingsClick(Sender: TObject);
begin
  with TfrmSettings.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfrmMain.actMountUpdate(Sender: TObject);
begin
  actMount.Enabled := isDevicePlugged() and (mountDir.IsEmpty);
end;

procedure TfrmMain.actMountExecute(Sender: TObject);
begin
  mountDir := mount(config.mountPoint);

  if not mountDir.IsEmpty then
    OpenDocument(mountDir + DirectorySeparator + DIR_DCIM);
end;

procedure TfrmMain.actUmountExecute(Sender: TObject);
begin
  if umount(mountDir) then
  begin
    RemoveDir(mountDir);
    mountDir := '';
  end;
end;

procedure TfrmMain.updateControls;
const
  DELIMITER = ': ';

begin
  if isDevicePlugged() then
  begin
    gbInfo.Enabled := True;
    gbInfo.Caption := getDeviceName();

    lblModelNumber.Caption := RS_MODEL_NUMBER_CAPTION + DELIMITER + getDeviceInfoByKey('RegulatoryModelNumber');
    lbliOSVersion.Caption := RS_OS_VERSION_CAPTION + DELIMITER + getDeviceInfoByKey('ProductVersion');
    lblSerialNumber.Caption := RS_SERIAL_NUMBER_CAPTION + DELIMITER + getDeviceInfoByKey('SerialNumber');
    lblCycleCount.Caption := RS_CYCLE_COUNT_CAPTION + DELIMITER + getDeviceCycleCount();

    lblSpaceUsed.Caption := RS_SPACE_USED + DELIMITER;
    lblDataCapacity.Caption := formatByteSize(StrToInt64(getDiskUsage(TOTAL_DATA_CAPACITY))) + ' / ';
    lblDiskCapacity.Caption := formatDiskCapacity(StrToInt64(getDiskUsage(TOTAL_DISK_CAPACITY)));
  end
  else
  begin
    gbInfo.Enabled := False;
    gbInfo.Caption := RS_GB_INFO_CAPTION;

    lblModelNumber.Caption := RS_MODEL_NUMBER_CAPTION;
    lbliOSVersion.Caption := RS_OS_VERSION_CAPTION;
    lblSerialNumber.Caption := RS_SERIAL_NUMBER_CAPTION;
    lblCycleCount.Caption := RS_CYCLE_COUNT_CAPTION;

    lblSpaceUsed.Caption := RS_SPACE_USED;
    lblDataCapacity.Caption := '';
    lblDiskCapacity.Caption := '';
  end;
end;

end.
