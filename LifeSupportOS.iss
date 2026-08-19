; LifeSupportOS.iss
; ------------------
; dist_lifeos\ (build.ps1 の出力) を1つのインストーラーにまとめる。
;
; 前提:
;   - このファイルは LifeOS\ (dist_lifeos の親フォルダ) 直下に置く
;   - Inno Setup 6 系がインストールされていること
;   - 事前に .\build.ps1 を実行して dist_lifeos\ を作っておくこと
;
; ビルド:
;   Inno Setup Compiler で本ファイルを開いて Compile、
;   または: "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" LifeSupportOS.iss
;
; データ保存先について:
;   LifeSupportOS.exe (launch_gateway.py) は起動時に
;   %LOCALAPPDATA%\ArchLifeEcosystem\ 配下にDB・認証トークンを作る設計のため、
;   このインストーラーは Program Files 配下にexe一式を置くだけでよい
;   (データ用のフォルダ作成・権限設定は不要)。

#define MyAppName "LifeSupportOS"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Myubd"
#define MyAppExeName "LifeSupportOS.exe"
#define MySourceDir "dist_lifeos"

[Setup]
AppId={{A3F1B2C4-5D6E-4A7B-9C8D-1E2F3A4B5C6D}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
; Program Files配下(64bit)にインストール。データはAppData側なので通常権限で動く。
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=installer_output
OutputBaseFilename=LifeSupportOS-Setup-{#MyAppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
; LICENSE.txt を用意したら以下を有効化する
; LicenseFile=LICENSE.txt
; アイコンを用意したら以下を有効化する
; SetupIconFile=archlife\archlife-fastapi\assets\icon.ico

[Languages]
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"

[Tasks]
Name: "desktopicon"; Description: "デスクトップにショートカットを作成する"; GroupDescription: "追加のショートカット:"

[Files]
; dist_lifeos\ の中身を丸ごと {app} 配下にコピー(LifeSupportOS.exe, _internal\, backends\ 全部含む)
Source: "{#MySourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{#MyAppName} をアンインストール"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{#MyAppName} を起動する"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; アンインストール時にexe一式(Program Files配下)は消すが、
; %APPDATA%\LifeSupportOS\ (Roaming) のユーザーデータは意図的に残す。
; 完全に削除したい場合は Type: filesandordirs で
; "{userappdata}\LifeSupportOS" を追加すること。
