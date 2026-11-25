# Gera o SQL administrativo fora do repositório, solicitando a senha sem eco.
$ErrorActionPreference = 'Stop'

$securePassword = Read-Host 'Senha administrativa (12+ caracteres, maiúscula, minúscula e número)' -AsSecureString
$passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
try {
  $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)
} finally {
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
}

try {
  if ($plainPassword.Length -lt 12 -or $plainPassword -notmatch '[a-z]' -or $plainPassword -notmatch '[A-Z]' -or $plainPassword -notmatch '[0-9]') {
    throw 'A senha administrativa precisa ter 12 caracteres, letra maiúscula, minúscula e número.'
  }

  $env:ADMIN_PASSWORD = $plainPassword
  try {
    $hash = (node --input-type=module -e "import bcrypt from 'bcryptjs'; console.log(await bcrypt.hash(process.env.ADMIN_PASSWORD, 12))").Trim()
  } finally {
    Remove-Item Env:ADMIN_PASSWORD -ErrorAction SilentlyContinue
    $plainPassword = $null
  }

  $templatePath = Join-Path $PSScriptRoot '..\database\create-admin.sql'
  $sql = Get-Content -Raw -LiteralPath $templatePath
  $sql = $sql.Replace('SET @admin_name = NULL; -- substitua pelo nome do administrador', "SET @admin_name = 'Administrador Doc Motor';")
  $sql = $sql.Replace('SET @admin_email = NULL; -- substitua pelo e-mail do administrador', "SET @admin_email = 'admin@docmotor.online';")
  $sql = $sql.Replace('SET @admin_password_hash = NULL; -- substitua pelo hash bcrypt gerado localmente', "SET @admin_password_hash = '$hash';")

  $outputPath = Join-Path $env:TEMP ("doc-motor-create-admin-$([Guid]::NewGuid()).sql")
  [IO.File]::WriteAllText($outputPath, $sql, [Text.UTF8Encoding]::new($false))
  Write-Output "SQL administrativo temporário criado em: $outputPath"
  Write-Output 'Importe o arquivo no phpMyAdmin e remova-o após o uso. Ele não está dentro do repositório.'
} finally {
  $plainPassword = $null
  $hash = $null
}
