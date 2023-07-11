program Pix4Direto;

uses
  Vcl.Forms,
  frmMain in 'frmMain.pas' {frmPix4},
  pix4 in 'pix4.pas',
  geradorComandos in 'geradorComandos.pas',
  Pix4Communication in 'Pix4Communication.pas',
  Log in 'Log.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPix4, frmPix4);
  Application.Run;
end.
