import json
import os
import logging
from datetime import date, datetime
from zoneinfo import ZoneInfo

import dotenv
import google.generativeai as gen
from google.api_core import exceptions

dotenv.load_dotenv()
gen.configure(api_key=os.environ["GEMINI_API_KEY"])
TZ = ZoneInfo("America/Lima")

logger = logging.getLogger()

# Lista de modelos en orden de preferencia (fallback automático)
MODELS = [
    "models/gemini-2.5-flash",      # 20 requests/día (gratis)
    "models/gemini-2.5-flash-lite", # Más cuota disponible
]

SYSTEM_PROMPT = """
Eres un extractor de información de gastos. Devuelves SOLO JSON válido, sin texto adicional, sin ```.

El JSON DEBE ser exactamente este:
{
  "monto": float,
  "categoria": string,
  "descripcion": string
}

CATEGORÍAS (elige la más apropiada):
- "comida": restaurantes, delivery, cafeterías, snacks, bebidas, comida rápida
- "mercado": supermercado, tienda, abarrotes, compras de alimentos para cocinar
- "transporte": taxi, uber, bus, gasolina, estacionamiento, peajes, pasajes
- "servicios domesticos": luz, agua, gas, internet, teléfono, cable, alquiler
- "salud": farmacia, médico, dentista, seguro, medicinas, consultas
- "ocio": cine, conciertos, entretenimiento, juegos, suscripciones (Netflix, Spotify)
- "gastos": compras generales, ropa, tecnología, artículos del hogar
- "otros": cualquier gasto que no encaje en las categorías anteriores

REGLAS:
- Categoriza inteligentemente: "pizza" → "comida", "supermercado" → "mercado", "uber" → "transporte".
- No incluyas comentarios, explicaciones ni texto fuera del JSON.
"""


def parse_gasto(texto):
    prompt = SYSTEM_PROMPT + "\nUsuario: " + texto
    
    # Intentar con cada modelo hasta que uno funcione
    last_error = None
    
    for model_name in MODELS:
        try:
            logger.info(f"Intentando con modelo: {model_name}")
            
            response = gen.GenerativeModel(
                model_name,
                generation_config={
                    "response_mime_type": "application/json"
                },
            ).generate_content(prompt)

            data = json.loads(response.text)
            
            # Siempre asignar la fecha actual de Lima, Perú (ignorar cualquier fecha que devuelva la IA)
            data["fecha"] = datetime.now(TZ).date().isoformat()
            
            logger.info(f"✅ Éxito con modelo: {model_name}")
            return data
            
        except exceptions.ResourceExhausted as e:
            # Cuota agotada, intentar con el siguiente modelo
            logger.warning(f"⚠️ Cuota agotada para {model_name}: {str(e)}")
            last_error = e
            continue
            
        except Exception as e:
            # Otro tipo de error, intentar con el siguiente modelo
            logger.warning(f"⚠️ Error con {model_name}: {str(e)}")
            last_error = e
            continue
    
    # Si llegamos aquí, todos los modelos fallaron
    logger.error(f"❌ Todos los modelos fallaron. Último error: {last_error}")
    raise RuntimeError(f"No se pudo procesar el gasto. Todos los modelos fallaron. Último error: {last_error}")