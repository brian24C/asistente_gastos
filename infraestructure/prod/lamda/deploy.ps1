# Script para desplegar con Terragrunt cargando variables desde .env
# Uso: .\deploy.ps1 [init|plan|apply|destroy|output]

param(
    [Parameter(Position=0)]
    [ValidateSet("init", "plan", "apply", "destroy", "output", "all")]
    [string]$Action = "all"
)

$ErrorActionPreference = "Stop"

# Obtener la ruta del archivo .env (en la raíz del proyecto)
$projectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$envFile = Join-Path $projectRoot ".env"

Write-Host "🔍 Buscando archivo .env en: $envFile" -ForegroundColor Cyan

# Cargar variables desde .env si existe
if (Test-Path $envFile) {
    Write-Host "✅ Archivo .env encontrado. Cargando variables..." -ForegroundColor Green
    
    Get-Content $envFile | ForEach-Object {
        # Ignorar líneas vacías y comentarios
        if ($_ -match '^\s*([^#][^=]+)\s*=\s*(.+)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            # Remover comillas si las tiene
            if ($value -match '^["''](.+)["'']$') {
                $value = $matches[1]
            }
            
            # Configurar variable de entorno
            Set-Item -Path "env:$name" -Value $value
            Write-Host "  ✓ $name" -ForegroundColor Gray
        }
    }
    
    Write-Host "✅ Variables cargadas desde .env" -ForegroundColor Green
} else {
    Write-Host "⚠️  Archivo .env no encontrado en: $envFile" -ForegroundColor Yellow
    Write-Host "   Asegúrate de tener las variables de entorno configuradas:" -ForegroundColor Yellow
    Write-Host "   - TELEGRAM_BOT_TOKEN" -ForegroundColor Yellow
    Write-Host "   - GEMINI_API_KEY" -ForegroundColor Yellow
    Write-Host "   - GOOGLE_SHEET_ID" -ForegroundColor Yellow
    Write-Host "   - GOOGLE_CREDENTIALS_JSON" -ForegroundColor Yellow
    Write-Host ""
}

# Verificar que las variables requeridas estén configuradas
$requiredVars = @(
    "TELEGRAM_BOT_TOKEN",
    "GEMINI_API_KEY", 
    "GOOGLE_SHEET_ID",
    "GOOGLE_CREDENTIALS_JSON"
)

$missingVars = @()
foreach ($var in $requiredVars) {
    if (-not (Get-Item "env:$var" -ErrorAction SilentlyContinue)) {
        $missingVars += $var
    }
}

if ($missingVars.Count -gt 0) {
    Write-Host "❌ Faltan las siguientes variables de entorno:" -ForegroundColor Red
    foreach ($var in $missingVars) {
        Write-Host "   - $var" -ForegroundColor Red
    }
    exit 1
}

Write-Host ""
Write-Host "🚀 Ejecutando Terragrunt..." -ForegroundColor Cyan
Write-Host ""

# Cambiar al directorio de Terragrunt
Set-Location $PSScriptRoot

# Ejecutar comandos según la acción
switch ($Action) {
    "init" {
        terragrunt init
    }
    "plan" {
        terragrunt plan
    }
    "apply" {
        terragrunt apply
    }
    "destroy" {
        terragrunt destroy
    }
    "output" {
        terragrunt output
    }
    "all" {
        Write-Host "📦 Paso 1/3: Inicializando Terragrunt..." -ForegroundColor Yellow
        terragrunt init
        
        Write-Host ""
        Write-Host "📋 Paso 2/3: Generando plan..." -ForegroundColor Yellow
        terragrunt plan
        
        Write-Host ""
        Write-Host "🚀 Paso 3/3: Aplicando cambios..." -ForegroundColor Yellow
        Write-Host "   (Escribe 'yes' cuando te lo pida)" -ForegroundColor Gray
        terragrunt apply
        
        Write-Host ""
        Write-Host "✅ Despliegue completado!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📡 Obteniendo URL de la Lambda..." -ForegroundColor Cyan
        terragrunt output function_url
    }
}

