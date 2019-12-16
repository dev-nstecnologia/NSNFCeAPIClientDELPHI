unit NFCeAPI;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, IdHTTP, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack,
  IdSSL, IdSSLOpenSSL, ShellApi, IdCoderMIME, EncdDecd;

function enviaConteudoParaAPI(conteudoEnviar, url, tpConteudo: String): String;
function emitirNFCeSincrono(conteudo, tpConteudo, tpAmb: String; caminho: String; exibeNaTela: boolean = false): String;
function emitirNFCe(conteudo, tpConteudo: String): String;
function downloadNFCe(chNFe, tpAmb:String): String;
function downloadNFCeESalvar(chNFe, tpAmb, caminho: String; exibeNaTela: Boolean): String;
function downloadEventoNFCeESalvar(chNFe, tpAmb, caminho: String; exibeNaTela: Boolean): String;
function cancelarNFCe(chNFe, tpAmb, dhEvento, nProt, xJust, caminho: String; exibeNaTela: boolean = false): String;
function consultaSituacao(chNFe, tpAmb: String): String;
function inutilizar(cUF, tpAmb, ano, CNPJ, serie, nNFIni, nNFFin, xJust:String): String;
function salvarXML(xml, caminho, chNFe: String; tpEvento: String = ''): String;
function salvarPDF(pdf, caminho, chNFe: String; tpEvento: String = ''): String;
procedure gravaLinhaLog(conteudo: String);

implementation

uses
  System.json;

var
  tempoResposta: String = '500';
  token: String = 'SEU_TOKEN';
  impressaoParam: String = '{'                          +
                              '"tipo": "pdf",'          +
                              '"ecologica": false,'     +
                              '"itemLinhas": "1",'      +
                              '"itemDesconto": false,'  +
                              '"larguraPapel": "80mm"'  +
                           '}';

  // Função genérica de envio para um url, contendo o token no header
function enviaConteudoParaAPI(conteudoEnviar, url, tpConteudo: String): String;
var
  retorno: String;
  conteudo: TStringStream;
  HTTP: TIdHTTP; // Disponível na aba 'Indy Servers'
  IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
  // Disponivel na aba Indy I/O Handlers
begin
  conteudo := TStringStream.Create(conteudoEnviar, TEncoding.UTF8);
  HTTP := TIdHTTP.Create(nil);
  try
    if tpConteudo = 'txt' then // Informa que vai mandar um TXT
    begin
      HTTP.Request.ContentType := 'text/plain;charset=utf-8';
    end
    else if tpConteudo = 'xml' then // Se for XML
    begin
      HTTP.Request.ContentType := 'application/xml;charset=utf-8';
    end
    else // JSON
    begin
      HTTP.Request.ContentType := 'application/json;charset=utf-8';
    end;

    // Abre SSL
    IdSSLIOHandlerSocketOpenSSL1 := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    HTTP.IOHandler := IdSSLIOHandlerSocketOpenSSL1;

    // Avisa o uso de UTF-8
    HTTP.Request.ContentEncoding := 'UTF-8';

    // Adiciona o token ao header
    HTTP.Request.CustomHeaders.Values['X-AUTH-TOKEN'] := token;
    // Result := conteudo.ToString;
    // Faz o envio por POST do json para a url
    try
      retorno := HTTP.Post(url, conteudo);

    except
      on E: EIdHTTPProtocolException do
        retorno := E.ErrorMessage;
      on E: Exception do
        retorno := E.Message;
    end;

  finally
    conteudo.Free();
    HTTP.Free();
  end;

  // Devolve o json de retorno da API
  Result := retorno;
end;

// Esta função emite uma NFC-e de forma síncrona, fazendo o envio e o download da nota
function emitirNFCeSincrono(conteudo, tpConteudo, tpAmb: String; caminho: String; exibeNaTela: boolean = false): String;
var
  retorno, resposta: String;
  statusEnvio, statusDownload, motivo, nsNRec: String;
  erros: TJSONValue;
  chNFe, cStat, nProt: String;
  jsonRetorno, jsonAux: TJSONObject;
  aux: String;
begin
  // Inicia as variáveis vazio
  statusEnvio := '';
  statusDownload := '';
  motivo := '';
  nsNRec := '';
  erros := TJSONString.Create('');
  chNFe := '';
  cStat := '';
  nProt := '';

  gravaLinhaLog('[EMISSAO_SINCRONA_INICIO]');

  resposta := emitirNFCe(conteudo, tpConteudo);
  jsonRetorno := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(resposta),
    0) as TJSONObject;
  statusEnvio := jsonRetorno.GetValue('status').Value;

  if (statusEnvio = '100') or (statusEnvio = '-100') then
  begin

    jsonAux := jsonRetorno.ParseJSONValue(TEncoding.ASCII.GetBytes(jsonRetorno.Get('nfeProc').JsonValue.ToString), 0) as TJSONObject; // Os dados de retorno encontram-se dentro de nfeProc
    cStat := jsonAux.GetValue('cStat').Value;

    if (cStat = '100') or (cStat = '150') then
    begin

      chNFe := jsonAux.GetValue('chNFe').Value;
      nProt := jsonAux.GetValue('nProt').Value;
      motivo := jsonAux.GetValue('xMotivo').Value;

      resposta := downloadNFCeESalvar(chNFe, tpAmb, caminho, exibeNaTela);
      jsonRetorno := TJSONObject.ParseJSONValue
        (TEncoding.ASCII.GetBytes(resposta), 0) as TJSONObject;
      statusDownload := jsonRetorno.GetValue('status').Value;

      if (statusDownload <> '100') then
      begin
        motivo := jsonRetorno.GetValue('motivo').Value;
      end;
    end
    else
    begin
      motivo := jsonAux.GetValue('xMotivo').Value;
    end;
  end
  else if (statusEnvio = '-995') then
  begin

    motivo := jsonRetorno.GetValue('motivo').Value;

    try
      erros := jsonRetorno.Get('erros').JsonValue;
    except
    end;
  end
  else
  begin
    try
      motivo := jsonRetorno.GetValue('motivo').Value;
    except
      motivo := jsonRetorno.ToString;
    end;
  end;

  retorno := '{' +
                  '"statusEnvio": "'    + statusEnvio + '",'     +
                  '"statusDownload": "' + statusDownload + '",'  +
                  '"cStat": "'          + cStat  + '",'          +
                  '"chNFe": "'          + chNFe  + '",'          +
                  '"nProt": "'          + nProt  + '",'          +
                  '"motivo": "'         + motivo + '",'          +
                  '"erros": '           + erros.ToString         +
             '}';

  // Grava resposta API
  gravaLinhaLog('[JSON_RETORNO]');
  gravaLinhaLog(retorno);
  gravaLinhaLog('[EMISSAO_SINCRONA_FIM]');
  gravaLinhaLog('');

  Result := retorno;
end;

// Envia NFCe
function emitirNFCe(conteudo, tpConteudo: String): String;
var
  url, resposta: String;
begin
  url := 'https://nfce.ns.eti.br/v1/nfce/issue';

  gravaLinhaLog('[ENVIO_DADOS]');
  gravaLinhaLog(conteudo);

  resposta := enviaConteudoParaAPI(conteudo, url, tpConteudo);

  gravaLinhaLog('[ENVIO_RESPOSTA]');
  gravaLinhaLog(resposta);

  Result := resposta;
end;

// Download dos arquivos da NFCe
function downloadNFCe(chNFe, tpAmb:String): String;
var
  json: String;
  url, resposta, status: String;
  jsonRetorno: TJSONObject;
begin

  json := '{' +
              '"chNFe": "'   + chNFe          + '",' +
              '"tpAmb": "'   + tpAmb          + '",' +
              '"impressao":' + impressaoParam +
          '}';

  url := 'https://nfce.ns.eti.br/v1/nfce/get';

  gravaLinhaLog('[DOWNLOAD_NFCE_DADOS]');
  gravaLinhaLog(json);

  resposta := enviaConteudoParaAPI(json, url, 'json');
  jsonRetorno := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(resposta),
    0) as TJSONObject;
  status := jsonRetorno.GetValue('status').Value;

  if (status <> '100') then
  begin
    gravaLinhaLog('[DOWNLOAD_NFCE_RESPOSTA]');
    gravaLinhaLog(resposta);
  end
  else
  begin
    gravaLinhaLog('[DOWNLOAD_NFCE_STATUS]');
    gravaLinhaLog(status);
  end;

  Result := resposta;
end;

// Download de NFCe
function downloadNFCeESalvar(chNFe, tpAmb, caminho: String; exibeNaTela: Boolean): String;
var
  xml, json, pdf: String;
  status, resposta: String;
  jsonRetorno, jsonAux: TJSONObject;
begin
  if not DirectoryExists(caminho) then
    CreateDir(caminho);

  resposta := downloadNFCe(chNFe, tpAmb);
  jsonRetorno := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(resposta),
    0) as TJSONObject;
  status := jsonRetorno.GetValue('status').Value;

  if status = '100' then
  begin

    jsonAux := jsonRetorno.ParseJSONValue(TEncoding.ASCII.GetBytes(jsonRetorno.Get('nfeProc').JsonValue.ToString), 0) as TJSONObject;

    xml := jsonAux.GetValue('xml').Value;
    salvarXML(xml, caminho, chNFe);

    if (Pos('PDF', impressaoParam.ToUpper) <> 0) then
    begin
      pdf := jsonRetorno.GetValue('pdf').Value;
      salvarPDF(pdf, caminho, chNFe);

      if exibeNaTela then
        ShellExecute(0, nil, PChar(caminho + chNFe + '-procNFe.pdf'), nil, nil,
          SW_SHOWNORMAL);
    end;
  end
  else
  begin
    Showmessage('Ocorreu um erro, veja o Retorno da API para mais informações');
  end;

  Result := resposta;
end;

// Download de NFCe
function downloadEventoNFCeESalvar(chNFe, tpAmb, caminho: String; exibeNaTela: Boolean): String;
var
  xml, json, pdf: String;
  status, resposta, chNFeCanc: String;
  jsonRetorno, jsonAux: TJSONObject;
begin

  resposta := downloadNFCe(chNFe, tpAmb);
  jsonRetorno := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(resposta),
    0) as TJSONObject;
  status := jsonRetorno.GetValue('status').Value;

  if status = '100' then
  begin
    if not DirectoryExists(caminho) then
      CreateDir(caminho);

    jsonAux := jsonRetorno.ParseJSONValue(TEncoding.ASCII.GetBytes(jsonRetorno.Get('retEvento').JsonValue.ToString), 0) as TJSONObject;
    xml := jsonAux.GetValue('xml').Value;
    chNFeCanc := jsonAux.GetValue('chNFeCanc').Value;
    salvarXML(xml, caminho, chNFeCanc, 'CANC');

    if(Pos('PDF', impressaoParam.ToUpper) <> 0) then
    begin
       pdf := jsonRetorno.GetValue('pdfCancelamento').Value;
       salvarPDF(pdf, caminho, chNFeCanc, 'CANC');
       if exibeNaTela then
        ShellExecute(0, nil, PChar(caminho + chNFeCanc + '-procEvenNFe.pdf'), nil, nil,
        SW_SHOWNORMAL);
    end;

  end
  else
  begin
    Showmessage('Ocorreu um erro, veja o Retorno da API para mais informações');
  end;

  Result := resposta;
end;

// Realizar o cancelamento da NFCe
function cancelarNFCe(chNFe, tpAmb, dhEvento, nProt, xJust, caminho: String; exibeNaTela: boolean = false): String;
var
  json: String;
  url, resposta, respostaDownload: String;
  status: String;
  jsonRetorno, jsonAux: TJSONObject;
begin

  json := '{' +
              '"chNFe": "'        + chNFe    + '",' +
              '"tpAmb": "'        + tpAmb    + '",' +
              '"dhEvento": "'     + dhEvento + '",' +
              '"nProt": "'        + nProt    + '",' +
              '"xJust": "'        + xJust    + '"'  +
          '}';

  url := 'https://nfce.ns.eti.br/v1/nfce/cancel';

  gravaLinhaLog('[CANCELAMENTO_DADOS]');
  gravaLinhaLog(json);

  resposta := enviaConteudoParaAPI(json, url, 'json');

  gravaLinhaLog('[CANCELAMENTO_RESPOSTA]');
  gravaLinhaLog(resposta);

  jsonRetorno := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(resposta),
    0) as TJSONObject;
  status := jsonRetorno.GetValue('status').Value;

  if (status = '135') then
  begin

    respostaDownload := downloadEventoNFCeESalvar(chNFe, tpAmb, caminho, exibeNaTela);
    jsonRetorno := TJSONObject.ParseJSONValue
      (TEncoding.ASCII.GetBytes(respostaDownload), 0) as TJSONObject;
    status := jsonRetorno.GetValue('status').Value;

    if (status <> '100') then
    begin
      ShowMessage('Ocorreu um erro ao fazer o download. Verifique os logs.')
    end;

  end;

  Result := resposta;
end;

// Realizar a consulta de situação de uma NFC-e
function consultaSituacao(chNFe, tpAmb: String): String;
var
  json: String;
  url, resposta, respostaDownload: String;
  status: String;
  jsonRetorno, jsonAux: TJSONObject;
begin

  json := '{' +
              '"chNFe": "' + chNFe + '",' +
              '"tpAmb": "' + tpAmb + '"'  +
          '}';

  url := 'https://nfce.ns.eti.br/v1/nfce/status';

  gravaLinhaLog('[CONSULTA_SITUACAO_DADOS]');
  gravaLinhaLog(json);

  resposta := enviaConteudoParaAPI(json, url, 'json');

  gravaLinhaLog('[CONSULTA_SITUACAO_RESPOSTA]');
  gravaLinhaLog(resposta);

  Result := resposta;
end;

// Realizar a inutilização de um intervalo de numeração de NFC-e
function inutilizar(cUF, tpAmb, ano, CNPJ, serie, nNFIni, nNFFin, xJust:String): String;
var
  json: String;
  url, resposta, respostaDownload: String;
  status: String;
  jsonRetorno, jsonAux: TJSONObject;
begin

  json := '{' +
              '"cUF": "'    + cUF + '",'    +
              '"tpAmb": "'  + tpAmb + '",'  +
              '"ano": "'    + ano + '",'    +
              '"CNPJ": "'   + CNPJ + '",'   +
              '"serie": "'  + serie + '",'  +
              '"nNFIni": "' + nNFIni + '",' +
              '"nNFFin": "' + nNFFin + '",' +
              '"xJust": "'  + xJust + '"'   +
          '}';

  url := 'https://nfce.ns.eti.br/v1/nfce/inut';

  gravaLinhaLog('[INUTILIZACAO_DADOS]');
  gravaLinhaLog(json);

  resposta := enviaConteudoParaAPI(json, url, 'json');

  gravaLinhaLog('[INUTILIZACAO_RESPOSTA]');
  gravaLinhaLog(resposta);

  Result := resposta;
end;

// Função para salvar o XML de retorno
function salvarXML(xml, caminho, chNFe: String; tpEvento: String = ''): String;
var
  arquivo: TextFile;
  conteudoSalvar, localParaSalvar, extensao: String;
begin
  if (tpEvento = 'CANC') then
  begin
    extensao := '-procEvenNFe.xml';
  end
  else
  begin
    extensao := '-procNFe.xml';
  end;

  localParaSalvar := caminho + chNFe + extensao;

  AssignFile(arquivo, localParaSalvar);
  Rewrite(arquivo);

  // Copia o retorno
  conteudoSalvar := xml;
  // Ajeita o XML retirando as barras antes das aspas duplas
  conteudoSalvar := StringReplace(conteudoSalvar, '\"', '"',
    [rfReplaceAll, rfIgnoreCase]);

  // Escreve o retorno no arquivo
  Writeln(arquivo, conteudoSalvar);

  // Fecha o arquivo
  CloseFile(arquivo);
end;

// Função para salvar o PDF de retorno
function salvarPDF(pdf, caminho, chNFe: String; tpEvento: String = ''): String;
var
  conteudoSalvar, localParaSalvar, extensao: String;
  base64decodificado: TStringStream;
  arquivo: TFileStream;
begin

  if (tpEvento = 'CANC') then
  begin
    extensao := '-procEvenNFe.pdf';
  end
  else
  begin
    extensao := '-procNFe.pdf';
  end;

  localParaSalvar := caminho + chNFe + extensao;

  // Copia e cria uma TString com o base64
  conteudoSalvar := pdf;
  base64decodificado := TStringStream.Create(conteudoSalvar);

  // Cria o arquivo .pdf e decodifica o base64 para o arquivo
  try
    arquivo := TFileStream.Create(localParaSalvar, fmCreate);
    try
      DecodeStream(base64decodificado, arquivo);
    finally
      arquivo.Free;
    end;
  finally
    base64decodificado.Free;
  end;
end;

// Grava uma linha no log
procedure gravaLinhaLog(conteudo: String);
var
  caminhoEXE, nomeArquivo, data: String;
  log: TextFile;
begin
  // Pega o caminho do executável
  caminhoEXE := ExtractFilePath(GetCurrentDir);
  caminhoEXE := caminhoEXE + 'log\';

  // Pega a data atual
  data := DateToStr(Date);

  // Ajeita o XML retirando as barras antes das aspas duplas
  data := StringReplace(data, '/', '', [rfReplaceAll, rfIgnoreCase]);

  nomeArquivo := caminhoEXE + data;

  // Se diretório \log não existe, é criado
  if not DirectoryExists(caminhoEXE) then
    CreateDir(caminhoEXE);

  AssignFile(log, nomeArquivo + '.txt');
{$I-}
  Reset(log);
{$I+}
  if (IOResult <> 0) then
    Rewrite(log) { arquivo não existe e será criado }
  else
  begin
    CloseFile(log);
    Append(log); { o arquivo existe e será aberto para saídas adicionais }
  end;

  Writeln(log, DateTimeToStr(Now) + ' - ' + conteudo);

  CloseFile(log);
end;

end.
