object DataModuleContextMenuHandler: TDataModuleContextMenuHandler
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 479
  Width = 741
  object DropContextMenu1: TDropContextMenu
    ContextMenu = PopupMenu1
    OnPopup = DropContextMenu1Popup
    Left = 48
    Top = 16
  end
  object PopupMenu1: TPopupMenu
    OwnerDraw = True
    Left = 48
    Top = 72
    object MenuLineBegin: TMenuItem
      Caption = '-'
    end
    object MenuCOMServer: TMenuItem
      Bitmap.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        04000000000080000000120B0000120B00001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCCCCCCCCCCFFCFFFC777777
        77CFC7CCCC77777777CFFCFFFC77777777CFFFFFFC77777777CFFCFFFC777777
        77CFC7CCCC77777777CFFCFFFC77777777CFFFFFFCCCCCCCCCCFFFFFFFFFFFCF
        FFFFFFFFFFFFFFCFFFFFFFFFFFFFFC7CFFFFFFFFFFFFFFCFFFFF}
      Caption = 'COM Server'
      Hint = 'Register or unregister the selected COM server'
      object MenuRegister: TMenuItem
        Bitmap.Data = {
          E6000000424DE60000000000000076000000280000000E0000000E0000000100
          0400000000007000000000000000000000001000000000000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
          3300333333333333330033334433333333003334224333333300334222243333
          330034222222433333003222AA2224333300322A33A2224333003AA3333A2224
          330033333333A2224300333333333A2224003333333333A2240033333333333A
          22003333333333333300}
        Caption = 'Register %s'
        Hint = 'Register the selected COM server'
        OnClick = MenuRegisterClick
      end
      object MenuUnregister: TMenuItem
        Bitmap.Data = {
          E6000000424DE60000000000000076000000280000000E0000000E0000000100
          0400000000007000000000000000000000001000000000000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
          3300333388888333330033381111183333003389199911833300339133389118
          3300391833311111830039183311199183003918811133918300391811133391
          8300391111333311830033911888819833003339111119833300333399999333
          33003333333333333300}
        Caption = 'Unregister %s'
        Hint = 'Unregister the selected COM server'
        OnClick = MenuUnregisterClick
      end
    end
    object MenuAbout: TMenuItem
      Caption = 'About'
      object MenuAboutInfo: TMenuItem
        Hint = 
          'Click to visit the Drag and Drop Component Suite home page on th' +
          'e net'
        OnClick = MenuAboutInfoClick
        OnDrawItem = MenuAboutInfoDrawItem
        OnMeasureItem = MenuAboutInfoMeasureItem
      end
    end
    object MenuLineEnd: TMenuItem
      Caption = '-'
    end
  end
  object ImageList1: TImageList
    AllocBy = 1
    Height = 416
    Masked = False
    Width = 200
    Left = 48
    Top = 132
  end
end
