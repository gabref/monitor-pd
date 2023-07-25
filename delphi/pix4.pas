unit pix4;

interface

uses
  Windows, Registry, SysUtils, System.Classes, SyncObjs, geradorComandos,
  Vcl.StdCtrls, Log, Pix4Communication, System.RegularExpressions,
  System.Generics.Collections, System.IOUtils;

type

  TPix4 = class

  public
    {public fields}
    produtos: TList<TPair<string, string>>; // Declare the global list

    {public methods}
    procedure LoadSerialPorts(items: TStrings);
    function OpenSerialPort(const ComPort: string): boolean;
    procedure DesconectarPix4;

    function InicializarPIX4: integer;
    function Reinicializar: integer;
    function ObterVersaoFirmware: Integer;
    function ObtemModelo: string;
    function ApresentaImagem(const filename: string; posY, posX, tipo: Integer): Integer;
    function ApresentaQRCode(const qrCode: string; tamanho, posY, posX: Integer): Integer;
    function ApresentaTexto(const texto: string; idTexto, tamanho, posY, posX: Integer; const hexadecimal: PAnsiChar): Integer;


    function ObtemConexao: Boolean;
    procedure ApresentaListaCompras(const descricao: string; const valor: PAnsiChar);
    function UploadImagem(const filename, filePath: string): Integer;
    procedure InicializaLayoutPagamento(const subTotal, desconto, totalPagar: PAnsiChar);
    function AdicionaFormaPagamento(tipoPagamento: Integer; const valor: PAnsiChar): Integer;


    constructor Create;
    destructor Destroy; override;


    function FileSizeImage(const aFilename: String): Int64;

  private
    {private fields}
    hSerialPort : THandle;

    {private methods}
    function CRC16_CCITTFALSE(bytesData: PAnsiChar; bytesLength: Integer): Word;
    function retornaDescricao(const descricao: string; tamanho: integer): String;
    function Valida_Dec_1302(const value: PAnsiChar): boolean;
    function ValidaHexadecimal(const value: PAnsiChar): boolean;

  end;

  const
    SUCESSO = 0;
    posicao = 158;
    id = 8;

  var
    valorTotal : Double;
    controle : integer;
    quantidade: integer;
    finalizaVenda : boolean;
    ultimo : string;

implementation

constructor TPix4.Create;
begin
  writeLogs('Biblioteca PIX4 Carregada com sucesso');
  writeLogs('Versão 0.1.0');

  valorTotal := 0;
  controle := 0;
  quantidade := 0;
  finalizaVenda := False;
  ultimo := '';

  if assigned(produtos) then
    produtos.Free;
  produtos := TList<TPair<string, string>>.Create;
  writelogs('---');
end;

destructor TPix4.Destroy;
begin
  writelogs('Biblioteca PIX4 liberada');

  if assigned(produtos) then
    produtos.Free;

  inherited Destroy;
  writelogs('---');
end;

  procedure TPix4.LoadSerialPorts(items: TStrings);
  var
    RegIni: TRegistry;
    AList: TStringList;
    loop: Integer;
  begin
    writeLogs('Entrando na função: LoadSerialPorts');
    items.Clear;
    RegIni := TRegistry.Create;
    AList := TStringList.Create; // Move the creation of AList outside the try-finally block
    try
      RegIni.RootKey := HKEY_LOCAL_MACHINE;
      if RegIni.OpenKeyReadOnly('HARDWARE\DEVICEMAP\SERIALCOMM') then // Directly open the required registry key
      begin
        RegIni.GetValueNames(AList);
        for loop := 0 to AList.Count - 1 do
          items.Add(RegIni.ReadString(AList[loop]));
      end;

      writeLogs('Dispositivos encontrados: ' + IntToStr(Alist.Count));
      writeLogs('Retorno LoadSerialPorts: ' + AList.ToString());
    finally
      RegIni.Free;
      AList.Free;
    end;
    writelogs('---');
  end;

function TPix4.OpenSerialPort(const ComPort: string): boolean;
begin
  writeLogs('Entrando na função: OpenSerialPort');
  hSerialPort := OpenPort(hSerialPort, ComPort);
  if hSerialPort = INVALID_HANDLE_VALUE then begin
     result := False;
     writeLogs('Erro na abertura da porta.');
     writeLogs('Retorno OpenSerialPort: False');
  end
  else begin
    result := True;
    writeLogs('Porta Aberta com sucesso');
     writeLogs('Retorno OpenSerialPort: True');
  end;
  writelogs('---');
end;

procedure TPix4.DesconectarPix4;
begin
  WriteLogs('Entrando na procedure: DesconectarPix4');
  CloseHandle(hSerialPort);
end;

function TPix4.InicializarPIX4;
var
  ret : integer;
begin
  writeLogs('Entrando na function: InicializarPIX4');
  if assigned(produtos) then
    produtos.Free;
  produtos := TList<TPair<string, string>>.Create;

  ret := writePix4(hSerialPort, gerarComandoInicializador);
  writeLogs('Retorno InicializarPIX4: ' + IntToStr(ret));
  result := ret
  writelogs('---');
end;

function TPix4.Reinicializar;
var
  ret: integer;
begin
  ret := writePix4(hSerialPort, gerarComandoRestart);
  writeLogs('Retorno Reinicializar: ' + IntToStr(ret));
  result := ret;
  writelogs('---');
end;

function TPix4.ObterVersaoFirmware: Integer;
var
  retorno: integer;
  data: integer;
begin
  writeLogs('Entrando na função: ObterVersaoFirmware');
  retorno := WritePix4(hSerialPort, gerarComandoObterVersaoFirmware);

  data := -1;

  if retorno = SUCESSO then
  begin
    data := ReadPix4int(hSerialPort);
    writeLogs('Firmware Version: ' + IntToStr(data));
    result := data;
  end
  else begin
    Result := data;
  end;

  writeLogs('Retorno ObterVersaoFirmware: ' + IntToStr(data));
  writelogs('---');
end;

function TPix4.ObtemModelo: string;
var
  retorno: integer;
  hexdata: string;
begin
  writeLogs('Entrando na função: ObtemModelo');
  retorno := WritePix4(hSerialPort, gerarComandoObterModelo);

  hexData := 'erro';

  if retorno = SUCESSO then
  begin
    hexdata := ReadPix4(hSerialPort);
    result := hexdata;
  end
  else
    Result := hexData;

  writeLogs('Retorno ObtemModelo: ' + hexData);
  writelogs('---');
end;

function TPix4.ApresentaImagem(const filename: string; posY, posX, tipo: Integer): Integer;
var
  ret : integer;
begin
  writeLogs('Entrando na função: ApresentaImagem');
  if tipo < 0 then
    tipo := 0;
  if tipo > 1 then
    tipo := 1;

  if (posY < 0) or (posY > 450) then
  begin
    writeLogs('Parâmetro posY fora do especificado ' + IntToStr(posY));
    Result := -1;
    Exit;
  end;

  if (posX < 0) or (posX > 300) then
  begin
    writeLogs('Parâmetro posX fora do especificado ' + IntToStr(posX));
    Result := -1;
    Exit;
  end;

  ret := WritePix4(hSerialPort, gerarComandoApresentaImagem(filename, posY, posX, tipo));
  writeLogs('Retorno ApresentaImagem: ' + IntToStr(ret));
  Result := ret;
  writelogs('---');
end;

function TPix4.ApresentaQRCode(const qrCode: string; tamanho, posY, posX: Integer): Integer;
var
  ret : integer;
begin
  writeLogs('Entrando na função: ApresentaQRCode');
  if (tamanho < 15) or (tamanho > 255) then
  begin
    writeLogs('Tamanho qrCode fora do especificado ' + IntToStr(tamanho));
    Result := -1;
    Exit;
  end;

  if (posY < 0) or (posY > 450) then
  begin
    writeLogs('Parâmetro posY fora do especificado ' + IntToStr(posY));
    Result := -1;
    Exit;
  end;

  if (posX < 0) or (posX > 300) then
  begin
    writeLogs('Parâmetro posX fora do especificado ' + IntToStr(posX));
    Result := -1;
    Exit;
  end;

  ret := WritePix4(hSerialPort, gerarComandoApresentarQRCode(qrCode, tamanho, posY, posX));
  writeLogs('Retorno ApresentaQRCode: ' + IntToStr(ret));
  result := ret;
  writelogs('---');
end;

function TPix4.ApresentaTexto(const texto: string; idTexto, tamanho, posY, posX: Integer; const hexadecimal: PAnsiChar): Integer;
var
  r, g, b: Byte;
  ret : integer;
begin
  writeLogs('Entrando na função: ApresentaTexto');
  if ValidaHexadecimal(PAnsiChar(hexadecimal)) then
  begin
    r := StrToInt('$' + String(hexadecimal[2]) + String(hexadecimal[3]));
    g := StrToInt('$' + String(hexadecimal[4]) + String(hexadecimal[5]));
    b := StrToInt('$' + String(hexadecimal[6]) + String(hexadecimal[7]));
  end
  else
  begin
    writeLogs('Parâmetro hexadecimal fora do especificado');
    Result := -1;
    Exit;
  end;

  if (idTexto < 1) or (idTexto > 19) then
  begin
    writeLogs('Parâmetro IdTexto fora do especificado ' + IntToStr(idTexto));
    Result := -1;
    Exit;
  end;

  if (tamanho < 10) or (tamanho > 50) then
  begin
    writeLogs('Parâmetro Tamanho fora do especificado ' + IntToStr(tamanho));
    Result := -1;
    Exit;
  end;

  if (posY < 0) or (posY > 450) then
  begin
    writeLogs('Parâmetro posH fora do especificado ' + IntToStr(posY));
    Result := -1;
    Exit;
  end;

  if (posX < 0) or (posX > 300) then
  begin
    writeLogs('Parâmetro posV fora do especificado ' + IntToStr(posX));
    Result := -1;
    Exit;
  end;

  ret := writePix4(hSerialPort, gerarComandoApresentarTexto(texto, idTexto, tamanho, posY, posX, r, g, b));
  writeLogs('Retorno ApresentaTexto: ' + IntToStr(ret));
  result := ret;
  writelogs('---');
end;

function TPix4.ObtemConexao: Boolean;
var
  dcb: TDCB;
begin
  writeLogs('Entrando na função: ObtemConexao');
  Result := (hSerialPort <> INVALID_HANDLE_VALUE) and GetCommState(hSerialPort, dcb);
  writelogs('---');
end;

// -------------
// Funções novas
// -------------

procedure TPix4.ApresentaListaCompras(const descricao: string; const valor: PAnsiChar);
var
  teste: Integer;
  aux, valorProduto, descricaoReal: string;
  i, contador, quantidade: Integer;
label
  cabecalho;
begin
  writeLogs('Entrando na procedure: ApresentaListaCompras');
  if not ObtemConexao then
  begin
    writeLogs('Não foi possível concluir a operação, sem conexão com Hardware');
    Exit;
  end;

  teste := 80;
  valorTotal := valorTotal + StrToFloat(String(valor));

  if not Valida_Dec_1302(valor) then
  begin
    writeLogs('Não foi possível finalizar a operação, valor fora do especificado');
    Exit;
  end;

  contador := 4;

  cabecalho:
  ApresentaTexto('Pré-Venda', 1, 22, 0, 10, '#000000');
  ApresentaTexto('#  Produto          R$', 2, 22, 30, 10, '#000000');
  ApresentaTexto('────────────────────────────────', 3, 22, 50, 0, '#000000');

  if produtos.Count >= 11 then
  begin
    controle := controle + 11;
    InicializarPIX4;
    aux := '';
    contador := 4;
    goto cabecalho;
  end;

  valorProduto := String(valor);
  descricaoReal := retornaDescricao(Trim(descricao), 15);
  produtos.Add(TPair<string, string>.Create(descricaoReal, valorProduto));

  for i := 0 to produtos.Count - 1 do
  begin
    quantidade := i + 1;
    aux := Format('%2s %-*s %7s', [IntToStr(quantidade + controle), 15, produtos[i].Key, produtos[i].Value]);
    ApresentaTexto(String(PAnsiChar(AnsiString(aux))), contador, 20, teste, 0, '#000000');
    teste := teste + 28;
    aux := '';
  end;

  ApresentaTexto('────────────────────────────────', 19, 22, 400, 0, '#000000');
  ApresentaTexto('Quantidade : ' + IntToStr(quantidade), 17, 22, 420, 0, '#000000');
  ApresentaTexto('Valor Total: ' + FormatFloat('0.00', valorTotal), 18, 22, 450, 0, '#000000');

  writeLogs('Retorno ApresentaListaCompras'); 
  writelogs('---');
end;

function TPix4.UploadImagem(const filename, filePath: string): Integer;
var
  bytes: TBytes;
  bytesWritten: DWORD;
  dadosComando, aux, ok: string;
  CRC16_file: Word;
  i: Integer;
begin
  writeLogs('Entrando na função: UploadImagem');
  ok := 'OK';
  if not ObtemConexao then
  begin
    writeLogs('Não foi possível concluir a operação, sem conexão com Hardware');
    Exit(-1);
  end;

  if not FileExists(filePath) then
  begin
    writeLogs('Não foi possível encontrar o arquivo');
    result := -1;
    exit;
  end;

  if FileSizeImage(filePath) = 0 then
  begin
      writeLogs('O Arquivo não pode ser vazio ou nulo');
      result := -1;
      Exit;
  end;

  try
    bytes := TFile.ReadAllBytes(filePath);
    writeLogs('Arquivo aberto com sucesso');
    writeLogs('Tamanho do arquivo: ' + IntToStr(length(bytes)));
  except
    // clear the array
    SetLength(bytes, 0);
    writeLogs('Não foi possível ler o arquivo');
    result := -1;
    exit;
  end;

  if Length(bytes) = 0 then
  begin
      writeLogs('O Arquivo não pode ser vazio ou nulo');
      result := -1;
      Exit;
  end;

  CRC16_file := CRC16_CCITTFALSE(PAnsiChar(bytes), Length(bytes));
  writeLogs('CRC do arquivo: ' + IntToStr(CRC16_file));

  dadosComando := filename + ',' + IntToStr(Length(bytes)) + ',' + IntToStr(CRC16_file);
  writeLogs(dadosComando);

  writePix4(hSerialPort, gerarComandoUploadImagem(dadosComando));

  i := 0;
  repeat
    aux := ReadPix4CharacterByCharacter(hSerialPort);
    i := i + 1;
  until (aux = ok) or (i = 5);

  if aux = ok then
  begin
    Sleep(100);

    writeLogs('Escrevendo bytes da imagem na porta serial');
    for i := 0 to Length(bytes) - 1 do
    begin
      if not WriteFile(hSerialPort, bytes[i], 1, bytesWritten, nil) then
      begin
        writeLogs('Failed to write data to the serial port. Error: ' + IntToStr(GetLastError));
        Result := FAILED_TO_WRITE;
        Exit;
      end;

      // Wait for the byte to be written
      FlushFileBuffers(hSerialPort);
    end;
  end
  else
  begin
    writeLogs('Não foi possível concluir a operação' + aux);
    Exit(-1);
  end;

  i := 0;
  repeat
    aux := ReadPix4CharacterByCharacter(hSerialPort);
    writeLogs('Lendo crc16, tentativa: ' + IntToStr(i));
    i := i + 1;
  until (aux = IntToStr(CRC16_file)) or (i = 5);

  if aux <> IntToStr(CRC16_file) then
  begin
    writeLogs('CRC16 retornado não bate com CRC16 real');
    result := -1;
    Exit;
  end;

  writeLogs('Upload concluído com sucesso');
  writeLogs('Retorno UploadImagem: '); 
  Result := 0;
  writeLogs('Saindo da Função UploadImagem');
  writelogs('---');
end;

procedure TPix4.InicializaLayoutPagamento(const subTotal, desconto, totalPagar: PAnsiChar);
var
  cabecalho, separador, descricao: string;
  posicao, contador: Integer;
  valores: array [0..2] of PAnsiChar;
  chaves: TStringList;
  i: Integer;
begin
  writeLogs('Entrando na procedure: InicializaLayoutPagamento');
  if not ObtemConexao then
  begin
    writeLogs('Não foi possível concluir a operação, sem conexão com Hardware');
    Exit;
  end;

  cabecalho := 'Finalizando Venda';
  separador := '───────────────────────────────────────────';

  ApresentaTexto(cabecalho, 1, 30, 10, 10, '#000000');
  ApresentaTexto(separador, 2, 30, 35, 0, '#000000');

  valores[0] := subTotal;
  valores[1] := desconto;
  valores[2] := totalPagar;

  if not (Valida_Dec_1302(valores[0]) and Valida_Dec_1302(valores[1]) and Valida_Dec_1302(valores[2])) then
  begin
    writeLogs('Não foi possível finalizar a operação, valores fora do especificado');
    Exit;
  end;

  finalizaVenda := True;

  chaves := TStringList.Create;
  chaves.Add('Sub-Total');
  chaves.Add('Descontos');
  chaves.Add('Total-Pagar');

  posicao := 40;
  contador := 3;

  for i := 0 to chaves.Count - 1 do
  begin
    descricao := Format('%-12s %-9s', [chaves[i], string(valores[i])]);
    ApresentaTexto(String(PAnsiChar(AnsiString(descricao))), contador, 23, posicao, 5, '#000000');
    descricao := '';
    Inc(contador);
    Inc(posicao, 30);
  end;

  ApresentaTexto(separador, 7, 30, 158, 0, '#000000');

  chaves.Free;

  writeLogs('Retorno InicializaLayoutPagamento: '); 
end;

function TPix4.AdicionaFormaPagamento(tipoPagamento: Integer; const valor: PAnsiChar): Integer;
var
  tipos: TStringList;
  descricao: string;
begin
  writeLogs('Entrando na função: AdicionaFormaPagamento');
  if not ObtemConexao then
  begin
    writeLogs('Não foi possível concluir a operação, sem conexão com Hardware');
    Result := -1;
    Exit;
  end;

  tipos := TStringList.Create;
  tipos.Add('Dinheiro');
  tipos.Add('Crédito');
  tipos.Add('Débito');
  tipos.Add('PIX');
  tipos.Add('Outros');

  if not Valida_Dec_1302(valor) then
  begin
    writeLogs('Não foi possível finalizar a operação, valor fora do especificado');
    Result := -1;
    Exit;
  end;

  if not finalizaVenda then
  begin
    writeLogs('Nao existe operação de finalizar venda');
    Result := -1;
    Exit;
  end;

  if (tipoPagamento < 1) or (tipoPagamento > 4) then
  begin
    writeLogs('tipo de pagamento forta do range especificado');
    Result := -1;
    Exit;
  end;

  if ultimo = tipos[tipoPagamento - 1] then
  begin
    writeLogs('tipo de pagamento ja adicionado');
    Result := -1;
    Exit;
  end;

  descricao := Format('%-12s %-9s', [tipos[tipoPagamento - 1], string(valor)]);

  if ApresentaTexto(String(PAnsiChar(AnsiString(descricao))), id + 1, 23, posicao + 30, 5, '#000000') = SUCESSO then
  begin
    writeLogs('Forma de Pagamento adicionado ao layout conm sucesso');
    ultimo := tipos[tipoPagamento - 1];
    Result := SUCESSO;
  end
  else
  begin
    writeLogs('Não foi possivel adicionar a forma de pagamento');
    Result := -1;
  end;

  tipos.Free;

  writeLogs('Retorno AdicionaFormaPagamento: '); 
  writelogs('---');
end;


// ==================
// ===== UTILS ======
// ==================

function TPix4.CRC16_CCITTFALSE(bytesData: PAnsiChar; bytesLength: Integer): Word;
var
  i: Byte;
  wCrc: Word;
begin
  wCrc := $FFFF;

  while (bytesLength > 0) do
  begin
    wCrc := wCrc xor (Byte(bytesData^) shl 8);
    Inc(bytesData);

    for i := 0 to 7 do
    begin
      if (wCrc and $8000) <> 0 then
        wCrc := (wCrc shl 1) xor $1021
      else
        wCrc := wCrc shl 1;
    end;

    Dec(bytesLength);
  end;

  Result := wCrc and $FFFF;
end;


function TPix4.retornaDescricao(const descricao: string; tamanho: Integer): string;
var
  descricaoResult: string;
  espaco: Integer;
begin
  if Length(descricao) > tamanho then
  begin
    espaco := Length(descricao) - tamanho;
    descricaoResult := Copy(descricao, 1, Length(descricao) - espaco);
  end
  else
  begin
    espaco := tamanho - Length(descricao);
    descricaoResult := descricao.PadRight(Length(descricao) + espaco, '.');
  end;

  Result := descricaoResult;
end;


function TPix4.Valida_Dec_1302(const value: PAnsiChar): Boolean;
var
  decimalValue: string;
begin
  decimalValue := String(value);

  if decimalValue.IsEmpty then
  begin
    writeLogs('Valor do parâmetro vazio');
    Result := False;
    Exit;
  end;

  Result := TRegEx.IsMatch(decimalValue, '0|0\.[0-9]{2}|[1-9]{1}[0-9]{0,12}(\.[0-9]{2})?');
end;


function TPix4.ValidaHexadecimal(const value: PAnsiChar): Boolean;
var
  hexValue: string;
begin
  hexValue := String(value);

  if hexValue.IsEmpty then
  begin
    writeLogs('Valor hexadecimal vazio');
    Result := False;
    Exit;
  end;

  Result := TRegEx.IsMatch(hexValue, '^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
end;

function TPix4.FileSizeImage(const aFilename: String): Int64;
var
info: TWin32FileAttributeData;
begin
  result := -1;

  if NOT GetFileAttributesEx(PChar(aFileName), GetFileExInfoStandard, @info) then
    EXIT;

  result := Int64(info.nFileSizeLow) or Int64(info.nFileSizeHigh shl 32);
end;

end.
