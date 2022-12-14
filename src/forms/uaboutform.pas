unit uAboutForm;

{$mode ObjFPC}{$H+}

interface

uses
  Forms, ExtCtrls, StdCtrls, LCLIntf, Classes;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    imgLogo: TImage;
    lblAppName: TLabel;
    lblHomepage: TLabel;
    lblGithub: TLabel;
    lblLicense: TLabel;
    procedure FormShow(Sender: TObject);
    procedure lblHomepageClick(Sender: TObject);
    procedure lblGithubClick(Sender: TObject);
    procedure lblLicenseClick(Sender: TObject);
  end;

implementation

{$R *.lfm}

{ TfrmAbout }

procedure TfrmAbout.lblHomepageClick(Sender: TObject);
begin
  OpenURL('https://helltar.com');
end;

procedure TfrmAbout.FormShow(Sender: TObject);
begin
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
end;

procedure TfrmAbout.lblGithubClick(Sender: TObject);
begin
  OpenURL('https://github.com/Helltar/idevicegui');
end;

procedure TfrmAbout.lblLicenseClick(Sender: TObject);
begin
  OpenURL('https://raw.githubusercontent.com/Helltar/idevicegui/master/LICENSE');
end;

end.
