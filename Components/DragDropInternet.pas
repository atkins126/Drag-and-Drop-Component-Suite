unit DragDropInternet;
// -----------------------------------------------------------------------------
// Project:         Drag and Drop Component Suite.
// Module:          DragDropInternet
// Description:     Implements Dragging and Dropping of internet related data.
// Version:         4.1
// Date:            22-JAN-2002
// Target:          Win32, Delphi 4-6, C++Builder 4-6
// Authors:         Anders Melander, anders@melander.dk, http://www.melander.dk
// Copyright        � 1997-2002 Angus Johnson & Anders Melander
// -----------------------------------------------------------------------------

interface

uses
  DragDrop,
  DropTarget,
  DropSource,
  DragDropFormats,
  Windows,
  Classes,
  ActiveX;

type

////////////////////////////////////////////////////////////////////////////////
//
//		TURLClipboardFormat
//
////////////////////////////////////////////////////////////////////////////////
// Implements support for the 'UniformResourceLocator' format.
////////////////////////////////////////////////////////////////////////////////

  TURLClipboardFormat = class(TCustomTextClipboardFormat)
  public
    function GetClipboardFormat: TClipFormat; override;
    property URL: string read GetString write SetString;
  end;

////////////////////////////////////////////////////////////////////////////////
//
//		TURLWClipboardFormat
//
////////////////////////////////////////////////////////////////////////////////
// Implements support for the 'UniformResourceLocatorW' format.
////////////////////////////////////////////////////////////////////////////////

  TURLWClipboardFormat = class(TCustomWideTextClipboardFormat)
  public
    function GetClipboardFormat: TClipFormat; override;
    property URL: WideString read GetText write SetText;
  end;

////////////////////////////////////////////////////////////////////////////////
//
//		TNetscapeBookmarkClipboardFormat
//
////////////////////////////////////////////////////////////////////////////////
// Implements support for the 'Netscape Bookmark' format.
////////////////////////////////////////////////////////////////////////////////
  TNetscapeBookmarkClipboardFormat = class(TCustomSimpleClipboardFormat)
  private
    FURL: string;
    FTitle: string;
  protected
    function ReadData(Value: pointer; Size: integer): boolean; override;
    function WriteData(Value: pointer; Size: integer): boolean; override;
    function GetSize: integer; override;
  public
    function GetClipboardFormat: TClipFormat; override;
    procedure Clear; override;
    property URL: string read FURL write FURL;
    property Title: string read FTitle write FTitle;
  end;

////////////////////////////////////////////////////////////////////////////////
//
//		TNetscapeImageClipboardFormat
//
////////////////////////////////////////////////////////////////////////////////
// Implements support for the 'Netscape Image Format' format.
////////////////////////////////////////////////////////////////////////////////
  TNetscapeImageClipboardFormat = class(TCustomSimpleClipboardFormat)
  private
    FURL: string;
    FTitle: string;
    FImage: string;
    FLowRes: string;
    FExtra: string;
    FHeight: integer;
    FWidth: integer;
  protected
    function ReadData(Value: pointer; Size: integer): boolean; override;
    function WriteData(Value: pointer; Size: integer): boolean; override;
    function GetSize: integer; override;
  public
    function GetClipboardFormat: TClipFormat; override;
    procedure Clear; override;
    property URL: string read FURL write FURL;
    property Title: string read FTitle write FTitle;
    property Image: string read FImage write FImage;
    property LowRes: string read FLowRes write FLowRes;
    property Extra: string read FExtra write FExtra;
    property Height: integer read FHeight write FHeight;
    property Width: integer read FWidth write FWidth;
  end;

////////////////////////////////////////////////////////////////////////////////
//
//		TVCardClipboardFormat
//
////////////////////////////////////////////////////////////////////////////////
// Implements support for the '+//ISBN 1-887687-00-9::versit::PDI//vCard'
// (vCard) format.
////////////////////////////////////////////////////////////////////////////////
  TVCardClipboardFormat = class(TCustomStringListClipboardFormat)
  protected
    function ReadData(Value: pointer; Size: integer): boolean; override;
    function WriteData(Value: pointer; Size: integer): boolean; override;
    function GetSize: integer; override;
  public
    function GetClipboardFormat: TClipFormat; override;
    property Items: TStrings read GetLines;
  end;

////////////////////////////////////////////////////////////////////////////////
//
//		THTMLClipboardFormat
//
////////////////////////////////////////////////////////////////////////////////
// Implements support for the 'HTML Format' format.
////////////////////////////////////////////////////////////////////////////////
  THTMLClipboardFormat = class(TCustomStringListClipboardFormat)
  public
    function GetClipboardFormat: TClipFormat; override;
    function HasData: boolean; override;
    function Assign(Source: TCustomDataFormat): boolean; override;
    function AssignTo(Dest: TCustomDataFormat): boolean; override;
    property HTML: TStrings read GetLines;
  end;

////////////////////////////////////////////////////////////////////////////////
//
//		TRFC822ClipboardFormat
//
////////////////////////////////////////////////////////////////////////////////
  TRFC822ClipboardFormat = class(TCustomStringListClipboardFormat)
  public
    function GetClipboardFormat: TClipFormat; override;
    function Assign(Source: TCustomDataFormat): boolean; override;
    function AssignTo(Dest: TCustomDataFormat): boolean; override;
    property Text: TStrings read GetLines;
  end;


////////////////////////////////////////////////////////////////////////////////
//
//		TURLDataFormat
//
////////////////////////////////////////////////////////////////////////////////
// Renderer for URL formats.
////////////////////////////////////////////////////////////////////////////////
  TURLDataFormat = class(TCustomDataFormat)
  private
    FURL: string;
    FTitle: string;
    procedure SetTitle(const Value: string);
    procedure SetURL(const Value: string);
  protected
  public
    function Assign(Source: TClipboardFormat): boolean; override;
    function AssignTo(Dest: TClipboardFormat): boolean; override;
    procedure Clear; override;
    function HasData: boolean; override;
    function NeedsData: boolean; override;
    property URL: string read FURL write SetURL;
    property Title: string read FTitle write SetTitle;
  end;


////////////////////////////////////////////////////////////////////////////////
//
//		THTMLDataFormat
//
////////////////////////////////////////////////////////////////////////////////
// Renderer for HTML text data.
////////////////////////////////////////////////////////////////////////////////
  THTMLDataFormat = class(TCustomDataFormat)
  private
    FHTML: TStrings;
    procedure SetHTML(const Value: TStrings);
  protected
  public
    constructor Create(AOwner: TDragDropComponent); override;
    destructor Destroy; override;
    function Assign(Source: TClipboardFormat): boolean; override;
    function AssignTo(Dest: TClipboardFormat): boolean; override;
    procedure Clear; override;
    function HasData: boolean; override;
    function NeedsData: boolean; override;
    property HTML: TStrings read FHTML write SetHTML;
  end;


////////////////////////////////////////////////////////////////////////////////
//
//		TStorageDataFormat
//		TOutlookDataFormat
//
////////////////////////////////////////////////////////////////////////////////
// Renderer for Microsoft Outlook email formats.
////////////////////////////////////////////////////////////////////////////////
  TStorageDataFormat = class(TCustomDataFormat)
  private
    FStorages: TStorageInterfaceList;
  protected
  public
    constructor Create(AOwner: TDragDropComponent); override;
    destructor Destroy; override;
    function Assign(Source: TClipboardFormat): boolean; override;
    function AssignTo(Dest: TClipboardFormat): boolean; override;
    procedure Clear; override;
    function HasData: boolean; override;
    function NeedsData: boolean; override;
    property Storages: TStorageInterfaceList read FStorages;
  end;

  TMessages = class(TObject)
  private
    FStorages: TStorageInterfaceList;
    FMessages: TInterfaceList;
    function GetCount: integer;
  protected
    function GetMessage(Index: integer): IUnknown;
  public
    constructor Create(AStorages: TStorageInterfaceList);
    destructor Destroy; override;
    procedure Clear;
    property Storages: TStorageInterfaceList read FStorages;
    property Messages[Index: integer]: IUnknown read GetMessage; default;
    property Count: integer read GetCount;
  end;

  TOutlookDataFormat = class(TStorageDataFormat)
  private
    FMessages: TMessages;
  protected
  public
    constructor Create(AOwner: TDragDropComponent); override;
    destructor Destroy; override;
    procedure Clear; override;
    property Messages: TMessages read FMessages;
  end;


////////////////////////////////////////////////////////////////////////////////
//
//		TDropURLTarget
//
////////////////////////////////////////////////////////////////////////////////
// URL drop target component.
////////////////////////////////////////////////////////////////////////////////
  TDropURLTarget = class(TCustomDropMultiTarget)
  private
    FURLFormat: TURLDataFormat;
  protected
    function GetTitle: string;
    function GetURL: string;
    function GetPreferredDropEffect: LongInt; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property URL: string read GetURL;
    property Title: string read GetTitle;
  end;

////////////////////////////////////////////////////////////////////////////////
//
//		TDropURLSource
//
////////////////////////////////////////////////////////////////////////////////
// URL drop source component.
////////////////////////////////////////////////////////////////////////////////
  TDropURLSource = class(TCustomDropMultiSource)
  private
    FURLFormat: TURLDataFormat;
    procedure SetTitle(const Value: string);
    procedure SetURL(const Value: string);
  protected
    function GetTitle: string;
    function GetURL: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property URL: string read GetURL write SetURL;
    property Title: string read GetTitle write SetTitle;
  end;


////////////////////////////////////////////////////////////////////////////////
//
//		Component registration
//
////////////////////////////////////////////////////////////////////////////////
procedure Register;

////////////////////////////////////////////////////////////////////////////////
//
//		Misc.
//
////////////////////////////////////////////////////////////////////////////////
function GetURLFromFile(const Filename: string; var URL: string): boolean;
function GetURLFromString(const s: string; var URL: string): boolean;
function GetURLFromStream(Stream: TStream; var URL: string): boolean;
function ConvertURLToFilename(const url: string): string;

function IsHTML(const s: string): boolean;
function MakeHTML(const s: string): string;
function MakeTextFromHTML(const s: string; FullHTML: boolean = False): string;


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//			IMPLEMENTATION
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
implementation

uses
  SysUtils,
  ShlObj,
  ComObj,
  DragDropFile,
  DragDropPIDL,
  DragDropText;

////////////////////////////////////////////////////////////////////////////////
//
//		Component registration
//
////////////////////////////////////////////////////////////////////////////////
procedure Register;
begin
  RegisterComponents(DragDropComponentPalettePage, [TDropURLTarget,
    TDropURLSource]);
end;


////////////////////////////////////////////////////////////////////////////////
//
//		Utilities
//
////////////////////////////////////////////////////////////////////////////////
function GetURLFromFile(const Filename: string; var URL: string): boolean;
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite);
  try
    Result := GetURLFromStream(Stream, URL);
  finally
    Stream.Free;
  end;
end;

function GetURLFromString(const s: string; var URL: string): boolean;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Stream.Size := Length(s);
    Move(PChar(s)^, Stream.Memory^, Length(s));
    Result := GetURLFromStream(Stream, URL);
  finally
    Stream.Free;
  end;
end;

const
  // *** DO NOT LOCALIZE ***
  InternetShortcut	= '[InternetShortcut]';
  InternetShortcutExt	= '.url';

function GetURLFromStream(Stream: TStream; var URL: string): boolean;
var
  URLfile: TStringList;
  i: integer;
  s: string;
  p: PChar;
begin
  Result := False;
  URLfile := TStringList.Create;
  try
    URLFile.LoadFromStream(Stream);
    i := 0;
    while (i < URLFile.Count-1) do
    begin
      if (CompareText(URLFile[i], InternetShortcut) = 0) then
      begin
        inc(i);
        while (i < URLFile.Count) do
        begin
          s := URLFile[i];
          p := PChar(s);
          if (StrLIComp(p, 'URL=', length('URL=')) = 0) then
          begin
            inc(p, length('URL='));
            URL := p;
            Result := True;
            exit;
          end else
            if (p^ = '[') then
              exit;
          inc(i);
        end;
      end;
      inc(i);
    end;
  finally
    URLFile.Free;
  end;
end;

function ConvertURLToFilename(const url: string): string;
const
  Invalids: set of char =
    ['\', '/', ':', '?', '*', '<', '>', ',', '|', '''', '"'];
var
  i: integer;
  LastInvalid: boolean;
begin
  Result := url;
  if (AnsiStrLIComp(PChar(lowercase(Result)), 'http://', 7) = 0) then
    delete(Result, 1, 7)
  else if (AnsiStrLIComp(PChar(lowercase(Result)), 'ftp://', 6) = 0) then
    delete(Result, 1, 6)
  else if (AnsiStrLIComp(PChar(lowercase(Result)), 'mailto:', 7) = 0) then
    delete(Result, 1, 7)
  else if (AnsiStrLIComp(PChar(lowercase(Result)), 'file:', 5) = 0) then
    delete(Result, 1, 5);

  if (length(Result) > 120) then
    SetLength(Result, 120);

  // Truncate at first slash
  i := pos('/', Result);
  if (i > 0) then
    SetLength(Result, i-1);

  // Replace invalids with spaces.
  // If string starts with invalids, they are trimmed.
  LastInvalid := True;
  for i := length(Result) downto 1 do
    if (Result[i] in Invalids) then
    begin
      if (not LastInvalid) then
      begin
        Result[i] := ' ';
        LastInvalid := True;
      end else
        // Repeating invalids are trimmed.
        Delete(Result, i, 1);
    end else
      LastInvalid := False;

  if Result = '' then
    Result := 'untitled';

   Result := Result+InternetShortcutExt;
end;

function IsHTML(const s: string): boolean;
begin
  Result := (pos('<HTML', Uppercase(s)) > 0);
end;

function MakeHTML(const s: string): string;
const
  Header: string =
    'Version:0.9'+#13#10+
    'StartHTML:aaaaaaaa'+#13#10+
    'EndHTML:bbbbbbbb'+#13#10+
    'StartFragment:cccccccc'+#13#10+
    'EndFragment:dddddddd'+#13#10;
  WrapperStart: string =
    '<HTML>'+#13#10+
    '<BODY>'+#13#10+
    '<!--StartFragment-->';
  WrapperEnd: string =
    '<!--EndFragment-->'+#13#10+
    '</BODY>'+#13#10+
    '</HTML>';
var
  n: integer;
begin
  (*
  ** See MSDN articles Q274308 and Q274326.
  *)
  { TODO -oanme -cImprovement : Needs to escape special chars in text to HTML conversion. ...or do I? }
  { DONE -oanme -cImprovement : Needs better text to HTML conversion. }
  if (not IsHTML(s)) then
  begin
    Result := Header+WrapperStart+s+WrapperEnd;
    n := Length(Header);
    Result := StringReplace(Result, 'aaaaaaaa', format('%.8d', [n]), []);
    Result := StringReplace(Result, 'bbbbbbbb', format('%.8d', [Length(Result)]), []);
    inc(n, Length(WrapperStart));
    Result := StringReplace(Result, 'cccccccc', format('%.8d', [n]), []);
    inc(n, Length(s));
    Result := StringReplace(Result, 'dddddddd', format('%.8d', [n]), []);
  end else
    Result := s;
end;

function MakeTextFromHTML(const s: string; FullHTML: boolean): string;
const
  Sections: array[boolean, 0..1] of string =
    (('StartFragment:', 'EndFragment'), ('StartHTML', 'EndHTML'));
var
  n1, n2: integer;
  p: PChar;
begin
  n1 := Pos(Sections[FullHTML, 0], s);
  n2 := Pos(Sections[FullHTML, 1], s);
  if (n1 > 0) and (n2 > 0) then
  begin
    p := PChar(@s[n1+Length(Sections[FullHTML, 0])]);
    // Convert string to number.
    n1 := 0;
    while (p^ <> #0) and (p^ in ['0'..'9']) do
    begin
      n1 := 10*n1 + ord(p^)-ord('0');
      inc(p);
    end;

    p := PChar(@s[n2+Length(Sections[FullHTML, 1])]);
    // Convert string to number.
    n2 := 0;
    while (p^ <> #0) and (p^ in ['0'..'9']) do
    begin
      n2 := 10*n2 + ord(p^)-ord('0');
      inc(p);
    end;

    Result := Copy(s, n1+1, n2-n1);
  end else
    Result := s;
end;

////////////////////////////////////////////////////////////////////////////////
//
//		TURLClipboardFormat
//
////////////////////////////////////////////////////////////////////////////////
var
  CF_URL: TClipFormat = 0;

// Note: CFSTR_INETURL = CFSTR_SHELLURL
function TURLClipboardFormat.GetClipboardFormat: TClipFormat;
begin
  if (CF_URL = 0) then
    CF_URL := RegisterClipboardFormat(CFSTR_SHELLURL);
  Result := CF_URL;
end;


////////////////////////////////////////////////////////////////////////////////
//
//		TURLWClipboardFormat
//
////////////////////////////////////////////////////////////////////////////////
var
  CF_INETURLW: TClipFormat = 0;

function TURLWClipboardFormat.GetClipboardFormat: TClipFormat;
begin
  if (CF_INETURLW = 0) then
    CF_INETURLW := RegisterClipboardFormat('UniformResourceLocatorW'); // *** DO NOT LOCALIZE ***
  Result := CF_INETURLW;
end;


////////////////////////////////////////////////////////////////////////////////
//
//		TNetscapeBookmarkClipboardFormat
//
////////////////////////////////////////////////////////////////////////////////
var
  CF_NETSCAPEBOOKMARK: TClipFormat = 0;

function TNetscapeBookmarkClipboardFormat.GetClipboardFormat: TClipFormat;
begin
  if (CF_NETSCAPEBOOKMARK = 0) then
    CF_NETSCAPEBOOKMARK := RegisterClipboardFormat('Netscape Bookmark'); // *** DO NOT LOCALIZE ***
  Result := CF_NETSCAPEBOOKMARK;
end;

function TNetscapeBookmarkClipboardFormat.GetSize: integer;
begin
  Result := 0;
  if (FURL <> '') then
  begin
    inc(Result, 1024);
    if (FTitle <> '') then
      inc(Result, 1024);
  end;
end;

function TNetscapeBookmarkClipboardFormat.ReadData(Value: pointer;
  Size: integer): boolean;
begin
  // Note: No check for missing string terminator!
  FURL := PChar(Value);
  if (Size > 1024) then
  begin
    inc(PChar(Value), 1024);
    FTitle := PChar(Value);
  end;
  Result := True;
end;

function TNetscapeBookmarkClipboardFormat.WriteData(Value: pointer;
  Size: integer): boolean;
begin
  StrLCopy(Value, PChar(FURL), Size);
  dec(Size, 1024);
  if (Size > 0) and (FTitle <> '') then
  begin
    inc(PChar(Value), 1024);
    StrLCopy(Value, PChar(FTitle), Size);
  end;
  Result := True;
end;

procedure TNetscapeBookmarkClipboardFormat.Clear;
begin
  FURL := '';
  FTitle := '';
end;


////////////////////////////////////////////////////////////////////////////////
//
//		TNetscapeImageClipboardFormat
//
////////////////////////////////////////////////////////////////////////////////
var
  CF_NETSCAPEIMAGE: TClipFormat = 0;

function TNetscapeImageClipboardFormat.GetClipboardFormat: TClipFormat;
begin
  if (CF_NETSCAPEIMAGE = 0) then
    CF_NETSCAPEIMAGE := RegisterClipboardFormat('Netscape Image Format');
  Result := CF_NETSCAPEIMAGE;
end;

type
  TNetscapeImageRec = record
    Size,
    _Unknown1,
    Width,
    Height,
    HorMargin,
    VerMargin,
    Border,
    OfsLowRes,
    OfsTitle,
    OfsURL,
    OfsExtra: DWORD
  end;
  PNetscapeImageRec = ^TNetscapeImageRec;

function TNetscapeImageClipboardFormat.GetSize: integer;
begin
  Result := SizeOf(TNetscapeImageRec);
  inc(Result, Length(FImage)+1);

  if (FLowRes <> '') then
    inc(Result, Length(FLowRes)+1);
  if (FTitle <> '') then
    inc(Result, Length(FTitle)+1);
  if (FUrl <> '') then
    inc(Result, Length(FUrl)+1);
  if (FExtra <> '') then
    inc(Result, Length(FExtra)+1);
end;

function TNetscapeImageClipboardFormat.ReadData(Value: pointer;
  Size: integer): boolean;
begin
  Result := (Size > SizeOf(TNetscapeImageRec));
  if (Result) then
  begin
    FWidth := PNetscapeImageRec(Value)^.Width;
    FHeight := PNetscapeImageRec(Value)^.Height;
    FImage := PChar(Value) + SizeOf(TNetscapeImageRec);
    if (PNetscapeImageRec(Value)^.OfsLowRes <> 0) then
      FLowRes := PChar(Value) + PNetscapeImageRec(Value)^.OfsLowRes;
    if (PNetscapeImageRec(Value)^.OfsTitle <> 0) then
      FTitle := PChar(Value) + PNetscapeImageRec(Value)^.OfsTitle;
    if (PNetscapeImageRec(Value)^.OfsURL <> 0) then
      FUrl := PChar(Value) + PNetscapeImageRec(Value)^.OfsUrl;
    if (PNetscapeImageRec(Value)^.OfsExtra <> 0) then
      FExtra := PChar(Value) + PNetscapeImageRec(Value)^.OfsExtra;
  end;
end;

function TNetscapeImageClipboardFormat.WriteData(Value: pointer;
  Size: integer): boolean;
var
  NetscapeImageRec: PNetscapeImageRec;
begin
  Result := (Size > SizeOf(TNetscapeImageRec));
  if (Result) then
  begin
    NetscapeImageRec := PNetscapeImageRec(Value);
    NetscapeImageRec^.Width := FWidth;
    NetscapeImageRec^.Height := FHeight;
    inc(PChar(Value), SizeOf(TNetscapeImageRec));
    dec(Size, SizeOf(TNetscapeImageRec));
    StrLCopy(Value, PChar(FImage), Size);
    dec(Size, Length(FImage)+1);
    if (Size <= 0) then
      exit;
    if (FLowRes <> '') then
    begin
      StrLCopy(Value, PChar(FLowRes), Size);
      NetscapeImageRec^.OfsLowRes := integer(Value) - integer(NetscapeImageRec);
      dec(Size, Length(FLowRes)+1);
      inc(PChar(Value), Length(FLowRes)+1);
      if (Size <= 0) then
        exit;
    end;
    if (FTitle <> '') then
    begin
      StrLCopy(Value, PChar(FTitle), Size);
      NetscapeImageRec^.OfsTitle := integer(Value) - integer(NetscapeImageRec);
      dec(Size, Length(FTitle)+1);
      inc(PChar(Value), Length(FTitle)+1);
      if (Size <= 0) then
        exit;
    end;
    if (FUrl <> '') then
    begin
      StrLCopy(Value, PChar(FUrl), Size);
      NetscapeImageRec^.OfsUrl := integer(Value) - integer(NetscapeImageRec);
      dec(Size, Length(FUrl)+1);
      inc(PChar(Value), Length(FUrl)+1);
      if (Size <= 0) then
        exit;
    end;
    if (FExtra <> '') then
    begin
      StrLCopy(Value, PChar(FExtra), Size);
      NetscapeImageRec^.OfsExtra := integer(Value) - integer(NetscapeImageRec);
      dec(Size, Length(FExtra)+1);
      inc(PChar(Value), Length(FExtra)+1);
      if (Size <= 0) then
        exit;
    end;
  end;
end;

procedure TNetscapeImageClipboardFormat.Clear;
begin
  FURL := '';
  FTitle := '';
  FImage := '';
  FLowRes := '';
  FExtra := '';
  FHeight := 0;
  FWidth := 0;
end;


////////////////////////////////////////////////////////////////////////////////
//
//		TVCardClipboardFormat
//
////////////////////////////////////////////////////////////////////////////////
var
  CF_VCARD: TClipFormat = 0;

function TVCardClipboardFormat.GetClipboardFormat: TClipFormat;
begin
  if (CF_VCARD = 0) then
    CF_VCARD := RegisterClipboardFormat('+//ISBN 1-887687-00-9::versit::PDI//vCard'); // *** DO NOT LOCALIZE ***
  Result := CF_VCARD;
end;

function TVCardClipboardFormat.GetSize: integer;
var
  i: integer;
begin
  if (Items.Count > 0) then
  begin
    Result := 22; // Length('begin:vcard'+#13+'end:vcard'+#0);
    for i := 0 to Items.Count-1 do
      inc(Result, Length(Items[i])+1);
  end else
    Result := 0;
end;

function TVCardClipboardFormat.ReadData(Value: pointer; Size: integer): boolean;
var
  i: integer;
  s: string;
begin
  Result := inherited ReadData(Value, Size);
  if (Result) then
  begin
    // Zap vCard header and trailer
    if (Items.Count > 0) and (CompareText(Items[0], 'begin:vcard') = 0) then
      Items.Delete(0);
    if (Items.Count > 0) and (CompareText(Items[Items.Count-1], 'end:vcard') = 0) then
      Items.Delete(Items.Count-1);
    // Convert to item/value list
    for i := 0 to Items.Count-1 do
      if (pos(':', Items[i]) > 0) then
      begin
        s := Items[i];
        s[pos(':', Items[i])] := '=';
        Items[i] := s;
      end;
  end;
end;

function DOSStringToUnixString(dos: string): string;
var
  s, d: PChar;
  l: integer;
begin
  SetLength(Result, Length(dos)+1);
  s := PChar(dos);
  d := PChar(Result);
  l := 1;
  while (s^ <> #0) do
  begin
    // Ignore LF
    if (s^ <> #10) then
    begin
      d^ := s^;
      inc(l);
      inc(d);
    end;
    inc(s);
  end;
  SetLength(Result, l);
end;

function TVCardClipboardFormat.WriteData(Value: pointer; Size: integer): boolean;
var
  s: string;
begin
  Result := (Items.Count > 0);
  if (Result) then
  begin
    s := DOSStringToUnixString('begin:vcard'+#13+Items.Text+#13+'end:vcard');
    StrLCopy(Value, PChar(s), Size);
  end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//		THTMLClipboardFormat
//
////////////////////////////////////////////////////////////////////////////////
var
  CF_HTML: TClipFormat = 0;

function THTMLClipboardFormat.GetClipboardFormat: TClipFormat;
begin
  if (CF_HTML = 0) then
    CF_HTML := RegisterClipboardFormat('HTML Format');
  Result := CF_HTML;
end;

function THTMLClipboardFormat.HasData: boolean;
begin
  Result := inherited HasData and IsHTML(HTML.Text);
end;

function THTMLClipboardFormat.Assign(Source: TCustomDataFormat): boolean;
begin
  Result := True;
  if (Source is TTextDataFormat) then
  begin
    if IsHTML(TTextDataFormat(Source).HTML) then
      HTML.Text := TTextDataFormat(Source).HTML
    else
      HTML.Text := MakeHTML(TTextDataFormat(Source).Text);
  end else
    Result := inherited Assign(Source);
end;

function THTMLClipboardFormat.AssignTo(Dest: TCustomDataFormat): boolean;
begin
  Result := True;
  if (Dest is TTextDataFormat) then
  begin
    TTextDataFormat(Dest).HTML := HTML.Text;
    // TTextDataFormat(Dest).Text := MakeTextFromHTML(HTML.Text)
  end else
    Result := inherited AssignTo(Dest);
end;


////////////////////////////////////////////////////////////////////////////////
//
//		TRFC822ClipboardFormat
//
////////////////////////////////////////////////////////////////////////////////
var
  CF_RFC822: TClipFormat = 0;

function TRFC822ClipboardFormat.GetClipboardFormat: TClipFormat;
begin
  if (CF_RFC822 = 0) then
    CF_RFC822 := RegisterClipboardFormat('Internet Message (rfc822/rfc1522)'); // *** DO NOT LOCALIZE ***
  Result := CF_RFC822;
end;

function TRFC822ClipboardFormat.Assign(Source: TCustomDataFormat): boolean;
begin
  Result := True;
  if (Source is TTextDataFormat) then
    Text.Text := TTextDataFormat(Source).Text
  else
    Result := inherited Assign(Source);
end;

function TRFC822ClipboardFormat.AssignTo(Dest: TCustomDataFormat): boolean;
begin
  Result := True;
  if (Dest is TTextDataFormat) then
    TTextDataFormat(Dest).Text := Text.Text
  else
    Result := inherited AssignTo(Dest);
end;


////////////////////////////////////////////////////////////////////////////////
//
//		TURLDataFormat
//
////////////////////////////////////////////////////////////////////////////////
function TURLDataFormat.Assign(Source: TClipboardFormat): boolean;
var
  s: string;
begin
  Result := False;
  (*
  ** TURLClipboardFormat
  *)
  if (Source is TURLClipboardFormat) then
  begin
    if (FURL = '') then
      FURL := TURLClipboardFormat(Source).URL;
    Result := True;
  end else
  (*
  ** TTextClipboardFormat
  *)
  if (Source is TTextClipboardFormat) then
  begin
    if (FURL = '') then
    begin
      s := TTextClipboardFormat(Source).Text;
      // Convert from text if the string looks like an URL
      if (pos('://', s) > 1) then
      begin
        FURL := s;
        Result := True;
      end;
    end;
  end else
  (*
  ** TFileClipboardFormat
  *)
  if (Source is TFileClipboardFormat) then
  begin
    if (FURL = '') then
    begin
      s := TFileClipboardFormat(Source).Files[0];
      // Convert from Internet Shortcut file format.
      if (CompareText(ExtractFileExt(s), InternetShortcutExt) = 0) and
        (GetURLFromFile(s, FURL)) then
      begin
        if (FTitle = '') then
          FTitle := ChangeFileExt(ExtractFileName(s), '');
        Result := True;
      end;
    end;
  end else
  (*
  ** TFileContentsClipboardFormat
  *)
  if (Source is TFileContentsClipboardFormat) then
  begin
    // Reject file contents unless we have already accepted the file group
    // descriptor (i.e. the internet shortcut file name).
    // We do this to prevent the situation where we has to pull a lot of data
    // from the source and then discard the data because it didn't actually
    // contain anything usefull (e.g. 10Mb of data from the AsyncSource demo).
    if (FURL = '') and (FTitle <> '') then
    begin
      s := TFileContentsClipboardFormat(Source).Data;
      Result := GetURLFromString(s, FURL);
    end;
  end else
  (*
  ** TFileGroupDescritorClipboardFormat
  *)
  if (Source is TFileGroupDescritorClipboardFormat) then
  begin
    if (FTitle = '') then
    begin
      if (TFileGroupDescritorClipboardFormat(Source).FileGroupDescriptor^.cItems > 0) then
      begin
        // Extract the title of an Internet Shortcut
        s := TFileGroupDescritorClipboardFormat(Source).FileGroupDescriptor^.fgd[0].cFileName;
        if (CompareText(ExtractFileExt(s), InternetShortcutExt) = 0) then
        begin
          FTitle := ChangeFileExt(s, '');
          Result := True;
        end;
      end;
    end;
  end else
  (*
  ** TFileGroupDescritorWClipboardFormat
  *)
  if (Source is TFileGroupDescritorWClipboardFormat) then
  begin
    if (FTitle = '') then
    begin
      if (TFileGroupDescritorWClipboardFormat(Source).FileGroupDescriptor^.cItems > 0) then
      begin
        // Extract the title of an Internet Shortcut
        s := TFileGroupDescritorWClipboardFormat(Source).FileGroupDescriptor^.fgd[0].cFileName;
        if (CompareText(ExtractFileExt(s), InternetShortcutExt) = 0) then
        begin
          FTitle := ChangeFileExt(s, '');
          Result := True;
        end;
      end;
    end;
  end else
  (*
  ** TNetscapeBookmarkClipboardFormat
  *)
  if (Source is TNetscapeBookmarkClipboardFormat) then
  begin
    if (FURL = '') then
      FURL := TNetscapeBookmarkClipboardFormat(Source).URL;
    if (FTitle = '') then
      FTitle := TNetscapeBookmarkClipboardFormat(Source).Title;
    Result := True;
  end else
  (*
  ** TNetscapeImageClipboardFormat
  *)
  if (Source is TNetscapeImageClipboardFormat) then
  begin
    if (FURL = '') then
      FURL := TNetscapeImageClipboardFormat(Source).URL;
    if (FTitle = '') then
      FTitle := TNetscapeImageClipboardFormat(Source).Title;
    Result := True;
  end else
    Result := inherited Assign(Source);
end;

function TURLDataFormat.AssignTo(Dest: TClipboardFormat): boolean;
var
  FGD: TFileGroupDescriptor;
  FGDW: DragDropFormats.TFileGroupDescriptorW;
  s: string;
begin
  Result := True;
  (*
  ** TURLClipboardFormat
  *)
  if (Dest is TURLClipboardFormat) then
  begin
    TURLClipboardFormat(Dest).URL := FURL;
  end else
  (*
  ** TTextClipboardFormat
  *)
  if (Dest is TTextClipboardFormat) then
  begin
    TTextClipboardFormat(Dest).Text := FURL;
  end else
  (*
  ** TFileContentsClipboardFormat
  *)
  if (Dest is TFileContentsClipboardFormat) then
  begin
    TFileContentsClipboardFormat(Dest).Data := InternetShortcut + #13#10 +
      'URL='+FURL + #13#10;
  end else
  (*
  ** TFileGroupDescritorClipboardFormat
  *)
  if (Dest is TFileGroupDescritorClipboardFormat) then
  begin
    FillChar(FGD, SizeOf(FGD), 0);
    FGD.cItems := 1;
    if (FTitle = '') then
      s := FURL
    else
      s := FTitle;
    StrLCopy(@FGD.fgd[0].cFileName[0], PChar(ConvertURLToFilename(s)),
      SizeOf(FGD.fgd[0].cFileName));
    FGD.fgd[0].dwFlags := FD_LINKUI or FD_FILESIZE;
    FGD.fgd[0].nFileSizeLow := Length(InternetShortcut)+Length(FURL)+8;
    TFileGroupDescritorClipboardFormat(Dest).CopyFrom(@FGD);
  end else
  (*
  ** TFileGroupDescritorWClipboardFormat
  *)
  if (Dest is TFileGroupDescritorWClipboardFormat) then
  begin
    FillChar(FGDW, SizeOf(FGDW), 0);
    FGDW.cItems := 1;
    if (FTitle = '') then
      s := FURL
    else
      s := FTitle;
    StringToWideChar(ConvertURLToFilename(s), @FGDW.fgd[0].cFileName[0],
      SizeOf(FGDW.fgd[0].cFileName) div 2);
    FGDW.fgd[0].dwFlags := FD_LINKUI or FD_FILESIZE;
    FGDW.fgd[0].nFileSizeLow := Length(InternetShortcut)+Length(FURL)+8;
    TFileGroupDescritorWClipboardFormat(Dest).CopyFrom(@FGDW);
  end else
  (*
  ** TNetscapeBookmarkClipboardFormat
  *)
  if (Dest is TNetscapeBookmarkClipboardFormat) then
  begin
    TNetscapeBookmarkClipboardFormat(Dest).URL := FURL;
    TNetscapeBookmarkClipboardFormat(Dest).Title := FTitle;
  end else
  (*
  ** TNetscapeImageClipboardFormat
  *)
  if (Dest is TNetscapeImageClipboardFormat) then
  begin
    TNetscapeImageClipboardFormat(Dest).URL := FURL;
    TNetscapeImageClipboardFormat(Dest).Title := FTitle;
  end else
    Result := inherited AssignTo(Dest);
end;

procedure TURLDataFormat.Clear;
begin
  Changing;
  FURL := '';
  FTitle := '';
end;

procedure TURLDataFormat.SetTitle(const Value: string);
begin
  Changing;
  FTitle := Value;
end;

procedure TURLDataFormat.SetURL(const Value: string);
begin
  Changing;
  FURL := Value;
end;

function TURLDataFormat.HasData: boolean;
begin
  Result := (FURL <> '') or (FTitle <> '');
end;

function TURLDataFormat.NeedsData: boolean;
begin
  Result := (FURL = '') or (FTitle = '');
end;


////////////////////////////////////////////////////////////////////////////////
//
//		THTMLDataFormat
//
////////////////////////////////////////////////////////////////////////////////
function THTMLDataFormat.Assign(Source: TClipboardFormat): boolean;
begin
  Result := True;

  if (Source is THTMLClipboardFormat) then
    FHTML.Assign(THTMLClipboardFormat(Source).HTML)

  else
    Result := inherited Assign(Source);
end;

function THTMLDataFormat.AssignTo(Dest: TClipboardFormat): boolean;
begin
  Result := True;

  if (Dest is THTMLClipboardFormat) then
    THTMLClipboardFormat(Dest).HTML.Assign(FHTML)

  else
    Result := inherited AssignTo(Dest);
end;

procedure THTMLDataFormat.Clear;
begin
  Changing;
  FHTML.Clear;
end;

constructor THTMLDataFormat.Create(AOwner: TDragDropComponent);
begin
  inherited Create(AOwner);
  FHTML := TStringList.Create;
end;

destructor THTMLDataFormat.Destroy;
begin
  FHTML.Free;
  inherited Destroy;
end;

function THTMLDataFormat.HasData: boolean;
begin
  Result := (FHTML.Count > 0);
end;

function THTMLDataFormat.NeedsData: boolean;
begin
  Result := (FHTML.Count = 0);
end;

procedure THTMLDataFormat.SetHTML(const Value: TStrings);
begin
  FHTML.Assign(Value);
end;

////////////////////////////////////////////////////////////////////////////////
//
//		TStorageDataFormat
//
////////////////////////////////////////////////////////////////////////////////
constructor TStorageDataFormat.Create(AOwner: TDragDropComponent);
begin
  inherited Create(AOwner);
  FStorages := TStorageInterfaceList.Create;
  FStorages.OnChanging := DoOnChanging;
end;

destructor TStorageDataFormat.Destroy;
begin
  Clear;
  FStorages.Free;
  inherited Destroy;
end;

procedure TStorageDataFormat.Clear;
begin
  Changing;
  FStorages.Clear;
end;

function TStorageDataFormat.Assign(Source: TClipboardFormat): boolean;
begin
  Result := True;

  if (Source is TFileContentsStorageClipboardFormat) then
    FStorages.Assign(TFileContentsStorageClipboardFormat(Source).Storages)

  else
    Result := inherited Assign(Source);
end;

function TStorageDataFormat.AssignTo(Dest: TClipboardFormat): boolean;
begin
  Result := True;

  if (Dest is TFileContentsStorageClipboardFormat) then
    TFileContentsStorageClipboardFormat(Dest).Storages.Assign(FStorages)

  else
    Result := inherited AssignTo(Dest);
end;

function TStorageDataFormat.HasData: boolean;
begin
  Result := (FStorages.Count > 0);
end;

function TStorageDataFormat.NeedsData: boolean;
begin
  Result := (FStorages.Count = 0);
end;

procedure TMessages.Clear;
var
  i: integer;
begin
  for i := 0 to FMessages.Count-1 do
  begin
    (*
    ** Due to an apparent bug in Outlook, we have to prevent the reference count
    ** of the IMessage object to reach zero.
    *)
    // Artificially increment reference count before we zap the reference to the
    // object.
    FMessages[i]._AddRef;
    // Zap reference stored in list.
    FMessages[i] := nil;
  end;
  FMessages.Clear;
end;

constructor TMessages.Create(AStorages: TStorageInterfaceList);
begin
  inherited Create;
  FStorages := AStorages;
  FMessages := TInterfaceList.Create;
end;

destructor TMessages.Destroy;
begin
  Clear;
  FMessages.Free;
  inherited Destroy;
end;

function TMessages.GetCount: integer;
begin
  Result := FStorages.Count;
end;

type
  TMAPIGetDefaultMalloc = function: pointer; stdcall;
  TMAPIInitialize = function(lpMapiInit: pointer): HResult; stdcall;
  TMAPIUninitialize = procedure; stdcall;
  TMAPIAllocateBuffer = function(cbSize: ULONG; var lppBuffer: pointer): SCODE; stdcall;
  TMAPIAllocateMore = function(cbSize: ULONG; lpObject: pointer; var lppBuffer: pointer): SCODE; stdcall;
  TMAPIFreeBuffer = function(lpBuffer: pointer): ULONG; stdcall;
  // Note: This declaration of OpenIMsgOnIStg has been hacked to remove dependencies on MAPI structures.
  TOpenIMsgOnIStg = function(lpMsgSess: pointer; lpAllocateBuffer: pointer;
    lpAllocateMore: pointer; lpFreeBuffer: pointer; lpMalloc: pointer;
    lpMapiSup: pointer; lpStg: IStorage; lpfMsgCallRelease: pointer;
    ulCallerData: ULONG; ulFlags: ULONG; out lppMsg: IUnknown): SCODE; stdcall;

var
  MAPIGetDefaultMalloc: TMAPIGetDefaultMalloc = nil;
  MAPIInitialize: TMAPIInitialize = nil;
  MAPIUninitialize: TMAPIUninitialize = nil;
  MAPIAllocateBuffer: TMAPIAllocateBuffer = nil;
  MAPIAllocateMore: TMAPIAllocateMore = nil;
  MAPIFreeBuffer: TMAPIFreeBuffer = nil;
  OpenIMsgOnIStg: TOpenIMsgOnIStg = nil;

var
  MAPI32: HMODULE = 0;

const
  MAPI32DLL = 'mapi32.dll';

procedure LoadMAPI32;

  procedure GetProc(const Name: string; var Func: pointer);
  begin
    Func := GetProcAddress(MAPI32, PChar(Name));
    if (Func = nil) then
      raise Exception.CreateFmt('Failed to get %s entry point for %s: %s',
        [MAPI32DLL, Name, SysErrorMessage(GetLastError)]);
  end;

begin
  if (MAPI32 = 0) then
  begin
    MAPI32 := SafeLoadLibrary(MAPI32DLL);
    if (MAPI32 <= HINSTANCE_ERROR) then
      raise Exception.CreateFmt('%s: %s', [SysErrorMessage(GetLastError), MAPI32DLL]);
    GetProc('MAPIGetDefaultMalloc@0', @MAPIGetDefaultMalloc);
    GetProc('MAPIInitialize', @MAPIInitialize);
    GetProc('MAPIUninitialize', @MAPIUninitialize);
    GetProc('MAPIAllocateBuffer', @MAPIAllocateBuffer);
    GetProc('MAPIAllocateMore', @MAPIAllocateMore);
    GetProc('MAPIFreeBuffer', @MAPIFreeBuffer);
    GetProc('OpenIMsgOnIStg@44', @OpenIMsgOnIStg);
  end;
end;

(*
function MAPIGetDefaultMalloc: pointer; stdcall; external 'mapi32.dll' name 'MAPIGetDefaultMalloc@0';
function MAPIInitialize(lpMapiInit: pointer): HResult; stdcall; external 'mapi32.dll';
procedure MAPIUninitialize; stdcall; external 'mapi32.dll';
function MAPIAllocateBuffer(cbSize: ULONG; var lppBuffer: pointer): SCODE; stdcall; external 'mapi32.dll';
function MAPIAllocateMore(cbSize: ULONG; lpObject: pointer; var lppBuffer: pointer): SCODE; stdcall; external 'mapi32.dll';
function MAPIFreeBuffer(lpBuffer: pointer): ULONG; stdcall; external 'mapi32.dll';

// Note: This declaration of OpenIMsgOnIStg has been hacked to remove dependencies on other structures.
function OpenIMsgOnIStg (
  lpMsgSess: pointer;                  { -> message session obj (optional) }
  lpAllocateBuffer: pointer;           { -> AllocateBuffer memory routine  }
  lpAllocateMore: pointer;             { -> AllocateMore memory routine    }
  lpFreeBuffer: pointer;               { -> FreeBuffer memory routine      }
  lpMalloc: pointer;                   { -> Co malloc object               }
  lpMapiSup: pointer;                  { -> MAPI Support Obj (optional)    }
  lpStg : IStorage;                    { -> open IStorage containing msg   }
  lpfMsgCallRelease: pointer;          { -> release callback rtn (opt) }
  ulCallerData: ULONG;                { caller data returned in callback  }
  ulFlags: ULONG;                     { -> flags (controls istg commit)   }
  out lppMsg: IUnknown): SCODE; stdcall; external 'mapi32.dll' name 'OpenIMsgOnIStg@44';
                                       { <- open message object            }
*)

function TMessages.GetMessage(Index: integer): IUnknown;
var
  i: integer;
begin
  if (FStorages.Count <> FMessages.Count) then
  begin
    FMessages.Capacity := FStorages.Count;
    for i := 0 to FStorages.Count-1 do
      FMessages.Add(nil);
  end;

  if (FMessages[Index] = nil) then
  begin
    LoadMAPI32;
    // Get IMessage from IStorage
    OleCheck(OpenIMsgOnIStg(nil,
      @MAPIAllocateBuffer,
      @MAPIAllocateMore,
      @MAPIFreeBuffer,
      MapiGetDefaultMalloc,
      nil,
      FStorages[Index],
      nil, 0, 0,
      Result));
    FMessages[Index] := Result;
  end else
    Result := FMessages[Index];
end;

{ TOutlookDataFormat }

procedure TOutlookDataFormat.Clear;
begin
  inherited Clear;
  FMessages.Clear;
end;

constructor TOutlookDataFormat.Create(AOwner: TDragDropComponent);
begin
  inherited Create(AOwner);
  FMessages := TMessages.Create(Storages);
end;

destructor TOutlookDataFormat.Destroy;
begin
  inherited Destroy;
  FMessages.Free;
end;


////////////////////////////////////////////////////////////////////////////////
//
//		TDropURLTarget
//
////////////////////////////////////////////////////////////////////////////////

constructor TDropURLTarget.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DragTypes := [dtCopy, dtLink];
  GetDataOnEnter := True;

  FURLFormat := TURLDataFormat.Create(Self);
end;

destructor TDropURLTarget.Destroy;
begin
  FURLFormat.Free;
  inherited Destroy;
end;

function TDropURLTarget.GetTitle: string;
begin
  Result := FURLFormat.Title;
end;

function TDropURLTarget.GetURL: string;
begin
  Result := FURLFormat.URL;
end;

function TDropURLTarget.GetPreferredDropEffect: LongInt;
begin
  Result := GetPreferredDropEffect;
  if (Result = DROPEFFECT_NONE) then
    Result := DROPEFFECT_LINK;
end;

////////////////////////////////////////////////////////////////////////////////
//
//		TDropURLSource
//
////////////////////////////////////////////////////////////////////////////////
constructor TDropURLSource.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DragTypes := [dtCopy, dtLink];
  PreferredDropEffect := DROPEFFECT_LINK;

  FURLFormat := TURLDataFormat.Create(Self);
end;

destructor TDropURLSource.Destroy;
begin
  FURLFormat.Free;
  inherited Destroy;
end;

function TDropURLSource.GetTitle: string;
begin
  Result := FURLFormat.Title;
end;

procedure TDropURLSource.SetTitle(const Value: string);
begin
  FURLFormat.Title := Value;
end;

function TDropURLSource.GetURL: string;
begin
  Result := FURLFormat.URL;
end;

procedure TDropURLSource.SetURL(const Value: string);
begin
  FURLFormat.URL := Value;
end;


////////////////////////////////////////////////////////////////////////////////
//
//		Initialization/Finalization
//
////////////////////////////////////////////////////////////////////////////////

initialization
  // Data format registration
  TURLDataFormat.RegisterDataFormat;
  THTMLDataFormat.RegisterDataFormat;
  TOutlookDataFormat.RegisterDataFormat;
  
  // Clipboard format registration
  TURLDataFormat.RegisterCompatibleFormat(TNetscapeBookmarkClipboardFormat, 0, csSourceTarget, [ddRead]);
  TURLDataFormat.RegisterCompatibleFormat(TNetscapeImageClipboardFormat, 1, csSourceTarget, [ddRead]);
  TURLDataFormat.RegisterCompatibleFormat(TFileGroupDescritorClipboardFormat, 2, csSourceTarget, [ddRead]);
  TURLDataFormat.RegisterCompatibleFormat(TFileGroupDescritorWClipboardFormat, 2, csSourceTarget, [ddRead]);
  TURLDataFormat.RegisterCompatibleFormat(TFileContentsClipboardFormat, 3, csSourceTarget, [ddRead]);
  TURLDataFormat.RegisterCompatibleFormat(TURLClipboardFormat, 4, csSourceTarget, [ddRead]);
  TURLDataFormat.RegisterCompatibleFormat(TTextClipboardFormat, 5, csSourceTarget, [ddRead]);
  TURLDataFormat.RegisterCompatibleFormat(TFileClipboardFormat, 6, [csTarget], [ddRead]);

  THTMLDataFormat.RegisterCompatibleFormat(THTMLClipboardFormat, 0, csSourceTarget, [ddRead]);

  TTextDataFormat.RegisterCompatibleFormat(TRFC822ClipboardFormat, 1, csSourceTarget, [ddRead]);
  TTextDataFormat.RegisterCompatibleFormat(THTMLClipboardFormat, 2, csSourceTarget, [ddRead]);

  TOutlookDataFormat.RegisterCompatibleFormat(TFileContentsStorageClipboardFormat, 0, [csTarget], [ddRead]);

finalization
  // Clipboard format unregistration
  TNetscapeBookmarkClipboardFormat.UnregisterClipboardFormat;
  TNetscapeImageClipboardFormat.UnregisterClipboardFormat;
  TURLClipboardFormat.UnregisterClipboardFormat;
  TVCardClipboardFormat.UnregisterClipboardFormat;
  THTMLClipboardFormat.UnregisterClipboardFormat;
  TRFC822ClipboardFormat.UnregisterClipboardFormat;

  // Target format unregistration
  TURLDataFormat.UnregisterDataFormat;
  TOutlookDataFormat.UnregisterDataFormat;
end.

