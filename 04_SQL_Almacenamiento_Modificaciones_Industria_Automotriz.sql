/* =================================================================================================
    PIPELINE DE DATOS S&OP AUTOMOTRIZ - LIMPIEZA Y MODELADO SQL
    Autor: [Tu Nombre/Usuario]
    Descripción: Script maestro de consolidación, limpieza y transformación de datos históricos 
                 del INEGI. Implementa una arquitectura por capas (Catálogos, Plata y Oro) 
                 preparando las entidades relacionales para su consumo directo en Power BI.
================================================================================================= */

-- =================================================================================================
-- FASE 1: MASTER DATA MANAGEMENT (CATÁLOGOS DIMENSIONALES)
-- Creación de catálogos estandarizados para homologar claves geográficas.
-- =================================================================================================

-- 1.1 Catálogo de Países (Encoding estandarizado)
CREATE TABLE IF NOT EXISTS cat_pais (
    id_pais INTEGER PRIMARY KEY,
    desc_pais TEXT
);

INSERT OR REPLACE INTO cat_pais (id_pais, desc_pais) VALUES
(1, 'México'), (2, 'Afganistán'), (3, 'Albania'), (4, 'Alemania'), (5, 'Andorra'),
(6, 'Angola'), (7, 'Anguila'), (8, 'Antigua y Barbuda'), (9, 'Antillas Neerlandesas'), (10, 'Arabia Saudita'),
(11, 'Argelia'), (12, 'Argentina'), (13, 'Armenia'), (14, 'Aruba'), (15, 'Asia'),
(16, 'Australia'), (17, 'Austria'), (18, 'Azerbaiyán'), (19, 'Bahamas'), (20, 'Bahrein'),
(21, 'Bangladesh'), (22, 'Barbados'), (23, 'Bélgica'), (24, 'Belice'), (25, 'Benín'),
(26, 'Bermudas'), (27, 'Bielorrusia'), (28, 'Bolivia'), (29, 'Bosnia y Herzegovina'), (30, 'Botswana'),
(31, 'Brasil'), (32, 'Brunei Darussalam'), (33, 'Bulgaria'), (34, 'Burkina Faso'), (35, 'Burundi'),
(36, 'Bután'), (37, 'Cabo Verde'), (38, 'Camboya'), (39, 'Camerún'), (40, 'Canadá'),
(41, 'Chad'), (42, 'Chile'), (43, 'China'), (44, 'Chipre'), (45, 'Ciudad del Vaticano'),
(46, 'Colombia'), (47, 'Corea del Norte'), (48, 'Corea del Sur'), (49, 'Costa de Marfil'), (50, 'Costa Rica'),
(51, 'Croacia'), (52, 'Cuba'), (53, 'Curazao'), (54, 'Dinamarca'), (55, 'Djibouti'),
(56, 'Dominica'), (57, 'Ecuador'), (58, 'Egipto'), (59, 'El Salvador'), (60, 'Emiratos Árabes Unidos'),
(61, 'Eritrea'), (62, 'Eslovaquia'), (63, 'Eslovenia'), (64, 'España'), (65, 'Estado de Micronesia'),
(66, 'Estados Unidos'), (67, 'Estonia'), (68, 'Etiopía'), (69, 'Europa'), (70, 'Federación Rusa'),
(71, 'Fidji'), (72, 'Filipinas'), (73, 'Finlandia'), (74, 'Francia'), (75, 'Franja de Gaza'),
(76, 'Gabón'), (77, 'Gambia'), (78, 'Georgia'), (79, 'Ghana'), (80, 'Gibraltar'),
(81, 'Granada'), (82, 'Grecia'), (83, 'Guadalupe y Dependencias'), (84, 'Guam'), (85, 'Guatemala'),
(86, 'Guinea'), (87, 'Guinea Bissau'), (88, 'Guinea Ecuatorial'), (89, 'Guyana'), (90, 'Guyana Francesa'),
(91, 'Haití'), (92, 'Honduras'), (93, 'Hong Kong'), (94, 'Hungría'), (95, 'India'),
(96, 'Indonesia'), (97, 'Irak'), (98, 'Irán'), (99, 'Irlanda'), (100, 'Isla Montserrat'),
(101, 'Isla Nive'), (102, 'Isla Norfolk'), (103, 'Isla Reunián'), (104, 'Islandia'), (105, 'Islas Caimán'),
(106, 'Islas Canal'), (107, 'Islas Cocos'), (108, 'Islas Comoras'), (109, 'Islas Cook'), (110, 'Islas Heard y Mcdonald'),
(111, 'Islas Malvinas'), (112, 'Islas Marianas'), (113, 'Islas Marshall'), (114, 'Islas Navidad'), (115, 'Islas Pitcairns'),
(116, 'Islas Salomón'), (117, 'Islas Svalbard y Jan Mayen'), (118, 'Islas Tokelau'), (119, 'Islas Turcas y Caicos'), (120, 'Islas Vírgenes (EU)'),
(121, 'Islas Vírgenes (Reino Unido)'), (122, 'Islas Wallis y Futuna'), (123, 'Israel'), (124, 'Italia'), (125, 'Jamaica'),
(126, 'Japón'), (127, 'Jordania'), (128, 'Kazajistán'), (129, 'Kenia'), (130, 'Kiribati'),
(131, 'Kuwait'), (132, 'Kyrgyzstán'), (133, 'Lesotho'), (134, 'Letonia'), (135, 'Líbano'),
(136, 'Liberia'), (137, 'Libia'), (138, 'Liechtenstein'), (139, 'Lituania'), (140, 'Luxemburgo'),
(141, 'Macao'), (142, 'Macedonia'), (143, 'Madagascar'), (144, 'Malasia'), (145, 'Malawi'),
(146, 'Maldivas'), (147, 'Malí'), (148, 'Malta'), (149, 'Marruecos'), (150, 'Martinica'),
(151, 'Mauricio'), (152, 'Mauritania'), (153, 'Moldavia'), (154, 'Mónaco'), (155, 'Mongolia'),
(156, 'Montenegro'), (157, 'Mozambique'), (158, 'Myanmar'), (159, 'Namibia'), (160, 'Nauru'),
(161, 'Nepal'), (162, 'Nicaragua'), (163, 'Níger'), (164, 'Nigeria'), (165, 'Noruega'),
(166, 'Nueva Caledonia'), (167, 'Nueva Zelanda'), (168, 'Omán'), (169, 'Países Bajos'), (170, 'Pakistán'),
(171, 'Palau'), (172, 'Panamá'), (173, 'Papúa Nueva Guinea'), (174, 'Paraguay'), (175, 'Perú'),
(176, 'Polinesia Francesa'), (177, 'Polonia'), (178, 'Portugal'), (179, 'Puerto Rico'), (180, 'Qatar'),
(181, 'Reino Unido'), (182, 'República Árabe Siria'), (183, 'República Centroafricana'), (184, 'República Checa'), (185, 'República de Laos'),
(186, 'República del Congo'), (187, 'República Dominicana'), (188, 'Ruanda'), (189, 'Rumania'), (190, 'Sahara Occidental'),
(191, 'Samoa Occidental'), (192, 'San Cristóbal y Nieves'), (193, 'San Marino'), (194, 'San Pedro y Miquelón'), (195, 'San Vicente y las Granadinas'),
(196, 'Santa Elena'), (197, 'Santa Lucía'), (198, 'Santo Tomé y Príncipe'), (199, 'Senegal'), (200, 'Serbia'),
(201, 'Serbia y Montenegro'), (202, 'Seychelles'), (203, 'Sierra Leona'), (204, 'Singapur'), (205, 'Somalia'),
(206, 'Sri Lanka'), (207, 'Sudáfrica'), (208, 'Sudán'), (209, 'Suecia'), (210, 'Suiza'),
(211, 'Surinam'), (212, 'Swazilandia'), (213, 'Tayikistán'), (214, 'Tailandia'), (215, 'Taiwán'),
(216, 'Tanzania'), (217, 'Territorios del Reino Unido del Océano Índico'), (218, 'Territorios Franceses Australes y Antárticos'), (219, 'Territorios Franceses de Ultramar'), (220, 'Territorios Franceses del Sur'),
(221, 'Timor Oriental'), (222, 'Togo'), (223, 'Tonga'), (224, 'Trinidad y Tobago'), (225, 'Túnez'),
(226, 'Turkmenistán'), (227, 'Turquía'), (228, 'Tuvalu'), (229, 'Ucrania'), (230, 'Uganda'),
(231, 'Uruguay'), (232, 'Uzbekistán'), (233, 'Vanuatu'), (234, 'Venezuela'), (235, 'Vietnam'),
(236, 'Yemen'), (237, 'Zaire'), (238, 'Zambia'), (239, 'Zimbabwe'), (240, 'Zona Canal de Panamá'),
(241, 'Zona Neutral Irak-Arabia Saudita'), (500, 'Reunión'), 
(990, 'No Especificado (América del Norte)'), (991, 'No Especificado (América Central)'), (992, 'No Especificado (América del Sur)'), 
(993, 'No Especificado (Antillas)'), (994, 'No Especificado (Asia)'), (995, 'No Especificado (Unión Europea)'), 
(996, 'No Especificado (Resto de Europa)'), (997, 'No Especificado (África)'), (998, 'No Especificado (Oceanía)'), (999, 'No Especificado');

-- 1.2 Catálogo de Entidades Federativas
CREATE TABLE IF NOT EXISTS cat_entidad (
    id_entidad INTEGER PRIMARY KEY,
    desc_entidad TEXT
);

INSERT OR REPLACE INTO cat_entidad (id_entidad, desc_entidad) VALUES
(1, 'Aguascalientes'), (2, 'Baja California'), (3, 'Baja California Sur'),
(4, 'Campeche'), (5, 'Coahuila de Zaragoza'), (6, 'Colima'),
(7, 'Chiapas'), (8, 'Chihuahua'), (9, 'Ciudad de México'),
(10, 'Durango'), (11, 'Guanajuato'), (12, 'Guerrero'),
(13, 'Hidalgo'), (14, 'Jalisco'), (15, 'México'),
(16, 'Michoacán de Ocampo'), (17, 'Morelos'), (18, 'Nayarit'),
(19, 'Nuevo León'), (20, 'Oaxaca'), (21, 'Puebla'),
(22, 'Querétaro'), (23, 'Quintana Roo'), (24, 'San Luis Potosí'),
(25, 'Sinaloa'), (26, 'Sonora'), (27, 'Tabasco'),
(28, 'Tamaulipas'), (29, 'Tlaxcala'), (30, 'Veracruz de Ignacio de la Llave'),
(31, 'Yucatán'), (32, 'Zacatecas'), (99, 'No especificado');


-- =================================================================================================
-- FASE 2: CAPA PLATA (DATA WRANGLING Y LIMPIEZA DE CADENAS)
-- Corrección de caracteres especiales, mapeo relacional y casteos de tipos.
-- =================================================================================================

-- 2.1 Limpieza de Tabla Exportaciones (V2)
DROP TABLE IF EXISTS "0_0_Historico_Exportaciones_V2";

CREATE TABLE "0_0_Historico_Exportaciones_V2" AS
SELECT 
    CASE 
        WHEN PROD_EST LIKE 'Registro Administrativo%' THEN 'Registro Administrativo de la Industria Automotriz de Vehiculos Ligeros. Exportacion de Vehiculos'
        ELSE PROD_EST 
    END AS PROD_EST,
    COBERTURA,
    ANIO,
    CAST(ID_MES AS INTEGER) AS ID_MES,
    
    CASE 
        WHEN MARCA = 'Mercedes Benz_Prod_Expo' THEN 'Mercedes Benz Prod Expo'
        ELSE MARCA 
    END AS MARCA,
    
    -- Corrección de Mojibake y caracteres sueltos (TRIM dinámico)
    CASE 
        WHEN MODELO = 'Golf Variant-/Crossgolf' THEN 'Golf Variant/Crossgolf'
        ELSE TRIM(TRIM(REPLACE(REPLACE(REPLACE(MODELO, 'SedÃ¡n', 'Sedan'), 'RÃ­o', 'Rio'), 'CoupÃ©', 'Coupe'), '-'), '_')
    END AS MODELO,
    
    CASE 
        WHEN TIPO = 'AutomÃ³viles' THEN 'Automoviles'
        ELSE TIPO 
    END AS TIPO,
    
    SEGMENTO,
    ID_PAIS_DESTINO,
    c.desc_pais AS Pais,
    UNI_VEH,
    ESTATUS
FROM "0_0_Historico_Exportaciones" e
LEFT JOIN cat_pais c ON e.ID_PAIS_DESTINO = c.id_pais;


-- 2.2 Limpieza de Tabla Ventas Híbridos (V3)
DROP TABLE IF EXISTS "1_0_Historico_Ventas_Hibridos_V3";

CREATE TABLE "1_0_Historico_Ventas_Hibridos_V3" AS
SELECT 
    CASE 
        WHEN e.PROD_EST LIKE 'Registro Administrativo%' THEN 'Registro Administrativo de la Industria Automotriz de Vehiculos Ligeros. Venta de Vehiculos Hibridos y Electricos'
        ELSE e.PROD_EST 
    END AS PROD_EST,
    e.COBERTURA,
    e.ANIO,
    CAST(e.ID_MES AS INTEGER) AS ID_MES,
    CAST(e.ID_ENTIDAD AS INTEGER) AS ID_ENTIDAD,
    c.desc_entidad AS Entidad,
    e.VEH_ELECTR,
    e.VEH_HIBRIDAS_PLUGIN,
    e.VEH_HIBRIDAS,
    e.ESTATUS
FROM "1_0_Historico_Ventas_Hibridos" e
LEFT JOIN cat_entidad c ON CAST(e.ID_ENTIDAD AS INTEGER) = c.id_entidad;


-- 2.3 Limpieza de Tabla Producción (V2)
DROP TABLE IF EXISTS "2_0_Historico_Produccion_V2";

CREATE TABLE "2_0_Historico_Produccion_V2" AS
SELECT 
    CASE 
        WHEN e.PROD_EST LIKE 'Registro administrativo%' THEN 'Registro Administrativo de la Industria Automotriz de Vehiculos Ligeros. Produccion de Vehiculos'
        ELSE e.PROD_EST 
    END AS PROD_EST,
    e.COBERTURA,
    e.ANIO,
    CAST(e.ID_MES AS INTEGER) AS ID_MES,
    e.MARCA,
    
    -- Remoción de puntuación final en cadena y caracteres especiales
    RTRIM(
        RTRIM(
            RTRIM(
                REPLACE(
                    REPLACE(
                        REPLACE(e.MODELO, 'SedÃ¡n', 'Sedan'), 
                    'RÃ­o', 'Rio'), 
                'CoupÃ©', 'Coupe'), 
            '-'), 
        '_'),
    '.') AS MODELO,
    
    CASE 
        WHEN e.TIPO = 'AutomÃ³viles' THEN 'Automoviles'
        ELSE e.TIPO 
    END AS TIPO,
    
    e.SEGMENTO,
    e.UNI_VEH,
    e.ESTATUS
FROM "2_0_Historico_Produccion" e;


-- 2.4 Limpieza de Tabla Ventas Todo Tipo (V2)
DROP TABLE IF EXISTS "3_0_Historico_Ventas_Todo_Tipo_V2";

CREATE TABLE "3_0_Historico_Ventas_Todo_Tipo_V2" AS
SELECT 
    CASE 
        WHEN e.PROD_EST LIKE 'Registro Administrativo%' THEN 'Registro Administrativo de la Industria Automotriz de Vehiculos Ligeros. Venta de Vehiculos'
        ELSE e.PROD_EST 
    END AS PROD_EST,
    e.COBERTURA,
    e.ANIO,
    CAST(e.ID_MES AS INTEGER) AS ID_MES,
    e.MARCA,
    
    -- Limpieza masiva (Data Cleansing) para cruces analíticos exactos
    CASE 
        WHEN e.MODELO = '500L' THEN '#N/D'
        WHEN e.MODELO = 'Golf Variant-/Crossgolf' THEN 'Golf Variant/Crossgolf'
        ELSE 
            RTRIM(
                RTRIM(
                    RTRIM(
                        REPLACE(
                            REPLACE(
                                REPLACE(
                                    REPLACE(
                                        REPLACE(e.MODELO, 'SedÃ¡n', 'Sedan'),
                                    'RÃ­o', 'Rio'),
                                'Ã“ptima', 'Optima'),
                            'elÃ©ctrico', 'electrico'),
                        '2  Pts.', '2 Pts')
                    , '-')
                , '*')
            , '.')
    END AS MODELO,
    
    CASE 
        WHEN e.TIPO = 'AutomÃ³viles' THEN 'Automoviles'
        ELSE e.TIPO 
    END AS TIPO,
    
    e.SEGMENTO,
    e.ORIGEN,
    CAST(e.ID_PAIS_ORIGEN AS INTEGER) AS ID_PAIS_ORIGEN,
    c.desc_pais AS [Pais Origen],
    e.UNI_VEH,
    e.ESTATUS
FROM "3_0_Historico_Ventas_Todo_Tipo" e
LEFT JOIN cat_pais c ON CAST(e.ID_PAIS_ORIGEN AS INTEGER) = c.id_pais;


-- =================================================================================================
-- FASE 3: CAPA ORO (MODELADO FINAL STAR SCHEMA)
-- Generación de llaves compuestas y formateo estandarizado de dimensiones de tiempo.
-- =================================================================================================

-- 3.1 Construcción del Fact Table: Exportaciones
DROP TABLE IF EXISTS "exportaciones";

CREATE TABLE "exportaciones" AS
SELECT 
    -- Generación de Primary Key dinámica (Hash textual) para Star Schema
    UPPER(MARCA || '-' || MODELO || '-' || TIPO || '-' || SEGMENTO) AS ID_Vehiculo,
    -- Estructuración de Date Key compatible con motores de BI
    printf('%04d-%02d-01', ANIO, ID_MES) AS Fecha,
    
    PROD_EST,
    COBERTURA,
    ANIO,
    ID_MES,
    MARCA,
    MODELO,
    TIPO,
    SEGMENTO,
    ID_PAIS_DESTINO,
    Pais,
    UNI_VEH,
    ESTATUS
FROM "0_0_Historico_Exportaciones_V3";


-- 3.2 Construcción del Fact Table: Ventas Híbridos
DROP TABLE IF EXISTS "ventas_hibridos";

CREATE TABLE "ventas_hibridos" AS
SELECT 
    printf('%04d-%02d-01', ANIO, ID_MES) AS Fecha,
    PROD_EST,
    COBERTURA,
    ANIO,
    ID_MES,
    ID_ENTIDAD,
    Entidad,
    VEH_ELECTR,
    VEH_HIBRIDAS_PLUGIN,
    VEH_HIBRIDAS,
    ESTATUS
FROM "1_0_Historico_Ventas_Hibridos_V3";


-- 3.3 Construcción del Fact Table: Producción
DROP TABLE IF EXISTS "produccion";

CREATE TABLE "produccion" AS
SELECT 
    UPPER(MARCA || '-' || MODELO || '-' || TIPO || '-' || SEGMENTO) AS ID_Vehiculo,
    printf('%04d-%02d-01', ANIO, ID_MES) AS Fecha,
    
    PROD_EST,
    COBERTURA,
    ANIO,
    ID_MES,
    MARCA,
    MODELO,
    TIPO,
    SEGMENTO,
    UNI_VEH,
    ESTATUS
FROM "2_0_Historico_Produccion_V3";


-- 3.4 Construcción del Fact Table: Ventas Todo Tipo
DROP TABLE IF EXISTS "ventas_todo_tipo";

CREATE TABLE "ventas_todo_tipo" AS
SELECT 
    UPPER(MARCA || '-' || MODELO || '-' || TIPO || '-' || SEGMENTO) AS ID_Vehiculo,
    printf('%04d-%02d-01', ANIO, ID_MES) AS Fecha,
    
    PROD_EST,
    COBERTURA,
    ANIO,
    ID_MES,
    MARCA,
    MODELO,
    TIPO,
    SEGMENTO,
    ORIGEN,
    ID_PAIS_ORIGEN,
    "Pais Origen",
    UNI_VEH,
    ESTATUS
FROM "3_0_Ventas_V3";
