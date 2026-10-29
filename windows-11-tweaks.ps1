# Run as Administrator
Write-Host "Applying Safe UI / Privacy Tweaks..." -ForegroundColor Cyan

# -------------------------------
# PRE-FIX: Kill blocking processes
# -------------------------------
# We kill these so the registry keys aren't 'locked' during the update
taskkill /f /im Widgets.exe /t 2>$null
taskkill /f /im msedgewebview2.exe 2>$null

# -------------------------------
# Disable Annoyance / Ads
# -------------------------------
$CDM = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Set-ItemProperty -Path $CDM -Name "RotatingLockScreenEnabled" -Value 0 -Force
Set-ItemProperty -Path $CDM -Name "SubscribedContent-338387Enabled" -Value 0 -Force
Set-ItemProperty -Path $CDM -Name "SubscribedContent-338388Enabled" -Value 0 -Force
Set-ItemProperty -Path $CDM -Name "SystemPaneSuggestionsEnabled" -Value 0 -Force

# Disable Edge Ads / First Run
$EdgePolicy = "HKCU:\Software\Policies\Microsoft\Edge"
if (-not (Test-Path $EdgePolicy)) { New-Item -Path $EdgePolicy -Force }
Set-ItemProperty -Path $EdgePolicy -Name "HideFirstRunExperience" -Value 1 -Force

# Disable Settings Ads & Home Banner
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Value 0 -Force
$ExplorerPolicies = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
if (-not (Test-Path $ExplorerPolicies)) { New-Item -Path $ExplorerPolicies -Force }
Set-ItemProperty -Path $ExplorerPolicies -Name "SettingsPageVisibility" -Value "hide:home" -Force

# -------------------------------
# Taskbar & Search Tweaks
# -------------------------------
$Adv = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $Adv -Name "Start_IrisRecommendations" -Value 0 -Force
Set-ItemProperty -Path $Adv -Name "Start_ShowPhoneLink" -Value 0 -Force
Set-ItemProperty -Path $Adv -Name "TaskbarMn" -Value 0 -Force # Hide Chat/Teams
Set-ItemProperty -Path $Adv -Name "TaskbarDa" -Value 0 -Force # Hide Widgets (Fixed)

# Disable Bing Search in Start
$SearchPolicy = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
if (-not (Test-Path $SearchPolicy)) { New-Item -Path $SearchPolicy -Force }
Set-ItemProperty -Path $SearchPolicy -Name "DisableSearchBoxSuggestions" -Value 1 -Force

# -------------------------------
# AI / Copilot Privacy (Safe Policies)
# -------------------------------
$CopilotPolicy = "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"
if (-not (Test-Path $CopilotPolicy)) { New-Item -Path $CopilotPolicy -Force }
Set-ItemProperty -Path $CopilotPolicy -Name "TurnOffWindowsCopilot" -Value 1 -Force

# Disable Recall (Local Machine - requires Admin)
$RecallPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
if (-not (Test-Path $RecallPath)) { New-Item -Path $RecallPath -Force }
Set-ItemProperty -Path $RecallPath -Name "DisableAIDataAnalysis" -Value 1 -Force

# -------------------------------
# REFRESH UI
# -------------------------------
Write-Host "Restarting Explorer to apply changes..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force

# -------------------------------
# FINAL AUDIT
# -------------------------------
Write-Host "`n--- Final Privacy Audit ---" -ForegroundColor Green
$AuditCDM = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
$AuditAdv = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$AuditAI  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"

Write-Host ("Spotlight:       " + (Get-ItemProperty $AuditCDM).RotatingLockScreenEnabled)
Write-Host ("LockScreen Tips: " + (Get-ItemProperty $AuditCDM)."SubscribedContent-338387Enabled")
Write-Host ("Suggestions:     " + (Get-ItemProperty $AuditCDM).SystemPaneSuggestionsEnabled)
Write-Host ("Widgets (Task):  " + (Get-ItemProperty $AuditAdv).TaskbarDa)
Write-Host ("Copilot Policy:  " + (Get-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot").TurnOffWindowsCopilot)
Write-Host ("Recall/AI:       " + (Get-ItemProperty $AuditAI).DisableAIDataAnalysis)

Write-Host "`nAll tweaks applied successfully." -ForegroundColor Cyan