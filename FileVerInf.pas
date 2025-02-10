{
  ************************************************************************************
  *                                                                                  *
  *															FileVersionInfo V1.0                                 *
  *                                                                                  *
  ************************************************************************************
  *	Copyright 2002, mcTech - Ural Gunaydin All Rights Reserved.       			       	 *
  *                                                                                  *
  *		File:       FileVerInfo.pas                                                    *
  *		Content:    FileVersionInfo Component unit file                                *
  *                                                                                  *
  *		Created by Ural Gunaydin                                                       *
  *                                                                                  *
  *		E-mail: uralg@ncable.net.au                                                    *
  *                                                                                  *
  ************************************************************************************
  * DISCLAIMER:                                                                      *
  * I will not except any responsibility if FileVersionInfo cause any damage to your *
  *	system. They are not necessarily will work on every system. I have    		       *
  * tested with WIN98 and WIN NT/2000, and got no problem at all. Please take        *
  *	a precaution and debug them first. Or run supplied exe file to test if           *
  *	everything OK.                                                                   *
  *																																					       	 *
  *	FileVersionInfo is free to use, modify or delete! If you mention my name in your *
  *	programs I'll be very happy.                                                     *
  *	Thank you.                                                                       *
  *																																						       *
  *	Ural Gunaydin.                                                                   *
  *																																					      	 *
  *********************************************************************************** }

UNIT FileVerInf;

{$ifdef RELEASE}
{$A+,B-,C-,D-,E-,F-,G+,H+,I+,J+,K-,L-,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y-,Z1}
{$else}
{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O-,P+,Q+,R+,S-,T-,U-,V+,W+,X+,Y+,Z1}
{$endif}

INTERFACE

USES
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Dialogs;

TYPE
  PLangAndCP = ^TLangAndCP;

  TLangAndCP = PACKED RECORD
    WLanguage: WORD;
    WCodePage: WORD;
  END;

  TFileVersionInfo = CLASS(TComponent)
  PRIVATE
    FVerFileName: TFileName;
    UiHandle, UiTranslate: UINT;
    PVerInfoBlock: PChar;
    PTranslateLCP: PLangAndCP;
    FVerFileCPID, FVerFileLangID: DWORD;

    FUNCTION GetVerFileInfoBlock: BOOL;
    FUNCTION GetVerFileInfoBlockStr(index: Integer): STRING;
    FUNCTION GetVerFileInfoBlockSize: DWORD;
    FUNCTION GetStrVerFileCP: STRING;
    FUNCTION GetStrVerFileLang: STRING;
    FUNCTION GetTranslateLCP: BOOL;

    FUNCTION GetVerFileName: TFileName;
    PROCEDURE SetVerFileName(Value: TFileName);

    PROPERTY VerFileInfoBlock: BOOL READ GetVerFileInfoBlock;
    PROPERTY VerFileInfoBlockSize: DWORD READ GetVerFileInfoBlockSize;
    PROPERTY TranslateLCP: BOOL READ GetTranslateLCP;

  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    DESTRUCTOR Destroy; OVERRIDE;

    { Code page string e.g. 1252 (ANSI - Latin I) }
    PROPERTY StrVerFileCP: STRING READ GetStrVerFileCP;
    { Language string English (Australia) }
    PROPERTY StrVerFileLang: STRING READ GetStrVerFileLang;
    { Comments string }
    PROPERTY StrVerFileComments: STRING INDEX 0 READ GetVerFileInfoBlockStr;
    { Company name string }
    PROPERTY StrVerFileCompanyName: STRING INDEX 1 READ GetVerFileInfoBlockStr;
    { File Description string }
    PROPERTY StrVerFileDescription: STRING INDEX 2 READ GetVerFileInfoBlockStr;
    { File Version string }
    PROPERTY StrVerFileVersion: STRING INDEX 3 READ GetVerFileInfoBlockStr;
    { Internal name string }
    PROPERTY StrVerFileInternalName: STRING INDEX 4 READ GetVerFileInfoBlockStr;
    { Copyright information string }
    PROPERTY StrVerFileCopyright: STRING INDEX 5 READ GetVerFileInfoBlockStr;
    { Trademarks information string }
    PROPERTY StrVerFileTrademarks: STRING INDEX 6 READ GetVerFileInfoBlockStr;
    { Original file name string }
    PROPERTY StrVerFileOriginalFilename: STRING INDEX 7 READ GetVerFileInfoBlockStr;
    { Product name string }
    PROPERTY StrVerFileProductName: STRING INDEX 8 READ GetVerFileInfoBlockStr;
    { Product version string }
    PROPERTY StrVerFileProductVersion: STRING INDEX 9 READ GetVerFileInfoBlockStr;
    { Private build information string }
    PROPERTY StrVerFilePrivateBuild: STRING INDEX 10 READ GetVerFileInfoBlockStr;
    { Special build information string }
    PROPERTY StrVerFileSpecialBuild: STRING INDEX 11 READ GetVerFileInfoBlockStr;

    { File's CodePage ID }
    PROPERTY VerFileCPID: DWORD READ FVerFileCPID;
    { File's Language ID }
    PROPERTY VerFileLangID: DWORD READ FVerFileLangID;

  PUBLISHED
    { Name of the file }
    PROPERTY VerFileName: TFileName READ GetVerFileName WRITE SetVerFileName;

  END;

  { Hacked from mcConst.pas }
FUNCTION GetLastErrorMsg(CONST Msg: STRING = ''): STRING;

IMPLEMENTATION

{ ******* Support functions, variables and other declarations ******** }
TYPE
  // Hacked from Winnls.h for use by GetCPInfoEx()
  _cpinfoex = PACKED RECORD
    MaxCharSize: UINT;
    DefaultChar: ARRAY [0 .. MAX_DEFAULTCHAR - 1] OF BYTE;
    LeadByte: ARRAY [0 .. MAX_LEADBYTES - 1] OF BYTE;
    UnicodeDefaultChar: WCHAR;
    CodePage: UINT;
    CodePageName: ARRAY [0 .. MAX_PATH - 1] OF Char;
  END;

  CPINFOEX = _cpinfoex;
  LPCPINFOEX = ^_cpinfoex;
  TCPInfoEx = CPINFOEX;
  PCPInfoEx = LPCPINFOEX;

  TFNGetCPInfoEx = FUNCTION(CodePage: UINT; DwFlags: DWORD; LPCPINFOEX: PCPInfoEx): BOOL; STDCALL;

VAR
  _GetCPInfoEx: TFNGetCPInfoEx = NIL;

  { Following functions hacked from mcConst.pas.
    Please do not try to locate this file, coz, I wrote mcConst.pas
    If you downladed APITools component and demo program, you will find mcConst
    right there where you installed }

  // This function checks availibilty of API function in an MS API DLL
  // Parameters:
  // [in]		Lib32FileName : Name of the DLL file e.g. 'Kernel32.dll'
  // [in]		Api32FuncName : Name of the function to extract e.g. 'GetCPInfoExA'
  // [out]	Api32Func			: function type reference
FUNCTION IsApi32FuncExists(CONST Lib32FileName, Api32FuncName: STRING; VAR Api32Func: TFarProc): BOOL;
VAR
  HDLL: THandle;
BEGIN
  Result := False;
  Api32Func := NIL;
  HDLL := LoadLibrary(PChar(Lib32FileName));
  IF HDLL < 32 THEN // error loading .DLL
    Exit; // ??? do not raise exception, coz we want to use another version if possible
  Api32Func := GetProcAddress(HDLL, PChar(Api32FuncName));
  Result := Api32Func <> NIL;
  IF (HDLL >= 32) THEN // free the library if there is no error
    FreeLibrary(HDLL);
END;

// This function is a C macro,
// Hacked one of C header file but I can't remember which one was.
// Makes a language ID from Neutral and SubLanguage IDs

FUNCTION MAKELANGID(PrimaryLanguage, SubLanguage: WORD): WORD;
BEGIN
  Result := (SubLanguage SHL 10) OR PrimaryLanguage;
END;

// Get GetLastError() API error code function's string
FUNCTION GetLastErrorMsg(CONST Msg: STRING = ''): STRING;
VAR
  MsgBuffer: PChar;
  ErrorCode: DWORD;
BEGIN
  Result := '';
  ErrorCode := GetLastError();
  IF ErrorCode = NO_ERROR THEN // no error detected, so do nothing
    Exit;

  FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER OR FORMAT_MESSAGE_FROM_SYSTEM, NIL, ErrorCode,
    // Thats where we use MAKELANGID function
    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), @MsgBuffer, 0, NIL);
  TRY
    IF Msg <> '' THEN
      MessageDlg(Format('%s'#13'Code: %d'#13'Desc: %s', [Msg, ErrorCode, MsgBuffer]), MtError, [MbOK], 0)
    ELSE
      Result := Format('Error #%d - %s', [ErrorCode, MsgBuffer]);
  FINALLY
    LocalFree(Cardinal(MsgBuffer));
    { If you want to terminate program on fatal errors,
      uncomment the following line }
    // ExitProcess(ErrorCode);
  END;
END;

FUNCTION GetCPInfoEx(CodePage: UINT; DwFlags: DWORD; LPCPINFOEX: PCPInfoEx): BOOL; STDCALL;
BEGIN
  IF IsApi32FuncExists(Kernel32, 'GetCPInfoExA', @_GetCPInfoEx) THEN
    Result := _GetCPInfoEx(CodePage, DwFlags, LPCPINFOEX)
  ELSE
    Result := False;
END;

CONSTRUCTOR TFileVersionInfo.Create(AOwner: TComponent);
BEGIN
  FVerFileName := '';
  UiHandle := 0;
  UiTranslate := 0;
  PVerInfoBlock := NIL;
  PTranslateLCP := NIL;
  FVerFileCPID := 0;
  FVerFileLangID := 0;

  INHERITED Create(AOwner);
END;

DESTRUCTOR TFileVersionInfo.Destroy;
BEGIN
  IF Assigned(PVerInfoBlock) THEN
    PVerInfoBlock := NIL;

  IF Assigned(PTranslateLCP) THEN
    PTranslateLCP := NIL;

  INHERITED Destroy;
END;

// Get File's Code Page string
FUNCTION TFileVersionInfo.GetStrVerFileCP: STRING;
VAR
  LPCPINFOEX: PCPInfoEx;
  PCPInfo: TCPInfo;
BEGIN
  LPCPINFOEX := AllocMem(SizeOf(TCPInfoEx));
  TRY
    // Try GetCPInfoEx function first
    IF GetCPInfoEx(VerFileCPID, 0, LPCPINFOEX) THEN
      Result := LPCPINFOEX^.CodePageName
    ELSE
      // If GetCPInfoEx function not available or returns to an error
      // try GetCPInfo function
      IF GetCPInfo(VerFileCPID, PCPInfo) THEN
        Result := LoadStr(VerFileCPID)
      ELSE
        // If both GetCPInfoEx and GetCPInfo functions fails for some reason
        // return string 'Unicode'
        Result := 'Unicode';
  FINALLY
    FreeMem(LPCPINFOEX, SizeOf(TCPInfoEx));
  END;
END;

FUNCTION TFileVersionInfo.GetStrVerFileLang: STRING;
VAR
  LangName: ARRAY [0 .. 63] OF Char; // address of buffer for information
BEGIN
  IF VerLanguageName(VerFileLangID, LangName, SizeOf(LangName)) > 0 THEN
    Result := STRING(LangName)
  ELSE
    Result := GetLastErrorMsg;
END;

FUNCTION TFileVersionInfo.GetVerFileInfoBlock: BOOL;
BEGIN
  Result := False;
  PVerInfoBlock := AllocMem(VerFileInfoBlockSize);
  TRY
    Result := GetFileVersionInfo(PChar(VerFileName), 0, VerFileInfoBlockSize, PVerInfoBlock);
  EXCEPT
    // Do not free version information data here!!!! Unless an exception raises.
    FreeMem(PVerInfoBlock, VerFileInfoBlockSize);
  END;
END;

{ This function is the heart of the TFileVersionInfo component }
FUNCTION TFileVersionInfo.GetVerFileInfoBlockStr(index: Integer): STRING;
VAR
  PBuffer, PSubBlock: PChar;
  StSubBlock: STRING;
  UiBytes: UINT;
BEGIN
  FVerFileCPID := 0;
  FVerFileLangID := 0;

  // First, determine the size, in bytes, of a file's version information
  IF VerFileInfoBlockSize = 0 THEN
  BEGIN
    Result := GetLastErrorMsg;
    Exit; // DO NOT raise exception here!!!!!
  END;

  TRY
    // if the size correctly determined,
    // retrieve version information for the specified file
    IF NOT VerFileInfoBlock THEN
    BEGIN
      Result := GetLastErrorMsg;
      Exit; // DO NOT raise exception here!!!!!
    END;

    // Read the language and code page
    IF NOT TranslateLCP THEN
      RAISE Exception.Create(GetLastErrorMsg(''));

    // Read the file description for each language and code page
    { pSubBlock
      Pointer to a zero-terminated string specifying which version-information value to retrieve.
      The string must consist of names separated by backslashes (\) and it must have one of the following forms.

      \\
      Specifies the root block. The function retrieves a pointer to the
      VS_FIXEDFILEINFO structure for the version-information resource.

      \\VarFileInfo\\Translation
      Specifies the translation array in a Var variable information structure—
      the Value member of this structure. The function retrieves a pointer to this
      array of language and code page identifiers. An application can use
      these identifiers to access a language-specific StringTable structure
      (using the szKey member) in the version-information resource.

      \\StringFileInfo\\lang-codepage\\string-name
      Specifies a value in a language-specific StringTable structure.
      The lang-codepage name is a concatenation of a language and code page
      identifier pair found as a DWORD in the translation array for the resource.
      Here the lang-codepage name must be specified as a hexadecimal string.
      The string-name name must be one of the predefined strings described below.
      The function retrieves a string value specific to the language and code page indicated

      The following are predefined version information Unicode strings.

      Comments 				InternalName 			ProductName
      CompanyName 		LegalCopyright 		ProductVersion
      FileDescription LegalTrademarks 	PrivateBuild
      FileVersion 		OriginalFilename 	SpecialBuild }

    { The VerQueryValue function below, retrieves specified version information
      from the specified version-information resource (file) }

    CASE INDEX OF
      0:
        StSubBlock := 'Comments';
      1:
        StSubBlock := 'CompanyName';
      2:
        StSubBlock := 'FileDescription';
      3:
        StSubBlock := 'FileVersion';
      4:
        StSubBlock := 'InternalName';
      5:
        StSubBlock := 'LegalCopyright';
      6:
        StSubBlock := 'LegalTrademarks';
      7:
        StSubBlock := 'OriginalFilename';
      8:
        StSubBlock := 'ProductName';
      9:
        StSubBlock := 'ProductVersion';
      10:
        StSubBlock := 'PrivateBuild';
      11:
        StSubBlock := 'SpecialBuild';
    END;

    // Format string value for each version string information
    PSubBlock := PChar(Format('\StringFileInfo\%.4x%.4x\%s', [VerFileLangID, VerFileCPID, StSubBlock]));

    // Call VerQueryValue function to get version information for specified file
    IF VerQueryValue(PVerInfoBlock, PSubBlock, Pointer(PBuffer), UiBytes) AND (PBuffer <> NIL) THEN
      Result := STRING(PBuffer)
    ELSE
      Result := GetLastErrorMsg;
    // return empty string or GetLastErrorStr if function fails
    // MS Version Info Dialog returns empty string...
    // DO NOT raise exception here!!!!!
  FINALLY
    // Now free version information data. This also frees pTranslateLCP data block
    FreeMem(PVerInfoBlock, VerFileInfoBlockSize);
  END;
END;

FUNCTION TFileVersionInfo.GetVerFileInfoBlockSize: DWORD;
BEGIN
  Result := GetFileVersionInfoSize(PChar(VerFileName), UiHandle);
END;

FUNCTION TFileVersionInfo.GetVerFileName: TFileName;
BEGIN
  IF FVerFileName <> '' THEN
    Result := FVerFileName
  ELSE
    Result := ParamStr(0);
END;

PROCEDURE TFileVersionInfo.SetVerFileName(Value: TFileName);
BEGIN
  IF FVerFileName <> Value THEN
    FVerFileName := Value;
END;

{ Translate Language and code page ids and assign them to
  VerFileLangID and VerFileCPID properties }
FUNCTION TFileVersionInfo.GetTranslateLCP: BOOL;
BEGIN
  Result := VerQueryValue(PVerInfoBlock, '\VarFileInfo\Translation', Pointer(PTranslateLCP), UiTranslate);
  IF Result THEN
  BEGIN
    FVerFileCPID := PTranslateLCP^.WCodePage;
    FVerFileLangID := PTranslateLCP^.WLanguage;
  END
  ELSE
    PTranslateLCP := NIL;
END;

END.
