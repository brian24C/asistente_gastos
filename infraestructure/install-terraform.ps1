# Script de instalación de Terraform y Terragrunt para Windows
# Ejecutar como Administrador: Set-ExecutionPolicy Bypass -Scope Process -Force; .\install-terraform.ps1

Write-Host "🚀 Instalando Terraform y Terragrunt..." -ForegroundColor Cyan

# Verificar si winget está disponible
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "✅ winget encontrado. Instalando con winget..." -ForegroundColor Green
    
    # Instalar Terraform
    Write-Host "📦 Instalando Terraform..." -ForegroundColor Yellow
    winget install --id HashiCorp.Terraform --accept-package-agreements --accept-source-agreements
    
    # Instalar Terragrunt
    Write-Host "📦 Instalando Terragrunt..." -ForegroundColor Yellow
    winget install --id Gruntwork.Terragrunt --accept-package-agreements --accept-source-agreements
    
    Write-Host "✅ Instalación completada!" -ForegroundColor Green
    Write-Host ""
    Write-Host "⚠️  IMPORTANTE: Cierra y vuelve a abrir PowerShell para que los cambios surtan efecto." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Luego verifica la instalación con:" -ForegroundColor Cyan
    Write-Host "  terraform version" -ForegroundColor White
    Write-Host "  terragrunt --version" -ForegroundColor White
    
} elseif (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "✅ Chocolatey encontrado. Instalando con Chocolatey..." -ForegroundColor Green
    
    # Instalar Terraform
    Write-Host "📦 Instalando Terraform..." -ForegroundColor Yellow
    choco install terraform -y
    
    # Instalar Terragrunt
    Write-Host "📦 Instalando Terragrunt..." -ForegroundColor Yellow
    choco install terragrunt -y
    
    Write-Host "✅ Instalación completada!" -ForegroundColor Green
    Write-Host ""
    Write-Host "⚠️  IMPORTANTE: Cierra y vuelve a abrir PowerShell para que los cambios surtan efecto." -ForegroundColor Yellow
    
} else {
    Write-Host "❌ No se encontró winget ni Chocolatey." -ForegroundColor Red
    Write-Host ""
    Write-Host "Opciones de instalación manual:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Instalar Chocolatey primero:" -ForegroundColor Cyan
    Write-Host "   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -ForegroundColor White
    Write-Host ""
    Write-Host "2. O descargar manualmente:" -ForegroundColor Cyan
    Write-Host "   Terraform: https://www.terraform.io/downloads" -ForegroundColor White
    Write-Host "   Terragrunt: https://github.com/gruntwork-io/terragrunt/releases" -ForegroundColor White
    Write-Host ""
    Write-Host "   Luego agregar los ejecutables al PATH del sistema." -ForegroundColor White
}

