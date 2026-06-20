import pandas as pd
import sqlite3
import os

# Configuración de variables de entorno y directorios
# Origen de los datasets crudos (Archivos INEGI)
ruta_carpeta_datos = r'C:\Users\Angel Zivec\Desktop\Portafolio de Analisis\1\2-Exportaciones\4-Conjunto_de_datos'

# Destino para la creación/conexión de la BD SQLite
ruta_base_datos = r'C:\Users\Angel Zivec\Desktop\Portafolio de Analisis\1\2-Exportaciones\02_Base_Datos\Industria_Automotriz_Raw.sqlite'

# Diccionario para mapeo de prefijos de archivos hacia sus tablas SQL correspondientes
mapeo_reportes = {
    '0.0': {'nombre_grupo': 'Exportaciones', 'tabla_sql': '0_0_Historico_Exportaciones', 'lista_dfs': []},
    '1.0': {'nombre_grupo': 'Híbridos y Eléctricos', 'tabla_sql': '1_0_Historico_Ventas_Hibridos', 'lista_dfs': []},
    '2.0': {'nombre_grupo': 'Producción', 'tabla_sql': '2_0_Historico_Produccion', 'lista_dfs': []},
    '3.0': {'nombre_grupo': 'Ventas Todo Tipo', 'tabla_sql': '3_0_Historico_Ventas_Todo_Tipo', 'lista_dfs': []}
}

print("Iniciando pipeline de ingesta (Raw Data)...")

# Validación de existencia de ruta origen
if not os.path.exists(ruta_carpeta_datos):
    print(f"Error: No se encontró el directorio de origen -> {ruta_carpeta_datos}")
    exit()

# Asegurar creación del directorio destino si no existe
os.makedirs(os.path.dirname(ruta_base_datos), exist_ok=True)

# ------------------------------------------------------------------------------
# Fase de Extracción y Clasificación
# ------------------------------------------------------------------------------
archivos_en_carpeta = os.listdir(ruta_carpeta_datos)
print(f"Se identificaron {len(archivos_en_carpeta)} elementos en el origen.")

for archivo in archivos_en_carpeta:
    ruta_completa_archivo = os.path.join(ruta_carpeta_datos, archivo)
    
    # Filtrar solo archivos válidos (descartar subdirectorios)
    if os.path.isfile(ruta_completa_archivo):
        es_excel = archivo.endswith('.xlsx') or archivo.endswith('.xls')
        es_csv = archivo.endswith('.csv')
        
        if es_excel or es_csv:
            # Extracción del prefijo identificador (ej: '0.0')
            prefijo = archivo[:3]
            
            if prefijo in mapeo_reportes:
                try:
                    print(f"Leyendo dataset: {archivo}")
                    
                    if es_excel:
                        df_temporal = pd.read_excel(ruta_completa_archivo)
                    else:
                        # Uso de latin1 para manejar codificación nativa del INEGI
                        df_temporal = pd.read_csv(ruta_completa_archivo, encoding='latin1')
                    
                    # Almacenamiento temporal en memoria según grupo
                    mapeo_reportes[prefijo]['lista_dfs'].append(df_temporal)
                    
                except Exception as e:
                    print(f"Error de lectura en archivo {archivo}: {e}")

# ------------------------------------------------------------------------------
# Fase de Transformación (Concatenación) y Carga (SQL)
# ------------------------------------------------------------------------------
try:
    # Conexión al motor SQLite
    conn = sqlite3.connect(ruta_base_datos)
    print(f"\nConexión exitosa a BD: {ruta_base_datos}")
    
    for prefijo, info in mapeo_reportes.items():
        print(f"\nProcesando bloque: {info['nombre_grupo']}...")
        
        if len(info['lista_dfs']) > 0:
            # Apilamiento vertical de archivos históricos
            df_historico_consolidado = pd.concat(info['lista_dfs'], ignore_index=True)
            
            # Volcado de estructura final a SQL
            print(f"Ejecutando volcado en tabla: {info['tabla_sql']}...")
            df_historico_consolidado.to_sql(
                name=info['tabla_sql'], 
                con=conn, 
                if_exists='replace', # Sobrescribe en caso de reprocesamiento
                index=False
            )
            print(f"Volcado completado. {len(df_historico_consolidado)} registros insertados.")
        else:
            print(f"Advertencia: Bloque vacío para prefijo {prefijo}")
            
    conn.commit()
    conn.close()
    print("\nEjecución ETL finalizada correctamente. Tablas raw disponibles en SQLite.")

except Exception as e:
    print(f"\nExcepción crítica durante la carga a SQL: {e}")
