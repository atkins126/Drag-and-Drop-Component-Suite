�
 TFORMAUTOSCROLL 0�  TPF0TFormAutoScrollFormAutoScrollLeft�Top� 
AutoScrollCaptionCustom auto scroll demoClientHeight�ClientWidth�Color	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style OldCreateOrderPositionpoDefaultPosOnlyPixelsPerInch`
TextHeight TPanelPanel3Left TopHWidth�Height� AlignalBottom
BevelOuterbvNoneBorderWidthCaption TabOrder  	TRichEdit	RichEdit1LeftTopWidth�Height� AlignalClientBorderStylebsNoneEnabledLines.Strings9This application demonstrates custom auto scroll margins. YStandard auto scroll uses fixed size scroll margins (or "scroll zone") where the size of Hthe margins are calculated based on the target control scroll bar width. TThis works well for most uses, but in some situations it is desirable to be able to Zdefine different scroll margins for each of the target control's edges. An example is the Uabove grid where we would like the scroll zone to be calculated relative to the data area of the grid.  ParentColor	ReadOnly	TabOrder WantReturns   TPanelPanel1Left Top Width�HeightHAlignalClient
BevelOuterbvNoneBorderWidthCaption TabOrder TStringGridStringGrid1LeftTop-Width�HeightAlignalClientColCount2RowCountOptionsgoFixedVertLinegoFixedHorzLine
goVertLine
goHorzLinegoThumbTracking TabOrder 
RowHeights   TPanelPanelSourceLeftTopWidth�Height)AlignalTop
BevelOuterbvNoneCaption&Drag from here and into the grid belowFont.CharsetDEFAULT_CHARSET
Font.ColorclBlueFont.Height�	Font.NameArial
Font.StylefsBold 
ParentFontTabOrderOnMouseDownPanelSourceMouseDown   TDropTextSourceDropTextSource1	DragTypesdtCopy Locale LeftTop  TDropTextTargetDropTextTarget1	DragTypesdtCopy OnEnterDropTextTarget1Enter
OnDragOverDropTextTarget1DragOverOnDropDropTextTarget1DropTargetStringGrid1LeftTop8   