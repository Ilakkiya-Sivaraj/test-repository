; Turn off old selected section
; 12 27 2013: Ilakkiya S
; Flow Tool Project

; -------------------------------
; Start


!define PRODUCT_NAME "Flow Tool 1.0"
!define FLOW_FILE Spoon.bat
!define TO_COPY_DIR C:\Users\311771\Desktop\foldertobecopied


!include "${NSISDIR}\Contrib\Modern UI\System.nsh"


!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"
SetCompressor lzma

Function finishpageaction
CreateShortcut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\${FLOW_FILE}" "" "$INSTDIR\spoon.ico"
FunctionEnd
 ########## MUI Settings ##########
!define MUI_ABORTWARNING_TEXT "Are you sure you wish to abort installation?"
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\classic-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\classic-uninstall.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "header.bmp"
!define WControlPanelItem_Add


 ########## Pages ##########

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "license.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\${FLOW_FILE}"
!define MUI_FINISHPAGE_SHOWREADME ""
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Create Desktop Shortcut"
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION finishpageaction
!insertmacro MUI_PAGE_FINISH
!insertmacro GetTime
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES


;--------------------------------
;Languages

 !insertmacro MUI_LANGUAGE "English"

;--------------------------------


;---------------------------------
# Admin Check section start
Section

    # call UserInfo plugin to get user info.  The plugin puts the result in the stack
    UserInfo::getAccountType

    # pop the result from the stack into $0
    Pop $0

    # compare the result with the string "Admin" to see if the user is admin.
    # If match, jump 3 lines down.
    StrCmp $0 "Admin" +3

    # if there is not a match, print message and return
    MessageBox MB_OK "This installer requires Administrator privileges to run."
    quit

    # otherwise, confirm and return
    MessageBox MB_OK "The User is Admin"

# Admin Check section end
SectionEnd



;General
Name "${PRODUCT_NAME}"
OutFile "..\${PRODUCT_NAME}.exe"
InstallDir "$PROGRAMFILES\${PRODUCT_NAME}"
InstallDirRegKey  HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_NAME}.exe" ""
ShowInstDetails show
ShowUnInstDetails show
RequestExecutionLevel admin
;--------------------------------


;---------------------------------
;Installer Sections

section "Java Check"

     # read the value from the registry into the $0 register
     readRegStr $0 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" CurrentVersion
     StrCmp $0 "" java_not_found java_found

      java_not_found:
       # message saying java need to install

      MessageBox MB_YESNOCANCEL "Java is required.  Would you like to download it now? (Please restart this installer after installing .Java)" IDNO +2 IDCANCEL +2
      ExecShell open "http://www.oracle.com/technetwork/java/javase/downloads/index.html"
      Abort

      java_found:
      # checking java version
       Push "1.6.0.0" ;Needed verion of product
       Push  $0   ;Here you have to put existing version of product on target computer
       Call CompareVersions
       Pop $0   ; If $R0 = '1' then existing version greater than or  equval to a needed version
           ${If} $0 == "1"
                MessageBox MB_OK "Java Exists"
           ${Else}
                 # message saying new version of java needed to be installed
                   MessageBox MB_YESNOCANCEL "Higher version of java(1.6.0.17 or higher) is required.  Would you like to download it now?" IDNO +2 IDCANCEL +2
                   ExecShell open "http://www.oracle.com/technetwork/java/javase/downloads/index.html"
                   Abort
           ${EndIf}

sectionEnd

section "HPCC Check"

       # read the value from the registry into the $1 register
        readRegStr $1 HKLM "SOFTWARE\HPCC Systems\clienttools_4.2.0" ""
        StrCmp $1 "" hpcc_not_found hpcc_found

        hpcc_not_found:
        # message saying java need to install
        MessageBox MB_YESNOCANCEL "HPCC is required.  Would you like to download it now? (Please restart this installer after installing it)" IDNO +2 IDCANCEL +2
        ExecShell open "http://hpccsystems.com/download/free-community-edition/client-tools"
        Abort

        hpcc_found:
        MessageBox MB_OK "HPCC tool version : $1"

sectionEnd

Section

SetOutPath "$INSTDIR"
File /r /x "${TO_COPY_DIR}\FlowTool.nsi" "${TO_COPY_DIR}\*.*"

WriteUninstaller "$INSTDIR\Uninstall.exe"

;CREATE Desktop Shortcut and Start menu items

CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\${FLOW_FILE}"
CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall.lnk" "$INSTDIR\Uninstall.exe"

;CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\${FLOW_FILE}" "" "$INSTDIR\spoon.ico"

;CREATE REGISTRY KEYS FOR ADD/REMOVE PROGRAMS IN CONTROL PANEL

WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayName"\
"Flow Tool (remove only)"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "UninstallString" \
"$INSTDIR\Uninstall.exe"

SectionEnd

;--------------------------------



;---------------------------------
;  Splash screen  function

Function .onInit
readRegStr $1 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"  UninstallString
StrCmp $1 "" tool_not_found tool_found

        tool_found:
                MessageBox MB_OK "Flow tool installation already exists"
                Quit
         tool_not_found:
                  # the plugins dir is automatically deleted when the installer exits
         	InitPluginsDir
           	File /oname=$PLUGINSDIR\splash.bmp "${TO_COPY_DIR}\splash.bmp"
          	#optional
        	#File /oname=$PLUGINSDIR\splash.wav "C:\myprog\sound.wav"

         	splash::show 1000 $PLUGINSDIR\splash

        	Pop $0 ; $0 has '1' if the user closed the splash screen early,
			; '0' if everything closed normally, and '-1' if some error occurred.


FunctionEnd
;--------------------------------



;---------------------------------

;Checks Java Version 1.6 or higher
Function CompareVersions
   ; stack: existing ver | needed ver
   Exch $R0
   Exch
   Exch $R1
   ; stack: $R1|$R0

   Push $R1
   Push $R0
   ; stack: e|n|$R1|$R0

   ClearErrors
   loop:
      IfErrors VersionNotFound
      Strcmp $R0 "" VersionTestEnd

      Call ParseVersion
      Pop $R0
      Exch

      Call ParseVersion
      Pop $R1
      Exch

      IntCmp $R1 $R0 +1 VersionOk VersionNotFound
      Pop $R0
      Push $R0

   goto loop

   VersionTestEnd:
      Pop $R0
      Pop $R1
      Push $R1
      Push $R0
      StrCmp $R0 $R1 VersionOk VersionNotFound

   VersionNotFound:
      StrCpy $R0 "0"
      Goto end

   VersionOk:
      StrCpy $R0 "1"
end:
   ; stack: e|n|$R1|$R0
   Exch $R0
   Pop $R0
   Exch $R0
   ; stack: res|$R1|$R0
   Exch
   ; stack: $R1|res|$R0
   Pop $R1
   ; stack: res|$R0
   Exch
   Pop $R0
   ; stack: res
FunctionEnd

;---------------------------------------------------------------------------------------
 ; ParseVersion
 ; input:
 ;      top of stack = version string ("xx.xx.xx.xx")
 ; output:
 ;      top of stack   = first number in version ("xx")
 ;      top of stack-1 = rest of the version string ("xx.xx.xx")
Function ParseVersion
   Exch $R1 ; version
   Push $R2
   Push $R3

   StrCpy $R2 1
   loop:
      StrCpy $R3 $R1 1 $R2
      StrCmp $R3 "." loopend
      StrLen $R3 $R1
      IntCmp $R3 $R2 loopend loopend
      IntOp $R2 $R2 + 1
      Goto loop
   loopend:
   Push $R1
   StrCpy $R1 $R1 $R2
   Exch $R1

   StrLen $R3 $R1
   IntOp $R3 $R3 - $R2
   IntOp $R2 $R2 + 1
   StrCpy $R1 $R1 $R3 $R2

   Push $R1

   Exch 2
   Pop $R3

   Exch 2
   Pop $R2

   Exch 2
   Pop $R1
FunctionEnd


;--------------------------------



;---------------------------------

; Uninstaller part

Section "Uninstall"


;Delete Start Menu Shortcuts
  Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\*.*"
  RmDir  "$SMPROGRAMS\${PRODUCT_NAME}"

;Delete Files
  RMDir /r "$INSTDIR"

;Remove the installation directory
  RMDir "$INSTDIR"

;Remove registry entry
  DeleteRegKey /ifempty  HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"

SectionEnd

;eof