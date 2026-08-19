# build.ps1
# ----------
# LifeSupportOS の.exe一式をビルドし、配布用フォルダ dist_lifeos\ に
# まとめるスクリプト。LifeOS\ (このファイルの親フォルダ) 直下に置いて実行する。
#
# 前提:
#   - Python 3.10、pip install pyinstaller が各バックエンドの依存と一緒に
#     入っていること(これまでの手順で入っているはず)
#   - node/npm が入っていること
#   - archlife / interview_app / study-support / health-support /
#     digital-vault / disaster-support / life-support-os-gateway /
#     local-ai-core が全部このフォルダの直下にあること
#
# 実行:
#   cd C:\Users\myubd\Desktop\LifeOS
#   .\build.ps1
#
# 出力: .\dist_lifeos\ に、LifeSupportOS.exe + backends\ 配下に6つのexeが
#       まとまった状態で置かれる。ここをそのままInno Setup等でインストーラー化できる。

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

function Step($msg) {
    Write-Host ""
    Write-Host "==== $msg ====" -ForegroundColor Cyan
}

# ── 1. フロントエンドのビルド ──────────────────────────────
Step "archlife-frontend をビルド"
Push-Location "$root\archlife\archlife-frontend"
npm install
npm run build:electron
Pop-Location

Step "interview_app フロントエンドをビルド(gateway統合版)"
Push-Location "$root\interview_app\react-fastapi\frontend"
npm install
npm run build:gateway
Pop-Location

# ── 2. バックエンド6つをexe化 ──────────────────────────────
Step "archlife_backend をexe化"
Push-Location "$root\archlife\archlife-fastapi"
pyinstaller launch_fastapi.spec --noconfirm
Pop-Location

Step "interview_backend をexe化"
Push-Location "$root\interview_app\react-fastapi\backend"
pyinstaller run_service.spec --noconfirm
Pop-Location

Step "study_support をexe化"
Push-Location "$root\study-support"
pyinstaller run_service.spec --noconfirm
Pop-Location

Step "health_support をexe化"
Push-Location "$root\health-support"
pyinstaller run_service.spec --noconfirm
Pop-Location

Step "digital_vault をexe化"
Push-Location "$root\digital-vault"
pyinstaller run_service.spec --noconfirm
Pop-Location

Step "disaster_support をexe化"
Push-Location "$root\disaster-support"
pyinstaller run_service.spec --noconfirm
Pop-Location

# ── 3. gateway(LifeSupportOS.exe)をexe化 ──────────────────
# 注意: フロントエンドのdistを同梱するので、必ず手順1の後に実行する。
Step "gateway (LifeSupportOS.exe) をexe化"
Push-Location "$root\life-support-os-gateway"
pyinstaller LifeSupportOS.spec --noconfirm
Pop-Location

# ── 4. 配布用フォルダに集約 ─────────────────────────────────
Step "dist_lifeos\ に集約"
$distRoot = "$root\dist_lifeos"
if (Test-Path $distRoot) { Remove-Item -Recurse -Force $distRoot }
New-Item -ItemType Directory -Force -Path "$distRoot\backends\archlife_backend" | Out-Null
New-Item -ItemType Directory -Force -Path "$distRoot\backends\interview_backend" | Out-Null
New-Item -ItemType Directory -Force -Path "$distRoot\backends\study_support" | Out-Null
New-Item -ItemType Directory -Force -Path "$distRoot\backends\health_support" | Out-Null
New-Item -ItemType Directory -Force -Path "$distRoot\backends\digital_vault" | Out-Null
New-Item -ItemType Directory -Force -Path "$distRoot\backends\disaster_support" | Out-Null

Copy-Item "$root\archlife\archlife-fastapi\dist\launch_fastapi\*" "$distRoot\backends\archlife_backend\" -Recurse
Copy-Item "$root\interview_app\react-fastapi\backend\dist\interview_backend\*" "$distRoot\backends\interview_backend\" -Recurse
Copy-Item "$root\study-support\dist\study_support\*" "$distRoot\backends\study_support\" -Recurse
Copy-Item "$root\health-support\dist\health_support\*" "$distRoot\backends\health_support\" -Recurse
Copy-Item "$root\digital-vault\dist\digital_vault\*" "$distRoot\backends\digital_vault\" -Recurse
Copy-Item "$root\disaster-support\dist\disaster_support\*" "$distRoot\backends\disaster_support\" -Recurse
Copy-Item "$root\life-support-os-gateway\dist\LifeSupportOS\*" "$distRoot\" -Recurse

Step "完了"
Write-Host "配布用一式は $distRoot にできています。" -ForegroundColor Green
Write-Host "動作確認: cd $distRoot のあと .\LifeSupportOS.exe を実行してください" -ForegroundColor Green
