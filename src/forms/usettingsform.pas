unit uSettingsForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfrmSettings }

  TfrmSettings = class(TForm)
    btnOpenDir: TButton;
    btnSave: TButton;
    edtMountpoint: TEdit;
    lblMountpoint: TLabel;
    selectDirectoryDialog: TSelectDirectoryDialog;
    procedure btnOpenDirClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  end;

implementation

uses
  uMainForm;

{$R *.lfm}

{ TfrmSettings }

procedure TfrmSettings.FormShow(Sender: TObject);
begin
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
end;

procedure TfrmSettings.btnOpenDirClick(Sender: TObject);
begin
  if selectDirectoryDialog.Execute then
    edtMountpoint.Text := selectDirectoryDialog.FileName;
end;

procedure TfrmSettings.btnSaveClick(Sender: TObject);
begin
  frmMain.config.mountPoint := edtMountpoint.Text;
  Close;
end;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
  selectDirectoryDialog.InitialDir := frmMain.config.mountPoint;
  edtMountpoint.Text := frmMain.config.mountPoint;
end;

end.
