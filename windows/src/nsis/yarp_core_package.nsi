
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "EnvVarUpdate.nsh"
!include "x64.nsh"

!define UninstLog "uninstall_YARP.log"
Var UninstLog
LangString UninstLogMissing ${LANG_ENGLISH} "${UninstLog} not found!$\r$\nUninstallation cannot proceed!"

!include "YarpNsisUtils.nsh"

!define MULTIUSER_EXECUTIONLEVEL Highest
!include MultiUser.nsh

Name "YARP ${YARP_VERSION}"
OutFile "${NSIS_OUTPUT_PATH}\yarp_${YARP_VERSION}_${BUILD_VERSION}.exe"

InstallDir "$PROGRAMFILES\${VENDOR}"
# this part no longer included in install path "\yarp-${YARP_VERSION}"

InstallDirRegKey HKCU "Software\YARP\Common" "LastInstallLocation"
RequestExecutionLevel admin

!define MUI_ABORTWARNING


!macro AddEnv Key Val
   Push $0
   ${EnvVarUpdate} $0 "${Key}" "A" "${WriteEnvStr_Base}" "${Val}"
   Pop $0
   FileWrite $UninstLog "ENVADD|${WriteEnvStr_Base}|${Key}|${Val}$\r$\n"
!macroend

!macro AddEnv1 Key Val
   WriteRegExpandStr ${WriteEnvStr_RegKey} "${Key}" "${Val}"
   FileWrite $UninstLog "KEYSET|${WriteEnvStr_Base}|${WriteEnvStr_KeyOnly}|${Key}|${Val}$\r$\n"
!macroend

!macro AddKey Key Subkey Val
   WriteRegStr "${WriteEnvStr_Base}" "${Key}" "${Subkey}" "${Val}"
   FileWrite $UninstLog "KEYSET|${WriteEnvStr_Base}|${Key}|${Subkey}|${Val}$\r$\n"
!macroend

;--------------------------------
;Pages

  !define MUI_PAGE_HEADER_TEXT "Welcome to YARP"
  !define MUI_PAGE_HEADER_SUBTEXT "Yet Another Robot Platform"
  !define MUI_LICENSEPAGE_TEXT_TOP "Most YARP components are released under the terms of the BSD-3-Clause. Some optional components are released under the terms of the LGPL-2.1 or later, GPL-2.0 or later, GPL-3.0 or later, or Apache-2.0 License."
  !define MUI_LICENSEPAGE_TEXT_BOTTOM "Material included in YARP is Copyright of Istituto Italiano di Tecnologia (IIT), RobotCub Consortium and other contributors."
#  !define MUI_LICENSEPAGE_BUTTON "Next >"
  !insertmacro MUI_PAGE_LICENSE "${YARP_LICENSE}"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"
  
;--------------------------------
;Installer Sections

Section "-first"
  SetOutPath "$INSTDIR"
  Push $0
  ReadRegStr $0 HKCU "Software\${VENDOR}\installer\YARPInventory" ""
  IfErrors Skip 0
	Push $0
	Push $0
	Call RemoveInventory
	Delete $0
  Skip:
    ClearErrors
  Pop $0
 
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
   
  WriteUninstaller "$INSTDIR\Uninstall_YARP.exe"
  SectionIn RO
  # !include ${NSIS_OUTPUT_PATH}\yarp_base_add.nsi
SectionEnd

Section -openlogfile
    CreateDirectory "$INSTDIR"
    IfFileExists "$INSTDIR\${UninstLog}" +3
      FileOpen $UninstLog "$INSTDIR\${UninstLog}" w
    Goto +4
      SetFileAttributes "$INSTDIR\${UninstLog}" NORMAL
      FileOpen $UninstLog "$INSTDIR\${UninstLog}" a
      FileSeek $UninstLog 0 END
    !insertmacro AddKey "Software\${VENDOR}\installer\YARPInventory" "" "$INSTDIR\${UninstLog}"

SectionEnd

SectionGroup "YARP core" SecYarp

  Section "Command-line utilities" SecPrograms
    SetOutPath "$INSTDIR"
    !include ${NSIS_OUTPUT_PATH}\yarp_programs_add.nsi
  SectionEnd

  Section "Libraries" SecLibraries
    SetOutPath "$INSTDIR"
    !include ${NSIS_OUTPUT_PATH}\yarp_libraries_add.nsi
  SectionEnd

  Section "Header files" SecHeaders
    SetOutPath "$INSTDIR"
    !include ${NSIS_OUTPUT_PATH}\yarp_headers_add.nsi
  SectionEnd

  Section "Runtime DLLs" SecDLLs
    SetOutPath "$INSTDIR"
    !include ${NSIS_OUTPUT_PATH}\yarp_dlls_add.nsi
  SectionEnd
	
  Section "Examples" SecExamples
    SetOutPath "$INSTDIR"
    !include ${NSIS_OUTPUT_PATH}\yarp_examples_add.nsi
  SectionEnd
  
  Section "CMake files"
    SetOutPath "$INSTDIR"
    ; SectionIn RO
    !include ${NSIS_OUTPUT_PATH}\yarp_base_add.nsi
	FileOpen $1 '$INSTDIR\${YARP_SUB}\share\yarp\plugins\yarp.ini' w
    FileWrite $1 '###### This file is automatically generated by NSIS'
    FileWrite $1 '$\r$\n'
    FileWrite $1 '[search yarp]'
    FileWrite $1 '$\r$\n'
    ${StrRepLocal} $2 "$INSTDIR\${YARP_SUB}\lib\yarp" "\" "/"
	FileWrite $1 'path "$2"'
    FileWrite $1 '$\r$\n'
    FileWrite $1 'extension ".dll"'
    FileWrite $1 '$\r$\n'
    FileWrite $1 'type "shared"'
    FileWrite $1 '$\r$\n'    
	FileClose $1
  SectionEnd

  Section "Set environment variables and registry keys" SecYarpEnv
    !insertmacro AddKey "Software\${VENDOR}\YARP\${YARP_SUB}" "" "$INSTDIR\${YARP_SUB}"
    !insertmacro AddKey "Software\${VENDOR}\YARP\Common" "LastInstallLocation" $INSTDIR
    !insertmacro AddKey "Software\${VENDOR}\YARP\Common" "LastInstallVersion" ${YARP_SUB}

    !insertmacro AddEnv "PATH" "$INSTDIR\${YARP_SUB}\bin"
    !insertmacro AddEnv "LIB" "$INSTDIR\${YARP_SUB}\lib"
    !insertmacro AddEnv "INCLUDE" "$INSTDIR\${YARP_SUB}\include"
	!insertmacro AddEnv "YARP_DATA_DIRS" "$INSTDIR\${YARP_SUB}\share\yarp"

	!insertmacro AddEnv1 "YARP_DIR" "$INSTDIR\${YARP_SUB}"

    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
	
  SectionEnd

SectionGroupEnd

SectionGroup "ACE (Adaptive Communication Environment)" SecAce  
  Section "ACE headers" SecAceHeaders
    SetOutPath "$INSTDIR"
    !include ${NSIS_OUTPUT_PATH}\ace_headers_add.nsi
  SectionEnd

  Section "ACE library" SecAceLibraries
    SetOutPath "$INSTDIR"
    !include ${NSIS_OUTPUT_PATH}\ace_libraries_add.nsi
  SectionEnd

  Section "ACE runtime DLL" SecAceDLLs
    SetOutPath "$INSTDIR"
    !include ${NSIS_OUTPUT_PATH}\ace_dlls_add.nsi
  SectionEnd

  Section "Set environment variables and registry keys" SecAceEnv
    !insertmacro AddKey "Software\${VENDOR}\ACE\${ACE_SUB}" "" "$INSTDIR\${ACE_SUB}"
    !insertmacro AddKey "Software\${VENDOR}\ACE\Common" "LastInstallLocation" $INSTDIR
    !insertmacro AddKey "Software\${VENDOR}\ACE\Common" "LastInstallVersion" ${YARP_SUB}
    !insertmacro AddEnv "PATH" "$INSTDIR\${ACE_SUB}\bin"
    !insertmacro AddEnv "LIB" "$INSTDIR\${ACE_SUB}\lib"
    !insertmacro AddEnv "INCLUDE" "$INSTDIR\${ACE_SUB}"
    !insertmacro AddEnv1 "ACE_ROOT" "$INSTDIR\${ACE_SUB}"
    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
  SectionEnd

SectionGroupEnd
  
; Removing GSL
; SectionGroup "GSL (GNU Scientific Library) (GPL license)" SecGsl
  ; Section "GSL headers" SecGslHeaders
    ; SetOutPath "$INSTDIR"
    ; !include ${NSIS_OUTPUT_PATH}\gsl_headers_add.nsi
  ; SectionEnd

  ; Section "GSL libraries" SecGslLibraries
    ; SetOutPath "$INSTDIR"
    ; !include ${NSIS_OUTPUT_PATH}\gsl_libraries_add.nsi
  ; SectionEnd
  SectionGroup "EIGEN library" SecEigen
  Section "EIGEN libraries" SecEigenLibraries
    SetOutPath "$INSTDIR"
    !include ${NSIS_OUTPUT_PATH}\eigen_base_add.nsi
  SectionEnd

  Section "YARP headers for math" SecYarpMathHeaders
    SetOutPath "$INSTDIR"
    !include ${NSIS_OUTPUT_PATH}\yarp_math_headers_add.nsi
  SectionEnd

  Section "YARP library for math" SecYarpMathLibraries
    SetOutPath "$INSTDIR"
    !include ${NSIS_OUTPUT_PATH}\yarp_math_libraries_add.nsi
  SectionEnd
  
  Section "YARP runtime DLL for math" SecYarpMathDLLs
    SetOutPath "$INSTDIR"
    !include ${NSIS_OUTPUT_PATH}\yarp_math_dlls_add.nsi
  SectionEnd

  ; Removing GSL
  ;Section "Set environment variables and registry keys" SecGslEnv
  Section "Set environment variables and registry keys" SecEigenEnv
    !insertmacro AddKey "Software\${VENDOR}\EIGEN\${EIGEN_SUB}" "" "$INSTDIR\${EIGEN_SUB}"
    !insertmacro AddKey "Software\${VENDOR}\EIGEN\Common" "LastInstallLocation" $INSTDIR
    !insertmacro AddKey "Software\${VENDOR}\EIGEN\Common" "LastInstallVersion" ${EIGEN_SUB}
    !insertmacro AddEnv1 EIGEN3_ROOT "$INSTDIR\${EIGEN_SUB}"
    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
  SectionEnd

SectionGroupEnd

!ifdef GTKMM_SUB
SectionGroup "GTKMM" SecGtkmm
  Section "GTKMM headers" SecGtkmmHeaders
    SetOutPath "$INSTDIR"
	!include ${NSIS_OUTPUT_PATH}\gtkmm_headers_add.nsi
  SectionEnd

  Section "GTKMM library" SecGtkmmLibraries
    !echo "Skipping GTK libraries"
    SetOutPath "$INSTDIR"
	!include ${NSIS_OUTPUT_PATH}\gtkmm_libraries_add.nsi
  SectionEnd

  Section "GTKMM runtime DLL" SecGtkmmDLLs
	  SetOutPath "$INSTDIR"
	  !include ${NSIS_OUTPUT_PATH}\gtkmm_dlls_add.nsi
  SectionEnd

  Section "Set environment variables and registry keys" SecGtkmmEnv
	  !insertmacro AddKey "Software\${VENDOR}\GTKMM\${GTKMM_SUB}" "" "$INSTDIR\${GTKMM_SUB}"
	  !insertmacro AddKey "Software\${VENDOR}\GTKMM\Common" "LastInstallLocation" $INSTDIR
	  !insertmacro AddKey "Software\${VENDOR}\GTKMM\Common" "LastInstallVersion" ${GTKMM_SUB}
	  !insertmacro AddEnv "PATH" "$INSTDIR\${GTKMM_SUB}\bin"
	  !insertmacro AddEnv "LIB" "$INSTDIR\${GTKMM_SUB}\lib"
	  !insertmacro AddEnv "INCLUDE" "$INSTDIR\${GTKMM_SUB}\include"
	  !insertmacro AddEnv1 GTKMM_BASEPATH "$INSTDIR\${GTKMM_SUB}"
	  !insertmacro AddEnv1 GTK_BASEPATH "$INSTDIR\${GTKMM_SUB}"
	  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
  SectionEnd

  Section "GTKMM GUIs" SecGtkGuis
		SetOutPath "$INSTDIR"
    # Removing GTK GUIs
		#!include ${NSIS_OUTPUT_PATH}\gtk_guis_add.nsi
		#CreateShortCut "$INSTDIR\bin\yarpview.lnk" "$INSTDIR\yarpview\yarpview.exe"
  SectionEnd
SectionGroupEnd
!else
    !echo "Skipping GTK material"
!endif

!ifdef QT_SUB
SectionGroup "Qt" SecQt
   Section "QT files" SecQtFile
      SetOutPath "$INSTDIR"
      !include ${NSIS_OUTPUT_PATH}\qt_files_add.nsi
      ExecWait '"$INSTDIR\${QT_SUB}\bin\qtpathcorrector.exe" patch -n "$INSTDIR\${QT_SUB}" -f "$INSTDIR\${QT_SUB}\bin\Qt5Core.dll"' $0
      ExecWait '"$INSTDIR\${QT_SUB}\bin\qtpathcorrector.exe" patch -n "$INSTDIR\${QT_SUB}" -f "$INSTDIR\${QT_SUB}\bin\Qt5Cored.dll"' $0
      ExecWait '"$INSTDIR\${QT_SUB}\bin\qtpathcorrector.exe" patch -n "$INSTDIR\${QT_SUB}" -f "$INSTDIR\${QT_SUB}\bin\qmake.exe"' $0
      Delete "$INSTDIR\${QT_SUB}\bin\qtpathcorrector.exe"
      Delete "$INSTDIR\${QT_SUB}\bin\msvcp100.dll"
      Delete "$INSTDIR\${QT_SUB}\bin\msvcr100.dll"
      FileOpen $1 '$INSTDIR\${QT_SUB}\bin\qtenv2.bat' w
      FileWrite $1 'echo off'
      FileWrite $1 '$\r$\n'
      FileWrite $1 'echo Setting up environment for Qt usage...'
      FileWrite $1 '$\r$\n'
      FileWrite $1 'set PATH="$INSTDIR\${QT_SUB}\bin;%PATH%"'
      FileWrite $1 '$\r$\n'
      FileWrite $1 'cd /D "$INSTDIR\${QT_SUB}"'
      FileWrite $1 '$\r$\n'
      FileWrite $1 'echo Remember to call vcvarsall.bat to complete environment setup!'
      FileClose $1
  SectionEnd
  Section "Set environment variables" SecQtEnv
    !insertmacro AddEnv "PATH" "$INSTDIR\${QT_SUB}\bin"
    !insertmacro AddEnv "LIB" "$INSTDIR\${QT_SUB}\lib"
    !insertmacro AddEnv "INCLUDE" "$INSTDIR\${QT_SUB}\include"
    !insertmacro AddEnv1 Qt5_DIR "$INSTDIR\${QT_SUB}\lib\cmake\Qt5"
    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
   SectionEnd
  Section "QT GUIs" SecQtGuis
      !echo "Skipping Qt guis" 
 	  SetOutPath "$INSTDIR"
	  !include ${NSIS_OUTPUT_PATH}\qt_guis_add.nsi
  SectionEnd
SectionGroupEnd
!else
  !echo "Skipping Qt material" 
!endif

!ifdef LIBJPEG_SUB
SectionGroup "libjpeg-turbo" SecLibjpeg
   Section "libjpeg-turbo files" SecLibjpegFile
      SetOutPath "$INSTDIR"
      !include ${NSIS_OUTPUT_PATH}\libjpeg_files_add.nsi
  SectionEnd
  Section "Set environment variables" SecLibjpegEnv
    !insertmacro AddEnv1 JPEG_INCLUDE_DIR "$INSTDIR\${LIBJPEG_SUB}\include"
    !insertmacro AddEnv1 JPEG_LIBRARY "$INSTDIR\${LIBJPEG_SUB}\lib\libjpeg.lib"
    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
   SectionEnd
SectionGroupEnd
!else
  !echo "Skipping libjpeg-turbo material" 
!endif

Section "Visual Studio Runtime (nonfree)" SecVcDlls
  SetOutPath "$INSTDIR"
  !include ${NSIS_OUTPUT_PATH}\yarp_vc_dlls_add.nsi
SectionEnd

Section "-last"
  ; Removing GSL
  ;!insertmacro SectionFlagIsSet ${SecGsl} ${SF_PSELECTED} isSel chkAll
   ;chkAll:
   ;  !insertmacro SectionFlagIsSet ${SecGsl} ${SF_SELECTED} isSel notSel
   !insertmacro SectionFlagIsSet ${SecEigen} ${SF_PSELECTED} isSel chkAll
   chkAll:
     !insertmacro SectionFlagIsSet ${SecEigen} ${SF_SELECTED} isSel notSel
   notSel:
     !insertmacro ReplaceInFile "$INSTDIR\${YARP_SUB}\cmake\YARPConfig.cmake" "YARP_math;" ""
	 !insertmacro ReplaceInFile "$INSTDIR\${YARP_SUB}\cmake\YARPConfig.cmake" "YARP_HAS_MATH_LIB TRUE" "YARP_HAS_MATH_LIB FALSE"
   isSel:
SectionEnd

!macro Unselect RR
  Push $R0
  Push $R1
  SectionGetFlags ${${RR}} $R0
  IntOp $R1 $R0 & ${SF_SELECTED}
  StrCmp $R1 ${SF_SELECTED} 0 +3
  IntOp $R0 $R0 ^ ${SF_SELECTED}
  SectionSetFlags ${${RR}} $R0
  Pop $R1
  Pop $R0
!macroend

!macro GroupRO GroupId
  Push $0
  IntOp $0 ${SF_SECGRP} | ${SF_RO}
  SectionSetFlags ${GroupId} $0
  Pop $0
!macroend
 

Function .onSelChange
  Push $R0
  Push $R1
  Push $R2
  SectionGetFlags ${SecYarp} $R0
  IntOp $R0 $R0 & ${SF_SELECTED}
  StrCmp $R0 ${SF_SELECTED} Skip 0
  !insertmacro Unselect "SecYarpMathLibraries"
  !insertmacro Unselect "SecYarpMathDLLs"
  !insertmacro Unselect "SecYarpMathHeaders"
  !ifdef QT_SUB
    !insertmacro Unselect "SecQtGuis"
  !endif
  !ifdef GTKMM_SUB
    !insertmacro Unselect "SecGtkGuis"
  !endif
  !insertmacro Unselect "SecVcDlls"
  Skip:
  Pop $R2
  Pop $R1
  Pop $R0
FunctionEnd

;--------------------------------
;Descriptions

;Language strings
LangString DESC_SecYarp ${LANG_ENGLISH} "YARP libraries and tools. Unselect this if you intend to compile YARP yourself and just want YARP's dependencies."
LangString DESC_SecAce ${LANG_ENGLISH} "The Adaptive Communications Environment, used by this version of YARP."
; Removing GSL
;LangString DESC_SecGsl ${LANG_ENGLISH} "The YARP math library.  Based on the GNU Scientific Library.  This is therefore GPL software, not the LGPL like YARP."
LangString DESC_SecEigen ${LANG_ENGLISH} "The YARP math library.  Based on the EIGEN Library."
LangString DESC_SecGtkmm ${LANG_ENGLISH} "User interface library.  Not needed to use the YARP library.  Used by the yarpview program."
LangString DESC_SecPrograms ${LANG_ENGLISH} "YARP programs, including the standard YARP companion, and the standard YARP name server."
LangString DESC_SecLibraries ${LANG_ENGLISH} "Libraries for linking against YARP."
LangString DESC_SecHeaders ${LANG_ENGLISH} "YARP header files."
LangString DESC_SecExamples ${LANG_ENGLISH} "A basic example of using YARP.  See online documentation, and many more examples in source code package."
LangString DESC_SecDLLs ${LANG_ENGLISH} "Libraries needed for YARP programs to run."
LangString DESC_SecAceLibraries ${LANG_ENGLISH} "ACE library files."
LangString DESC_SecAceDLLs ${LANG_ENGLISH} "ACE library run-time."
;LangString DESC_SecGslLibraries ${LANG_ENGLISH} "Math library files."
LangString DESC_SecYarpMathDLLs ${LANG_ENGLISH} "Math library run-time."
;LangString DESC_SecGslHeaders ${LANG_ENGLISH} "Math library header files."
LangString DESC_SecGtkGuis ${LANG_ENGLISH} "GUIs usign GTK+."
LangString DESC_SecQtGuis ${LANG_ENGLISH} "GUIs usign Qt."
LangString DESC_SecYarpEnv ${LANG_ENGLISH} "Add YARP to PATH, LIB, and INCLUDE variables, and set YARP_DIR variable."
LangString DESC_SecVcDlls ${LANG_ENGLISH} "Visual Studio runtime redistributable files.  Not free software.  If you already have Visual Studio installed, you may want to skip this."

;Assign language strings to sections
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SecYarp} $(DESC_SecYarp)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGtkmm} $(DESC_SecGtkmm)
!insertmacro MUI_DESCRIPTION_TEXT ${SecPrograms} $(DESC_SecPrograms)
!insertmacro MUI_DESCRIPTION_TEXT ${SecLibraries} $(DESC_SecLibraries)
!insertmacro MUI_DESCRIPTION_TEXT ${SecHeaders} $(DESC_SecHeaders)
!insertmacro MUI_DESCRIPTION_TEXT ${SecExamples} $(DESC_SecExamples)
!insertmacro MUI_DESCRIPTION_TEXT ${SecDLLs} $(DESC_SecDLLs)
!insertmacro MUI_DESCRIPTION_TEXT ${SecVcDlls} $(DESC_SecVcDlls)
!insertmacro MUI_DESCRIPTION_TEXT ${SecAce} $(DESC_SecAce)
!insertmacro MUI_DESCRIPTION_TEXT ${SecAceLibraries} $(DESC_SecAceLibraries)
!insertmacro MUI_DESCRIPTION_TEXT ${SecAceDLLs} $(DESC_SecAceDLLs)
; Removing GSL
;!insertmacro MUI_DESCRIPTION_TEXT ${SecGsl} $(DESC_SecGsl)
;!insertmacro MUI_DESCRIPTION_TEXT ${SecGslLibraries} $(DESC_SecGslLibraries)
;!insertmacro MUI_DESCRIPTION_TEXT ${SecEigen} $(DESC_SecEigen)
!insertmacro MUI_DESCRIPTION_TEXT ${SecYarpMathDLLs} $(DESC_SecYarpMathDLLs)
; Removing GSL
;!insertmacro MUI_DESCRIPTION_TEXT ${SecGslHeaders} $(DESC_SecGslHeaders)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGtkGuis} $(DESC_SecGtkGuis)
!insertmacro MUI_DESCRIPTION_TEXT ${SecQtGuis} $(DESC_SecQtGuis)
!insertmacro MUI_DESCRIPTION_TEXT ${SecYarpEnv} $(DESC_SecYarpEnv)
;!insertmacro MUI_DESCRIPTION_TEXT ${Sec} $(DESC_Sec)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  IfFileExists "$INSTDIR\${UninstLog}" +3
    MessageBox MB_OK|MB_ICONSTOP "$(UninstLogMissing)"
      Abort
 
  Push $0
  Push "$INSTDIR\${UninstLog}"
  Call un.RemoveInventory
 
  Delete "$INSTDIR\${UninstLog}"

  # ${un.EnvVarUpdate} $0 "PATH" "R" "${WriteEnvStr_Base}" "$INSTDIR\${YARP_SUB}\bin"
  # ${un.EnvVarUpdate} $0 "LIB" "R" "${WriteEnvStr_Base}" "$INSTDIR\${YARP_SUB}\lib"
  # ${un.EnvVarUpdate} $0 "INCLUDE" "R" "${WriteEnvStr_Base}" "$INSTDIR\${YARP_SUB}\include"

  # DeleteRegValue ${WriteEnvStr_RegKey} YARP_DIR
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
  
  RMDir /r "$INSTDIR\${YARP_SUB}"
  # Removing GSL
  #RMDir /r "$INSTDIR\${GSL_SUB}"
  RMDir /r "$INSTDIR\${EIGEN_SUB}"
  RMDir /r "$INSTDIR\${ACE_SUB}"
  !ifdef GTKMM_SUB
    RMDir /r "$INSTDIR\${GTKMM_SUB}"
  !endif
  !ifdef QT_SUB
    RMDir /r "$INSTDIR\${QT_SUB}"
  !endif
  !ifdef LIBJPEG_SUB
    RMDir /r "$INSTDIR\${LIBJPEG_SUB}"
  !endif
  
  # cleanup YARP registry entries
  DeleteRegKey /ifempty HKCU "Software\${VENDOR}\YARP\Common"
  DeleteRegKey /ifempty HKCU "Software\${VENDOR}\YARP\${YARP_SUB}"
  DeleteRegKey /ifempty HKCU "Software\${VENDOR}\YARP"
  
  # Removing GSL
  # cleanup GSL registry entries
  #DeleteRegKey /ifempty HKCU "Software\${VENDOR}\GSL\Common"
  #DeleteRegKey /ifempty HKCU "Software\${VENDOR}\GSL\${GSL_SUB}"
  #DeleteRegKey /ifempty HKCU "Software\${VENDOR}\GSL"
  DeleteRegKey /ifempty HKCU "Software\${VENDOR}\EIGEN\Common"
  DeleteRegKey /ifempty HKCU "Software\${VENDOR}\EIGEN\${EIGEN_SUB}"
  DeleteRegKey /ifempty HKCU "Software\${VENDOR}\EIGEN"
  
  # cleanup GTKMM registry entries
  DeleteRegKey /ifempty HKCU "Software\${VENDOR}\GTKMM\Common"
  DeleteRegKey /ifempty HKCU "Software\${VENDOR}\GTKMM\${GTKMM_SUB}"
  #DeleteRegKey /ifempty HKCU "Software\${VENDOR}\GTKMM\${GSL_SUB}" # clean up a mistake in an earlier installer 
  DeleteRegKey /ifempty HKCU "Software\${VENDOR}\GTKMM"
  
  # cleanup ACE registry entries
  DeleteRegKey /ifempty HKCU "Software\${VENDOR}\ACE\Common"
  DeleteRegKey /ifempty HKCU "Software\${VENDOR}\ACE\${ACE_SUB}"
  DeleteRegKey /ifempty HKCU "Software\${VENDOR}\ACE"

  # cleanup installation inventory file link
  DeleteRegKey /ifempty HKCU "Software\${VENDOR}\installer\YARPInventory"
  DeleteRegKey /ifempty HKCU "Software\${VENDOR}\installer"
  
  # cleanup vendor entry if empty
  DeleteRegKey /ifempty HKCU "Software\${VENDOR}"

  Delete "$INSTDIR\Uninstall_YARP.exe"
  
SectionEnd

Function .onInit
	!insertmacro MULTIUSER_INIT
	${If} ${YARP_PLATFORM} == "x64"
	${OrIf} ${YARP_PLATFORM} == "amd64"
	${OrIf} ${YARP_PLATFORM} == "x86_amd64"
		${If} ${RUNNINGX64}
			StrCpy $instdir "$PROGRAMFILES64\${VENDOR}"
			SetRegView 64
		${Else}
			MessageBox MB_OK "Sorry, but this version runs only on x64 machines"
			Abort
		${EndIf}
	${Else}
		${If} ${RUNNINGX64}
			StrCpy $instdir "$PROGRAMFILES32\${VENDOR}"
		${EndIf}
	${EndIf}
FunctionEnd

Function un.onInit
  !insertmacro MULTIUSER_UNINIT
FunctionEnd