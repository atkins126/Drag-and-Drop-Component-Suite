{++

  m a p i x . p a s

  Abstract:

    Automatic conversion of mapix.h.

  Comments:

    This source file automatically converted by
    htrans 0.91 beta 1 Copyright (c) 1997 Alexander Staubo

  Revision history:

    18-06-1997 20:53 alex  [Autogenerated]
    18-06-1997 20:53 alex  Retouched for release

--}

unit MapiX;

interface

uses
  Windows, SysUtils, ActiveX,
  MapiGuid, MapiDefs;

(*
 *  M A P I X . H
 *  
 *  Definitions of objects/flags, etc used by Extended MAPI.
 *  
 *  Copyright 1986-1996 Microsoft Corporation. All Rights Reserved.
 *)

{ ------------------------------------------------------ }

{ shared with simple mapi }

type
  TFLAGS = ULONG;
  
{ MAPILogon() flags.       }

const
  MAPI_LOGON_UI = $00000001            { Display logon UI                 }
  ;
  MAPI_NEW_SESSION = $00000002         { Don't use shared session         }
  ;
  MAPI_ALLOW_OTHERS = $00000008        { Make this a shared session       }
  ;
  MAPI_EXPLICIT_PROFILE = $00000010    { Don't use default profile        }
  ;
  MAPI_EXTENDED = $00000020            { Extended MAPI Logon              }
  ;
  MAPI_FORCE_DOWNLOAD = $00001000      { Get new mail before return       }
  ;
  MAPI_SERVICE_UI_ALWAYS = $00002000   { Do logon UI in all providers     }
  ;
  MAPI_NO_MAIL = $00008000             { Do not activate transports       }
  ;

{ #define MAPI_NT_SERVICE          0x00010000  Allow logon from an NT service  }

const
  MAPI_PASSWORD_UI = $00020000         { Display password UI only         }
  ;

  MAPI_TIMEOUT_SHORT = $00100000       { Minimal wait for logon resources }
  ;
  MAPI_SIMPLE_DEFAULT = MAPI_LOGON_UI or MAPI_FORCE_DOWNLOAD or MAPI_ALLOW_OTHERS;
  MAPI_SIMPLE_EXPLICIT = MAPI_NEW_SESSION or MAPI_FORCE_DOWNLOAD or MAPI_EXPLICIT_PROFILE;

{ Structure passed to MAPIInitialize(), and its ulFlags values }

type
  TMAPIINIT_0 =     
    record
      ulVersion : ULONG;
      ulFlags : ULONG;
    end;
  
  PMAPIINIT_0 = ^TMAPIINIT_0;
  
  TMAPIINIT = TMAPIINIT_0;
  
  PMAPIINIT = ^TMAPIINIT;
  
const
  MAPI_INIT_VERSION = 0;
  MAPI_MULTITHREAD_NOTIFICATIONS = $00000001;

{ Reserved for MAPI                    0x40000000 }

{ #define MAPI_NT_SERVICE              0x00010000  Use from NT service }

{ IMAPISession Interface -------------------------------------------------- }

{ Flags for OpenEntry and others }

{#define MAPI_MODIFY               ((ULONG) 0x00000001) }

{ Flags for Logoff }

const
  MAPI_LOGOFF_SHARED = $00000001       { Close all shared sessions    }
  ;
  MAPI_LOGOFF_UI = $00000002           { It's OK to present UI        }
  ;

{ Flags for SetDefaultStore. They are mutually exclusive. }

const
  MAPI_DEFAULT_STORE = $00000001       { for incoming messages }
  ;
  MAPI_SIMPLE_STORE_TEMPORARY = $00000002
                                       { for simple MAPI and CMC }
  ;
  MAPI_SIMPLE_STORE_PERMANENT = $00000003
                                       { for simple MAPI and CMC }
  ;
  MAPI_PRIMARY_STORE = $00000004       { Used by some clients }
  ;
  MAPI_SECONDARY_STORE = $00000005     { Used by some clients }
  ;

{ Flags for ShowForm. }

const
  MAPI_POST_MESSAGE = $00000001        { Selects post/send semantics }
  ;
  MAPI_NEW_MESSAGE = $00000002         { Governs copying during submission }
  ;

{  MessageOptions }

{***** MAPI_UNICODE            ((ULONG) 0x80000000) }

{  QueryDefaultMessageOpt }

{***** MAPI_UNICODE            ((ULONG) 0x80000000) }

{ IAddrBook Interface ----------------------------------------------------- }

{  CreateOneOff }

{***** MAPI_UNICODE            ((ULONG) 0x80000000) }

{***** MAPI_SEND_NO_RICH_INFO      ((ULONG) 0x00010000) }

{  RecipOptions }

{***** MAPI_UNICODE            ((ULONG) 0x80000000) }

{  QueryDefaultRecipOpt }

{***** MAPI_UNICODE            ((ULONG) 0x80000000) }

{  GetSearchPath }

{***** MAPI_UNICODE            ((ULONG) 0x80000000) }

{ IMsgServiceAdmin Interface ---------------------------------------------- }

{ Values for PR_RESOURCE_FLAGS in message service table }

const
  SERVICE_DEFAULT_STORE = $00000001;
  SERVICE_SINGLE_COPY = $00000002;
  SERVICE_CREATE_WITH_STORE = $00000004;
  SERVICE_PRIMARY_IDENTITY = $00000008;
  SERVICE_NO_PRIMARY_IDENTITY = $00000020;

{  GetMsgServiceTable }

{***** MAPI_UNICODE            ((ULONG) 0x80000000) }

{  GetProviderTable }

{***** MAPI_UNICODE            ((ULONG) 0x80000000) }

{ IProfAdmin Interface ---------------------------------------------------- }

{ Flags for CreateProfile }

const
  MAPI_DEFAULT_SERVICES = $00000001;

{ GetProfileTable }

{***** MAPI_UNICODE            ((ULONG) 0x80000000) }

{!! Interface declarations }

type
  IAddrBook = interface;
  IMsgServiceAdmin = interface;

  IMAPISession =
    interface(IUnknown)
    [strIID_IMAPISession]
      function GetLastError (hResult : HResult; ulFlags : ULONG;
        var lppMAPIError : PMAPIERROR) : HResult; stdcall;
      function GetMsgStoresTable (ulFlags : ULONG;
        out lppTable : IMAPITable) : HResult; stdcall;
      function OpenMsgStore (ulUIParam : ULONG; cbEntryID : ULONG;
        lpEntryID : PENTRYID; const lpInterface : TIID; ulFlags : ULONG;
        out lppMDB : IMsgStore) : HResult; stdcall;
      function OpenAddressBook (ulUIParam : ULONG; const lpInterface : TIID;
        ulFlags : ULONG; out lppAdrBook : IAddrBook) : HResult; stdcall;
      function OpenProfileSection (lpUID : PMAPIUID; const lpInterface : TIID;
        ulFlags : ULONG; out lppProfSect : IProfSect) : HResult; stdcall;
      function GetStatusTable (ulFlags : ULONG;
        out lppTable : IMAPITable) : HResult; stdcall;
      function OpenEntry (cbEntryID : ULONG; lpEntryID : PENTRYID;
        const lpInterface : TIID; ulFlags : ULONG; var lpulObjType : ULONG;
        out lppUnk : IUnknown) : HResult; stdcall;
      function CompareEntryIDs (cbEntryID1 : ULONG; lpEntryID1 : PENTRYID;
        cbEntryID2 : ULONG; lpEntryID2 : PENTRYID; ulFlags : ULONG;
        var lpulResult : ULONG) : HResult; stdcall;
      function Advise (cbEntryID : ULONG; lpEntryID : PENTRYID;
        ulEventMask : ULONG; lpAdviseSink : IMAPIAdviseSink;
        var lpulConnection : ULONG) : HResult; stdcall;
      function Unadvise (ulConnection : ULONG) : HResult; stdcall;
      function MessageOptions (ulUIParam : ULONG; ulFlags : ULONG;
        lpszAdrType : PChar; lpMessage : IMessage) : HResult; stdcall;
      function QueryDefaultMessageOpt (lpszAdrType : PChar; ulFlags : ULONG;
        var lpcValues : ULONG; var lppOptions : PSPropValue) : HResult; stdcall;
      function EnumAdrTypes (ulFlags : ULONG; var lpcAdrTypes : ULONG;
        var lpppszAdrTypes : PChar) : HResult; stdcall;
      function QueryIdentity (var lpcbEntryID : ULONG;
        var lppEntryID : PENTRYID) : HResult; stdcall;
      function Logoff (ulUIParam : ULONG; ulFlags : ULONG;
        ulReserved : ULONG) : HResult; stdcall;
      function SetDefaultStore (ulFlags : ULONG; cbEntryID : ULONG;
        lpEntryID : PENTRYID) : HResult; stdcall;
      function AdminServices (ulFlags : ULONG;
        out lppServiceAdmin : IMsgServiceAdmin) : HResult; stdcall;
      function ShowForm (ulUIParam : ULONG; lpMsgStore : IMsgStore;
        lpParentFolder : IMAPIFolder; const lpInterface : TIID;
        ulMessageToken : ULONG; lpMessageSent : IMessage; ulFlags : ULONG;
        ulMessageStatus : ULONG; ulMessageFlags : ULONG; ulAccess : ULONG;
        lpszMessageClass : LPSTR) : HResult; stdcall;
      function PrepareForm (const lpInterface : TIID; lpMessage : IMessage;
        var lpulMessageToken : ULONG) : HResult; stdcall;
    end;

  IAddrBook =
    interface(IMAPIProp)
    [strIID_IAddrBook]  
      function OpenEntry (cbEntryID : ULONG; lpEntryID : PENTRYID; const lpInterface : TIID;
        ulFlags : ULONG; var lpulObjType : ULONG; out lppUnk : IUnknown) : HResult; stdcall;
      function CompareEntryIDs (cbEntryID1 : ULONG; lpEntryID1 : PENTRYID; 
        cbEntryID2 : ULONG; lpEntryID2 : PENTRYID; ulFlags : ULONG; 
        var lpulResult : ULONG) : HResult; stdcall;
      function Advise (cbEntryID : ULONG; lpEntryID : PENTRYID; ulEventMask : ULONG; 
        lpAdviseSink : IMAPIAdviseSink; var lpulConnection : ULONG) : HResult; stdcall;
      function Unadvise (ulConnection : ULONG) : HResult; stdcall;
      function CreateOneOff (lpszName : PChar; lpszAdrType : PChar;
        lpszAddress : PChar; ulFlags : ULONG; var lpcbEntryID : ULONG;
        var lppEntryID : PENTRYID) : HResult; stdcall;
      function NewEntry (ulUIParam : ULONG; ulFlags : ULONG; cbEIDContainer : ULONG; 
        lpEIDContainer : PENTRYID; cbEIDNewEntryTpl : ULONG; 
        lpEIDNewEntryTpl : PENTRYID; var lpcbEIDNewEntry : ULONG; 
        var lppEIDNewEntry : PENTRYID) : HResult; stdcall;
      function ResolveName (ulUIParam : ULONG; ulFlags : ULONG;
        lpszNewEntryTitle : PChar; lpAdrList : PADRLIST) : HResult; stdcall;
      function Address (var lpulUIParam : ULONG; lpAdrParms : PADRPARM; 
        var lppAdrList : PADRLIST) : HResult; stdcall;
      function Details (var lpulUIParam : ULONG; lpfnDismiss : PFNDISMISS; 
        lpvDismissContext : Pointer; cbEntryID : ULONG; lpEntryID : PENTRYID; 
        lpfButtonCallback : PFNBUTTON; lpvButtonContext : Pointer; 
        lpszButtonText : PChar; ulFlags : ULONG) : HResult; stdcall;
      function RecipOptions (ulUIParam : ULONG; ulFlags : ULONG;
        lpRecip : PADRENTRY) : HResult; stdcall;
      function QueryDefaultRecipOpt (lpszAdrType : PChar; ulFlags : ULONG;
        var lpcValues : ULONG; var lppOptions : PSPropValue) : HResult; stdcall;
      function GetPAB (var lpcbEntryID : ULONG;
        var lppEntryID : PENTRYID) : HResult; stdcall;
      function SetPAB (cbEntryID : ULONG;
        lpEntryID : PENTRYID) : HResult; stdcall;
      function GetDefaultDir (var lpcbEntryID : ULONG;
        var lppEntryID : PENTRYID) : HResult; stdcall;
      function SetDefaultDir (cbEntryID : ULONG;
        lpEntryID : PENTRYID) : HResult; stdcall;
      function GetSearchPath (ulFlags : ULONG;
        var lppSearchPath : PSRowSet) : HResult; stdcall;
      function SetSearchPath (ulFlags : ULONG;
        lpSearchPath : PSRowSet) : HResult; stdcall;
      function PrepareRecips (ulFlags : ULONG; lpPropTagArray : PSPropTagArray;
        lpRecipList : PADRLIST) : HResult; stdcall;
    end;

  IProfAdmin =
    interface(IUnknown)
    [strIID_IProfAdmin]
      function GetLastError (hResult : HResult; ulFlags : ULONG;
        var lppMAPIError : PMAPIERROR) : HResult; stdcall;
      function GetProfileTable (ulFlags : ULONG; out lppTable : IMAPITable) : HResult; stdcall;
      function CreateProfile (lpszProfileName : PChar; lpszPassword : PChar; 
        ulUIParam : ULONG; ulFlags : ULONG) : HResult; stdcall;
      function DeleteProfile (lpszProfileName : PChar; ulFlags : ULONG) : HResult; stdcall;
      function ChangeProfilePassword (lpszProfileName : PChar; 
        lpszOldPassword : PChar; lpszNewPassword : PChar; ulFlags : ULONG) : HResult; stdcall;
      function CopyProfile (lpszOldProfileName : PChar; lpszOldPassword : PChar; 
        lpszNewProfileName : PChar; ulUIParam : ULONG; ulFlags : ULONG) : HResult; stdcall;
      function RenameProfile (lpszOldProfileName : PChar; lpszOldPassword : PChar; 
        lpszNewProfileName : PChar; ulUIParam : ULONG; ulFlags : ULONG) : HResult; stdcall;
      function SetDefaultProfile (lpszProfileName : PChar; ulFlags : ULONG) : HResult; stdcall;
      function AdminServices (lpszProfileName : PChar; lpszPassword : PChar; 
        ulUIParam : ULONG; ulFlags : ULONG; out lppServiceAdmin : IMsgServiceAdmin) : HResult; stdcall;
    end;

  IMsgServiceAdmin =
    interface(IUnknown)
    [strIID_IMsgServiceAdmin]
      function GetLastError (hResult : HResult; ulFlags : ULONG;
        var lppMAPIError : PMAPIERROR) : HResult; stdcall;
      function GetMsgServiceTable (ulFlags : ULONG; out lppTable : IMAPITable) : HResult; stdcall;
      function CreateMsgService (lpszService : PChar; lpszDisplayName : PChar; 
        ulUIParam : ULONG; ulFlags : ULONG) : HResult; stdcall;
      function DeleteMsgService (lpUID : PMAPIUID) : HResult; stdcall;
      function CopyMsgService (lpUID : PMAPIUID; lpszDisplayName : PChar; 
        const lpInterfaceToCopy : TIID; const lpInterfaceDst : TIID;
        lpObjectDst : Pointer; ulUIParam : ULONG;
        ulFlags : ULONG) : HResult; stdcall;
      function RenameMsgService (lpUID : PMAPIUID; ulFlags : ULONG; 
        lpszDisplayName : PChar) : HResult; stdcall;
      function ConfigureMsgService (lpUID : PMAPIUID; ulUIParam : ULONG; 
        ulFlags : ULONG; cValues : ULONG; lpProps : PSPropValue) : HResult; stdcall;
      function OpenProfileSection (lpUID : PMAPIUID; const lpInterface : TIID;
        ulFlags : ULONG; out lppProfSect : IProfSect) : HResult; stdcall;
      function MsgServiceTransportOrder (cUID : ULONG; lpUIDList : PMAPIUID; 
        ulFlags : ULONG) : HResult; stdcall;
      function AdminProviders (lpUID : PMAPIUID; ulFlags : ULONG;
        out lppProviderAdmin : IProviderAdmin) : HResult; stdcall;
      function SetPrimaryIdentity (lpUID : PMAPIUID; ulFlags : ULONG) : HResult; stdcall;
      function GetProviderTable (ulFlags : ULONG; out lppTable : IMAPITable) : HResult; stdcall;
    end;

{!! These functions have been converted from being dynamically bound variables
  to statically bound externals }

{ MAPI base functions }

function MAPIInitialize (lpMapiInit : Pointer) : HResult; stdcall;
procedure MAPIUninitialize; stdcall;

{  Extended MAPI Logon function }

function MAPILogonEx (ulUIParam : ULONG; lpszProfileName : PChar;
  lpszPassword : PChar; ulFlags : ULONG; {  ulFlags takes all that SimpleMAPI does + MAPI_UNICODE }
  out lppSession : IMAPISession) : HResult; stdcall;

function MAPIAllocateBuffer (cbSize : ULONG;
  var lppBuffer : Pointer) : SCODE; stdcall;

function MAPIAllocateMore (cbSize : ULONG; lpObject : Pointer;
  var lppBuffer : Pointer) : SCODE; stdcall;

function MAPIFreeBuffer (lpBuffer : Pointer) : ULONG; stdcall;

function MAPIAdminProfiles (ulFlags : ULONG;
  out lppProfAdmin : IProfAdmin) : HResult; stdcall;

implementation

const
  Mapi32Dll = 'mapi32.dll';

function MAPIInitialize; external Mapi32Dll;
procedure MAPIUninitialize; external Mapi32Dll;
function MAPILogonEx; external Mapi32Dll;
function MAPIAllocateBuffer; external Mapi32Dll;
function MAPIAllocateMore; external Mapi32Dll;
function MAPIFreeBuffer; external Mapi32Dll;
function MAPIAdminProfiles; external Mapi32Dll;

end.

