unit pix4;

interface

uses
  Windows, Registry, SysUtils, System.Classes, SyncObjs, geradorComandos,
  Vcl.StdCtrls, Log, Pix4Communication;

type

  TPix4 = class

  public
    {public fields}

    {public methods}
    procedure LoadSerialPorts(items: TStrings);
    function OpenSerialPort(const ComPort: string): boolean;
    procedure Disconnect;

    function ObterVersaoFirmware: Integer;
    function ObtemModelo: string;

  private
    {private fields}
    hSerialPort : THandle;

    {private methods}
  end;

implementation

  procedure TPix4.LoadSerialPorts(items: TStrings);
  var
    RegIni: TRegistry;
    AList: TStringList;
    loop: Integer;
  begin
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
    finally
      RegIni.Free;
      AList.Free;
    end;
  end;

function TPix4.OpenSerialPort(const ComPort: string): boolean;
begin
  hSerialPort := OpenPort(hSerialPort, ComPort);
  if hSerialPort = INVALID_HANDLE_VALUE then
     result := False
  else
    result := True;
end;

procedure TPix4.Disconnect;
begin
  CloseHandle(hSerialPort);
end;



function TPix4.ObterVersaoFirmware: Integer;
var
  retorno: Boolean;
  data: integer;
  firmwareVersion: integer;
begin
  retorno := WritePix4(hSerialPort, gerarComandoObterVersaoFirmware);

  if retorno then
  begin
    data := ReadPix4Int(hSerialPort);
    writeLogs('firmware Version: ' + IntToStr(data));
    result := data;
  end
  else
    Result := -1;
end;

function TPix4.ObtemModelo: string;
var
  retorno: Boolean;
  hexdata: string;
begin
  retorno := WritePix4(hSerialPort, gerarComandoObterModelo);

  if retorno then
  begin
    hexdata := ReadPix4(hSerialPort);
    result := hexdata;
  end
  else
    Result := 'erro';
end;

end.
