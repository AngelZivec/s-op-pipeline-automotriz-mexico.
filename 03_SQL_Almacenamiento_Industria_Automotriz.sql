/* ==============================================================================
   PROYECTO: Sistema S&OP Automotriz
   FASE: Modelado y Estructuración Relacional (Paso a Tablas V3 - Capa Oro)
   
   OBJETIVO: 
   Transformar las tablas de la "Capa Plata" (V2) en "Capa Oro". 
   Aquí se aplican las reglas de negocio finales: creación de llaves primarias 
   sintéticas y normalización de fechas para habilitar la Inteligencia de Tiempo 
   (Time Intelligence) nativa en Power BI.
   ============================================================================== */

-- ------------------------------------------------------------------------------
-- 1. TABLA FINAL: EXPORTACIONES
-- Nota: La creación de ID_Vehiculo es vital para evitar ambigüedades al cruzar 
-- datos con Dim_Vehiculos. El formato de fecha YYYY-MM-DD es el estándar 
-- requerido por Power BI para reconocer el campo como un tipo 'Date'.
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS "0_0_Historico_Exportaciones_V3";

CREATE TABLE "0_0_Historico_Exportaciones_V3" AS
SELECT 
    -- Llave compuesta: Asegura una relación única entre el vehículo y sus características
    UPPER(MARCA || '-' || MODELO || '-' || TIPO || '-' || SEGMENTO) AS ID_Vehiculo,
    
    -- Conversión a fecha: Crea una columna de tipo fecha (primer día del mes)
    printf('%04d-%02d-01', ANIO, ID_MES) AS Fecha,
    
    PROD_EST, COBERTURA, ANIO, ID_MES, MARCA, MODELO, TIPO, 
    SEGMENTO, ID_PAIS_DESTINO, Pais, UNI_VEH, ESTATUS
FROM "0_0_Historico_Exportaciones_V2";

-- ------------------------------------------------------------------------------
-- 2. TABLA FINAL: PRODUCCIÓN
-- Nota: Se mantiene la consistencia de la llave 'ID_Vehiculo' aquí para que, 
-- al cargarla en Power BI, el modelo en estrella (Star Schema) pueda conectar 
-- esta tabla con las de Exportaciones y Ventas bajo la misma dimensión.
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS "2_0_Historico_Produccion_V3";

CREATE TABLE "2_0_Historico_Produccion_V3" AS
SELECT 
    UPPER(MARCA || '-' || MODELO || '-' || TIPO || '-' || SEGMENTO) AS ID_Vehiculo,
    
    printf('%04d-%02d-01', ANIO, ID_MES) AS Fecha,
    
    PROD_EST, COBERTURA, ANIO, ID_MES, MARCA, MODELO, TIPO, 
    SEGMENTO, UNI_VEH, ESTATUS
FROM "2_0_Historico_Produccion_V2";

-- ------------------------------------------------------------------------------
-- 3. TABLA FINAL: VENTAS MERCADO INTERNO (TODO TIPO)
-- Nota: En esta tabla, la inclusión de 'Pais Origen' permite realizar un 
-- análisis de origen del producto, fundamental para el reporte S&OP de 
-- importaciones vs. producción nacional.
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS "3_0_Ventas_V3";

CREATE TABLE "3_0_Ventas_V3" AS
SELECT 
    UPPER(MARCA || '-' || MODELO || '-' || TIPO || '-' || SEGMENTO) AS ID_Vehiculo,
    
    printf('%04d-%02d-01', ANIO, ID_MES) AS Fecha,
    
    PROD_EST, COBERTURA, ANIO, ID_MES, MARCA, MODELO, TIPO, 
    SEGMENTO, ORIGEN, ID_PAIS_ORIGEN, "Pais Origen", UNI_VEH, ESTATUS
FROM "3_0_Historico_Ventas_Todo_Tipo_V2";

-- ------------------------------------------------------------------------------
-- 4. TABLA FINAL: VENTAS VEHÍCULOS ECOLÓGICOS (HÍBRIDOS/ELÉCTRICOS)
-- Nota: A diferencia de las anteriores, esta tabla no requiere 'ID_Vehiculo' 
-- porque su granularidad es por 'Entidad Federativa' y no por modelo de vehículo.
-- Se mantiene la fecha estandarizada para permitir comparativas temporales 
-- con las otras tablas de ventas.
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS "1_0_Historico_Ventas_Hibridos_V3";

CREATE TABLE "1_0_Historico_Ventas_Hibridos_V3" AS
SELECT 
    printf('%04d-%02d-01', ANIO, ID_MES) AS Fecha,
    
    PROD_EST, COBERTURA, ANIO, ID_MES, ID_ENTIDAD, Entidad, 
    VEH_ELECTR, VEH_HIBRIDAS_PLUGIN, VEH_HIBRIDAS, ESTATUS
FROM "1_0_Historico_Ventas_Hibridos_V2";
