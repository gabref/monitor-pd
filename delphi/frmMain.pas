unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Pix4, Pix4Communication, Registry, SyncObjs, System.IOUtils;

type
  TfrmPix4 = class(TForm)
    btnLoadSerialPorts: TButton;
    memoLogs: TMemo;
    btnOpenConnection: TButton;
    btnCloseConnection: TButton;
    btnVersaoFirmware: TButton;
    btnModelo: TButton;
    cmbPorts: TComboBox;
    btnInicializaDisplay: TButton;
    btnReinicializaDisplay: TButton;
    btnApresentaImagemDisplay: TButton;
    btnApresentaQRCode: TButton;
    btnApresentaTextoColorido: TButton;
    btnApresentaListaCompras: TButton;
    btnCarregaImagemDisplay: TButton;
    btnInicializaLayoutPagamento: TButton;
    btnAdicionaFormaPagamento: TButton;
    btnObtemConexao: TButton;
    Button1: TButton;
    editImgName: TEdit;
    procedure btnLoadSerialPortsClick(Sender: TObject);
    procedure btnOpenConnectionClick(Sender: TObject);
    procedure btnCloseConnectionClick(Sender: TObject);
    procedure btnVersaoFirmwareClick(Sender: TObject);
    procedure btnMoeloClick(Sender: TObject);
    function CheckPix4: Boolean;
    procedure btnInicializaDisplayClick(Sender: TObject);
    procedure btnReinicializaDisplayClick(Sender: TObject);
    procedure btnApresentaImagemDisplayClick(Sender: TObject);
    procedure btnApresentaQRCodeClick(Sender: TObject);
    procedure btnApresentaTextoColoridoClick(Sender: TObject);
    procedure btnApresentaListaComprasClick(Sender: TObject);
    procedure btnCarregaImagemDisplayClick(Sender: TObject);
    procedure btnInicializaLayoutPagamentoClick(Sender: TObject);
    procedure btnAdicionaFormaPagamentoClick(Sender: TObject);
    procedure btnObtemConexaoClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
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

function TFrmPix4.CheckPix4: boolean;
begin
  if not assigned(pix4) then
  begin
    memoLogs.Lines.Add('First Load Ports and Select Port to start');
    result := False;
    exit;
  end;
  result := True;
end;

procedure TfrmPix4.btnLoadSerialPortsClick(Sender: TObject);
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

procedure TfrmPix4.btnObtemConexaoClick(Sender: TObject);
begin
    if not CheckPix4 then exit;
  if pix4.ObtemConexao then
    memologs.Lines.Add('True')
  else
    memoLogs.Lines.Add('False');

end;

procedure TfrmPix4.btnOpenConnectionClick(Sender: TObject);
var
  portOpen: boolean;
begin
    if not CheckPix4 then exit;
    portOpen := pix4.OpenSerialPort(cmbPorts.Text);
    if portOpen then
    begin
      memoLogs.Lines.Add('Connection opened');
      exit;
    end;
    memoLogs.Lines.Add('connection failed');
end;

procedure TfrmPix4.btnCloseConnectionClick(Sender: TObject);
begin
  if assigned(pix4) then
  begin
    Pix4.DesconectarPix4;
    FreeAndNil(pix4);
  end;
  memoLogs.Lines.Add('pix4 connection closed');
end;

procedure TfrmPix4.btnVersaoFirmwareClick(Sender: TObject);
var
  temp : integer;
begin
  if not CheckPix4 then exit;
  temp := Pix4.ObterVersaoFirmware;
  memoLogs.Lines.Add(inttoStr(temp));
end;

procedure TfrmPix4.btnMoeloClick(Sender: TObject);
var
  ret : string;
begin
  if not CheckPix4 then exit;
  ret := pix4.ObtemModelo;
  memoLogs.lines.add(ret);

end;

procedure TfrmPix4.btnInicializaDisplayClick(Sender: TObject);
var
  ret : integer;
begin
  if not CheckPix4 then exit;
  ret := pix4.InicializarPIX4;
  memoLogs.Lines.Add(IntToStr(ret));
end;

procedure TfrmPix4.btnReinicializaDisplayClick(Sender: TObject);
var
  ret : integer;
begin
  if not CheckPix4 then exit;
  ret := pix4.Reinicializar;
  memoLogs.Lines.Add(IntToStr(ret));
end;

procedure TfrmPix4.btnCarregaImagemDisplayClick(Sender: TObject);
var
  ret : integer;
  imgName: string;
begin
  if not CheckPix4 then exit;
  imgName := editImgName.Text;
  ret := pix4.UploadImagem('imagemTeste', imgName);
  memoLogs.Lines.Add(IntToStr(ret));
end;

procedure TfrmPix4.btnApresentaImagemDisplayClick(Sender: TObject);
var
  ret : integer;
begin
  if not CheckPix4 then exit;
  ret := pix4.ApresentaImagem('imagemTeste', 0, 0, 1);
  memoLogs.Lines.Add(IntToStr(ret));
end;

procedure TfrmPix4.btnApresentaQRCodeClick(Sender: TObject);
var
  ret : integer;
begin
  if not CheckPix4 then exit;
  ret := pix4.ApresentaQRCode('Teste de QRCode', 150, 90, 140);
  memoLogs.Lines.Add(IntToStr(ret));
end;

procedure TfrmPix4.btnApresentaTextoColoridoClick(Sender: TObject);
var
  ret : integer;
begin
  if not CheckPix4 then exit;
  ret := pix4.ApresentaTexto('Teste de Texto', 1, 30, 100, 40, '#000000');
  memoLogs.Lines.Add(IntToStr(ret));
end;

procedure TfrmPix4.btnApresentaListaComprasClick(Sender: TObject);
begin
  if not CheckPix4 then exit;
  pix4.ApresentaListaCompras('Bolo de Morango', '99,98');
end;

procedure TfrmPix4.btnInicializaLayoutPagamentoClick(Sender: TObject);
begin
  if not CheckPix4 then exit;
  pix4.InicializaLayoutPagamento('99.00', '39.99', '60.00');
end;

procedure TfrmPix4.btnAdicionaFormaPagamentoClick(Sender: TObject);
var
  ret : integer;
begin
  if not CheckPix4 then exit;
  ret := pix4.AdicionaFormaPagamento(1, '60.00');
  memoLogs.Lines.Add(IntToStr(ret));
end;





procedure TfrmPix4.Button1Click(Sender: TObject);
var
  bytes: TBytes;
  bytesWritten: DWORD;
  dadosComando, aux: string;
  fileStream: TFileStream;
  CRC16_file: Word;
  i: Integer;
  filePath : string;
  size : int64;
begin
  filePath := editImgName.Text;
  if not FileExists(filePath) then
  begin
    memoLogs.Lines.Add('no file');
    exit;
  end;

  memoLogs.Lines.Add('Achou file');

  size := pix4.FileSizeImage(filePath);

  memoLogs.Lines.Add('Tamanho do file: ' + size.ToString);

  if pix4.FileSizeImage(filePath) = 0 then
  begin
      memoLogs.Lines.add('O Arquivo não pode ser vazio ou nulo');
      Exit;
  end;
  memologs.Lines.Add('arquivo não vazio');

//  fileStream := TFileStream.Create(filePath, fmOpenRead or fmShareDenyWrite);
//  try
//    if fileStream.Size = 0 then
//    begin
//      writeLogs('O Arquivo não pode ser vazio ou nulo');
//      Exit;
//    end;
//
//    SetLength(bytes, fileStream.Size);
//    fileStream.ReadBuffer(bytes[0], Length(bytes));
//  finally
//    fileStream.Free;
//  end;

  try
    bytes := TFile.ReadAllBytes(filePath);
    memoLogs.Lines.add('Arquivo aberto com sucesso');
    memoLogs.Lines.add('Tamanho do arquivo: ' + IntToStr(length(bytes)));
  except
    // clear the array
    SetLength(bytes, 0);
    memoLogs.Lines.add('Não foi possível ler o arquivo');
    exit;
  end;

  if Length(bytes) = 0 then
  begin
      memoLogs.Lines.add('O Arquivo não pode ser vazio ou nulo');
      Exit;
  end;

  memoLogs.Lines.Add('FUNFANDO');
end;

end.
