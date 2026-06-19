import pandas as pd
import sqlite3
import os

# ==============================================================================
# 1. CONFIGURACIÓN DE RUTAS (Modifica estas rutas según tu computadora)
# ==============================================================================
# Pon la ruta exacta de tu carpeta "4-Conjunto_de_datos"
ruta_carpeta_datos = r'C:\Users\Angel Zivec\Desktop\Portafolio de Analisis\1\2-Exportaciones\4-Conjunto_de_datos'

# Pon la ruta donde quieres que se cree tu archivo de Base de Datos de SQLite
ruta_base_datos = r'C:\Users\Angel Zivec\Desktop\Portafolio de Analisis\1\2-Exportaciones\02_Base_Datos\Industria_Automotriz_Raw.sqlite'

# ==============================================================================
# 2. MAPEO DE PREFIJOS Y TABLAS DESTINO
# ==============================================================================
mapeo_reportes = {
    '0.0': {'nombre_grupo': 'Exportaciones', 'tabla_sql': '0_0_Historico_Exportaciones', 'lista_dfs': []},
    '1.0': {'nombre_grupo': 'Híbridos y Eléctricos', 'tabla_sql': '1_0_Historico_Ventas_Hibridos', 'lista_dfs': []},
    '2.0': {'nombre_grupo': 'Producción', 'tabla_sql': '2_0_Historico_Produccion', 'lista_dfs': []},
    '3.0': {'nombre_grupo': 'Ventas Todo Tipo', 'tabla_sql': '3_0_Historico_Ventas_Todo_Tipo', 'lista_dfs': []}
}

print("🚀 Iniciando el Sincronizador Maestro (Fase de Carga Cruda)...")

# Verificar que la carpeta exista antes de continuar
if not os.path.exists(ruta_carpeta_datos):
    print(f"❌ Error crítico: La ruta de la carpeta no existe: {ruta_carpeta_datos}")
    exit()

# Asegurar que la carpeta destino de la base de datos exista
os.makedirs(os.path.dirname(ruta_base_datos), exist_ok=True)

# ==============================================================================
# 3. LECTURA Y CLASIFICACIÓN DE ARCHIVOS
# ==============================================================================
archivos_en_carpeta = os.listdir(ruta_carpeta_datos)
print(f"📂 Se encontraron {len(archivos_en_carpeta)} elementos en la carpeta.")

for archivo in archivos_en_carpeta:
    ruta_completa_archivo = os.path.join(ruta_carpeta_datos, archivo)
    
    # Solo procesar archivos (omitir subcarpetas como 'Limpieza' o 'Explicacion de reportes')
    if os.path.isfile(ruta_completa_archivo):
        # Validar el formato del archivo
        es_excel = archivo.endswith('.xlsx') or archivo.endswith('.xls')
        es_csv = archivo.endswith('.csv')
        
        if es_excel or es_csv:
            # Identificar el prefijo del archivo (primeros 3 caracteres, ej: '0.0')
            prefijo = archivo[:3]
            
            if prefijo in mapeo_reportes:
                try:
                    print(f"📥 Leyendo archivo crudo: {archivo}")
                    # Cargar archivo según su tipo
                    if es_excel:
                        # Nota: Si el INEGI tiene renglones vacíos arriba, aquí agregarías skiprows=X
                        df_temporal = pd.read_excel(ruta_completa_archivo)
                    else:
                        df_temporal = pd.read_csv(ruta_completa_archivo, encoding='latin1') # latin1 evita errores de acentos en INEGI
                    
                    # Añadir el dataframe a su respectivo grupo histórico
                    mapeo_reportes[prefijo]['lista_dfs'].append(df_temporal)
                    
                except Exception as e:
                    print(f"⚠️ Error al leer el archivo {archivo}: {e}")

# ==============================================================================
# 4. CONCATENACIÓN E INYECCIÓN MASIVA A SQLITE
# ==============================================================================
try:
    # Abrir o crear la base de datos en SQLite
    conn = sqlite3.connect(ruta_base_datos)
    print(f"\n🗄️ Conexión establecida con la base de datos en: {ruta_base_datos}")
    
    for prefijo, info in mapeo_reportes.items():
        print(f"\n🔄 Procesando grupo {prefijo} [{info['nombre_grupo']}]...")
        
        if len(info['lista_dfs']) > 0:
            # PASO CRÍTICO: Apilar todos los años uno debajo del otro
            print(f"   🧩 Concatenando {len(info['lista_dfs'])} archivos anuales...")
            df_historico_consolidado = pd.concat(info['lista_dfs'], ignore_index=True)
            
            # PASO DE INYECCIÓN: Mandar a la tabla correspondiente sin modificaciones
            print(f"   💾 Inyectando datos en la tabla SQLite: '{info['tabla_sql']}'...")
            df_historico_consolidado.to_sql(
                name=info['tabla_sql'], 
                con=conn, 
                if_exists='replace', # Si ya existía la tabla de pruebas, la reemplaza con la nueva estructurada
                index=False
            )
            print(f"   ✅ ¡Éxito! Registros totales cargados: {len(df_historico_consolidado)}")
        else:
            print(f"   ⚠️ No se encontraron archivos para el prefijo {prefijo}")
            
    conn.commit()
    conn.close()
    print("\n🎉 ¡PROCESO DE INGESTACIÓN COMPLETO! Las 4 Súper Tablas Crudas ya están en el servidor SQLite.")

except Exception as e:
    print(f"\n❌ Error durante el proceso de inyección a la base de datos: {e}")