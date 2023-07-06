object frmPix4: TfrmPix4
  Left = 0
  Top = 0
  Caption = 'Pix4'
  ClientHeight = 450
  ClientWidth = 671
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 121
    Height = 73
    Caption = 'Load Serial Ports'
    TabOrder = 0
    OnClick = Button1Click
  end
  object memoLogs: TMemo
    Left = 328
    Top = 56
    Width = 313
    Height = 369
    Lines.Strings = (
      'memoLogs')
    TabOrder = 1
  end
  object Button2: TButton
    Left = 8
    Top = 128
    Width = 121
    Height = 65
    Caption = 'Open Pix4 Connection'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 8
    Top = 216
    Width = 121
    Height = 65
    Caption = 'Close Connection'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 8
    Top = 296
    Width = 121
    Height = 57
    Caption = 'Obtem Vers'#227'o Firmware'
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 184
    Top = 160
    Width = 97
    Height = 113
    Caption = 'testeee'
    TabOrder = 5
    OnClick = Button5Click
  end
  object cmbPorts: TComboBox
    Left = 8
    Top = 96
    Width = 121
    Height = 21
    TabOrder = 6
    Text = 'Com ports Availables'
  end
end
