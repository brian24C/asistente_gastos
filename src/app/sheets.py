import base64
import json
import os
import logging

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

logger = logging.getLogger()


def get_google_credentials():
    creds_b64 = os.getenv("GOOGLE_CREDENTIALS_JSON_BASE64")
    if not creds_b64:
        raise RuntimeError("Missing GOOGLE_CREDENTIALS_JSON_BASE64")

    creds_json = base64.b64decode(creds_b64).decode("utf-8")
    creds_dict = json.loads(creds_json)
    
    return service_account.Credentials.from_service_account_info(creds_dict)


def append_gasto(gasto):
    try:
        creds = get_google_credentials()
        service = build("sheets", "v4", credentials=creds)

        values = [[gasto["fecha"], gasto["monto"], gasto["categoria"], gasto["descripcion"], gasto["quien"]]]
        body = {"values": values}

        SHEET_ID = os.getenv("GOOGLE_SHEET_ID")
        
        # Usar directamente el nombre de la primera pestaña por defecto
        # En español: "Hoja 1", en inglés: "Sheet1"
        # Si tu hoja tiene otro nombre, cámbialo aquí o usa la primera pestaña que encuentres
        # Para evitar la llamada adicional que consume memoria, usamos "Hoja 1" directamente
        sheet_name = "registros"  # Nombre por defecto en Google Sheets en español
        
        # Agregar los datos directamente (append agregará después de la última fila)
        result = service.spreadsheets().values().append(
            spreadsheetId=SHEET_ID,
            range=f"{sheet_name}!A:E",
            valueInputOption="USER_ENTERED",
            body=body,
        ).execute()
        
        logger.info(f"✅ Escrito exitosamente en '{sheet_name}'. Filas actualizadas: {result.get('updates', {}).get('updatedRows', 0)}")
        
    except HttpError as error:
        error_details = json.loads(error.content.decode('utf-8')) if error.content else {}
        logger.error(f"❌ Error HTTP {error.resp.status}: {error.resp.reason}")
        logger.error(f"Detalles: {error_details}")
        
        if error.resp.status == 403:
            logger.error("🔒 Error 403: Permisos denegados")
            logger.error("💡 Asegúrate de compartir tu Google Sheet con el email del Service Account")
            # Obtener el email del Service Account
            try:
                creds_b64 = os.getenv("GOOGLE_CREDENTIALS_JSON_BASE64")
                if creds_b64:
                    creds_json = base64.b64decode(creds_b64).decode("utf-8")
                    creds_dict = json.loads(creds_json)
                    sa_email = creds_dict.get("client_email", "unknown")
                    logger.error(f"   Email del Service Account: {sa_email}")
                    logger.error(f"   Acción: Comparte tu Google Sheet con este email y dale permisos de 'Editor'")
            except:
                pass
        elif error.resp.status == 400:
            logger.error("🔴 Error 400: Solicitud inválida")
            logger.error("💡 Verifica que el Sheet ID sea correcto y que la pestaña 'registros' exista")
        elif error.resp.status == 404:
            logger.error("🔴 Error 404: No se encontró el Sheet")
            logger.error("💡 Verifica que el GOOGLE_SHEET_ID sea correcto")
        
        raise
    except Exception as e:
        logger.error(f"❌ Error inesperado: {type(e).__name__}: {str(e)}")
        raise
