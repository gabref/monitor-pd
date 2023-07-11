unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Pix4, Pix4Communication, Registry, SyncObjs;

type
  TfrmPix4 = class(TForm)
    Button1: TButton;
    memoLogs: TMemo;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    cmbPorts: TComboBox;
    Button6: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    pix4 : tpix4;
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
var
  portOpen: boolean;
begin
    portOpen := pix4.OpenSerialPort(cmbPorts.Text);
    if portOpen then
    begin
      ShowMessage('Connection opened');
      exit;
    end;
    showmessage('connection failed');
end;

procedure TfrmPix4.Button3Click(Sender: TObject);
begin
  Pix4.Disconnect;
  pix4.Free;
  memoLogs.Lines.Add('pix4 connection closed');
end;

procedure TfrmPix4.Button4Click(Sender: TObject);
var
  temp : integer;
begin
  temp := Pix4.ObterVersaoFirmware;
  memoLogs.Lines.Add(inttoStr(temp));
  showmessage(inttostr(temp));
end;

procedure TfrmPix4.Button5Click(Sender: TObject);
var
  ret : string;
begin
  ret := pix4.ObtemModelo;
  memoLogs.lines.add(ret);
  showmessage('read the pix4 info: ' + ret);

end;

procedure TfrmPix4.Button6Click(Sender: TObject);
var
  hex : string;
begin
  hex := '02 07 16 01';
end;

end.
