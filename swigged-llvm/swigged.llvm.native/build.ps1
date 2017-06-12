# BUILD SCRIPT FOR WINDOWS TARGETS

# Invokes a Cmd.exe shell script and updates the environment.
function Invoke-CmdScript {
  param(
    [String] $scriptName
  )
  $cmdLine = """$scriptName"" $args & set"
  & $Env:SystemRoot\system32\cmd.exe /c $cmdLine |
  select-string '^([^=]*)=(.*)$' | foreach-object {
    $varName = $_.Matches[0].Groups[1].Value
    $varValue = $_.Matches[0].Groups[2].Value
    set-item Env:$varName $varValue
  }
}


bash -c "rm -rf x86-Debug"
bash -c "rm -rf x86-Release"
bash -c "rm -rf x64-Debug"
bash -c "rm -rf x64-Release"

mkdir x86-Debug
mkdir x86-Release
mkdir x64-Debug
mkdir x64-Release

cd x86-Debug
Invoke-CmdScript "%VSINSTALLDIR%\VC\Auxiliary\Build\vcvarsall.bat" x86
cmake -MORELIBS="AArch64AsmParser AArch64AsmPrinter AArch64CodeGen AArch64Desc AArch64Disassembler AArch64Info AArch64Utils"    "-DLLVM_DIR=%CD%\..\..\llvm\x86-Debug\lib\cmake\llvm"    -G "Visual Studio 15 2017" ..
cd ..\x86-Release
cmake -MORELIBS="AArch64AsmParser AArch64AsmPrinter AArch64CodeGen AArch64Desc AArch64Disassembler AArch64Info AArch64Utils"    "-DLLVM_DIR=%CD%\..\..\llvm\x86-Release\lib\cmake\llvm"    -G "Visual Studio 15 2017" ..

Invoke-CmdScript "%VSINSTALLDIR%\VC\Auxiliary\Build\vcvarsall.bat" x64
cd ..\x64-Debug
cmake -MORELIBS="AArch64AsmParser AArch64AsmPrinter AArch64CodeGen AArch64Desc AArch64Disassembler AArch64Info AArch64Utils"    "-DLLVM_DIR=%CD%\..\..\llvm\x64-Debug\lib\cmake\llvm"    -G "Visual Studio 15 2017 Win64" ..
cd ..\x64-Release
cmake -MORELIBS="AArch64AsmParser AArch64AsmPrinter AArch64CodeGen AArch64Desc AArch64Disassembler AArch64Info AArch64Utils"    "-DLLVM_DIR=%CD%\..\..\llvm\x64-Release\lib\cmake\llvm"    -G "Visual Studio 15 2017 Win64" ..

cd ..

Invoke-CmdScript "%VSINSTALLDIR%\VC\Auxiliary\Build\vcvarsall.bat" x86
cd x86-Debug
msbuild swigged-llvm-native.sln /p:Configuration=Debug /p:Platform=Win32
cd ..\x86-Release
msbuild swigged-llvm-native.sln /p:Configuration=Release /p:Platform=Win32


Invoke-CmdScript "%VSINSTALLDIR%\VC\Auxiliary\Build\vcvarsall.bat" x64
cd ..\x64-Debug
msbuild swigged-llvm-native.sln /p:Configuration=Debug /p:Platform=x64
cd ..\x64-Release
msbuild swigged-llvm-native.sln /p:Configuration=Release /p:Platform=x64

cd ..
