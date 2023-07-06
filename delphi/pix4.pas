unit pix4;

interface

uses
  Windows, Registry, SysUtils, System.Classes, geradorComandos;

type
  TPix4 = class

  public
    {public fields}
    const
      HexDigits: array[0..15] of Char = '0123456789ABCDEF';

    {public methods}
    procedure LoadSerialPorts(items: TStrings);
    function OpenSerialPort(const PortName: string): THandle;
    procedure Disconnect(PortHandle: THandle);
    function WriteData(PortHandle: THandle; const Data: TBytes): Boolean;
    function ReadData(PortHandle: THandle; Count: Integer): TBytes;
    function IOBterVersaoFirmware(PortHandle: THandle): Integer;
  private
    {private fields}
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

function TPix4.OpenSerialPort(const PortName: string): THandle;
var
  PortHandle: THandle;
  DCB: TDCB;
  BaudRate: DWORD;
begin
  BaudRate := 9600;
  PortHandle := CreateFile(PChar(PortName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
  if PortHandle = INVALID_HANDLE_VALUE then
    RaiseLastOSError;

  // Get the current serial port settings
  FillChar(DCB, SizeOf(DCB), 0);
  DCB.DCBlength := SizeOf(DCB);
  if not GetCommState(PortHandle, DCB) then
  begin
    CloseHandle(PortHandle);
    RaiseLastOSError;
  end;

  // Update the baud rate
  DCB.BaudRate := BaudRate;

  // Apply the modified serial port settings
  if not SetCommState(PortHandle, DCB) then
  begin
    CloseHandle(PortHandle);
    RaiseLastOSError;
  end;

  Result := PortHandle;
end;

procedure TPix4.Disconnect(PortHandle: THandle);
begin
  CloseHandle(PortHandle);
end;


function TPix4.WriteData(PortHandle: THandle; const Data: TBytes): Boolean;
var
  BytesWritten: DWORD;
begin
  Result := WriteFile(PortHandle, Data[0], Length(Data), BytesWritten, nil);
  if not Result then begin
    RaiseLastOSError;
  end;
end;

function TPix4.ReadData(PortHandle: THandle; Count: Integer): TBytes;
var
  BytesRead: DWORD;
  Buffer: array of Byte;
begin
  SetLength(Buffer, Count);
  if not ReadFile(PortHandle, Buffer[0], Count, BytesRead, nil) then
    RaiseLastOSError;

  SetLength(Result, BytesRead);
  Move(Buffer[0], Result[0], BytesRead);
end;

function BytesToHex(const Bytes: TBytes): string;
var
  I: Integer;
begin
  SetLength(Result, Length(Bytes) * 2);
  for I := 0 to Length(Bytes) - 1 do
    Result[(I * 2) + 1] := TPix4.HexDigits[(Bytes[I] shr 4) + 1];
    Result[(I * 2) + 2] := TPix4.HexDigits[(Bytes[I] and $0F) + 1];
  end;

function TPix4.IOBterVersaoFirmware(PortHandle: THandle): Integer;
var
  retorno, ok: Boolean;
  aux: Integer;
  data: TBytes;
begin
  retorno := writeData(PortHandle, TGeradorComandos.GerarComandoObterVersaoFirmware);

  if retorno then
  begin
    data := readData(PortHandle, 4);
    aux := StrToInt('$' + BytesToHex(data));
    if aux <= 0 then
      Result := -1
    else
      Result := aux;
  end
  else
    Result := -1;
end;

end.