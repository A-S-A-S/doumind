Write-Host "File Encryption/Decryption Tool"
Write-Host "1. Encrypt a file"
Write-Host "2. Decrypt a file"
$choice = Read-Host "Enter your choice (1 or 2)"

if ($choice -eq "1") {
    # ENCRYPTION
    Write-Host "`nEncryption Mode" -ForegroundColor Green
    
    $filePath = Read-Host "Enter the file path to encrypt"
    if (-not (Test-Path $filePath)) {
        Write-Host "File does not exist at the specified path." -ForegroundColor Red
        exit
    }

    $encryptedPath = "$filePath.enc"
    if (Test-Path $encryptedPath) {
        $overwrite = Read-Host "Encrypted file already exists. Overwrite? (y/n)"
        if ($overwrite -ne 'y') {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
            exit
        }
    }

    $password = Read-Host "Enter the password to encrypt the file" -AsSecureString
    
    # 16 bytes is the standard size for AES-256
    $salt = New-Object byte[] 16
    $iv = New-Object byte[] 16
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
    $rng.GetBytes($salt)
    $rng.GetBytes($iv)
    
    try {
        # Key from password
        $keyGen = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($password, $salt, 10000)
        $key = $keyGen.GetBytes(32)

        # Setup AES
        $aes = [System.Security.Cryptography.Aes]::Create()
        $aes.Mode = 'CBC'
        $aes.Padding = 'PKCS7'
        $aes.KeySize = 256
        $aes.Key = $key
        $aes.IV = $iv
        $encryptor = $aes.CreateEncryptor()

        # Encrypt file
        $plainBytes = [System.IO.File]::ReadAllBytes($filePath)
        $encryptedBytes = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)

        # Salt + vector + data
        $finalOutput = $salt + $iv + $encryptedBytes
        [System.IO.File]::WriteAllBytes($encryptedPath, $finalOutput)

        Write-Host "File encrypted successfully: $encryptedPath" -ForegroundColor Green
    }
    catch {
        Write-Host "Encryption failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        # Clean up from memory just in to follow best practices
        if ($encryptor) { $encryptor.Dispose() }
        if ($aes) { $aes.Dispose() }
        if ($keyGen) { $keyGen.Dispose() }
        if ($rng) { $rng.Dispose() }
    }
}
elseif ($choice -eq "2") {
    # DECRYPTION
    Write-Host "`nDecryption Mode" -ForegroundColor Green
    
    $filePath = Read-Host "Enter the path to the encrypted file (.enc)"
    if (-not (Test-Path $filePath)) {
        Write-Host "Encrypted file does not exist at the specified path." -ForegroundColor Red
        exit
    }

    $decryptedPath = $filePath -replace '\.enc$', '.decrypted'
    if (Test-Path $decryptedPath) {
        $overwrite = Read-Host "Decrypted file already exists. Overwrite? (y/n)"
        if ($overwrite -ne 'y') {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
            exit
        }
    }

    $password = Read-Host "Enter the password to decrypt the file" -AsSecureString
    
    try {
        # Read encrypted file
        $encryptedData = [System.IO.File]::ReadAllBytes($filePath)
        
        if ($encryptedData.Length -lt 32) {
            throw "Invalid encrypted file format"
        }

        # Extract salt, IV, and data
        $salt = $encryptedData[0..15]
        $iv = $encryptedData[16..31]
        $encryptedBytes = $encryptedData[32..($encryptedData.Length-1)]

        # Key from password
        $keyGen = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($password, $salt, 10000)
        $key = $keyGen.GetBytes(32)

        # Setup AES
        $aes = [System.Security.Cryptography.Aes]::Create()
        $aes.Mode = 'CBC'
        $aes.Padding = 'PKCS7'
        $aes.KeySize = 256
        $aes.Key = $key
        $aes.IV = $iv
        $decryptor = $aes.CreateDecryptor()

        $decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
        [System.IO.File]::WriteAllBytes($decryptedPath, $decryptedBytes)

        Write-Host "File decrypted successfully: $decryptedPath" -ForegroundColor Green
    }
    catch {
        Write-Host "Decryption failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Check your password or file integrity." -ForegroundColor Yellow
    }
    finally {
        # Clean up
        if ($decryptor) { $decryptor.Dispose() }
        if ($aes) { $aes.Dispose() }
        if ($keyGen) { $keyGen.Dispose() }
    }
}
else {
    Write-Host "Invalid choice. Please enter 1 or 2." -ForegroundColor Red
}