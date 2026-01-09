# 🚀 Guía de Despliegue con Terragrunt

Esta guía te ayudará a desplegar la infraestructura de AWS Lambda usando Terragrunt.

## 📋 Prerrequisitos

### 1. Instalar Terraform

**Opción A: Con Chocolatey (Recomendado)**
```powershell
# Verificar si Chocolatey está instalado
choco --version

# Si no está instalado, instálalo primero (ejecutar como Administrador):
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Instalar Terraform
choco install terraform -y

# Verificar instalación
terraform version
```

**Opción B: Instalación Manual**
```powershell
# 1. Descargar Terraform desde: https://www.terraform.io/downloads
# 2. Extraer el archivo terraform.exe
# 3. Agregar al PATH o copiar a una carpeta en el PATH (ej: C:\Windows\System32)
# 4. Verificar instalación
terraform version
```

**Opción C: Con winget (Windows 10/11)**
```powershell
winget install HashiCorp.Terraform
terraform version
```

### 2. Instalar Terragrunt

**Opción A: Con Chocolatey**
```powershell
choco install terragrunt -y
terragrunt --version
```

**Opción B: Instalación Manual**
```powershell
# 1. Descargar desde: https://github.com/gruntwork-io/terragrunt/releases
# 2. Descargar terragrunt_windows_amd64.exe
# 3. Renombrar a terragrunt.exe
# 4. Agregar al PATH o copiar a una carpeta en el PATH
# 5. Verificar instalación
terragrunt --version
```

**Opción C: Con winget**
```powershell
winget install Gruntwork.Terragrunt
terragrunt --version
```

3. **AWS CLI** configurado con credenciales
   ```bash
   aws configure
   # O usa variables de entorno:
   # AWS_ACCESS_KEY_ID
   # AWS_SECRET_ACCESS_KEY
   # AWS_DEFAULT_REGION
   ```

4. **Imagen Docker en ECR** (ya completado ✅)
   - Tu imagen debe estar en: `<AWS_ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/asistente-gastos:v1.0.0`
   - Reemplaza `<AWS_ACCOUNT_ID>` con tu Account ID de AWS
   - O actualiza el `image_uri` en `terragrunt.hcl` con tu versión

## 🔐 Configurar Variables de Entorno

Antes de ejecutar Terragrunt, necesitas configurar las siguientes variables de entorno:

### Opción 1: Variables de Entorno del Sistema (Recomendado)

En **PowerShell**:
```powershell
$env:TELEGRAM_BOT_TOKEN = "tu_token_de_telegram"
$env:GEMINI_API_KEY = "tu_clave_api_gemini"
$env:GOOGLE_SHEET_ID = "id_de_tu_hoja_google"
$env:GOOGLE_CREDENTIALS_JSON = "tu_json_base64"
```

En **CMD**:
```cmd
set TELEGRAM_BOT_TOKEN=tu_token_de_telegram
set GEMINI_API_KEY=tu_clave_api_gemini
set GOOGLE_SHEET_ID=id_de_tu_hoja_google
set GOOGLE_CREDENTIALS_JSON=tu_json_base64
```

> 💡 **Nota**: `GOOGLE_CREDENTIALS_JSON` debe contener el JSON de tu Service Account ya codificado en Base64.

### Opción 2: Archivo .env (Alternativa)

Crea un archivo `.env` en la raíz del proyecto y carga las variables:

```bash
# PowerShell
Get-Content .env | ForEach-Object {
    $name, $value = $_.split('=', 2)
    Set-Item -Path "env:$name" -Value $value
}
```

### 📝 Obtener los Valores

1. **TELEGRAM_BOT_TOKEN**: 
   - Crea un bot con [@BotFather](https://t.me/BotFather) en Telegram
   - Formato: `123456789:ABCdefGHI...`

2. **GEMINI_API_KEY**: 
   - Obtén tu API key desde [Google AI Studio](https://makersuite.google.com/app/apikey)

3. **GOOGLE_SHEET_ID**: 
   - Abre tu Google Sheet
   - El ID está en la URL: `https://docs.google.com/spreadsheets/d/[SHEET_ID]/edit`

4. **GOOGLE_CREDENTIALS_JSON**: 
   - Descarga el JSON de tu Service Account desde Google Cloud Console
   - Convierte el JSON a Base64:
     ```powershell
     # PowerShell
     $json = Get-Content -Path "ruta/a/tu/service-account.json" -Raw
     [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($json))
     ```
   - Agrega el valor Base64 a tu `.env` como `GOOGLE_CREDENTIALS_JSON`
   > 💡 **Nota**: El valor debe estar ya codificado en Base64. El módulo de Terraform lo configurará en la Lambda como `GOOGLE_CREDENTIALS_JSON_BASE64` automáticamente.

## 🏃 Ejecutar Terragrunt

### Opción 1: Usar el Script Helper (Recomendado si tienes archivo .env) ⭐

Si tienes un archivo `.env` en la raíz del proyecto, usa el script helper que carga automáticamente las variables:

```powershell
cd infraestructure/prod/lamda
.\deploy.ps1
```

Esto ejecutará automáticamente: `init` → `plan` → `apply` → `output`

O ejecuta comandos específicos:
```powershell
.\deploy.ps1 init      # Solo inicializar
.\deploy.ps1 plan      # Solo ver el plan
.\deploy.ps1 apply     # Solo aplicar
.\deploy.ps1 output    # Ver outputs (incluye function_url)
.\deploy.ps1 destroy   # Destruir infraestructura
```

**El script:**
- ✅ Busca y carga automáticamente el archivo `.env` de la raíz del proyecto
- ✅ Verifica que todas las variables requeridas estén configuradas
- ✅ Ejecuta Terragrunt con las variables cargadas

### Opción 2: Ejecutar Terragrunt Manualmente

Si prefieres ejecutar Terragrunt directamente:

#### 1. Cargar variables desde .env (si tienes archivo .env)

```powershell
# Desde la raíz del proyecto
Get-Content .env | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)\s*=\s*(.+)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        if ($value -match '^["''](.+)["'']$') { $value = $matches[1] }
        Set-Item -Path "env:$name" -Value $value
    }
}
```

#### 2. Navegar al directorio de Terragrunt

```bash
cd infraestructure/prod/lamda
```

#### 3. Inicializar Terragrunt

```bash
terragrunt init
```

Este comando:
- Descarga el módulo de Terraform
- Configura el backend (si está configurado)
- Prepara el entorno

#### 4. Revisar el Plan (Opcional pero Recomendado)

```bash
terragrunt plan
```

Esto te mostrará qué recursos se van a crear/modificar sin aplicar cambios.

#### 5. Aplicar la Infraestructura

```bash
terragrunt apply
```

Terragrunt te pedirá confirmación. Escribe `yes` para continuar.

#### 6. Ver la URL de la Lambda

Después del despliegue, Terragrunt mostrará la URL de la función Lambda:

```bash
terragrunt output function_url
```

## 🔄 Actualizar la Infraestructura

Si cambias el `image_uri` en `terragrunt.hcl` o cualquier otra variable:

```bash
cd infraestructure/prod/lamda
terragrunt plan    # Revisar cambios
terragrunt apply   # Aplicar cambios
```

## 🗑️ Destruir la Infraestructura

Si necesitas eliminar todos los recursos:

```bash
cd infraestructure/prod/lamda
terragrunt destroy
```

⚠️ **Advertencia**: Esto eliminará la función Lambda y todos los recursos asociados.

## 📊 Verificar el Despliegue

### Verificar la Lambda

```bash
aws lambda get-function \
  --function-name asistente-gastos \
  --region us-east-2
```

### Ver los Logs

```bash
aws logs tail /aws/lambda/asistente-gastos \
  --region us-east-2 \
  --since 5m \
  --follow
```

### Probar la Lambda URL

```bash
curl -X POST "https://<lambda-url>/" \
  -H "Content-Type: application/json" \
  -d '{"message":{"text":"gasté 20000 en empanadas","chat":{"id":12345}}}'
```

## 🐛 Solución de Problemas

### Error: "Missing required variable"

Asegúrate de que todas las variables de entorno estén configuradas:
```bash
# PowerShell
$env:TELEGRAM_BOT_TOKEN
$env:GEMINI_API_KEY
$env:GOOGLE_SHEET_ID
$env:GOOGLE_CREDENTIALS_JSON
```

### Error: "Image not found in ECR"

Verifica que la imagen existe en ECR:
```bash
aws ecr describe-images \
  --repository-name asistente-gastos \
  --region us-east-2
```

### Error: "Access Denied"

Verifica tus credenciales de AWS:
```bash
aws sts get-caller-identity
```

## 📚 Recursos Adicionales

- [Documentación de Terragrunt](https://terragrunt.gruntwork.io/docs/)
- [Documentación de Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Lambda con Docker](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html)

