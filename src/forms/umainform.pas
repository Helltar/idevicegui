unit uMainForm;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, Graphics, Dialogs, StdCtrls, ExtCtrls, ActnList, LCLIntf;

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
    procedure btnExitClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmMainTimer(Sender: TObject);
  private
    mountDir: string;
    procedure updateControls();
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uUtils, uidevice;

resourcestring
  {$I strings.inc}

const
  DIR_DCIM = 'DCIM';

{$R *.lfm}

{ TfrmMain }

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

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.actMountUpdate(Sender: TObject);
begin
  actMount.Enabled := isDevicePlugged() and (mountDir.IsEmpty);
end;

procedure TfrmMain.actMountExecute(Sender: TObject);
begin
  mountDir := mount(GetUserDir + 'Downloads/');

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
    gbInfo.Caption := getDeviceName();
    lblModelNumber.Caption := RS_MODEL_NUMBER_CAPTION + DELIMITER + getDeviceInfoByKey('ModelNumber');
    lbliOSVersion.Caption := RS_OS_VERSION_CAPTION + DELIMITER + getDeviceInfoByKey('ProductVersion');
    lblSerialNumber.Caption := RS_SERIAL_NUMBER_CAPTION + DELIMITER + getDeviceInfoByKey('SerialNumber');
    lblCycleCount.Caption := RS_CYCLE_COUNT_CAPTION + DELIMITER + getDeviceCycleCount();
  end
  else
  begin
    gbInfo.Caption := RS_GB_INFO_CAPTION;
    lblModelNumber.Caption := RS_MODEL_NUMBER_CAPTION + DELIMITER + RS_NULL;
    lbliOSVersion.Caption := RS_OS_VERSION_CAPTION + DELIMITER + RS_NULL;
    lblSerialNumber.Caption := RS_SERIAL_NUMBER_CAPTION + DELIMITER + RS_NULL;
    lblCycleCount.Caption := RS_CYCLE_COUNT_CAPTION + DELIMITER + RS_NULL;
  end;
end;

end.
