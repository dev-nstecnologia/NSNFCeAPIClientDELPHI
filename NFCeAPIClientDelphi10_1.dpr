program NFCeAPIClientDelphi10_1;

uses
  Vcl.Forms,
  principal in 'principal.pas' {frmPrincipal},
  NFCeAPI in 'NFCeAPI.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
