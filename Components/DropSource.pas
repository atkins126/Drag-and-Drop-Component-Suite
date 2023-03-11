unit DropSource;
// -----------------------------------------------------------------------------
// Project:         Drag and Drop Component Suite
// Module:          DropSource
// Description:     Implements Dragging & Dropping of data
//                  FROM your application to another.
// Version:         4.1
// Date:            22-JAN-2002
// Target:          Win32, Delphi 4-6, C++Builder 4-6
// Authors:         Anders Melander, anders@melander.dk, http://www.melander.dk
// Copyright        � 1997-2002 Angus Johnson & Anders Melander
// -----------------------------------------------------------------------------
// General changes:
// - Some component glyphs has changed.
//
// TDropSource changes:
// - CutToClipboard and CopyToClipboard now uses OleSetClipboard.
//   This means that descendant classes no longer needs to override the
//   CutOrCopyToClipboard method.
// - New OnGetData event.
// - Changed to use new V4 architecture:
//   * All clipboard format support has been removed from TDropSource, it has
//     been renamed to TCustomDropSource and the old TDropSource has been
//     modified to descend from TCustomDropSource and has moved to the
//     DropSource3 unit. TDropSource is now supported for backwards
//     compatibility only and will be removed in a future version.
//   * A new TCustomDropMultiSource, derived from TCustomDropSource, uses the
//     new architecture (with TClipboardFormat and TDataFormat) and is the new
//     base class for all the drop source components.
// - TInterfacedComponent moved to DragDrop unit.
// -----------------------------------------------------------------------------
// TODO -oanme -cCheckItOut : OleQueryLinkFromData
// TODO -oanme -cDocumentation : CutToClipboard and CopyToClipboard alters the value of PreferredDropEffect.
// TODO -oanme -cDocumentation : Clipboard must be flushed or emptied manually after CutToClipboard and CopyToClipboard. Automatic flush is not guaranteed.
// TODO -oanme -cDocumentation : Delete-on-paste. Why and How.
// TODO -oanme -cDocumentation : Optimized move. Why and How.
// TODO -oanme -cDocumentation : OnPaste event is only fired if target sets the "Paste Succeeded" clipboard format. Explorer does this for delete-on-paste move operations.
// TODO -oanme -cDocumentation : DragDetectPlus. Why and How.
// -----------------------------------------------------------------------------

interface

uses
  DragDrop,
  DragDropFormats,
  ActiveX,
  Controls,
  Windows,
  Classes;

{$include DragDrop.inc}
{$ifdef VER135_PLUS}
// shldisp.h only exists in C++Builder 5 and later.
{$HPPEMIT '#include <shldisp.h>'}
{$endif}

type
  tagSTGMEDIUM = ActiveX.TStgMedium;
  tagFORMATETC = ActiveX.TFormatEtc;

  TDragResult = (drDropCopy, drDropMove, drDropLink, drCancel,
    drOutMemory, drAsync, drUnknown);

  TDropEvent = procedure(Sender: TObject; DragType: TDragType;
    var ContinueDrop: Boolean) of object;

  //: TAfterDropEvent is fired after the target has finished processing a
  // successfull drop.
  // The Optimized parameter is True if the target either performed an operation
  // other than a move or performed an "optimized move". In either cases, the
  // source isn't required to delete the source data.
  // If the Optimized parameter is False, the target performed an "unoptimized
  // move" operation and the source is required to delete the source data to
  // complete the move operation.
  TAfterDropEvent = procedure(Sender: TObject; DragResult: TDragResult;
    Optimized: Boolean) of object;

  TFeedbackEvent = procedure(Sender: TObject; Effect: LongInt;
    var UseDefaultCursors: Boolean) of object;

  //: The TDropDataEvent event is fired when the target requests data from the
  // drop source or offers data to the drop source.
  // The Handled flag should be set if the event handler satisfied the request.
  TDropDataEvent = procedure(Sender: TObject; const FormatEtc: TFormatEtc;
    out Medium: TStgMedium; var Handled: Boolean) of object;

  //: TPasteEvent is fired when the target sends a "Paste Succeeded" value
  // back to the drop source after a clipboard transfer.
  // The DeleteOnPaste parameter is True if the source is required to delete
  // the source data. This will only occur after a CutToClipboard operation
  // (corresponds to a move drag/drop).
  TPasteEvent = procedure(Sender: TObject; Action: TDragResult;
    DeleteOnPaste: boolean) of object;


////////////////////////////////////////////////////////////////////////////////
//
//		TCustomDropSource
//
////////////////////////////////////////////////////////////////////////////////
// Abstract base class for all Drop Source components.
// Implements the IDropSource and IDataObject interfaces.
////////////////////////////////////////////////////////////////////////////////
  TCustomDropSource = class(TDragDropComponent, IDropSource, IDataObject,
    IAsyncOperation2)
  private
    FDragTypes: TDragTypes;
    FFeedbackEffect: LongInt;
    // Events...
    FOnDrop: TDropEvent;
    FOnAfterDrop: TAfterDropEvent;
    FOnFeedback: TFeedBackEvent;
    FOnGetData: TDropDataEvent;
    FOnSetData: TDropDataEvent;
    FOnPaste: TPasteEvent;
    // Drag images...
    FImages: TImageList;
    FShowImage: boolean;
    FImageIndex: integer;
    FImageHotSpot: TPoint;
    FDragSourceHelper: IDragSourceHelper;
    // Async transfer...
    FAllowAsync: boolean;
    FRequestAsync: boolean;
    FAsyncSourceTransfer: boolean;
    FAsyncTargetTransfer: boolean;
    FAsyncDataObject: IDataObject;
    FAsyncDropSource: IDropSource;
    FDragInProgress: boolean;

  protected
    property FeedbackEffect: LongInt read FFeedbackEffect write FFeedbackEffect;

    // IDropSource implementation
    function QueryContinueDrag(fEscapePressed: bool;
      grfKeyState: LongInt): HRESULT; stdcall;
    function GiveFeedback(dwEffect: LongInt): HRESULT; stdcall;

    // IDataObject implementation
    function GetData(const FormatEtcIn: TFormatEtc;
      out Medium: TStgMedium):HRESULT; stdcall;
    function GetDataHere(const FormatEtc: TFormatEtc;
      out Medium: TStgMedium):HRESULT; stdcall;
    function QueryGetData(const FormatEtc: TFormatEtc): HRESULT; stdcall;
    function GetCanonicalFormatEtc(const FormatEtc: TFormatEtc;
      out FormatEtcout: TFormatEtc): HRESULT; stdcall;
    function SetData(const FormatEtc: TFormatEtc; var Medium: TStgMedium;
      fRelease: Bool): HRESULT; stdcall;
    function EnumFormatEtc(dwDirection: LongInt;
      out EnumFormatEtc: IEnumFormatEtc): HRESULT; stdcall;
    function dAdvise(const FormatEtc: TFormatEtc; advf: LongInt;
      const advsink: IAdviseSink; out dwConnection: LongInt): HRESULT; stdcall;
    function dUnadvise(dwConnection: LongInt): HRESULT; stdcall;
    function EnumdAdvise(out EnumAdvise: IEnumStatData): HRESULT; stdcall;

    // IAsyncOperation implementation
    function EndOperation(hResult: HRESULT; const pbcReserved: IBindCtx;
      dwEffects: DWORD): HResult; stdcall;
    function GetAsyncMode(out pfIsOpAsync: Bool): HRESULT; stdcall;
    function InOperation(out pfInAsyncOp: Bool): HRESULT; stdcall;
    function SetAsyncMode(fDoOpAsync: Bool): HRESULT; stdcall;
    function StartOperation(const pbcReserved: IBindCtx): HRESULT; stdcall;

    // Abstract methods
    function DoGetData(const FormatEtcIn: TFormatEtc;
      out Medium: TStgMedium): HRESULT; virtual; abstract;
    function DoSetData(const FormatEtc: TFormatEtc;
      var Medium: TStgMedium): HRESULT; virtual;
    function HasFormat(const FormatEtc: TFormatEtc): boolean; virtual; abstract;
    function GetEnumFormatEtc(dwDirection: LongInt): IEnumFormatEtc; virtual; abstract;
    function DoExecute: TDragResult; virtual;

    // Data format event sink
    procedure DataChanging(Sender: TObject); virtual;

    // Clipboard
    function CutOrCopyToClipboard: boolean; virtual;
    procedure DoOnPaste(Action: TDragResult; DeleteOnPaste: boolean); virtual;

    // Property access
    procedure SetShowImage(Value: boolean);
    procedure SetImages(const Value: TImageList);
    procedure SetImageIndex(const Value: integer);
    procedure SetPoint(Index: integer; Value: integer);
    function GetPoint(Index: integer): integer;
    function GetPerformedDropEffect: longInt; virtual;
    function GetLogicalPerformedDropEffect: longInt; virtual;
    procedure SetPerformedDropEffect(const Value: longInt); virtual;
    function GetPreferredDropEffect: longInt; virtual;
    procedure SetPreferredDropEffect(const Value: longInt); virtual;
    function GetInShellDragLoop: boolean; virtual;
    function GetTargetCLSID: TCLSID; virtual;
    procedure SetInShellDragLoop(const Value: boolean); virtual;
    function GetLiveDataOnClipboard: boolean;
    procedure SetAllowAsync(const Value: boolean);

    // Component management
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    property DragSourceHelper: IDragSourceHelper read FDragSourceHelper;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute(Asynchronous: boolean = False): TDragResult; virtual;
    function CutToClipboard: boolean; virtual;
    function CopyToClipboard: boolean; virtual;
    procedure FlushClipboard; virtual;
    procedure EmptyClipboard; virtual;

    property PreferredDropEffect: longInt read GetPreferredDropEffect
      write SetPreferredDropEffect;
    property PerformedDropEffect: longInt read GetPerformedDropEffect
      write SetPerformedDropEffect;
    property LogicalPerformedDropEffect: longInt read GetLogicalPerformedDropEffect;
    property InShellDragLoop: boolean read GetInShellDragLoop
      write SetInShellDragLoop;
    property TargetCLSID: TCLSID read GetTargetCLSID;
    property LiveDataOnClipboard: boolean read GetLiveDataOnClipboard;
    property AsyncTransfer: boolean read FAsyncTargetTransfer;
    property DragInProgress: boolean read FDragInProgress;

  published
    property DragTypes: TDragTypes read FDragTypes write FDragTypes;
    // Events
    property OnFeedback: TFeedbackEvent read FOnFeedback write FOnFeedback;
    property OnDrop: TDropEvent read FOnDrop write FOnDrop;
    property OnAfterDrop: TAfterDropEvent read FOnAfterDrop write FOnAfterDrop;
    property OnGetData: TDropDataEvent read FOnGetData write FOnGetData;
    property OnSetData: TDropDataEvent read FOnSetData write FOnSetData;
    property OnPaste: TPasteEvent read FOnPaste write FOnPaste;

    // Drag Images...
    property Images: TImageList read FImages write SetImages;
    property ImageIndex: integer read FImageIndex write SetImageIndex default 0;
    property ShowImage: boolean read FShowImage write SetShowImage default False;
    property ImageHotSpotX: integer index 1 read GetPoint write SetPoint default 16;
    property ImageHotSpotY: integer index 2 read GetPoint write SetPoint default 16;
    // Async transfer...
    property AllowAsyncTransfer: boolean read FAllowAsync write SetAllowAsync default False;
  end;


////////////////////////////////////////////////////////////////////////////////
//
//		TCustomDropMultiSource
//
////////////////////////////////////////////////////////////////////////////////
// Drop target base class which can accept multiple formats.
////////////////////////////////////////////////////////////////////////////////
  TCustomDropMultiSource = class(TCustomDropSource)
  private
    FFeedbackDataFormat: TFeedbackDataFormat;
    FRawDataFormat: TRawDataFormat;

  protected
    function DoGetData(const FormatEtcIn: TFormatEtc;
      out Medium: TStgMedium):HRESULT; override;
    function DoSetData(const FormatEtc: TFormatEtc;
      var Medium: TStgMedium): HRESULT; override;
    function HasFormat(const FormatEtc: TFormatEtc): boolean; override;
    function GetEnumFormatEtc(dwDirection: LongInt): IEnumFormatEtc; override;

    function GetPerformedDropEffect: longInt; override;
    function GetLogicalPerformedDropEffect: longInt; override;
    function GetPreferredDropEffect: longInt; override;
    procedure SetPerformedDropEffect(const Value: longInt); override;
    procedure SetPreferredDropEffect(const Value: longInt); override;
    function GetInShellDragLoop: boolean; override;
    procedure SetInShellDragLoop(const Value: boolean); override;
    function GetTargetCLSID: TCLSID; override;

    procedure DoOnSetData(DataFormat: TCustomDataFormat;
      ClipboardFormat: TClipboardFormat);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
{$ifdef TIME2HELP}
    property DataFormats: TDataFormats;
{$else}
    property DataFormats;
{$endif}
    // TODO : Add support for delayed rendering with OnRenderData event.
  published
  end;

////////////////////////////////////////////////////////////////////////////////
//
//		TDropEmptySource
//
////////////////////////////////////////////////////////////////////////////////
// Do-nothing source for use with TDataFormatAdapter and such
////////////////////////////////////////////////////////////////////////////////
  TDropEmptySource = class(TCustomDropMultiSource);


////////////////////////////////////////////////////////////////////////////////
//
//		Utility functions
//
////////////////////////////////////////////////////////////////////////////////
  function DropEffectToDragResult(DropEffect: longInt): TDragResult;


////////////////////////////////////////////////////////////////////////////////
//
//		Component registration
//
////////////////////////////////////////////////////////////////////////////////
procedure Register;


(*******************************************************************************
**
**			IMPLEMENTATION
**
*******************************************************************************)
implementation

uses
  Messages,
  CommCtrl,
  ComObj,
  Graphics,
  SysUtils;

resourcestring
  sDropSourceBusy = 'A drag and drop operation is already in progress';
  sDropSourceAsyncFailed = 'Failed to initiate asynchronouse drag and drop operation';
  sDropSourceAsyncBusy = 'An asynchronous drag and drop operation is in progress';

////////////////////////////////////////////////////////////////////////////////
//
//		Component registration
//
////////////////////////////////////////////////////////////////////////////////
procedure Register;
begin
  RegisterComponents(DragDropComponentPalettePage, [TDropEmptySource]);
end;


////////////////////////////////////////////////////////////////////////////////
//
//		Utility functions
//
////////////////////////////////////////////////////////////////////////////////
function DropEffectToDragResult(DropEffect: longInt): TDragResult;
begin
  case DropEffect of
    DROPEFFECT_NONE:
      Result := drCancel;
    DROPEFFECT_COPY:
      Result := drDropCopy;
    DROPEFFECT_MOVE:
      Result := drDropMove;
    DROPEFFECT_LINK:
      Result := drDropLink;
  else
    Result := drUnknown; // This is probably an error condition
  end;
end;


////////////////////////////////////////////////////////////////////////////////
//
// Experimental undocumented Windows Shell Drag Image support
//
////////////////////////////////////////////////////////////////////////////////
// This will probably only work on Windows 9x or in Shell Extensions/Shell Name
// Space Extensions.
////////////////////////////////////////////////////////////////////////////////
{$ifdef SHELL_DRAGIMAGE}
const
  // DAD_AutoScroll return values
  DAD_SCROLL_UP    = 1;
  DAD_SCROLL_DOWN  = 2;
  DAD_SCROLL_LEFT  = 4;
  DAD_SCROLL_RIGHT = 8;

type
  SCROLLSAMPLES = packed record
    dwCount: DWORD;
    dwLastTime: DWORD;
    bWrapped: BOOL;
    aptPositions: array[0..2] of TPoint;
    adwTimes: array[0..2] of DWORD;
  end;
  LPSCROLLSAMPLES = ^SCROLLSAMPLES;
  TScrollSamples = ScrollSamples;
  PScrollSamples = LPSCROLLSAMPLES;

var
  Shell32Handle: THandle = THandle(-1);
  DAD_DragEnter: function(hWindow: hWnd): BOOL; stdcall;
  DAD_DragEnterEx: function(hWindow: hWnd; x, y: integer): BOOL; stdcall;
  DAD_DragMove: function(x, y: integer): BOOL; stdcall;
  DAD_AutoScroll: function(hWindow: hWnd; var lpSamples: TScrollSamples;
    var lppt: TPoint): DWORD; stdcall;
  DAD_DragLeave: function: BOOL; stdcall;
  DAD_SetDragImageFromListView: function(hWindow: hWnd; x, y: integer): BOOL; stdcall;
  DAD_SetDragImage: function(hImageList: THandle; var lppt: TPoint): BOOL; stdcall;
  DAD_ShowDragImage: function(Show: BOOL): BOOL; stdcall;

function InitShellDragImage: boolean;
const
  Shell32 = 'Shell32.dll';
begin
  if (Shell32Handle = THandle(-1)) then
  begin
    Shell32Handle := SafeLoadLibrary(Shell32);
    if (Shell32Handle > HINSTANCE_ERROR) then
    begin
      DAD_AutoScroll := GetProcAddress(Shell32Handle, PChar(129));
      if (not Assigned(DAD_AutoScroll)) then
      begin
        Result := False;
        FreeLibrary(Shell32Handle);
        Shell32Handle := 0;
        exit;
      end;
      DAD_DragEnter := GetProcAddress(Shell32Handle, PChar(130));
      DAD_DragLeave := GetProcAddress(Shell32Handle, PChar(132));
      DAD_DragEnterEx := GetProcAddress(Shell32Handle, PChar(131));
      DAD_DragMove := GetProcAddress(Shell32Handle, PChar(134));
      DAD_SetDragImage := GetProcAddress(Shell32Handle, PChar(136));
      DAD_ShowDragImage := GetProcAddress(Shell32Handle, PChar(137));
      DAD_SetDragImageFromListView := GetProcAddress(Shell32Handle, PChar(177));
      Result := True;
    end else
      Result := False;
  end else
    Result := (Shell32Handle > HINSTANCE_ERROR);
end;
{$endif}

////////////////////////////////////////////////////////////////////////////////
//
//		TDropSourceThread
//
////////////////////////////////////////////////////////////////////////////////
// Executes a drop source operation from a thread.
// TDropSourceThread is an alternative to the Windows 2000 Asynchronous Data
// Transfer support.
////////////////////////////////////////////////////////////////////////////////
type
  TDropSourceThread = class(TThread)
  private
    FDropSource: TCustomDropSource;
    FDragResult: TDragResult;
    FDataObjectStream: pointer;
    FDropSourceStream: pointer;
    FStarted: THandle;
  protected
    procedure Execute; override;
  public
    constructor Create(ADropSource: TCustomDropSource);
    destructor Destroy; override;
    property DragResult: TDragResult read FDragResult;
    property Started: THandle read FStarted;
  end;

constructor TDropSourceThread.Create(ADropSource: TCustomDropSource);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FDropSource := ADropSource;
  FDragResult := drAsync;
  FStarted := Windows.CreateEvent(nil, False, False, nil);

  // Marshall interfaces to thread for use by DoDragDrop API function.
  OleCheck(CoMarshalInterThreadInterfaceInStream(IDataObject, FDropSource,
    IStream(FDataObjectStream)));
  // Note: For some reason I get an "Interface not supported" if I attempt to
  // marshall the IDropSource interface. It seems to work fine if I marshall the
  // IUnknown interface instead.
  OleCheck(CoMarshalInterThreadInterfaceInStream(IUnknown, FDropSource,
    IStream(FDropSourceStream)));
end;

destructor TDropSourceThread.Destroy;
begin
  if (FDataObjectStream <> nil) then
    IUnknown(FDataObjectStream)._Release;
  if (FDropSourceStream <> nil) then
    IUnknown(FDropSourceStream)._Release;
  CloseHandle(FStarted);
  inherited Destroy;
end;

procedure TDropSourceThread.Execute;
var
  pt: TPoint;
  hwndAttach: HWND;
  dwAttachThreadID, dwCurrentThreadID: DWORD;
  Msg: TMsg;
begin
  (*
  ** See Microsoft Knowledgebase Article Q139408 for an explanation of the
  ** AttachThreadInput stuff.
  **   http://support.microsoft.com/support/kb/articles/Q139/4/08.asp
  *)

  try
    // Notify world that we are running
    SetEvent(FStarted);

    // Get handle of window under mouse-cursor.
    GetCursorPos(pt);
    hwndAttach := WindowFromPoint(pt);
    ASSERT((hwndAttach <> 0), 'Can''t find window with drag-object');

    // Get thread IDs.
    dwAttachThreadID := GetWindowThreadProcessId(hwndAttach, nil);
    dwCurrentThreadID := GetCurrentThreadId();

    // Attach input queues if necessary.
    if (dwAttachThreadID <> dwCurrentThreadID) then
      AttachThreadInput(dwAttachThreadID, dwCurrentThreadID, True);
    try

      // Initialize OLE for this thread.
      OleInitialize(nil);
      try
        // Unmarshall interfaces passed to us from main thread and give them to
        // the drop source component for use in the DoDragDrop API call.
        try
          OleCheck(CoGetInterfaceAndReleaseStream(IStream(FDataObjectStream),
            IDataObject, FDropSource.FAsyncDataObject));
          FDataObjectStream := nil;
          OleCheck(CoGetInterfaceAndReleaseStream(IStream(FDropSourceStream),
            IAsyncOperation, FDropSource.FAsyncDropSource));
          FDropSourceStream := nil;

          // Start drag & drop.
          FDragResult := FDropSource.DoExecute;

        finally
          FDropSource.FAsyncDropSource := nil;
          FDropSource.FAsyncDataObject := nil;
        end;

        // In case the drop target is also performing an asynchronous transfer
        // (via IAsyncOperation), we must wait for the transfer to complete.
        // Warning: We have to do this because the drop target will be
        // disconnected from the drop source if the thread that started the
        // drag/drop terminates before the transfer has completed.
        while (FDropSource.FAsyncTargetTransfer) and (not Terminated) do
        begin
          // Must pump message queue or drag/drop will freeze and we will never
          // get out of this loop.
          if (GetMessage(Msg, 0, 0, 0)) then
          begin
            if (Msg.Message <> WM_QUIT) then
            begin
              TranslateMessage(Msg);
              DispatchMessage(Msg);
            end else
              Terminate;
          end;
        end;
      finally
        OleUninitialize;
      end;

    finally
      // Restore input queue settings.
      if (dwAttachThreadID <> dwCurrentThreadID) then
        AttachThreadInput(dwAttachThreadID, dwCurrentThreadID, False);
      // Set Terminated flag so owner knows that drag has finished.
      Terminate;

      FDropSource.FDragInProgress := False;
      FDropSource.FAsyncSourceTransfer := False;
    end;
  except
    FDragResult := drUnknown;
    // Make sure OnAfterDrop gets called to notify user that things went wrong
    // and reset the async flag.
    FDropSource.EndOperation(E_UNEXPECTED, nil, DROPEFFECT_NONE);
    Terminate;
  end;
end;

// -----------------------------------------------------------------------------
//			TCustomDropSource
// -----------------------------------------------------------------------------

constructor TCustomDropSource.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DragTypes := [dtCopy]; //default to Copy.

  // Note: Normally we would call _AddRef or coLockObjectExternal(Self) here to
  // make sure that the component wasn't deleted prematurely (e.g. after a call
  // to RegisterDragDrop), but since our ancestor class TInterfacedComponent
  // disables reference counting, we do not need to do so.

  FImageHotSpot := Point(16,16);
  FImages := nil;
end;

destructor TCustomDropSource.Destroy;
begin
  // DONE -oanme -cImprovement : Maybe FlushClipboard would be more appropiate?
  FlushClipboard;
  inherited Destroy;
end;

// -----------------------------------------------------------------------------

function TCustomDropSource.GetCanonicalFormatEtc(const FormatEtc: TFormatEtc;
  out FormatEtcout: TFormatEtc): HRESULT;
begin
  Result := DATA_S_SAMEFORMATETC;
end;
// -----------------------------------------------------------------------------

function TCustomDropSource.SetData(const FormatEtc: TFormatEtc;
  var Medium: TStgMedium; fRelease: Bool): HRESULT;
begin
  // Warning: Ordinarily it would be much more efficient to just call
  // HasFormat(FormatEtc) to determine if we support the given format, but
  // because we have to able to accept *all* data formats, even unknown ones, in
  // order to support the Windows 2000 drag helper functionality, we can't
  // reject any formats here. Instead we pass the request on to DoSetData and
  // let it worry about the details.

  // if (HasFormat(FormatEtc)) then
  // begin
    try
      Result := DoSetData(FormatEtc, Medium);
    finally
      if (fRelease) then
        ReleaseStgMedium(Medium);
    end;
  // end else
  //   Result:= DV_E_FORMATETC;
end;
// -----------------------------------------------------------------------------

function TCustomDropSource.DAdvise(const FormatEtc: TFormatEtc; advf: LongInt;
  const advSink: IAdviseSink; out dwConnection: LongInt): HRESULT;
begin
  Result := OLE_E_ADVISENOTSUPPORTED;
end;

function TCustomDropSource.DUnadvise(dwConnection: LongInt): HRESULT;
begin
  Result := OLE_E_ADVISENOTSUPPORTED;
end;

function TCustomDropSource.EnumDAdvise(out EnumAdvise: IEnumStatData): HRESULT;
begin
  Result := OLE_E_ADVISENOTSUPPORTED;
end;

function TCustomDropSource.GetData(const FormatEtcIn: TFormatEtc;
  out Medium: TStgMedium):HRESULT; stdcall;
var
  Handled: boolean;
begin
  Handled := False;
  if (Assigned(FOnGetData)) then
    // Fire event to ask user for data.
    FOnGetData(Self, FormatEtcIn, Medium, Handled);

  // If user provided data, there is no need to call descendant for it.
  if (Handled) then
    Result := S_OK
  else if (HasFormat(FormatEtcIn)) then
    // Call descendant class to get data.
    Result := DoGetData(FormatEtcIn, Medium)
  else
    Result:= DV_E_FORMATETC;
end;

function TCustomDropSource.GetDataHere(const FormatEtc: TFormatEtc;
  out Medium: TStgMedium):HRESULT; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TCustomDropSource.QueryGetData(const FormatEtc: TFormatEtc): HRESULT; stdcall;
begin
  if (HasFormat(FormatEtc)) then
    Result:= S_OK
  else
    Result:= DV_E_FORMATETC;
end;

function TCustomDropSource.EnumFormatEtc(dwDirection: LongInt;
  out EnumFormatEtc:IEnumFormatEtc): HRESULT; stdcall;
begin
  EnumFormatEtc := GetEnumFormatEtc(dwDirection);
  if (EnumFormatEtc <> nil) then
    Result := S_OK
  else
    Result := E_NOTIMPL;
end;

// Implements IDropSource.QueryContinueDrag
function TCustomDropSource.QueryContinueDrag(fEscapePressed: bool;
  grfKeyState: LongInt): HRESULT; stdcall;
var
  ContinueDrop: Boolean;
  DragType: TDragType;
begin
  if FEscapePressed then
    Result := DRAGDROP_S_CANCEL
  // Allow drag and drop with either mouse buttons.
  else if (grfKeyState and (MK_LBUTTON or MK_RBUTTON) = 0) then
  begin
    ContinueDrop := DropEffectToDragType(FeedbackEffect, DragType) and
      (DragType in DragTypes);

    InShellDragLoop := False;

    // If a valid drop then do OnDrop event if assigned...
    if ContinueDrop and Assigned(OnDrop) then
      OnDrop(Self, DragType, ContinueDrop);

    if ContinueDrop then
      Result := DRAGDROP_S_DROP
    else
      Result := DRAGDROP_S_CANCEL;
  end else
    Result := S_OK;
end;

// Implements IDropSource.GiveFeedback
function TCustomDropSource.GiveFeedback(dwEffect: LongInt): HRESULT; stdcall;
var
  UseDefaultCursors: Boolean;
begin
  UseDefaultCursors := True;
  FeedbackEffect := dwEffect;
  if Assigned(OnFeedback) then
    OnFeedback(Self, dwEffect, UseDefaultCursors);
  if UseDefaultCursors then
    Result := DRAGDROP_S_USEDEFAULTCURSORS
  else
    Result := S_OK;
end;

function TCustomDropSource.DoSetData(const FormatEtc: TFormatEtc;
  var Medium: TStgMedium): HRESULT;
var
  Handled: boolean;
begin
  Result := E_NOTIMPL;
  if (Assigned(FOnSetData)) then
  begin
    Handled := False;
    // Fire event to ask user to handle data.
    FOnSetData(Self, FormatEtc, Medium, Handled);
    if (Handled) then
      Result := S_OK;
  end;
end;

procedure TCustomDropSource.SetAllowAsync(const Value: boolean);
begin
  if (FAllowAsync <> Value) then
  begin
    FAllowAsync := Value;
    if (not FAllowAsync) then
    begin
      FRequestAsync := False;
      FAsyncTargetTransfer := False;
    end;
  end;
end;

function TCustomDropSource.GetAsyncMode(out pfIsOpAsync: Bool): HRESULT;
begin
  pfIsOpAsync := FRequestAsync;
  Result := S_OK;
end;

function TCustomDropSource.SetAsyncMode(fDoOpAsync: Bool): HRESULT;
begin
  if (FAllowAsync) then
  begin
    Result := S_OK;
    if (FRequestAsync <> fDoOpAsync) then
    begin
      FRequestAsync := fDoOpAsync;

      // The following AddRef is required according to SDK and MSDN. Don't know
      // why...
      // _AddRef;
      // The corresponding Release is in IAsynOperation.EndOperation.
    end;
  end else
    Result := E_NOTIMPL;
end;

function TCustomDropSource.InOperation(out pfInAsyncOp: Bool): HRESULT;
begin
  pfInAsyncOp := FAsyncTargetTransfer;
  Result := S_OK;
end;

function TCustomDropSource.StartOperation(const pbcReserved: IBindCtx): HRESULT;
begin
  if (FRequestAsync) then
  begin
    FAsyncTargetTransfer := True;
    Result := S_OK;
  end else
    Result := E_NOTIMPL;
end;

function TCustomDropSource.EndOperation(hResult: HRESULT;
  const pbcReserved: IBindCtx; dwEffects: DWORD): HRESULT;
var
  DropResult: TDragResult;
begin
  if (FAsyncTargetTransfer) then
  begin
    // The following Release is required according to SDK and MSDN. Don't know
    // why...
    // _Release;
    // The corresponding AddRef is in IAsynOperation.SetAsyncMode.

    FAsyncTargetTransfer := False;
    if (Assigned(FOnAfterDrop)) then
    begin
      if (Succeeded(hResult)) then
        DropResult := DropEffectToDragResult(dwEffects and DragTypesToDropEffect(FDragTypes))
      else
        DropResult := drUnknown;
      // Note: The following logic is slightly different from the corresponding
      // code in TCustomDropSource.DoExecute. This might be a bug.
      FOnAfterDrop(Self, DropResult,
        (DropResult <> drDropMove) or (PerformedDropEffect <> DROPEFFECT_MOVE));
    end;
    Result := S_OK;
  end else
    Result := E_FAIL;
end;

function TCustomDropSource.DoExecute: TDragResult;

  function GetRGBColor(Value: TColor): DWORD;
  begin
    Result := ColorToRGB(Value);
    case Result of
      clNone: Result := CLR_NONE;
      clDefault: Result := CLR_DEFAULT;
    end;
  end;

var
  DropResult: HRESULT;
  AllowedEffects,
  DropEffect: longint;
  IsDraggingImage: boolean;
  shDragImage: TSHDRAGIMAGE;
  shDragBitmap: TBitmap;
begin
  AllowedEffects := DragTypesToDropEffect(FDragTypes);

  if (FShowImage) then
  begin
    // Attempt to create Drag Drop helper object.
    // At present this is only supported on Windows 2000 and later (and reported
    // broken in Windows ME).
    // If the object can't be created, we fall back to the old image list based
    // method (which only works on Win9x or within the application).
    if (Succeeded(CoCreateInstance(CLSID_DragDropHelper, nil, CLSCTX_INPROC_SERVER,
      IDragSourceHelper, FDragSourceHelper))) and (FDragSourceHelper <> nil) then
    begin
      // Display drag image.
      IsDraggingImage := True;

      // TODO : Should also support DragSourceHelper.InitializeFromWindow
      shDragBitmap := TBitmap.Create;
      try
        shDragBitmap.PixelFormat := pfDevice;
        // TImageList.GetBitmap uses TImageList.Draw to extract the bitmap so we
        // must clear the destination bitmap before extraction.
        if (FImages.BkColor <> clNone) then
          shDragBitmap.Canvas.Brush.Color := FImages.BkColor;
        shDragBitmap.Canvas.FillRect(shDragBitmap.Canvas.ClipRect);
        FImages.GetBitmap(ImageIndex, shDragBitmap);
        shDragImage.hbmpDragImage := shDragBitmap.Handle;
        shDragImage.sizeDragImage.cx := shDragBitmap.Width;
        shDragImage.sizeDragImage.cy := shDragBitmap.Height;
        shDragImage.crColorKey := GetRGBColor(FImages.BkColor);
        shDragImage.ptOffset.x := ImageHotSpotX;
        shDragImage.ptOffset.y := ImageHotSpotY;
        if (Succeeded(FDragSourceHelper.InitializeFromBitmap(shDragImage, Self))) then
          // Apparently the bitmap is now owned by the drag/drop image handler...
          // The documentation doesn't mention this explicitly, but the
          // implemtation of Microsoft's SDK samples suggests that this is the
          // case.
          shDragBitmap.ReleaseHandle
        else
          FDragSourceHelper := nil;
      finally
        shDragBitmap.Free;
      end;
    end else
      IsDraggingImage := False;

    // Fall back to image list drag image if platform doesn't support
    // IDragSourceHelper or if we "just" failed to initialize properly.
    if (FDragSourceHelper = nil) then
    begin
      IsDraggingImage := ImageList_BeginDrag(FImages.Handle, FImageIndex,
        FImageHotSpot.X, FImageHotSpot.Y);

{$ifdef SHELL_DRAGIMAGE}
      // Experimental Shell Drag Image support.
      if (InitShellDragImage) then
      begin
        if DAD_SetDragImage(FImages.Handle, FImageHotSpot) then
          DAD_ShowDragImage(True);
      end;
{$endif}
    end;
  end else
    IsDraggingImage := False;

  try
    InShellDragLoop := True;
    try

      (*************************************************************************
      **
      **               DoDragDrop - this is were it all starts
      **
      *************************************************************************)
(*
      if (FAsyncSourceTransfer) then
      begin
        DropResult := DoDragDrop(FAsyncDataObject, FAsyncDropSource, AllowedEffects, DropEffect);
        FAsyncDataObject := nil;
        FAsyncDropSource := nil;
      end else
*)
      DropResult := DoDragDrop(Self, Self, AllowedEffects, DropEffect);
      if (FAsyncSourceTransfer) then
      begin
        FAsyncDataObject := nil;
        FAsyncDropSource := nil;
      end;

    finally
      // InShellDragLoop is also reset in TCustomDropSource.QueryContinueDrag.
      // This is just to make absolutely sure that it is reset (actually no big
      // deal if it isn't).
      InShellDragLoop := False;
    end;

  finally
    if IsDraggingImage then
    begin
      if (FDragSourceHelper <> nil) then
      begin
        FDragSourceHelper := nil;
      end else
        ImageList_EndDrag;
    end;
  end;

  case DropResult of
    DRAGDROP_S_DROP:
      (*
      ** Special handling of "optimized move".
      ** If PerformedDropEffect has been set by the target to DROPEFFECT_MOVE
      ** and the drop effect returned from DoDragDrop is different from
      ** DROPEFFECT_MOVE, then an optimized move was performed.
      ** Note: This is different from how MSDN states that an optimized move is
      ** signalled, but matches how Windows 2000 signals an optimized move.
      **
      ** On Windows 2000 an optimized move is signalled by:
      ** 1) Returning DRAGDROP_S_DROP from DoDragDrop.
      ** 2) Setting drop effect to DROPEFFECT_NONE.
      ** 3) Setting the "Performed Dropeffect" format to DROPEFFECT_MOVE.
      **
      ** On previous version of Windows, an optimized move is signalled by:
      ** 1) Returning DRAGDROP_S_DROP from DoDragDrop.
      ** 2) Setting drop effect to DROPEFFECT_MOVE.
      ** 3) Setting the "Performed Dropeffect" format to DROPEFFECT_NONE.
      **
      ** The documentation states that an optimized move is signalled by:
      ** 1) Returning DRAGDROP_S_DROP from DoDragDrop.
      ** 2) Setting drop effect to DROPEFFECT_NONE or DROPEFFECT_COPY.
      ** 3) Setting the "Performed Dropeffect" format to DROPEFFECT_NONE.
      *)
      if (LogicalPerformedDropEffect = DROPEFFECT_MOVE) or
        ((DropEffect <> DROPEFFECT_MOVE) and (PerformedDropEffect = DROPEFFECT_MOVE)) then
        Result := drDropMove
      else
        Result := DropEffectToDragResult(DropEffect and AllowedEffects);
    DRAGDROP_S_CANCEL:
      Result := drCancel;
    E_OUTOFMEMORY:
      Result := drOutMemory;
    else
      // This should never happen!
      // ...but can happen if we pass something invalid to the drop target.
      // e.g. if we drop empty text on WordPad it will return DV_E_FORMATETC.
      Result := drUnknown;
  end;

  // Reset PerformedDropEffect if the target didn't set it.
  if (PerformedDropEffect = -1) then
    PerformedDropEffect := DROPEFFECT_NONE;

  // Fire OnAfterDrop event unless we are in the middle of an async data
  // transfer.
  if (not AsyncTransfer) and (Assigned(FOnAfterDrop)) then
    FOnAfterDrop(Self, Result,
      (Result = drDropMove) and
      ((DropEffect <> DROPEFFECT_MOVE) or (PerformedDropEffect <> DROPEFFECT_MOVE)));

end;

function TCustomDropSource.Execute(Asynchronous: boolean): TDragResult;
var
  AsyncThread: TDropSourceThread;
begin
  if (AsyncTransfer) then
    raise Exception.Create(sDropSourceAsyncBusy);
  if (DragInProgress) then
    raise Exception.Create(sDropSourceBusy);

  // Reset the "Performed Drop Effect" value. If it is supported by the target,
  // the target will set it to the desired value when the drop occurs.
  PerformedDropEffect := -1;

  FAsyncDataObject := nil;
  FAsyncDropSource := nil;
  FAsyncTargetTransfer := False;
  FAsyncSourceTransfer := False;
  FRequestAsync := False;
  if (AllowAsyncTransfer) then
    SetAsyncMode(True);

  if (Asynchronous) then
  begin
    // Perform an asynchronous drag and drop operation.
    FAsyncSourceTransfer := True;

    // Create a thread to perform the drag...
    AsyncThread := TDropSourceThread.Create(Self);
    try
      FDragInProgress := True;
      // ...and launch it.
      AsyncThread.Resume;

      // Wait for thread to start.
      // If the thread takes longer than 10 seconds to start we assume that
      // something went wrong.
      if (WaitForSingleObject(AsyncThread.Started, 10000) <> WAIT_OBJECT_0) then
        raise Exception.Create(sDropSourceAsyncFailed);

(*
      // Wait for the transfer to complete.
      while DropEmptySource1.DragInProgress do
        Application.ProcessMessages;
      // Wait for the thread to terminate (it should do so itself when the
      // transfer completes)
      WaitFor;
*)
      Result := drAsync;
    except
      FAsyncSourceTransfer := False;
      FDragInProgress := False;
      AsyncThread.Free;
      raise;
    end;
  end else
  begin
    // Perform a normal synchronous drag and drop operation.
    FDragInProgress := True;
    try
      Result := DoExecute;
    finally
      FDragInProgress := False;
    end;
  end;
end;

function TCustomDropSource.GetPerformedDropEffect: longInt;
begin
  Result := DROPEFFECT_NONE;
end;

function TCustomDropSource.GetLogicalPerformedDropEffect: longInt;
begin
  Result := DROPEFFECT_NONE;
end;

procedure TCustomDropSource.SetPerformedDropEffect(const Value: longInt);
begin
  // Not implemented in base class
end;

function TCustomDropSource.GetPreferredDropEffect: longInt;
begin
  Result := DROPEFFECT_NONE;
end;

procedure TCustomDropSource.SetPreferredDropEffect(const Value: longInt);
begin
  // Not implemented in base class
end;

function TCustomDropSource.GetInShellDragLoop: boolean;
begin
  Result := False;
end;

function TCustomDropSource.GetTargetCLSID: TCLSID;
begin
  Result := GUID_NULL;
end;

procedure TCustomDropSource.SetInShellDragLoop(const Value: boolean);
begin
  // Not implemented in base class
end;

procedure TCustomDropSource.DataChanging(Sender: TObject);
begin
  // Data is changing - Flush clipboard to freeze the contents. 
  FlushClipboard;
end;

procedure TCustomDropSource.FlushClipboard;
begin
  // If we have live data on the clipboard...
  if (LiveDataOnClipboard) then
    // ...we force the clipboard to make a static copy of the data
    // before the data changes.
    OleCheck(OleFlushClipboard);
end;

procedure TCustomDropSource.EmptyClipboard;
begin
  // If we have live data on the clipboard...
  if (LiveDataOnClipboard) then
    // ...we empty the clipboard.
    OleCheck(OleSetClipboard(nil));
end;

function TCustomDropSource.CutToClipboard: boolean;
begin
  PreferredDropEffect := DROPEFFECT_MOVE;
  // Copy data to clipboard
  Result := CutOrCopyToClipboard;
end;
// -----------------------------------------------------------------------------

function TCustomDropSource.CopyToClipboard: boolean;
begin
  PreferredDropEffect := DROPEFFECT_COPY;
  // Copy data to clipboard
  Result := CutOrCopyToClipboard;
end;
// -----------------------------------------------------------------------------

function TCustomDropSource.CutOrCopyToClipboard: boolean;
begin
  Result := (Succeeded(OleSetClipboard(Self as IDataObject)));
end;

procedure TCustomDropSource.DoOnPaste(Action: TDragResult; DeleteOnPaste: boolean);
begin
  if (Assigned(FOnPaste)) then
    FOnPaste(Self, Action, DeleteOnPaste);
end;

function TCustomDropSource.GetLiveDataOnClipboard: boolean;
begin
  Result := (OleIsCurrentClipboard(Self as IDataObject) = S_OK);
end;

// -----------------------------------------------------------------------------

procedure TCustomDropSource.SetImages(const Value: TImageList);
var
  OldValue: TImageList;
begin
  if (FImages = Value) then
    exit;

  OldValue := FImages;
  FImages := Value;

  if (csLoading in ComponentState) then
    exit;

  if (FImages = nil) or (FImageIndex >= FImages.Count) then
    FImageIndex := 0;

  if (FImages = nil) or (FImages.Count = 0) then
    FShowImage := False
  else
    // At design time, set ShowImage True when assigning an image list for the
    // first time.
    if (csDesigning in ComponentState) and (FImages <> nil) and
      (OldValue = nil) then
      FShowImage := True;
end;
// -----------------------------------------------------------------------------

procedure TCustomDropSource.SetImageIndex(const Value: integer);
begin
  if (csLoading in ComponentState) then
  begin
    FImageIndex := Value;
    exit;
  end;

  if (Value < 0) or (FImages = nil) or (FImages.Count = 0) then
  begin
    FImageIndex := 0;
    FShowImage := False;
  end else
    if (Value < FImages.Count) then
      FImageIndex := Value;
end;
// -----------------------------------------------------------------------------

procedure TCustomDropSource.SetPoint(Index: integer; Value: integer);
begin
  if (Index = 1) then
    FImageHotSpot.x := Value
  else
    FImageHotSpot.y := Value;
end;
// -----------------------------------------------------------------------------

function TCustomDropSource.GetPoint(Index: integer): integer;
begin
  if (Index = 1) then
    Result := FImageHotSpot.x
  else
    Result := FImageHotSpot.y;
end;
// -----------------------------------------------------------------------------

procedure TCustomDropSource.SetShowImage(Value: boolean);
begin
  FShowImage := Value;
  if (csLoading in ComponentState) then
    exit;
  if (FImages = nil) then
    FShowImage := False;
end;
// -----------------------------------------------------------------------------

procedure TCustomDropSource.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FImages) then
    Images := nil;
end;


////////////////////////////////////////////////////////////////////////////////
//
//		TEnumFormatEtc
//
////////////////////////////////////////////////////////////////////////////////
// Format enumerator used by TCustomDropMultiTarget.
////////////////////////////////////////////////////////////////////////////////
type
  TEnumFormatEtc = class(TInterfacedObject, IEnumFormatEtc)
  private
    FFormats: TClipboardFormats;
    FIndex: integer;
  protected
    constructor CreateClone(AFormats: TClipboardFormats; AIndex: Integer);
  public
    constructor Create(AFormats: TDataFormats; Direction: TDataDirection);
    destructor Destroy; override;
    { IEnumFormatEtc implentation }
    function Next(Celt: LongInt; out Elt; pCeltFetched: pLongInt): HRESULT; stdcall;
    function Skip(Celt: LongInt): HRESULT; stdcall;
    function Reset: HRESULT; stdcall;
    function Clone(out Enum: IEnumFormatEtc): HRESULT; stdcall;
  end;

constructor TEnumFormatEtc.Create(AFormats: TDataFormats; Direction: TDataDirection);
var
  i, j: integer;
begin
  inherited Create;
  FFormats := TClipboardFormats.Create(nil, False);
  FIndex := 0;
  for i := 0 to AFormats.Count-1 do
    (*
    ** Only offer formats which contain data at this time.
    ** This might cause problems with formats which provides data on-demand.
    *)
    if AFormats[i].HasData then
      for j := 0 to AFormats[i].CompatibleFormats.Count-1 do
        if (Direction in AFormats[i].CompatibleFormats[j].DataDirections) and
          (not FFormats.Contain(TClipboardFormatClass(AFormats[i].CompatibleFormats[j].ClassType))) then
          FFormats.Add(AFormats[i].CompatibleFormats[j]);
end;

constructor TEnumFormatEtc.CreateClone(AFormats: TClipboardFormats; AIndex: Integer);
var
  i: integer;
begin
  inherited Create;
  FFormats := TClipboardFormats.Create(nil, False);
  FIndex := AIndex;
  for i := 0 to AFormats.Count-1 do
    FFormats.Add(AFormats[i]);
end;

destructor TEnumFormatEtc.Destroy;
begin
  FFormats.Free;
  FFormats := nil;
  inherited Destroy;
end;

function TEnumFormatEtc.Next(Celt: LongInt; out Elt;
  pCeltFetched: pLongInt): HRESULT;
var
  i: integer;
  FormatEtc: PFormatEtc;
begin
  i := 0;
  FormatEtc := PFormatEtc(@Elt);
  while (i < Celt) and (FIndex < FFormats.Count) do
  begin
    FormatEtc^ := FFormats[FIndex].FormatEtc;
    Inc(FormatEtc);
    Inc(i);
    Inc(FIndex);
  end;

  if (pCeltFetched <> nil) then
    pCeltFetched^ := i;

  if (i = Celt) then
    Result := S_OK
  else
    Result := S_FALSE;
end;

function TEnumFormatEtc.Skip(Celt: LongInt): HRESULT;
begin
  if (FIndex + Celt <= FFormats.Count) then
  begin
    inc(FIndex, Celt);
    Result := S_OK;
  end else
  begin
    FIndex := FFormats.Count;
    Result := S_FALSE;
  end;
end;

function TEnumFormatEtc.Reset: HRESULT;
begin
  FIndex := 0;
  Result := S_OK;
end;

function TEnumFormatEtc.Clone(out Enum: IEnumFormatEtc): HRESULT;
begin
  Enum := TEnumFormatEtc.CreateClone(FFormats, FIndex);
  Result := S_OK;
end;


////////////////////////////////////////////////////////////////////////////////
//
//		TCustomDropMultiSource
//
////////////////////////////////////////////////////////////////////////////////
type
  TSourceDataFormats = class(TDataFormats)
  public
    function Add(DataFormat: TCustomDataFormat): integer; override;
  end;

function TSourceDataFormats.Add(DataFormat: TCustomDataFormat): integer;
begin
  Result := inherited Add(DataFormat);
  // Set up change notification so drop source can flush clipboard if data changes.
  DataFormat.OnChanging := TCustomDropMultiSource(DataFormat.Owner).DataChanging;
end;

constructor TCustomDropMultiSource.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataFormats := TSourceDataFormats.Create;
  FFeedbackDataFormat := TFeedbackDataFormat.Create(Self);
  FRawDataFormat := TRawDataFormat.Create(Self);
end;

destructor TCustomDropMultiSource.Destroy;
var
  i: integer;
begin
  // Must flush clipboard before data formats are destroyed. Otherwise clipboard
  // can be left with references to data which can no longer be supplied.
  FlushClipboard;
  
  // Delete all target formats owned by the object
  for i := FDataFormats.Count-1 downto 0 do
    FDataFormats[i].Free;
  FDataFormats.Free;
  inherited Destroy;
end;

function TCustomDropMultiSource.DoGetData(const FormatEtcIn: TFormatEtc;
  out Medium: TStgMedium): HRESULT;
var
  i, j: integer;
  DF: TCustomDataFormat;
  CF: TClipboardFormat;
begin
  // TODO : Add support for delayed rendering with OnRenderData event.
  Medium.tymed := 0;
  Medium.UnkForRelease := nil;
  Medium.hGlobal := 0;

  Result := DV_E_FORMATETC;

  (*
  ** Loop through all data formats associated with this drop source to find one
  ** which can offer the clipboard format requested by the target.
  *)
  for i := 0 to DataFormats.Count-1 do
  begin
    DF := DataFormats[i];

    // Ignore empty data formats.
    if (not DF.HasData) then
      continue;

    (*
    ** Loop through all the data format's supported clipboard formats to find
    ** one which contains data and can provide it in the format requested by the
    ** target.
    *)
    for j := 0 to DF.CompatibleFormats.Count-1 do
    begin
      CF := DF.CompatibleFormats[j];
      (*
      ** 1) Determine if the clipboard format supports the format requested by
      **    the target.
      ** 2) Transfer data from the data format object to the clipboard format
      **    object.
      ** 3) Determine if the clipboard format object now has data to offer.
      ** 4) Transfer the data from the clipboard format object to the medium.
      *)
      if (CF.AcceptFormat(FormatEtcIn)) and
        (DataFormats[i].AssignTo(CF)) and
        (CF.HasData) and
        (CF.SetDataToMedium(FormatEtcIn, Medium)) then
      begin
        // Once data has been sucessfully transfered to the medium, we clear
        // the data in the TClipboardFormat object in order to conserve
        // resources.
        CF.Clear;
        Result := S_OK;
        exit;
      end;
    end;
  end;
end;

function TCustomDropMultiSource.DoSetData(const FormatEtc: TFormatEtc;
  var Medium: TStgMedium): HRESULT;
var
  i, j: integer;
  GenericClipboardFormat: TRawClipboardFormat;
begin
  Result := E_NOTIMPL;

  // Get data for requested source format.
  for i := 0 to DataFormats.Count-1 do
    for j := 0 to DataFormats[i].CompatibleFormats.Count-1 do
      if (DataFormats[i].CompatibleFormats[j].AcceptFormat(FormatEtc)) and
        (DataFormats[i].CompatibleFormats[j].GetDataFromMedium(Self, Medium)) and
        (DataFormats[i].Assign(DataFormats[i].CompatibleFormats[j])) then
      begin
        DoOnSetData(DataFormats[i], DataFormats[i].CompatibleFormats[j]);
        // Once data has been sucessfully transfered to the medium, we clear
        // the data in the TClipboardFormat object in order to conserve
        // resources.
        DataFormats[i].CompatibleFormats[j].Clear;
        Result := S_OK;
        exit;
      end;

  // The requested data format wasn't supported by any of the registered
  // clipboard formats, but in order to support the Windows 2000 drag drop helper
  // object we have to accept any data which is written to the IDataObject.
  // To do this we create a new clipboard format object, initialize it with the
  // format information passed to us and copy the data.
  GenericClipboardFormat := TRawClipboardFormat.CreateFormatEtc(FormatEtc);
  FRawDataFormat.CompatibleFormats.Add(GenericClipboardFormat);
  if (GenericClipboardFormat.GetDataFromMedium(Self, Medium)) and
    (FRawDataFormat.Assign(GenericClipboardFormat)) then
    Result := S_OK;
end;

function TCustomDropMultiSource.GetEnumFormatEtc(dwDirection: Integer): IEnumFormatEtc;
begin
  if (dwDirection = DATADIR_GET) then
    Result := TEnumFormatEtc.Create(FDataFormats, ddRead)
  else if (dwDirection = DATADIR_SET) then
    Result := TEnumFormatEtc.Create(FDataFormats, ddWrite)
  else
    Result := nil;
end;

function TCustomDropMultiSource.HasFormat(const FormatEtc: TFormatEtc): boolean;
var
  i, j: integer;
begin
  Result := False;

  for i := 0 to DataFormats.Count-1 do
    for j := 0 to DataFormats[i].CompatibleFormats.Count-1 do
      if (DataFormats[i].CompatibleFormats[j].AcceptFormat(FormatEtc)) then
      begin
        Result := True;
        exit;
      end;
end;

function TCustomDropMultiSource.GetPerformedDropEffect: longInt;
begin
  Result := FFeedbackDataFormat.PerformedDropEffect;
end;

function TCustomDropMultiSource.GetLogicalPerformedDropEffect: longInt;
begin
  Result := FFeedbackDataFormat.LogicalPerformedDropEffect;
end;

function TCustomDropMultiSource.GetPreferredDropEffect: longInt;
begin
  Result := FFeedbackDataFormat.PreferredDropEffect;
end;

procedure TCustomDropMultiSource.SetPerformedDropEffect(const Value: longInt);
begin
  FFeedbackDataFormat.PerformedDropEffect := Value;
end;

procedure TCustomDropMultiSource.SetPreferredDropEffect(const Value: longInt);
begin
  FFeedbackDataFormat.PreferredDropEffect := Value;
end;

function TCustomDropMultiSource.GetInShellDragLoop: boolean;
begin
  Result := FFeedbackDataFormat.InShellDragLoop;
end;

procedure TCustomDropMultiSource.SetInShellDragLoop(const Value: boolean);
begin
  FFeedbackDataFormat.InShellDragLoop := Value;
end;

function TCustomDropMultiSource.GetTargetCLSID: TCLSID;
begin
  Result := FFeedbackDataFormat.TargetCLSID;
end;

procedure TCustomDropMultiSource.DoOnSetData(DataFormat: TCustomDataFormat;
  ClipboardFormat: TClipboardFormat);
var
  DropEffect: longInt;
begin
  if (ClipboardFormat is TPasteSucceededClipboardFormat) then
  begin
    DropEffect := TPasteSucceededClipboardFormat(ClipboardFormat).Value;
    DoOnPaste(DropEffectToDragResult(DropEffect),
      (DropEffect = DROPEFFECT_MOVE) and (PerformedDropEffect = DROPEFFECT_MOVE));
  end;
end;

initialization
finalization
{$ifdef SHELL_DRAGIMAGE}
  if (Shell32Handle > HINSTANCE_ERROR) then
    FreeLibrary(Shell32Handle);
{$endif}
end.

