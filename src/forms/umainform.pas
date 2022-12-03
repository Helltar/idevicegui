unit uMainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ActnList, LCLIntf, Buttons, Menus, Clipbrd, ATButtons,
  //------
  uConfig;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    actUpdateButtons: TAction;
    actlMain: TActionList;
    actMount: TAction;
    btnMount: TATButton;
    btnUmount: TATButton;
    btnMenu: TATButton;
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
    pmMain: TPopupMenu;
    tmMain: TTimer;
    procedure actUpdateButtonsUpdate(Sender: TObject);
    procedure btnMenuClick(Sender: TObject);
    procedure btnMountClick(Sender: TObject);
    procedure btnUmountClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblSerialNumberDataClick(Sender: TObject);
    procedure miSettingsClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure tmMainTimer(Sender: TObject);
  private
    mountDir: string;
    function umount(): boolean;
    function isDCIMMount(): boolean;
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

  updateControls();
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

procedure TfrmMain.lblSerialNumberDataClick(Sender: TObject);
begin
  Clipboard.AsText := lblSerialNumberData.Caption;
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

procedure TfrmMain.btnMenuClick(Sender: TObject);
begin
  pmMain.PopUp;
end;

procedure TfrmMain.actUpdateButtonsUpdate(Sender: TObject);
begin
  btnMount.Enabled := isDevicePlugged() and not isDCIMMount();
  btnUmount.Enabled := not mountDir.IsEmpty;
end;

procedure TfrmMain.btnMountClick(Sender: TObject);
begin
  mountDir := mount(config.mountPoint);

  if isDCIMMount() then
    OpenDocument(mountDir + DirectorySeparator + DIR_DCIM);
end;

procedure TfrmMain.btnUmountClick(Sender: TObject);
begin
  umount();
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := True;

  if isDCIMMount() then
    CanClose := umount();
end;

function TfrmMain.umount: boolean;
begin
  Result := False;

  if isDCIMMount() then
    if uUtils.umount(mountDir) then
    begin
      RemoveDir(mountDir);
      mountDir := '';
      Result := True;
    end;
end;

function TfrmMain.isDCIMMount: boolean;
begin
  Result := not mountDir.IsEmpty;
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
      lblSerialNumberData.Caption := getDeviceInfoByKey('SerialNumber'); // 'DX0XXXXXX000'

    if lblCycleCountData.Caption = '' then
      lblCycleCountData.Caption := getDeviceCycleCount();

    if lblSpaceUsedData.Caption = '' then
      lblSpaceUsedData.Caption :=
        formatByteSize(getDiskUsage(TOTAL_DISK_CAPACITY) - getDiskUsage(TOTAL_DATA_AVAILABLE)) + ' / ' +
        formatDiskCapacity(getDiskUsage(TOTAL_DISK_CAPACITY));
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
