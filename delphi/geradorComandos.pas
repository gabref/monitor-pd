unit geradorComandos;

interface

uses
  SysUtils, pix4Communication;

  function gerarComandoInicializador: TBytes;
  function gerarComandoRestart: TBytes;
  function gerarComandoApresentaImagem(const filename: string; posH, posV, tipo: Integer): TBytes;
  function gerarComandoObterVersaoFirmware: TBytes;
  function gerarComandoObterModelo: TBytes;
  function gerarComandoApresentarQRCode(const qrCode: string; tamanho, posH, posV: Integer): TBytes;
  function gerarComandoApresentarTexto(const texto: string; idTexto, tamanho, posH, posV, r, g, b: Integer): TBytes;
  function gerarComandoUploadImagem(const dadosComando: string): TBytes;
  function gerarComandoEstiloDefault(estilo: Integer): TBytes;
  function gerarComandoAlteraEstilo(estilo: Integer): TBytes;
  function ResolveHexa(hexa: Integer; lado: Integer): Cardinal;

implementation

function gerarComandoInicializador: TBytes;
var
  hex: string;
begin
  hex := '1b 40';
  Result := HexToByte(hex);
end;

function gerarComandoRestart: TBytes;
var
  hexData: string;
begin
  hexData := '02 1D AA 55';
  Result := HexToByte(hexData);
end;

function gerarComandoApresentaImagem(const filename: string; posH, posV, tipo: Integer): TBytes;
var
  APRESENTA_IMAGEM: TBytes;
begin
  APRESENTA_IMAGEM := [$02, $08, $06];
  APRESENTA_IMAGEM := APRESENTA_IMAGEM + [Byte(tipo),
    Byte(resolveHexa(posV, 1)),
    Byte(resolveHexa(posV, 2)),
    Byte(resolveHexa(posH, 1)),
    Byte(resolveHexa(posH, 2))];
  Result := APRESENTA_IMAGEM + TEncoding.UTF8.GetBytes(filename) + HexToByte('00');
end;

function gerarComandoObterVersaoFirmware: TBytes;
var
  hex: string;
begin
  hex := '02 07 16 02';
  Result := HexToByte(hex);
end;

function gerarComandoObterModelo: TBytes;
var
  hex: string;
begin
  hex := '02 07 16 01';
  Result := HexToByte(hex);
end;

function gerarComandoApresentarQRCode(const qrCode: string; tamanho, posH, posV: Integer): TBytes;
var
  APRESENTA_QRCODE: TBytes;
begin
  APRESENTA_QRCODE := [$02, $08, $06, $20];
  APRESENTA_QRCODE := APRESENTA_QRCODE + [Byte(tamanho),
    Byte(resolveHexa(posV, 1)),
    Byte(resolveHexa(posV, 2)),
    Byte(resolveHexa(posH, 1)),
    Byte(resolveHexa(posH, 2))];
  Result := APRESENTA_QRCODE + TEncoding.UTF8.GetBytes(qrCode) + [0];
end;

function gerarComandoApresentarTexto(const texto: string; idTexto, tamanho, posH, posV, r, g, b: Integer): TBytes;
var
  APRESENTA_TEXTO: TBytes;
begin
  APRESENTA_TEXTO := [$02, $08, $09];
  APRESENTA_TEXTO := APRESENTA_TEXTO + [Byte(idTexto),
    Byte(tamanho),
    Byte(resolveHexa(posV, 1)),
    Byte(resolveHexa(posV, 2)),
    Byte(resolveHexa(posH, 1)),
    Byte(resolveHexa(posH, 2)),
    Byte(r),
    Byte(g),
    Byte(b)];
  Result := APRESENTA_TEXTO + TEncoding.UTF8.GetBytes(texto) + [$0A, $0A, 0];
end;

function gerarComandoUploadImagem(const dadosComando: string): TBytes;
var
  UPLOAD_IMAGE: TBytes;
begin
  UPLOAD_IMAGE := [$02, $07, $05, $01];
  UPLOAD_IMAGE := UPLOAD_IMAGE + TEncoding.UTF8.GetBytes(dadosComando) + [$0A];
  Result := UPLOAD_IMAGE;
end;

function gerarComandoEstiloDefault(estilo: Integer): TBytes;
var
  DEFINE_ESTILO_DEFAULT: TBytes;
begin
  DEFINE_ESTILO_DEFAULT := [$02, $08, $07];
  DEFINE_ESTILO_DEFAULT := DEFINE_ESTILO_DEFAULT + [Byte(estilo)];
  Result := DEFINE_ESTILO_DEFAULT;
end;

function gerarComandoAlteraEstilo(estilo: Integer): TBytes;
var
  ALTERA_ESTILO: TBytes;
begin
  ALTERA_ESTILO := [$02, $08, $00];
  ALTERA_ESTILO := ALTERA_ESTILO + [Byte(estilo)];
  Result := ALTERA_ESTILO;
end;


function ResolveHexa(hexa: Integer; lado: Integer): Cardinal;
var
  hexValue: string;
  decimal: Cardinal;
begin
  hexValue := IntToHex(hexa, 4);

  if lado = 1 then
    decimal := StrToIntDef('$' + Copy(hexValue, 1, 2), 0)
  else
    decimal := StrToIntDef('$' + Copy(hexValue, 3, 2), 0);

  Result := decimal;
end;


end.
