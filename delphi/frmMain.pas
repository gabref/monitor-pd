unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Pix4, Registry, SyncObjs;

type
  TSerialThread = class(TThread)
  private
    FComPort: string;
    FReceivedData: string;
  protected
    procedure Execute; override;
  public
    constructor Create(const ComPort: string);
    property ReceivedData: string read FReceivedData;
  end;

  TfrmPix4 = class(TForm)
    Button1: TButton;
    memoLogs: TMemo;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    cmbPorts: TComboBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure HandleReceivedData(const Data: string);
    procedure SerialThreadTerminate(Sender: TObject);
  private
    { Private declarations }
    FSerialThread: TSerialThread;
    FLock: TCriticalSection;
  public
    { Public declarations }
    pix4 : tpix4;
    PortHandle : THandle;
  end;

var
  frmPix4: TfrmPix4;

implementation

{$R *.dfm}

procedure TfrmPix4.Button1Click(Sender: TObject);
var
  portList : TStringList;
  I: Integer;
begin
  memologs.Clear;
  pix4 := tpix4.Create;
  portList := TStringList.Create;
  pix4.LoadSerialPorts(portList);
  memoLogs.Lines.AddStrings(portList);
  cmbPorts.Items.Clear; // Clear existing items in the ComboBox
  for i := 0 to portList.Count - 1 do
  begin
    cmbPorts.Items.Add(portList[i]); // Add each item to the ComboBox
  end;
end;

procedure TfrmPix4.Button2Click(Sender: TObject);
begin
  try
    PortHandle := pix4.OpenSerialPort(cmbPorts.Text);
    try
      // connection opened successfully, do further operations...
      ShowMessage('Connection opened');
    finally
      // close the connection
      // CloseHandle(PortHandle);
    end;
  except on E: Exception do begin
      Writeln('Failed to open COM port: ', E.Message);
      ShowMessage('connection failed');
    end;
  end;
end;

procedure TfrmPix4.Button3Click(Sender: TObject);
begin
  Pix4.Disconnect(PortHandle);
end;

procedure TfrmPix4.Button4Click(Sender: TObject);
var
  temp : integer;
begin
  temp := Pix4.IOBterVersaoFirmware(PortHandle);
  memoLogs.Lines.Add(inttoStr(temp));
  showmessage(inttostr(temp));
end;

// -------------------------------------------------
// -------------------------------------------------
// -------------------------------------------------
// -------------------------------------------------
// -------------------------------------------------

constructor TSerialThread.Create(const ComPort: string);
begin
  inherited Create(True);
  FComPort := ComPort;
end;

procedure TSerialThread.Execute;
var
  hSerialPort: THandle;
  dcb: TDCB;
  bytesWritten: DWORD;
  bytesRead: DWORD;
  hexData: string;
  bytesData: TBytes;
  readBuffer: array[0..99] of Byte;
  timeouts: TCommTimeouts;
begin
  // Open the serial connection
  hSerialPort := CreateFile(
    PChar(Format('\\.\%s', [FComPort])),
    GENERIC_READ or GENERIC_WRITE,
    0,
    nil,
    OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL,
    0
  );
  if hSerialPort = INVALID_HANDLE_VALUE then
  begin
    Synchronize(procedure
    begin
      frmPix4.HandleReceivedData('Failed to open the serial port. Error: ' + IntToStr(GetLastError));
    end);
    Exit;
  end;

  // Configure the serial port settings
  FillChar(dcb, SizeOf(dcb), 0);
  dcb.DCBlength := SizeOf(dcb);
  if not GetCommState(hSerialPort, dcb) then
  begin
    Synchronize(procedure
    begin
      frmPix4.HandleReceivedData('Failed to retrieve serial port settings. Error: ' + IntToStr(GetLastError));
    end);
    CloseHandle(hSerialPort);
    Exit;
  end;
  dcb.BaudRate := CBR_9600;
  dcb.ByteSize := 8;
  dcb.Parity := NOPARITY;
  dcb.StopBits := ONESTOPBIT;
  if not SetCommState(hSerialPort, dcb) then
  begin
    Synchronize(procedure
    begin
      frmPix4.HandleReceivedData('Failed to set serial port settings. Error: ' + IntToStr(GetLastError));
    end);
    CloseHandle(hSerialPort);
    Exit;
  end;

  // Set the timeouts for read operations
  FillChar(timeouts, SizeOf(timeouts), 0);
  timeouts.ReadIntervalTimeout := MAXDWORD;
  timeouts.ReadTotalTimeoutMultiplier := 0;
  timeouts.ReadTotalTimeoutConstant := 2000; // Set a timeout value in milliseconds (adjust as needed)
  if not SetCommTimeouts(hSerialPort, timeouts) then
  begin
    Synchronize(
      procedure
      begin
        frmPix4.HandleReceivedData('Failed to set serial port timeouts. Error: ' + IntToStr(GetLastError));
      end
    );
    CloseHandle(hSerialPort);
    Exit;
  end;

  // Convert hex data to bytes
  hexData := '02 07 16 01';
  hexData := StringReplace(hexData, ' ', '', [rfReplaceAll]);
  SetLength(bytesData, Length(hexData) div 2);
  HexToBin(PChar(hexData), @bytesData[0], Length(bytesData));

  // Send the data
  if not WriteFile(hSerialPort, bytesData[0], Length(bytesData), bytesWritten, nil) then
  begin
    Synchronize(procedure
    begin
      frmPix4.HandleReceivedData('Failed to write data to the serial port. Error: ' + IntToStr(GetLastError));
    end);
    CloseHandle(hSerialPort);
    Exit;
  end;


    Synchronize(procedure
    begin
      frmPix4.HandleReceivedData('About to read the port');
    end);
  // Read data from the serial port
  if not ReadFile(hSerialPort, readBuffer, SizeOf(readBuffer), bytesRead, nil) then
  begin
    Synchronize(procedure
    begin
      frmPix4.HandleReceivedData('Failed to read data from the serial port. Error: ' + IntToStr(GetLastError));
    end);
    CloseHandle(hSerialPort);
    Exit;
  end;

            Synchronize(procedure
    begin
      frmPix4.HandleReceivedData('Port was read, about to convert');
    end);
  // Convert received data to string
  SetString(hexData, PAnsiChar(@readBuffer[0]), bytesRead * 2);
  Synchronize(procedure
  begin
    frmPix4.HandleReceivedData(hexData);
  end);

  // Close the serial connection
  CloseHandle(hSerialPort);
end;

                        procedure TfrmPix4.Button5Click(Sender: TObject);
begin
  FSerialThread := TSerialThread.Create(cmbPorts.Text); // Replace with the desired COM port
  FSerialThread.OnTerminate := SerialThreadTerminate;
  FSerialThread.Start;
end;

procedure TfrmPix4.SerialThreadTerminate(Sender: TObject);
begin
  FSerialThread := nil;
end;

procedure TfrmPix4.HandleReceivedData(const Data: string);
begin
  // Handle the received data here
  memologs.Lines.add('Received data: ' + Data);
end;


end.