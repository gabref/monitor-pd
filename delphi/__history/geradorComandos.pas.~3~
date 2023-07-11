unit geradorComandos;

interface

uses
  SysUtils, pix4Communication;

  function gerarComandoObterVersaoFirmware: TBytes;
  function gerarComandoObterModelo: TBytes;

implementation


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

end.
