object DataModuleDragDropHandler: TDataModuleDragDropHandler
  Height = 479
  Width = 741
  object PopupMenu1: TPopupMenu
    Left = 48
    Top = 72
    object MenuEncrypt: TMenuItem
      Bitmap.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000000C1742002140BD000C17420000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000223DA885CEE6FF00223EA9000D
        173D000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000002742A183CCE5FF7DCAE4FF0027
        43A2000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000324EA983CCE5FF00324EA9000E
        152E000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000003C5BB683CCE5FF72BBD4F6003C
        5BB6000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000003C5BB583CCE5FF003C5BB5000F
        172E000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000003B59B183CCE5FF66B8D5FF003B
        59B1000000000000000000000000000000000000000000000000000000000000
        000000000000000000000002030500162141003956AC83CCE5FF61B3D2FF0039
        56AC001621410002030500000000000000000000000000000000000000000000
        000000000000000204070026386D306E89C572B4CEEB72BCDAFF5BAECEFF50A1
        C2EB226886C50026386D00020407000000000000000000000000000000000000
        000000000000001C294B43839ECC96DAF6FF88CCEEFF67B2D3FF4CA2C5FF4DAF
        D7FF62C6EDFF2F7A9BCC001C294B000000000000000000000000000000000000
        00000000000001344D8594D8EFF79ADEF8FF96DAF5FF81CAE5FF6EBDDAFF6AC3
        E4FF69CAF0FF66C7ECF701344D85000000000000000000000000000000000000
        000000000000013D5A92A1E5FEFF0D7B8FCE007284C9007284C9007284C90072
        84C907798ECE6ED3FAFF013D5A92000000000000000000000000000000000000
        00000000000001324A7181C6DEEB3C94B0DD00445482000D1019000D10190044
        5482248CACDD62BADCEB01324A71000000000000000000000000000000000000
        0000000000000016202F195D7DA49DE1F9FF3A87A6D60B5978BA085876BA227C
        9ED677D1F3FF165C7DA40016202F000000000000000000000000000000000000
        000000000000000001010125374C1A5F7FA16DB3CDDD8DD5ECFF80CCE6FF5EAA
        C6DD175D7FA10125374C00000101000000000000000000000000000000000000
        00000000000000000000000001010117222D01354F6902426283024262830135
        4F690117222D0000010100000000000000000000000000000000}
      Caption = 'Encrypt %s'
      Hint = 'Encrypt the file and place the encrypted file in this directory.'
      OnClick = MenuEncryptClick
    end
    object MenuLine1: TMenuItem
      Caption = '-'
    end
  end
  object DragDropHandler1: TDragDropHandler
    ContextMenu = PopupMenu1
    OnPopup = DragDropHandler1Popup
    Left = 48
    Top = 16
  end
end
