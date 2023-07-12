object frmPix4: TfrmPix4
  Left = 0
  Top = 0
  Caption = 'Pix4'
  ClientHeight = 526
  ClientWidth = 775
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnLoadSerialPorts: TButton
    Left = 16
    Top = 23
    Width = 121
    Height = 65
    Caption = 'Load Serial Ports'
    TabOrder = 0
    OnClick = btnLoadSerialPortsClick
  end
  object memoLogs: TMemo
    Left = 496
    Top = 16
    Width = 257
    Height = 489
    Lines.Strings = (
      'memoLogs')
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object btnOpenConnection: TButton
    Left = 16
    Top = 121
    Width = 121
    Height = 65
    Caption = 'Open Pix4 Connection'
    TabOrder = 2
    OnClick = btnOpenConnectionClick
  end
  object btnCloseConnection: TButton
    Left = 16
    Top = 360
    Width = 121
    Height = 65
    Caption = 'Close Connection'
    TabOrder = 3
    OnClick = btnCloseConnectionClick
  end
  object btnVersaoFirmware: TButton
    Left = 16
    Top = 440
    Width = 121
    Height = 65
    Caption = 'Obtem Vers'#227'o Firmware'
    TabOrder = 4
    OnClick = btnVersaoFirmwareClick
  end
  object btnModelo: TButton
    Left = 184
    Top = 440
    Width = 121
    Height = 65
    Caption = 'Obtem Modelo'
    TabOrder = 5
    OnClick = btnMoeloClick
  end
  object cmbPorts: TComboBox
    Left = 16
    Top = 94
    Width = 121
    Height = 21
    TabOrder = 6
    Text = 'Com ports Availables'
  end
  object btnInicializaDisplay: TButton
    Left = 16
    Top = 200
    Width = 121
    Height = 65
    Caption = 'Inicializa Display'
    TabOrder = 7
    OnClick = btnInicializaDisplayClick
  end
  object btnReinicializaDisplay: TButton
    Left = 16
    Top = 281
    Width = 121
    Height = 65
    Caption = 'Reinicializa Display'
    TabOrder = 8
    OnClick = btnReinicializaDisplayClick
  end
  object btnApresentaImagemDisplay: TButton
    Left = 184
    Top = 121
    Width = 121
    Height = 65
    Caption = 'Apresenta Imagem Display'
    TabOrder = 9
    WordWrap = True
    OnClick = btnApresentaImagemDisplayClick
  end
  object btnApresentaQRCode: TButton
    Left = 184
    Top = 200
    Width = 121
    Height = 65
    Caption = 'Apresenta QR Code'
    TabOrder = 10
    WordWrap = True
    OnClick = btnApresentaQRCodeClick
  end
  object btnApresentaTextoColorido: TButton
    Left = 184
    Top = 281
    Width = 121
    Height = 65
    Caption = 'Apresenta Texto Colorido'
    TabOrder = 11
    WordWrap = True
    OnClick = btnApresentaTextoColoridoClick
  end
  object btnApresentaListaCompras: TButton
    Left = 184
    Top = 360
    Width = 121
    Height = 65
    Caption = 'Apresenta Lista  Compras'
    TabOrder = 12
    WordWrap = True
    OnClick = btnApresentaListaComprasClick
  end
  object btnCarregaImagemDisplay: TButton
    Left = 184
    Top = 23
    Width = 121
    Height = 65
    Caption = 'Carrega Imagem Display'
    TabOrder = 13
    WordWrap = True
    OnClick = btnCarregaImagemDisplayClick
  end
  object btnInicializaLayoutPagamento: TButton
    Left = 344
    Top = 23
    Width = 121
    Height = 65
    Caption = 'Inicializa Layout Pagemento'
    TabOrder = 14
    WordWrap = True
    OnClick = btnInicializaLayoutPagamentoClick
  end
  object btnAdicionaFormaPagamento: TButton
    Left = 344
    Top = 121
    Width = 121
    Height = 65
    Caption = 'Adicionar Forma Pagamento'
    TabOrder = 15
    WordWrap = True
    OnClick = btnAdicionaFormaPagamentoClick
  end
  object btnObtemConexao: TButton
    Left = 344
    Top = 200
    Width = 121
    Height = 65
    Caption = 'Obtem Conex'#227'o'
    TabOrder = 16
    WordWrap = True
    OnClick = btnObtemConexaoClick
  end
  object Button1: TButton
    Left = 344
    Top = 281
    Width = 113
    Height = 65
    Caption = 'btnTeste'
    TabOrder = 17
    OnClick = Button1Click
  end
end
