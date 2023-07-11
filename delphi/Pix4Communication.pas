unit Pix4Communication;

(*
  This Unit makes the actual communication with the Pix4 device.
*)

interface

uses
  Windows, System.Classes, System.SysUtils, Log;

  function HexToByte(hexData: string): TBytes;
  function OpenPort(hSerialPort: THandle; ComPort: string): THandle;
  function WritePix4(hSerialPort: THandle; bytesData: TBytes): Boolean;
  function ReadPix4(hSerialPort: THandle): string;
  function ReadPix4Int(hSerialPort: THandle): integer;

implementation

function HexToByte(hexData: string): TBytes;
var
  bytesData: TBytes;
begin
  hexData := StringReplace(hexData, ' ', '', [rfReplaceAll]);
  SetLength(bytesData, Length(hexData) div 2);
  HexToBin(PChar(hexData), @bytesData[0], Length(bytesData));
  result := bytesData;
end;

function WritePix4(hSerialPort: THandle; bytesData: TBytes): boolean;
var
  bytesWritten: DWORD;
  dcb: TDCB;
begin
  // check if serial port handle is valid before writing
  if (hSerialPort = INVALID_HANDLE_VALUE) or (hSerialPort = 0) then
  begin
    writeLogs('Invalid serial port handle');
    result := false;
    exit;
  end;
    // Check if the serial port is open
  if not GetCommState(hSerialPort, dcb) then
  begin
    writeLogs('Serial port is not open.');
    Result := False;
    Exit;
  end;


  // write data to the serial port
  if not WriteFile(hSerialPort, bytesData[0], Length(bytesData), bytesWritten, nil) then
  begin
    writeLogs('Failed to write data to the serial port. Error: ' + IntToStr(GetLastError));
    result := False;
    exit;
  end;

  // Check if all bytes were written successfully
  if bytesWritten <> DWORD(Length(bytesData)) then
  begin
    writeLogs('Not all bytes were written to the serial port.');
    Result := False;
    Exit;
  end;

  result := True;
end;

function ReadPix4(hSerialPort: THandle): string;
var
  hexData: string;
  bytesRead: DWORD;
  readBuffer: array[0..99] of Byte;
begin
  // read data from the serial port
  if not ReadFile(hSerialPort, readBuffer, SizeOf(readBuffer), bytesRead, nil) then
  begin
    writeLogs('Failed to read data from the serial port. Error: ' + IntToStr(GetLastError));
    result := 'erro';
    exit;
  end;

  writeLogs('Port was read, about to convert');
  // convert received data to string
  SetString(hexData, PAnsiChar(@readBuffer[0]), bytesRead * 2);
  writeLogs(hexData);
  result := hexData;
end;

function ReadPix4Int(hSerialPort: THandle): integer;
var
  bytesRead: DWORD;
  readBuffer: array[0..99] of Byte;
  hexData: AnsiString;
  intValue: integer;
begin
  // read data from the serial port
  if not ReadFile(hSerialPort, readBuffer, SizeOf(readBuffer), bytesRead, nil) then
  begin
    writeLogs('Failed to read data from the serial port. Error: ' + IntToStr(GetLastError));
    result := -1;
    exit;
  end;

  writeLogs('Port was read, about to convert');
  // convert received data to string
  SetString(hexData, PAnsiChar(@readBuffer[0]), bytesRead * 2);

  writeLogs('Int in String: ' + Trim(String(hexData)));
  // convert string to int
  try
    intValue := StrToInt(Trim(String(hexData)));
    result := intValue;
  except
    on EConvertError do
    begin
      writeLogs('Failed to convert data to integer.');
      result := -1;
    end;
  end;
end;

function OpenPort(hSerialPort: THandle; ComPort: string): THandle;
var
  dcb: TDCB;
  timeouts: TCommTimeouts;
begin
  // open the serial connection
  hSerialPort := CreateFile(
    PChar(Format('\\.\%s', [ComPort])),
    GENERIC_READ or GENERIC_WRITE,
    0,
    nil,
    OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL,
    0
  );
  if hSerialPort = INVALID_HANDLE_VALUE then
  begin
    writeLogs('Failed to open the serial port. Error: ' + IntToStr(GetLastError));
    result := hSerialPort;
    exit;
  end;

  // configure the serial port settings
  FillChar(dcb, SizeOf(dcb), 0);
  dcb.DCBlength := SizeOf(dcb);
  if not GetCommState(hSerialPort, dcb) then
  begin
    writeLogs('Failed to retrieve serial port settings. Error: ' + IntToStr(GetLastError));
    CloseHandle(hSerialPort);
    result := hSerialPort;
    exit;
  end;
  dcb.BaudRate := CBR_9600;
  dcb.ByteSize := 8;
  dcb.Parity := NOPARITY;
  dcb.StopBits := ONESTOPBIT;
  if not SetCommState(hSerialPort, dcb) then
  begin
    writeLogs('Failed to set serial port settings. Error: ' + IntToStr(GetLastError));
    CloseHandle(hSerialPort);
    result := hSerialPort;
    exit;
  end;

  // set the timeouts for read operations
  FillChar(timeouts, SizeOf(timeouts), 0);
  timeouts.ReadIntervalTimeout := MAXDWORD;
  timeouts.ReadTotalTimeoutMultiplier := 0;
  timeouts.ReadTotalTimeoutConstant := 2000; // set a timeout in milliseconds
  if not SetCommTimeouts(hSerialPort, timeouts) then
  begin
    writeLogs('Failed to set serial port timeouts. Error: ' + IntToStr(GetLastError));
    CloseHandle(hSerialPort);
    result := hSerialPort;
    exit;
  end;

  result := hSerialPort;
end;

end.