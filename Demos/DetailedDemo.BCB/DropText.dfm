�
 TFORMTEXT 0�
  TPF0	TFormTextFormTextLeftToplBorderStylebsDialogCaptionDrag 'n' Drop Demo - TextClientHeightVClientWidth�Color	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style OldCreateOrderPositionpoMainFormCenterPixelsPerInch`
TextHeight TMemoMemo1LeftTop� Width�HeightDTabStop	AlignmenttaCenterColor	clBtnFaceLines.Strings<This (bottom) example demonstrates dragging a text SELECTION,to another application that can accept text.HThe drag code is almost identical to above but requires the edit control:to be hooked to override normal WM_LBUTTONDOWN processing. ReadOnly	TabOrder WantReturns  TButtonButtonCloseLeftTopWidth�HeightCancel	Caption&CloseFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameArial
Font.StylefsBold 
ParentFontTabOrderOnClickButtonCloseClick  TEditEdit2LeftTop Width�Height
AutoSelectTabOrderTextZSelect some or all of this text and drag it to another application which will accept text.OnMouseMoveEdit2MouseMove  
TStatusBar
StatusBar1Left TopCWidth�HeightPanels SimplePanel	SizeGrip  TMemoMemo2LeftTop.Width�HeightCTabStop	AlignmenttaCenterColor	clBtnFaceLines.StringsJThis (top) example demonstrates a very simple drag operation which allows Kdragging ALL of the edit control text TO and FROM other applications which Kaccept Drag'n'Drop text (eg WordPad). Drag to Desktop to create scrap file.1Implementing this takes only a few lines of code. ReadOnly	TabOrderWantReturns  TEditEdit1LeftTopvWidth�HeightCursorcrHandPoint
AutoSelectTabOrderTextUClick on this edit control and drag it to another application which will accept text.OnMouseDownEdit1MouseDown  TButtonButtonClipboardLeftTop� Width�HeightCaption9Click this button to copy the above text to the ClipboardTabOrderOnClickButtonClipboardClick  TPanelPanel1Left
TopWidth�Height
BevelOuterbvNoneBorderWidthBorderStylebsSingleCaption TDropTextSource, TDropTextTargetColorclGrayFont.CharsetDEFAULT_CHARSET
Font.ColorclWhiteFont.Height�	Font.NameArial
Font.StylefsBold 
ParentFontTabOrder  TDropTextSourceDropSource1	DragTypesdtCopy 
OnFeedbackDropSource1FeedbackLocale LeftTop3  TDropTextTargetDropTextTarget1	DragTypesdtCopydtLink OnDropDropTextTarget1DropTargetEdit1Left�TopP  TDropTextTargetDropTextTarget2	DragTypesdtCopy OnDropDropTextTarget2DropTargetEdit2Left�Top�   
TDropDummy
DropDummy1	DragTypes TargetOwnerLeft�Top0   