unit Pix4Communication;

(*
  This Unit makes the actual communication with the Pix4 device.
*)

interface

uses
  Windows, System.Classes, System.SysUtils, Log;

  function HexToByte(hexData: string): TBytes;
  function OpenPort(hSerialPort: THandle; ComPort: string): THandle;
  function WritePix4(hSerialPort: THandle; bytesData: TBytes): integer;
  function ReadPix4(hSerialPort: THandle): string;
  function ReadPix4Int(hSerialPort: THandle): integer;
  function ReadPix4CharacterByCharacter(hSerialPort: THandle): string;
  function AddSpacesEveryTwo(const toAdd: string): string;

const
  SUCESSO = 0;
  INVALID_PORT = -2;
  PORT_CLOSED = -4;
  FAILED_TO_WRITE = -3;
  BYTES_NOT_WRITTEN = -5;

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

function WritePix4(hSerialPort: THandle; bytesData: TBytes): integer;
var
  bytesWritten: DWORD;
  dcb: TDCB;
begin
  // check if serial port handle is valid before writing
  if (hSerialPort = INVALID_HANDLE_VALUE) or (hSerialPort = 0) then
  begin
    writeLogs('Invalid serial port handle');
    result := INVALID_PORT;
    exit;
  end;
    // Check if the serial port is open
  if not GetCommState(hSerialPort, dcb) then
  begin
    writeLogs('Serial port is not open.');
    Result := PORT_CLOSED;
    Exit;
  end;


  // write data to the serial port
  if not WriteFile(hSerialPort, bytesData[0], Length(bytesData), bytesWritten, nil) then
  begin
    writeLogs('Failed to write data to the serial port. Error: ' + IntToStr(GetLastError));
    result := FAILED_TO_WRITE;
    exit;
  end;

  // Check if all bytes were written successfully
  if bytesWritten <> DWORD(Length(bytesData)) then
  begin
    writeLogs('Not all bytes were written to the serial port.');
    Result := BYTES_NOT_WRITTEN;
    Exit;
  end;

  // wait for the byte to be written
  FlushFileBuffers(hSerialPort);

  result := SUCESSO;
end;

function ReadPix4(hSerialPort: THandle): string;
var
  i: integer;
  hexData: string;
  bytesRead: DWORD;
  readBuffer: array[0..255] of Byte;
  errors: DWORD;
  status: TCOMSTAT;
begin
  FillChar(status, SizeOf(status), 0);
  ClearCommError(hSerialPort, errors, @status);

  // read data from the serial port
  if not ReadFile(hSerialPort, readBuffer, SizeOf(readBuffer), bytesRead, nil) then
  begin
    writeLogs('Failed to read data from the serial port. Error: ' + IntToStr(GetLastError));
    result := 'erro';
    exit;
  end;

  writeLogs('Port was read, about to convert');

  // convert received bytes to hexadecimal string
  hexData := '';
  for i := 0 to bytesRead - 1 do
    hexData := hexData + IntToHex(readBuffer[i], 2);
  writeLogs(AddSpacesEveryTwo(hexData));

  writeLogs('bytesRead: ' + IntToStr(bytesRead));

  // convert received bytes to string ASCII encoding
  SetString(hexData, PAnsiChar(@readBuffer[0]), bytesRead);

  writeLogs(hexData);
  result := hexData;
end;

function ReadPix4Int(hSerialPort: THandle): integer;
var
  bytesRead: DWORD;
  readBuffer: array[0..255] of Byte;
  hexData: string;
  hexDataInt, i: integer;
begin
  // read data from the serial port
  if not ReadFile(hSerialPort, readBuffer, SizeOf(readBuffer), bytesRead, nil) then
  begin
    writeLogs('Failed to read data from the serial port. Error: ' + IntToStr(GetLastError));
    result := -1;
    exit;
  end;

  writeLogs('Port was read, about to convert');
  // Convert received bytes to hexadecimal string
  hexData := '';
  for i := 0 to bytesRead - 1 do
    hexData := hexData + IntToHex(readBuffer[i], 2);
  writeLogs(AddSpacesEveryTwo(hexData));

  // Convert the hexadecimal string to an integer value
  // Provide a default error value if conversion fails
  hexDataInt := StrToIntDef('$' + hexData, -1);

  writeLogs(IntToStr(hexDataInt));
  Result := hexDataInt;
end;

function ReadPix4CharacterByCharacter(hSerialPort: THandle): string;
var
  i, j: integer;
  hexData: string;
  bytesRead: DWORD;
  readBuffer: array[0..255] of Byte;
  errors: DWORD;
  status: TCOMSTAT;
  toRead: Cardinal;
  dotFound: boolean;
begin
  j := 0;
  dotFound := False;
  writeLogs('Entrando na função: ReadPix4CharacterByCharacter.');
  repeat
    FillChar(status, SizeOf(status), 0);
    ClearCommError(hSerialPort, errors, @status);

    if status.cbInQue > 0 then
      toRead := 1
    else
      toRead := 0;

    // read data from the serial port
    if not ReadFile(hSerialPort, readBuffer[j], toRead, bytesRead, nil) then
    begin
      writeLogs('Failed to read data from the serial port. Error: ' + IntToStr(GetLastError));
      result := 'erro';
      exit;
    end;

    writeLogs('readBuffer[' + IntToStr(j) + '] = ' + IntToHex(readBuffer[j]));
    if readBuffer[j] = $0A then // check for dot characters
    begin
      writeLogs('check buffer');
      dotFound := True;
      break;
    end;
    j := j + 1;

  until (bytesRead = 0) or dotFound;

  writeLogs('Port was read byte by byte, about to convert');

  // convert received bytes to hexadecimal string
  hexData := '';
  for i := 0 to j do
    hexData := hexData + IntToHex(readBuffer[i], 2);
  writeLogs('hex: ' + AddSpacesEveryTwo(hexData));

  writeLogs('bytesRead: ' + IntToStr(bytesRead));
  writeLogs('j: ' + IntToStr(j));

  // convert received bytes to string ASCII encoding
  SetString(hexData, PAnsiChar(@readBuffer[0]), j);

  writeLogs('ascii: ' + hexData);
  result := hexData;
end;


function OpenPort(hSerialPort: THandle; ComPort: string): THandle;
var
  dcb: TDCB;
  timeouts: TCommTimeouts;
  errMsg: DWORD;
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

  // use win32 api to get last error. returns an integer error code. There are
  // about 16.000 error codes, but we care about two (is device connected?, and
  // is it already being used by another app?
  errMsg := GetLastError;

  // the win32 error code for ERROR_FILE_NOT_FOUND is DWORD 2
  if errMsg = 2 then
  begin
    writeLogs('you need to, like, plug the device first');
    result := hSerialPort;
    exit;
  end;

  // the win32 error code for ERROR_ACCESS_DENIED is DWORD 5
  if errMsg = 5 then
  begin
    writeLogs('another app is already using your device');
    result := hSerialPort;
    exit;
  end;

  if hSerialPort = INVALID_HANDLE_VALUE then
  begin
    writeLogs('Failed to open the serial port. Error: ' + IntToStr(GetLastError));
    result := hSerialPort;
    exit;
  end;

  if errMsg <> 0 then
  begin
    writeLogs('Something went wrong opening the port. Check the win32 api ' +
    'to get the meaning of the ErrorCode: ' + IntToStr(GetLastError));
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




function AddSpacesEveryTwo(const toAdd: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(toAdd) do
  begin
    Result := Result + toAdd[i];
    if (i mod 2 = 0) and (i < Length(toAdd)) then
      Result := Result + ' ';
  end;
end;

end.
