unit geradorComandos;

interface

uses
  SysUtils;

  type
    TGeradorComandos = class
    public
      class function gerarComandoObterVersaoFirmware: TBytes; static;
    end;

implementation

class function TGeradorComandos.gerarComandoObterVersaoFirmware: TBytes;
begin
  Result := [$02, $07, $16, $02];
end;

end.
