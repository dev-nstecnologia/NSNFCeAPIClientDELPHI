object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  Caption = 'frmPrincipal'
  ClientHeight = 614
  ClientWidth = 580
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object labelTokenEnviar: TLabel
    Left = 30
    Top = 8
    Width = 64
    Height = 16
    Caption = 'Salvar em:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object pgControl: TPageControl
    Left = 8
    Top = 47
    Width = 561
    Height = 561
    ActivePage = formEmissao
    Align = alCustom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object formEmissao: TTabSheet
      Caption = 'Emiss'#227'o S'#237'ncrona'
      object Label1: TLabel
        Left = 16
        Top = 15
        Width = 61
        Height = 16
        Caption = 'Conteudo:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label2: TLabel
        Left = 339
        Top = 15
        Width = 111
        Height = 16
        Caption = 'Tipo de Conteudo:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label5: TLabel
        Left = 21
        Top = 220
        Width = 110
        Height = 16
        Caption = 'Tipo de Ambiente:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object btnEnviar: TButton
        Left = 240
        Top = 256
        Width = 292
        Height = 28
        Caption = 'Enviar'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = btnEnviarClick
      end
      object memoConteudoEnviar: TMemo
        Left = 21
        Top = 37
        Width = 511
        Height = 153
        ScrollBars = ssBoth
        TabOrder = 1
      end
      object cbTpConteudo: TComboBox
        Left = 456
        Top = 3
        Width = 76
        Height = 28
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 2
        Text = 'txt'
        Items.Strings = (
          'txt'
          'xml'
          'json')
      end
      object chkExibir: TCheckBox
        Left = 20
        Top = 256
        Width = 111
        Height = 17
        Caption = 'Exibir em tela?'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
      end
      object GroupBox4: TGroupBox
        Left = 3
        Top = 311
        Width = 544
        Height = 212
        Caption = 'Retorno API'
        TabOrder = 4
        object memoRetorno: TMemo
          Left = 12
          Top = 24
          Width = 517
          Height = 177
          TabOrder = 0
        end
      end
      object cbTpAmb: TComboBox
        Left = 137
        Top = 214
        Width = 41
        Height = 28
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 5
        Text = '2'
        Items.Strings = (
          '2'
          '1')
      end
    end
  end
  object txtCaminho: TEdit
    Left = 100
    Top = 8
    Width = 459
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Text = './Notas/'
  end
end
