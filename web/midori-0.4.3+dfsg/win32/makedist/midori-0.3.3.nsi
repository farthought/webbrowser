;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copyright (C) 2009 Enrico Tröger <enrico(dot)troeger(at)uvena(dot)de>
;               2010-2011 Peter de Ridder <peter(at)xfce(dot)org>
;
; This library is free software; you can redistribute it and/or
; modify it under the terms of the GNU Lesser General Public
; License as published by the Free Software Foundation; either
; version 2.1 of the License, or (at your option) any later version.
;
; See the file COPYING for the full license text.
;
; Installer script for Midori (Windows Installer)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Do a Cyclic Redundancy Check to make sure the installer was not corrupted by the download
CRCCheck force
RequestExecutionLevel user ; set execution level for Windows Vista

;;;;;;;;;;;;;;;;;;;
; helper defines  ;
;;;;;;;;;;;;;;;;;;;
!define PRODUCT_NAME "Midori"
!define PRODUCT_VERSION "0.3.3"
!define PRODUCT_BUILD "0"
!define PRODUCT_VERSION_ID "${PRODUCT_VERSION}.${PRODUCT_BUILD}"
!define PRODUCT_PUBLISHER "Christian Dywan"
!define PRODUCT_WEB_SITE "http://www.twotoasts.de/"
!define PRODUCT_DIR_REGKEY "Software\${PRODUCT_NAME}"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_BROWER_KEY "Software\Clients\StartMenuInternet"
!define PRODUCT_EXE "$INSTDIR\bin\midori.exe"
!define UNINSTALL_EXE "$INSTDIR\uninst.exe"
!define RESOURCEDIR "midori-${PRODUCT_VERSION}"

;;;;;;;;;;;;;;;;;;;;;
; Version resource  ;
;;;;;;;;;;;;;;;;;;;;;
VIProductVersion "${PRODUCT_VERSION_ID}"
VIAddVersionKey "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey "FileVersion" "${PRODUCT_VERSION}"
VIAddVersionKey "ProductVersion" "${PRODUCT_VERSION}"
VIAddVersionKey "LegalCopyright" "Copyright 2009 by Christian Dywan"
VIAddVersionKey "FileDescription" "${PRODUCT_NAME} Installer"

BrandingText "$(^NAME) installer (NSIS ${NSIS_VERSION})"
InstallDir "$PROGRAMFILES\${PRODUCT_NAME}"
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
SetCompressor /SOLID lzma
ShowInstDetails hide
ShowUnInstDetails hide
XPStyle on
OutFile "${PRODUCT_NAME}-${PRODUCT_VERSION}_setup.exe"

Var Answer
Var UserName
Var StartmenuFolder
Var UNINSTDIR
Var DefaultBrowser

;;;;;;;;;;;;;;;;
; MUI Settings ;
;;;;;;;;;;;;;;;;
!include "MUI2.nsh"

!define MUI_ABORTWARNING
!define MUI_ICON "midori.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall-full.ico"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
;!define MUI_LICENSEPAGE_RADIOBUTTONS
!insertmacro MUI_PAGE_LICENSE "${RESOURCEDIR}\COPYING"
; Components page
!insertmacro MUI_PAGE_COMPONENTS
; Directory page
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE OnDirLeave
!insertmacro MUI_PAGE_DIRECTORY
; Start menu page
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "Midori"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
!insertmacro MUI_PAGE_STARTMENU ${PRODUCT_NAME} "$StartmenuFolder"
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN "${PRODUCT_EXE}"
!define MUI_FINISHPAGE_RUN_NOTCHECKED
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!insertmacro MUI_PAGE_FINISH

; Uninstaller page
!insertmacro MUI_UNPAGE_CONFIRM 
!insertmacro MUI_UNPAGE_INSTFILES 
!insertmacro MUI_UNPAGE_FINISH 

; Language file
!insertmacro MUI_LANGUAGE "English" 

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sections and InstTypes  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
InstType "Full"
InstType "Minimal"

Section "!Program Files" SEC01
	SectionIn RO 1 2
	SetOverwrite ifnewer

	SetOutPath "$INSTDIR"
	File "${RESOURCEDIR}\*"

	SetOutPath "$INSTDIR\bin"
	File /r "${RESOURCEDIR}\bin\*"

	SetOutPath "$INSTDIR\etc"
	File /r "${RESOURCEDIR}\etc\*"

	SetOutPath "$INSTDIR\lib"
	File /r /x "midori" "${RESOURCEDIR}\lib\*"

	SetOutPath "$INSTDIR\share"
	File /r /x "locale" /x "user" /x "Tango" "${RESOURCEDIR}\share\*"

	SetOutPath "$INSTDIR\share\icons\Tango"
	File "${RESOURCEDIR}\share\icons\Tango\index.theme"

	SetOutPath "$INSTDIR"
	CreateShortCut "$INSTDIR\Midori.lnk" "${PRODUCT_EXE}"

	!insertmacro MUI_STARTMENU_WRITE_BEGIN ${PRODUCT_NAME}
	CreateDirectory "$SMPROGRAMS\$StartmenuFolder"
	CreateShortCut "$SMPROGRAMS\$StartmenuFolder\Midori.lnk" "${PRODUCT_EXE}"
	!insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "Extensions" SEC04
	SectionIn 1
	SetOverwrite ifnewer
	SetOutPath "$INSTDIR\lib"
	File /r "${RESOURCEDIR}\lib\midori"
SectionEnd

Section "Language Files" SEC02
	SectionIn 1
	SetOutPath "$INSTDIR\share"
	File /r "${RESOURCEDIR}\share\locale"
SectionEnd

Section "FAQ" SEC06
	SectionIn 1
	SetOutPath "$INSTDIR\share\doc\midori"
	File "${RESOURCEDIR}\share\doc\midori\faq.css"
	File "${RESOURCEDIR}\share\doc\midori\faq.html"
SectionEnd

!macro InstallTangoIconRenameSmall OPath IPath
	File "/oname=16x16\${OPath}.png" "${RESOURCEDIR}\share\icons\Tango\16x16\${IPath}.png"
	File "/oname=22x22\${OPath}.png" "${RESOURCEDIR}\share\icons\Tango\22x22\${IPath}.png"
	File "/oname=32x32\${OPath}.png" "${RESOURCEDIR}\share\icons\Tango\32x32\${IPath}.png"
!macroend

!macro InstallTangoIconRename OPath IPath
	!insertmacro InstallTangoIconRenameSmall ${OPath} ${IPath}
	File "/oname=48x48\${OPath}.png" "${RESOURCEDIR}\share\icons\Tango\48x48\${IPath}.png"
	File /nonfatal "/oname=64x64\${OPath}.png" "${RESOURCEDIR}\share\icons\Tango\64x64\${IPath}.png"
	File /nonfatal "/oname=72x72\${OPath}.png" "${RESOURCEDIR}\share\icons\Tango\72x72\${IPath}.png"
	File /nonfatal "/oname=96x96\${OPath}.png" "${RESOURCEDIR}\share\icons\Tango\96x96\${IPath}.png"
	File /nonfatal "/oname=128x128\${OPath}.png" "${RESOURCEDIR}\share\icons\Tango\128x128\${IPath}.png"
	File "/oname=scalable\${OPath}.svg" "${RESOURCEDIR}\share\icons\Tango\scalable\${IPath}.svg"
	File /nonfatal "/oname=scalable\${OPath}.icon" "${RESOURCEDIR}\share\icons\Tango\scalable\${IPath}.icon"
!macroend

!macro InstallTangoIconSmall IconPath
	!insertmacro InstallTangoIconRenameSmall ${IconPath} ${IconPath}
!macroend

!macro InstallTangoIcon IconPath
	!insertmacro InstallTangoIconRename ${IconPath} ${IconPath}
!macroend

!macro CreateTangoSectionsSmall SectionPath
	CreateDirectory "$INSTDIR\share\icons\Tango\16x16\${SectionPath}"
	CreateDirectory "$INSTDIR\share\icons\Tango\22x22\${SectionPath}"
	CreateDirectory "$INSTDIR\share\icons\Tango\32x32\${SectionPath}"
!macroend

!macro CreateTangoSections SectionPath
	!insertmacro CreateTangoSectionsSmall ${SectionPath}
	CreateDirectory "$INSTDIR\share\icons\Tango\48x48\${SectionPath}"
	CreateDirectory "$INSTDIR\share\icons\Tango\64x64\${SectionPath}"
	CreateDirectory "$INSTDIR\share\icons\Tango\72x72\${SectionPath}"
	CreateDirectory "$INSTDIR\share\icons\Tango\96x96\${SectionPath}"
	CreateDirectory "$INSTDIR\share\icons\Tango\128x128\${SectionPath}"
	CreateDirectory "$INSTDIR\share\icons\Tango\scalable\${SectionPath}"
!macroend

Section "Tango icons" SEC07
	SectionIn 1
	SetOutPath "$INSTDIR\share\icons\Tango"

	!insertmacro CreateTangoSections "actions"
	!insertmacro CreateTangoSectionsSmall "animations"
	!insertmacro CreateTangoSections "apps"
	!insertmacro CreateTangoSections "categories"
	!insertmacro CreateTangoSections "devices"
	!insertmacro CreateTangoSections "emblems"
	!insertmacro CreateTangoSections "emotes"
	!insertmacro CreateTangoSections "mimetypes"
	!insertmacro CreateTangoSections "places"
	!insertmacro CreateTangoSections "status"

	!insertmacro InstallTangoIcon "actions\gtk-add"
	!insertmacro InstallTangoIcon "actions\gtk-bold"
	!insertmacro InstallTangoIcon "actions\gtk-cancel"
	!insertmacro InstallTangoIcon "actions\gtk-cancel"
	!insertmacro InstallTangoIcon "actions\gtk-clear"
	!insertmacro InstallTangoIcon "actions\gtk-copy"
	!insertmacro InstallTangoIcon "actions\gtk-cut"
	!insertmacro InstallTangoIcon "actions\gtk-delete"
	!insertmacro InstallTangoIcon "actions\gtk-find"
	!insertmacro InstallTangoIcon "actions\gtk-fullscreen"
	!insertmacro InstallTangoIcon "actions\gtk-go-back-ltr"
	!insertmacro InstallTangoIcon "actions\gtk-go-back-ltr"
	!insertmacro InstallTangoIcon "actions\gtk-go-down"
	!insertmacro InstallTangoIcon "actions\gtk-go-forward-ltr"
	!insertmacro InstallTangoIcon "actions\gtk-go-forward-ltr"
	!insertmacro InstallTangoIcon "actions\gtk-go-up"
	!insertmacro InstallTangoIcon "actions\gtk-goto-first-ltr"
	!insertmacro InstallTangoIcon "actions\gtk-goto-first-ltr"
	!insertmacro InstallTangoIcon "actions\gtk-goto-last-ltr"
	!insertmacro InstallTangoIcon "actions\gtk-goto-last-ltr"
	!insertmacro InstallTangoIcon "actions\gtk-home"
	!insertmacro InstallTangoIcon "actions\gtk-indent-ltr"
	!insertmacro InstallTangoIcon "actions\gtk-indent-rtl"
	!insertmacro InstallTangoIcon "actions\gtk-italic"
	!insertmacro InstallTangoIcon "actions\gtk-jump-to-ltr"
	!insertmacro InstallTangoIcon "actions\gtk-jump-to-ltr"
	!insertmacro InstallTangoIcon "actions\gtk-media-next-ltr"
	!insertmacro InstallTangoIcon "actions\gtk-media-next-rtl"
	!insertmacro InstallTangoIcon "actions\gtk-media-previous-ltr"
	!insertmacro InstallTangoIcon "actions\gtk-media-previous-rtl"
	!insertmacro InstallTangoIcon "actions\gtk-open"
	!insertmacro InstallTangoIcon "actions\gtk-paste"
	!insertmacro InstallTangoIcon "actions\gtk-print"
	!insertmacro InstallTangoIcon "actions\gtk-properties"
	!insertmacro InstallTangoIcon "actions\gtk-redo-ltr"
	!insertmacro InstallTangoIcon "actions\gtk-refresh"
	!insertmacro InstallTangoIcon "actions\gtk-remove"
	!insertmacro InstallTangoIcon "actions\gtk-save"
	!insertmacro InstallTangoIcon "actions\gtk-save-as"
	!insertmacro InstallTangoIcon "actions\gtk-select-all"
	!insertmacro InstallTangoIcon "actions\gtk-stop"
	!insertmacro InstallTangoIcon "actions\gtk-underline"
	!insertmacro InstallTangoIcon "actions\gtk-undo-ltr"
	!insertmacro InstallTangoIcon "actions\stock_add-bookmark"
	!insertmacro InstallTangoIcon "actions\stock_new-tab"
	!insertmacro InstallTangoIcon "actions\stock_new-window"
	!insertmacro InstallTangoIconSmall "animations\process-working"
	!insertmacro InstallTangoIcon "apps\gnome-settings-theme"
	!insertmacro InstallTangoIcon "apps\gtk-help"
	!insertmacro InstallTangoIcon "apps\terminal"
	!insertmacro InstallTangoIcon "apps\web-browser"
	!insertmacro InstallTangoIcon "categories\gtk-preferences"
	#!insertmacro InstallTangoIcon "cookie-manager"
	#!insertmacro InstallTangoIcon "document-open-recent"
	#!insertmacro InstallTangoIcon "extention"
	#!insertmacro InstallTangoIcon "feed-panel"
	#!insertmacro InstallTangoIcon "gtk-about"
	#!insertmacro InstallTangoIcon "gtk-close"
	#!insertmacro InstallTangoIcon "gtk-convert"
	#!insertmacro InstallTangoIcon "gtk-dialog-authentication"
	#!insertmacro InstallTangoIcon "gtk-dnd-multiple"
	#!insertmacro InstallTangoIcon "gtk-edit"
	#!insertmacro InstallTangoIcon "gtk-execute"
	#!insertmacro InstallTangoIcon "gtk-file"
	#!insertmacro InstallTangoIcon "gtk-index"
	#!insertmacro InstallTangoIcon "gtk-info"
	#!insertmacro InstallTangoIcon "gtk-ok"
	#!insertmacro InstallTangoIcon "gtk-orientation-portait"
	#!insertmacro InstallTangoIcon "gtk-quit"
	#!insertmacro InstallTangoIcon "gtk-select-color"
	#!insertmacro InstallTangoIcon "gtk-select-font"
	#!insertmacro InstallTangoIcon "gtk-sort-ascending"
	#!insertmacro InstallTangoIcon "gtk-spell-check"
	#!insertmacro InstallTangoIcon "gtk-undelete"
	#!insertmacro InstallTangoIcon "gtk-yes"
	#!insertmacro InstallTangoIcon "gtk-zoom-100"
	#!insertmacro InstallTangoIcon "gtk-zoom-in"
	#!insertmacro InstallTangoIcon "gtk-zoom-out"
	!insertmacro InstallTangoIcon "mimetypes\gnome-mime-application-x-shockwave-flash"
	!insertmacro InstallTangoIcon "mimetypes\gnome-mime-image"
	!insertmacro InstallTangoIcon "mimetypes\package"
	!insertmacro InstallTangoIcon "mimetypes\stock_script"
	!insertmacro InstallTangoIcon "mimetypes\vcard"
	#!insertmacro InstallTangoIcon "news-feed"
	#!insertmacro InstallTangoIcon "place-holder"
	!insertmacro InstallTangoIcon "places\gnome-stock-trash"
	!insertmacro InstallTangoIcon "places\gtk-directory"
	!insertmacro InstallTangoIcon "places\gtk-network"
	!insertmacro InstallTangoIcon "status\gtk-dialog-error"
	!insertmacro InstallTangoIcon "status\gtk-dialog-info"
	!insertmacro InstallTangoIcon "status\gtk-dialog-warning"
	!insertmacro InstallTangoIcon "status\gtk-missing-image"
	!insertmacro InstallTangoIcon "status\network-offline"
	#!insertmacro InstallTangoIcon "stock_bookmark"
	#!insertmacro InstallTangoIcon "stock_mail-send"
	#!insertmacro InstallTangoIcon "tab-panel"
SectionEnd

Section "Desktop Shortcuts" SEC03
	SectionIn 1
	CreateShortCut "$DESKTOP\Midori.lnk" "${PRODUCT_EXE}"
	CreateShortCut "$QUICKLAUNCH\Midori.lnk" "${PRODUCT_EXE}"
SectionEnd

Section "Default Browser" SEC05
	SectionIn 1
	StrCpy $DefaultBrowser "yes"
SectionEnd

Section -AdditionalIcons
	SetOutPath $INSTDIR
	!insertmacro MUI_STARTMENU_WRITE_BEGIN ${PRODUCT_NAME}
	WriteIniStr "$INSTDIR\Website.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
	CreateShortCut "$SMPROGRAMS\$StartmenuFolder\Website.lnk" "${PRODUCT_EXE}" \
		"${PRODUCT_WEB_SITE}" "${PRODUCT_EXE}"
	CreateShortCut "$SMPROGRAMS\$StartmenuFolder\Uninstall.lnk" "${UNINSTALL_EXE}"
	CreateShortCut "$SMPROGRAMS\$StartmenuFolder\Make Default.lnk" "${UNINSTALL_EXE}" \
		"/S /MAKEDEFAULT" "${PRODUCT_EXE}"
	!insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section -Post
	WriteUninstaller "${UNINSTALL_EXE}"
	WriteRegStr SHCTX "${PRODUCT_DIR_REGKEY}" Path "$INSTDIR"
	WriteRegStr SHCTX "${PRODUCT_UNINST_KEY}" "StartMenu" "$SMPROGRAMS\$StartmenuFolder"
	${if} $Answer == "yes" ; if user is admin
		WriteRegStr SHCTX "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
		WriteRegStr SHCTX "${PRODUCT_UNINST_KEY}" "UninstallString" "${UNINSTALL_EXE}"
		WriteRegStr SHCTX "${PRODUCT_UNINST_KEY}" "DisplayIcon" "${PRODUCT_EXE}"
		WriteRegStr SHCTX "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
		WriteRegStr SHCTX "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
		WriteRegStr SHCTX "${PRODUCT_UNINST_KEY}" "URLUpdateInfo" "${PRODUCT_WEB_SITE}"
		WriteRegStr SHCTX "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
		WriteRegDWORD SHCTX "${PRODUCT_UNINST_KEY}" "NoModify" 0x00000001
		WriteRegDWORD SHCTX "${PRODUCT_UNINST_KEY}" "NoRepair" 0x00000001

		WriteRegStr HKLM "${PRODUCT_BROWER_KEY}\MIDORI.EXE" "" "${PRODUCT_NAME}"
		WriteRegStr HKLM "${PRODUCT_BROWER_KEY}\MIDORI.EXE\DefaultIcon" "" "${PRODUCT_EXE},0"
		WriteRegStr HKLM "${PRODUCT_BROWER_KEY}\MIDORI.EXE\shell\open\command" "" "${PRODUCT_EXE}"
		WriteRegStr HKLM "${PRODUCT_BROWER_KEY}\MIDORI.EXE\InstallInfo" "HideIconsCommand" '"${UNINSTALL_EXE}" /S /HIDE'
		WriteRegDWORD HKLM "${PRODUCT_BROWER_KEY}\MIDORI.EXE\InstallInfo" "IconsVisible" 0x00000000
		WriteRegStr HKLM "${PRODUCT_BROWER_KEY}\MIDORI.EXE\InstallInfo" "ReinstallCommand" '"${UNINSTALL_EXE}" /S /MAKEDEFAULT'
		WriteRegStr HKLM "${PRODUCT_BROWER_KEY}\MIDORI.EXE\InstallInfo" "ShowIconsCommand" '"${UNINSTALL_EXE}" /S /SHOW'
	${endif}

	${if} $DefaultBrowser == "yes"
		${if} $Answer == "yes" ; if user is admin
			WriteRegDWORD HKLM "${PRODUCT_BROWER_KEY}\MIDORI.EXE\InstallInfo" "IconsVisible" 0x00000001
		${endif}
		WriteRegStr HKCU "${PRODUCT_BROWER_KEY}" "" "MIDORI.EXE"
		WriteRegStr HKCR "http\DefaultIcon" "" "${PRODUCT_EXE},0"
		WriteRegStr HKCR "http\shell\open\command" "" '${PRODUCT_EXE} "%1"'
		WriteRegStr HKCR "https\DefaultIcon" "" "${PRODUCT_EXE},0"
		WriteRegStr HKCR "https\shell\open\command" "" '${PRODUCT_EXE} "%1"'
	${endif}
SectionEnd

Section Uninstall
	Delete "$INSTDIR\Website.url"
	Delete "${UNINSTALL_EXE}"
	Delete "$INSTDIR\COPYING"
	Delete "$INSTDIR\AUTHORS"
	Delete "$INSTDIR\Midori.lnk"

	; delete start menu entry
	ReadRegStr $0 SHCTX "${PRODUCT_UNINST_KEY}" "StartMenu"
	RMDir /r "$0"

	Delete "$QUICKLAUNCH\Midori.lnk"
	Delete "$DESKTOP\Midori.lnk"

	RMDir /r "$INSTDIR\bin"
	RMDir /r "$INSTDIR\etc"
	RMDir /r "$INSTDIR\lib"
	RMDir /r "$INSTDIR\share"
	RMDir "$INSTDIR"

	DeleteRegKey SHCTX "${PRODUCT_UNINST_KEY}"
	DeleteRegKey HKCU "${PRODUCT_UNINST_KEY}"
	DeleteRegKey SHCTX "${PRODUCT_DIR_REGKEY}"
	DeleteRegKey HKCU "${PRODUCT_DIR_REGKEY}"
	DeleteRegKey HKLM "${PRODUCT_BROWER_KEY}\MIDORI.EXE"

	SetAutoClose true
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;
; Section descriptions  ;
;;;;;;;;;;;;;;;;;;;;;;;;;
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SEC01} "Required program files. You cannot skip these files."
!insertmacro MUI_DESCRIPTION_TEXT ${SEC02} "Various translations of Midori's interface."
!insertmacro MUI_DESCRIPTION_TEXT ${SEC03} "Create shortcuts for Midori on the desktop and in the Quicklaunch Bar"
!insertmacro MUI_DESCRIPTION_TEXT ${SEC04} "Available plugins like 'Advertisement Blocker', 'Form history filler' and 'Mouse Gestures'."
!insertmacro MUI_DESCRIPTION_TEXT ${SEC05} "Make Midori the default browser."
!insertmacro MUI_DESCRIPTION_TEXT ${SEC06} "User manual of the Midori application."
!insertmacro MUI_DESCRIPTION_TEXT ${SEC07} "Better looking icons from the Tango icon theme."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;;;;;;;;;;;;;;;;;;;;;
; helper functions  ;
;;;;;;;;;;;;;;;;;;;;;

; (from http://jabref.svn.sourceforge.net/viewvc/jabref/trunk/jabref/src/windows/nsis/setup.nsi)
!macro IsUserAdmin Result UName
	ClearErrors
	UserInfo::GetName
	IfErrors Win9x
	Pop $0
	StrCpy ${UName} $0
	UserInfo::GetAccountType
	Pop $1
	${if} $1 == "Admin"
		StrCpy ${Result} "yes"
	${else}
		StrCpy ${Result} "no"
	${endif}
	Goto done

Win9x:
	StrCpy ${Result} "yes"
done:
!macroend

; (from http://nsis.sourceforge.net/GetOptions)
Function un.GetOptions
	!define GetOptions `!insertmacro GetOptionsCall`
 
	!macro GetOptionsCall _PARAMETERS _OPTION _RESULT
		Push `${_PARAMETERS}`
		Push `${_OPTION}`
		Call un.GetOptions
		Pop ${_RESULT}
	!macroend
 
	Exch $1
	Exch
	Exch $0
	Exch
	Push $2
	Push $3
	Push $4
	Push $5
	Push $6
	Push $7
	ClearErrors
 
	StrCpy $2 $1 '' 1
	StrCpy $1 $1 1
	StrLen $3 $2
	StrCpy $7 0
 
	begin:
	StrCpy $4 -1
	StrCpy $6 ''
 
	quote:
	IntOp $4 $4 + 1
	StrCpy $5 $0 1 $4
	StrCmp $5$7 '0' notfound
	StrCmp $5 '' trimright
	StrCmp $5 '"' 0 +7
	StrCmp $6 '' 0 +3
	StrCpy $6 '"'
	goto quote
	StrCmp $6 '"' 0 +3
	StrCpy $6 ''
	goto quote
	StrCmp $5 `'` 0 +7
	StrCmp $6 `` 0 +3
	StrCpy $6 `'`
	goto quote
	StrCmp $6 `'` 0 +3
	StrCpy $6 ``
	goto quote
	StrCmp $5 '`' 0 +7
	StrCmp $6 '' 0 +3
	StrCpy $6 '`'
	goto quote
	StrCmp $6 '`' 0 +3
	StrCpy $6 ''
	goto quote
	StrCmp $6 '"' quote
	StrCmp $6 `'` quote
	StrCmp $6 '`' quote
	StrCmp $5 $1 0 quote
	StrCmp $7 0 trimleft trimright
 
	trimleft:
	IntOp $4 $4 + 1
	StrCpy $5 $0 $3 $4
	StrCmp $5 '' notfound
	StrCmp $5 $2 0 quote
	IntOp $4 $4 + $3
	StrCpy $0 $0 '' $4
	StrCpy $4 $0 1
	StrCmp $4 ' ' 0 +3
	StrCpy $0 $0 '' 1
	goto -3
	StrCpy $7 1
	goto begin
 
	trimright:
	StrCpy $0 $0 $4
	StrCpy $4 $0 1 -1
	StrCmp $4 ' ' 0 +3
	StrCpy $0 $0 -1
	goto -3
	StrCpy $3 $0 1
	StrCpy $4 $0 1 -1
	StrCmp $3 $4 0 end
	StrCmp $3 '"' +3
	StrCmp $3 `'` +2
	StrCmp $3 '`' 0 end
	StrCpy $0 $0 -1 1
	goto end
 
	notfound:
	SetErrors
	StrCpy $0 ''
 
	end:
	Pop $7
	Pop $6
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Exch $0
FunctionEnd

Function .onInit
	StrCpy "$StartmenuFolder" "Midori"

	; (from http://jabref.svn.sourceforge.net/viewvc/jabref/trunk/jabref/src/windows/nsis/setup.nsi)
	; If the user does *not* have administrator privileges, abort
	StrCpy $Answer ""
	StrCpy $UserName ""
	!insertmacro IsUserAdmin $Answer $UserName ; macro from LyXUtils.nsh
	${if} $Answer == "yes"
		SetShellVarContext all ; set that e.g. shortcuts will be created for all users
	${else}
		SetShellVarContext current
		; TODO is this really what we want? $PROGRAMFILES is not much better because
		; probably the unprivileged user can't write it anyways
		StrCpy $INSTDIR "$PROFILE\$(^Name)"
	${endif}

	; prevent running multiple instances of the installer
	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "midori_installer") i .r1 ?e'
	Pop $R0
	StrCmp $R0 0 +3
	MessageBox MB_OK|MB_ICONEXCLAMATION "The installer is already running." /SD IDOK
	Abort
	; warn about a new install over an existing installation
	ReadRegStr $R0 SHCTX "${PRODUCT_UNINST_KEY}" "UninstallString"
	StrCmp $R0 "" finish

	MessageBox MB_YESNO|MB_ICONEXCLAMATION \
	"Midori has already been installed. $\nDo you want to remove the previous version before installing $(^Name) ?" \
		/SD IDYES IDYES remove IDNO finish

remove:
	; run the uninstaller
	ClearErrors
	; we read the installation path of the old installation from the Registry
	ReadRegStr $UNINSTDIR SHCTX "${PRODUCT_DIR_REGKEY}" "Path"
	IfSilent dosilent nonsilent
dosilent:
	ExecWait '$R0 /S _?=$UNINSTDIR' ;Do not copy the uninstaller to a temp file
	Goto finish
nonsilent:
	ExecWait '$R0 _?=$UNINSTDIR' ;Do not copy the uninstaller to a temp file
finish:
FunctionEnd

Function un.onInit
	StrCpy $Answer ""
	!insertmacro IsUserAdmin $Answer $UserName
	${if} $Answer == "yes"
		SetShellVarContext all
	${else}
		SetShellVarContext current
	${endif}

	${GetOptions} "$CMDLINE" "/MAKEDEFAULT" $0
	IfErrors 0 +2
	goto makedefault_next

	WriteRegStr HKCU "${PRODUCT_BROWER_KEY}" "" "MIDORI.EXE"
	WriteRegStr HKCR "http\DefaultIcon" "" "${PRODUCT_EXE},0"
	WriteRegStr HKCR "http\shell\open\command" "" '${PRODUCT_EXE} "%1"'
	WriteRegStr HKCR "https\DefaultIcon" "" "${PRODUCT_EXE},0"
	WriteRegStr HKCR "https\shell\open\command" "" '${PRODUCT_EXE} "%1"'
	Abort
makedefault_next:

	${GetOptions} "$CMDLINE" "/SHOW" $0
	IfErrors 0 +2
	goto show_next

	${if} $Answer == "yes" ; if user is admin
		WriteRegDWORD HKLM "${PRODUCT_BROWER_KEY}\MIDORI.EXE\InstallInfo" "IconsVisible" 0x00000001
	${endif}
	CreateShortCut "$DESKTOP\Midori.lnk" "${PRODUCT_EXE}"
	CreateShortCut "$QUICKLAUNCH\Midori.lnk" "${PRODUCT_EXE}"
	Abort
show_next:

	${GetOptions} "$CMDLINE" "/HIDE" $0
	IfErrors 0 +2
	goto hide_next

	${if} $Answer == "yes" ; if user is admin
		WriteRegDWORD HKLM "${PRODUCT_BROWER_KEY}\MIDORI.EXE\InstallInfo" "IconsVisible" 0x00000000
	${endif}
	Delete "$QUICKLAUNCH\Midori.lnk"
	Delete "$DESKTOP\Midori.lnk"
	Abort
hide_next:

	; If the user does *not* have administrator privileges, abort
	${if} $Answer != "yes"
		; check if the Midori has been installed with admin permisions
		ReadRegStr $0 HKLM "${PRODUCT_UNINST_KEY}" "Publisher"
		${if} $0 != ""
			MessageBox MB_OK|MB_ICONSTOP "You need administrator privileges to uninstall Midori!" \
				/SD IDOK
			Abort
		${endif}
	${endif}
FunctionEnd

Function OnDirLeave
	ClearErrors
	SetOutPath "$INSTDIR" ; what about IfError creating $INSTDIR?
	GetTempFileName $1 "$INSTDIR" ; creates tmp file (or fails)
	FileOpen $0 "$1" "w" ; error to open?
	FileWriteByte $0 "0"
	IfErrors notPossible possible

notPossible:
	RMDir "$INSTDIR" ; removes folder if empty
	MessageBox MB_OK "The given directory is not writeable. Please choose another one!" /SD IDOK
	Abort
possible:
	FileClose $0
	Delete "$1"
FunctionEnd
