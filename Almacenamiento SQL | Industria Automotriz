-- ==============================================================================
-- PROYECTO: Sistema S&OP Automotriz
-- FASE: Modelado y Estructuración Relacional (Paso a Tablas V3)
-- OBJETIVO: Generar llaves de conexión para el modelo de estrella y formatear 
--           fechas para la Inteligencia de Tiempo en Power BI.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. TABLA FINAL: EXPORTACIONES
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS "0_0_Historico_Exportaciones_V3";

CREATE TABLE "0_0_Historico_Exportaciones_V3" AS
SELECT 
    -- Generación de Llave Maestra para cruce relacional con Dim_Vehiculos
    UPPER(MARCA || '-' || MODELO || '-' || TIPO || '-' || SEGMENTO) AS ID_Vehiculo,
    
    -- Estandarización de fecha (YYYY-MM-DD) para habilitar Time Intelligence
    printf('%04d-%02d-01', ANIO, ID_MES) AS Fecha,
    
    PROD_EST, COBERTURA, ANIO, ID_MES, MARCA, MODELO, TIPO, 
    SEGMENTO, ID_PAIS_DESTINO, Pais, UNI_VEH, ESTATUS
FROM "0_0_Historico_Exportaciones_V2";

-- ------------------------------------------------------------------------------
-- 2. TABLA FINAL: PRODUCCIÓN
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS "2_0_Historico_Produccion_V3";

CREATE TABLE "2_0_Historico_Produccion_V3" AS
SELECT 
    -- Generación de Llave Maestra
    UPPER(MARCA || '-' || MODELO || '-' || TIPO || '-' || SEGMENTO) AS ID_Vehiculo,
    
    -- Estandarización de fecha
    printf('%04d-%02d-01', ANIO, ID_MES) AS Fecha,
    
    PROD_EST, COBERTURA, ANIO, ID_MES, MARCA, MODELO, TIPO, 
    SEGMENTO, UNI_VEH, ESTATUS
FROM "2_0_Historico_Produccion_V2";

-- ------------------------------------------------------------------------------
-- 3. TABLA FINAL: VENTAS MERCADO INTERNO (TODO TIPO)
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS "3_0_Ventas_V3";

CREATE TABLE "3_0_Ventas_V3" AS
SELECT 
    -- Generación de Llave Maestra
    UPPER(MARCA || '-' || MODELO || '-' || TIPO || '-' || SEGMENTO) AS ID_Vehiculo,
    
    -- Estandarización de fecha
    printf('%04d-%02d-01', ANIO, ID_MES) AS Fecha,
    
    PROD_EST, COBERTURA, ANIO, ID_MES, MARCA, MODELO, TIPO, 
    SEGMENTO, ORIGEN, ID_PAIS_ORIGEN, "Pais Origen", UNI_VEH, ESTATUS
FROM "3_0_Historico_Ventas_Todo_Tipo_V2";

-- ------------------------------------------------------------------------------
-- 4. TABLA FINAL: VENTAS VEHÍCULOS ECOLÓGICOS (HÍBRIDOS/ELÉCTRICOS)
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS "1_0_Historico_Ventas_Hibridos_V3";

CREATE TABLE "1_0_Historico_Ventas_Hibridos_V3" AS
SELECT 
    -- Estandarización de fecha (Módulo sin llaves de vehículo por nivel de granularidad)
    printf('%04d-%02d-01', ANIO, ID_MES) AS Fecha,
    
    PROD_EST, COBERTURA, ANIO, ID_MES, ID_ENTIDAD, Entidad, 
    VEH_ELECTR, VEH_HIBRIDAS_PLUGIN, VEH_HIBRIDAS, ESTATUS
FROM "1_0_Historico_Ventas_Hibridos_V2";
