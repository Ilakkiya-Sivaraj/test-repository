;--------------------------------
;Steps
;--------------------------------
;Locate Java Runtime/JRE
;Ensure version 1.4 or higher
;Write CLASSPATH, PATH and JAVA_HOME to .Bat file
;
;If JRE unavailable or version less than 1.4, launch Explorer and open ;http://www.java.com and inform user to download the correct version of JRE.
;--------------------------------

;--------------------------------
;AUTHOR: Ashwin Jayaprakash
;WEBSITE: http://www.JavaForU.com
;--------------------------------

;--------------------------------
; Constants
;--------------------------------
!define GET_JAVA_URL "http://www.java.com"

;--------------------------------
; Variables
;--------------------------------
!include "${NSISDIR}\Contrib\Modern UI\System.nsh"


!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"
SetCompressor lzma

;--------------------------------
; Main Install settings
;--------------------------------
Name "ABC"
InstallDir ".\ABC"
OutFile "ABC_Installer.exe"

;--------------------------------



      




Section "find java" FINDJAVA

  StrCpy $1 "SOFTWARE\JavaSoft\Java Runtime Environment"
  StrCpy $2 0
  ReadRegStr $2 HKLM "$1" CurrentVersion
  StrCmp $2 "" DetectTry2
 
  goto java_found

  DetectTry2:
  ReadRegStr $2 HKLM "SOFTWARE\JavaSoft\Java Development Kit" CurrentVersion
  StrCmp $2 ""  java_not_found
  
  

  java_found:
      # checking java version
       Push "1.9.0.0" ;Needed verion of product
       Push  $2   ;Here you have to put existing version of product on target computer
       Call CompareVersions
       Pop $2   ; If $R0 = '1' then existing version greater than or  equval to a needed version
           ${If} $2== "1"
                MessageBox MB_OK "Java Exists"
           ${Else}
                 # message saying new version of java needed to be installed
                   MessageBox MB_YESNOCANCEL "Higher version of java(1.6.0.17 or higher) is required.  Would you like to download it now?" IDNO +2 IDCANCEL +2
                   ExecShell open "http://www.oracle.com/technetwork/java/javase/downloads/index.html"
                   Abort
           ${EndIf}


 java_not_found:
       # message saying java need to install
      MessageBox MB_YESNOCANCEL "Java is required.  Would you like to download it now? (Please restart this installer after installing .Java)" IDNO +2 IDCANCEL +2
      ExecShell open "http://www.oracle.com/technetwork/java/javase/downloads/index.html"
      Abort
SectionEnd
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
; eof
;--------------------------------