unit uMainForm;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, Graphics, Dialogs, StdCtrls, ExtCtrls, ActnList, LCLIntf, Buttons, Menus,
  //------
  uConfig;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    actMount: TAction;
    actUmount: TAction;
    actlMain: TActionList;
    bitBtnMenu: TBitBtn;
    btnMount: TButton;
    btnUmount: TButton;
    gbInfo: TGroupBox;
    lblModelNumberData: TLabel;
    lbliOSVersionData: TLabel;
    lblSerialNumberData: TLabel;
    lblCycleCountData: TLabel;
    lblSpaceUsedData: TLabel;
    lblSpaceUsed: TLabel;
    lblModelNumber: TLabel;
    lbliOSVersion: TLabel;
    lblSerialNumber: TLabel;
    lblCycleCount: TLabel;
    separator: TMenuItem;
    miAbout: TMenuItem;
    miSettings: TMenuItem;
    miExit: TMenuItem;
    pnlButtons: TPanel;
    pmMain: TPopupMenu;
    tmMain: TTimer;
    procedure actMountExecute(Sender: TObject);
    procedure actMountUpdate(Sender: TObject);
    procedure actUmountExecute(Sender: TObject);
    procedure actUmountUpdate(Sender: TObject);
    procedure bitBtnMenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miSettingsClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure tmMainTimer(Sender: TObject);
  private
    mountDir: string;
  public
    config: TConfig;
    procedure updateControls();
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uSettingsForm, uAboutForm,
  uUtils, uidevice;

resourcestring
  RS_GB_INFO_CAPTION = 'not plugged';

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
end;

procedure TfrmMain.miSettingsClick(Sender: TObject);
begin
  with TfrmSettings.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfrmMain.miAboutClick(Sender: TObject);
begin
  with TfrmAbout.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfrmMain.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.tmMainTimer(Sender: TObject);
begin
  updateControls();
end;

procedure TfrmMain.actUmountUpdate(Sender: TObject);
begin
  actUmount.Enabled := not mountDir.IsEmpty;
end;

procedure TfrmMain.bitBtnMenuClick(Sender: TObject);
begin
  pmMain.PopUp;
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
var
  deviceName: string;

begin
  if isDevicePlugged() then
  begin
    if not gbInfo.Enabled then
      gbInfo.Enabled := True;

    deviceName := getDeviceName();

    if gbInfo.Caption <> deviceName then
      gbInfo.Caption := deviceName;

    if lblModelNumberData.Caption = '' then
      lblModelNumberData.Caption := getDeviceInfoByKey('RegulatoryModelNumber');

    if lbliOSVersionData.Caption = '' then
      lbliOSVersionData.Caption := getDeviceInfoByKey('ProductVersion');

    if lblSerialNumberData.Caption = '' then
      lblSerialNumberData.Caption := getDeviceInfoByKey('SerialNumber');

    if lblCycleCountData.Caption = '' then
      lblCycleCountData.Caption := getDeviceCycleCount();

    if lblSpaceUsedData.Caption = '' then
      lblSpaceUsedData.Caption :=
        formatByteSize(StrToInt64(getDiskUsage(TOTAL_DATA_CAPACITY))) + ' / ' + formatDiskCapacity(StrToInt64(getDiskUsage(TOTAL_DISK_CAPACITY)));
  end
  else
  if gbInfo.Enabled then
  begin
    gbInfo.Enabled := False;
    gbInfo.Caption := RS_GB_INFO_CAPTION;
    lblModelNumberData.Caption := '';
    lbliOSVersionData.Caption := '';
    lblSerialNumberData.Caption := '';
    lblCycleCountData.Caption := '';
    lblSpaceUsedData.Caption := '';
  end;
end;

end.
