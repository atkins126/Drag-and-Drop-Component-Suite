�
 TFORMMAIN 0e  TPF0	TFormMainFormMainLeftToplBorderStylebsDialogCaptionExtract/Download DemoClientHeightClientWidth�Color	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style OldCreateOrderPositionpoDefaultPosOnlyPixelsPerInch`
TextHeight TPanelPanel1Left Top Width�Height)AlignalTop
BevelOuterbvNoneTabOrder TLabelLabel2LeftTopWidth� HeightCaption4A demo of how to drag files from a zipped archive...  TButtonButtonCloseLeftqTopWidth>HeightCancel	CaptionE&xitTabOrder OnClickButtonCloseClick   	TListView	ListView1Left Top)Width�Height� AlignalClientColumnsCaptionA list of  'archived'  files...Width�  ColumnClick
Items.Data
�   �          ��������        RootFile1.txt    ��������        RootFile2.wri    ��������        SubFolder\File3.pas    ��������        SubFolder\File4.dfm    ��������        #SubFolder\NestedSubFolder\File5.cppMultiSelect	ReadOnly		RowSelect	TabOrder 	ViewStylevsReportOnMouseDownListView1MouseDown  
TStatusBar
StatusBar1Left Top� Width�HeightPanels SimplePanel	
SimpleText1'Extract'  files by dragging them to Explorer ...  TDropFileSourceDropFileSource1	DragTypesdtCopydtMove OnDropDropFileSource1DropOnAfterDropDropFileSource1AfterDropLeft�Top\   