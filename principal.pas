unit principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TfrmPrincipal = class(TForm)
    labelTokenEnviar: TLabel;
    pgControl: TPageControl;
    formEmissao: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    btnEnviar: TButton;
    memoConteudoEnviar: TMemo;
    cbTpConteudo: TComboBox;
    chkExibir: TCheckBox;
    GroupBox4: TGroupBox;
    memoRetorno: TMemo;
    txtCaminho: TEdit;
    cbTpAmb: TComboBox;
    procedure btnEnviarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses NFCeAPI, System.JSON;

procedure TfrmPrincipal.btnEnviarClick(Sender: TObject);
var
  retorno: String;
  resposta: String;
  motivo, erros: String;
  statusEnvio, statusDownload: String;
  chNFe, cStat, nProt: String;
  jsonRetorno: TJSONObject;
begin
  // Valida se todos os campos foram preenchidos
  if ((txtCaminho.Text <> '') and (memoConteudoEnviar.Text <> '')) then
  begin
    memoRetorno.Lines.Clear;
    retorno := emitirNFCeSincrono(memoConteudoEnviar.Text, cbTpConteudo.Text,
    cbTpAmb.Text, txtCaminho.Text, chkExibir.Checked);
    memoRetorno.Text := retorno;

    //Tratamento de retorno
    jsonRetorno := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(retorno), 0) as TJSONObject;

	  statusEnvio := jsonRetorno.GetValue('statusEnvio').Value;
    statusDownload := jsonRetorno.GetValue('statusDownload').Value;
    cStat := jsonRetorno.GetValue('cStat').Value;
    chNFe := jsonRetorno.GetValue('chNFe').Value;
    nProt := jsonRetorno.GetValue('nProt').Value;
    motivo := jsonRetorno.GetValue('motivo').Value;
    erros := jsonRetorno.GetValue('erros').Value;

    // Testa se houve sucesso na emissão
    if ((statusEnvio = '100') Or (statusEnvio = '-100')) then
    begin
      // Testa se a nota foi autorizada
      if (cStat = '100') then
      begin
        ShowMessage(motivo);
        if (statusDownload <> '100') then
        begin
          // Aqui você pode realizar um tratamento em caso de erro no download
        end
      end
      else
      begin
        ShowMessage(motivo);
      end
    end
    else
    begin
      ShowMessage(motivo + #13 + erros);
    end
  end
  else
  begin
    Showmessage('Todos os campos devem estar preenchidos');
  end;
end;
end.
