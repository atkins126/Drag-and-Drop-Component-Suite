�
 TFORMSOURCE 0  TPF0TFormSource
FormSourceLeftTop{BorderStylebsDialogCaptionCustom Drop SourceClientHeight� ClientWidth�Color	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style OldCreateOrderPositionpoDefaultPosOnlyPixelsPerInch`
TextHeight TPanelPanel3Left Top`Width�Height� AlignalBottom
BevelOuterbvNoneBorderWidthCaption TabOrder  TMemoMemo1LeftTopWidth�Height}AlignalClientBorderStylebsNoneLines.StringsNThis application demonstrates how to define and drag custom clipboard formats. OThe custom format stores the time-of-day and a color value in a structure. The GTGenericDataFormat class is used to add support for this format to the /TDropTextSource and TDropTextTarget components. NTo see the custom clipboard format in action, drag from the source window and Sdrop on the target window. You can also do this between multiple instances of this application. ParentColor	ReadOnly	TabOrder WantReturns   TPanelPanel1Left Top Width�Height`AlignalClient
BevelInner	bvLowered
BevelOuterbvNoneBorderWidthCaption TabOrder TPanelPanelSourceLeftTopWidth�HeightCCursorcrHandPointAlignalClientCaption00:00:00.000TabOrder OnMouseDownPanelSourceMouseDown  TPanelPanel4LeftTopWidth�HeightAlignalTopCaptionDrop sourceTabOrder   TDropTextSourceDropTextSource1	DragTypesdtCopy Locale LeftTop   TTimerTimer1OnTimerTimer1TimerLeft4Top    