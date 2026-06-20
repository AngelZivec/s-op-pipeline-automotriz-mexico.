# 📖 Diccionario de Medidas DAX: Sistema S&OP Automotriz

## 📊 Bloque Comercial: KPIs Principales (YoY y Run-Rate)
---

### 📌 Indicadores Base de Año Actual y Año Anterior
```dax
0.1 Ventas AP = 
// Fija el max year ignorando filtros de tiempo externos para anclar la vista actual (CY).
VAR AnioPresente = CALCULATE(YEAR(MAX('3_0_Ventas_V3'[Fecha])), ALL('3_0_Ventas_V3'))

RETURN
CALCULATE(
    SUM('3_0_Ventas_V3'[Unidades Vehiculares]),
    'Calendario'[Año] = AnioPresente
) + 0

0.2 Ventas AA = 
// Desplaza dinámicamente el ancla un año atrás para establecer la base comparativa (LY).
VAR AnioPresente = CALCULATE(YEAR(MAX('3_0_Ventas_V3'[Fecha])), ALL('3_0_Ventas_V3'))
VAR AnioAnterior = AnioPresente - 1

RETURN
CALCULATE(
    SUM('3_0_Ventas_V3'[Unidades Vehiculares]),
    'Calendario'[Año] = AnioAnterior
) + 0

💡 Racional de Negocio: Diseñé estas medidas calculando dinámicamente el último año con datos vivos en el fact table (ALL),
   en lugar de usar funciones estáticas de Time Intelligence. Esto convierte al tablero en un producto "evergreen"
   (cero mantenimiento en el cambio de año) y evita que los reportes se rompan si el calendario tiene gaps operativos.

📌 Variación Comercial y Gaps

0.3 Gap Ventas Unid = 
// Delta absoluto YoY en unidades. Se suma 0 para evitar blanks en matrices visuales.
VAR ResultadoGap = [0.1 Ventas AP] - [0.2 Ventas AA]
RETURN
ResultadoGap + 0

0.4 Variacion % = 
// Crecimiento YoY. Uso de DIVIDE para manejo seguro de errores (divisiones por cero).
VAR Resultado = DIVIDE([0.3 Gap Ventas Unid], [0.2 Ventas AA], 0)
RETURN
Resultado + 0

💡 Racional de Negocio: Cálculo del Delta de crecimiento. Estructurado con manejo de errores (DIVIDE) y control de nulos 
   (+0) para asegurar que al cruzar estos KPIs por múltiples dimensiones en matrices (Marca, Segmento), el grid de Power BI se mantenga 
   estable y legible para la dirección.

📌 Promedio de Absorción de Mercado

0.5 Promedio Mensual AP = 
// Promedio de run-rate. Filtra meses sin movimiento para no sesgar el ritmo comercial.
VAR Promedio = 
    AVERAGEX(
        FILTER(VALUES('Calendario'[Mes]), [0.1 Ventas AP] > 0),
        [0.1 Ventas AP]
    )
RETURN
COALESCE(Promedio, 0)

💡 Racional de Negocio: Este es un indicador crítico para calcular el ritmo de ventas (run-rate). Utilicé AVERAGEX anidado con un FILTER para 
   promediar exclusivamente los meses que ya reportan ventas. Esto previene que los meses futuros (aún en ceros) derrumben estadísticamente 
   el indicador y afecten el pronóstico.

📈 Bloque de Tendencias y Benchmarks (Run-Rate y Largo Plazo)
📌 Velocidad Comercial y Aceleración

0.6 Promedio Mensual AA = 
// Calcula la línea base del run-rate histórico (Last Year) filtrando meses inactivos.
VAR Promedio = 
    AVERAGEX(
        FILTER(VALUES('Calendario'[Mes]), [0.2 Ventas AA] > 0),
        [0.2 Ventas AA]
    )
RETURN
COALESCE(Promedio, 0)

0.7 Gap Promedios = 
// Delta absoluto de la velocidad de ventas (Run-Rate actual vs histórico).
[0.5 Promedio Mensual AP] - [0.6 Promedio Mensual AA]

0.8 % Gap Promedios = 
// Variación relativa del ritmo comercial. Útil para ver si el mercado se está acelerando.
VAR Resultado = DIVIDE([0.7 Gap Promedios], [0.6 Promedio Mensual AA], 0)
RETURN
Resultado + 0

💡 Racional de Negocio: Comparar totales crudos suele esconder picos atípicos. Diseñé este set de medidas para evaluar el "Run-Rate" 
   (velocidad de absorción del mercado). El delta entre promedios nos permite decirle a la Dirección si, en promedio mensual, estamos 
   desplazando el inventario más rápido o más lento que el año anterior.

📌 Benchmarks de Mercado: Histórico y Ciclo de 5 Años

0.9 Promedio Historico Ventas Anual = 
// Benchmark "All-Time". REMOVEFILTERS rompe el contexto de fecha actual para obtener 
// el promedio mensual absoluto de todo el histórico de la base de datos.
VAR PromHistorico = 
    CALCULATE(
        AVERAGEX(
            FILTER(VALUES('Calendario'[Mes]), CALCULATE(SUM('3_0_Ventas_V3'[Unidades Vehiculares])) > 0),
            CALCULATE(SUM('3_0_Ventas_V3'[Unidades Vehiculares]))
        ),
        REMOVEFILTERS('Calendario'[Date])
    )
RETURN
COALESCE(PromHistorico, 0)

1.0 Promedio Ventas 5 Anios = 
// Define la ventana S&OP de mediano plazo (CY y 4 años atrás).
VAR AnioPresente = CALCULATE(YEAR(MAX('3_0_Ventas_V3'[Fecha])), ALL('3_0_Ventas_V3'))
VAR InicioPeriodo = AnioPresente - 4

// Aisla el volumen total de ese lustro y calcula la media anual estabilizada.
VAR TotalVentasPeriodo = 
    CALCULATE(
        SUM('3_0_Ventas_V3'[Unidades Vehiculares]),
        'Calendario'[Año] >= InicioPeriodo,
        'Calendario'[Año] <= AnioPresente
    )
    
RETURN
COALESCE(DIVIDE(TotalVentasPeriodo, 5, 0), 0)

💡 Racional de Negocio: En planeación de demanda automotriz (S&OP), un solo año es insuficiente para ver el comportamiento real por ciclos económicos o pandemias. 
   La medida Promedio Ventas 5 Anios encapsula dinámicamente el ciclo de planeación táctica estándar a mediano plazo, absorbiendo anomalías estadísticas.
   Por su parte, la medida histórica utiliza un REMOVEFILTERS de tiempo para establecer el límite superior/inferior del comportamiento de la marca 
   en México desde el origen de la base de datos.

🔮 Bloque de Pronósticos y Planeación de Demanda (Forecasting Engine)
📌 Modelos Estadísticos de Estacionalidad

1.1 Estacionalidad Promedio Mensual = 
// Fija el último año operativo (CY) para establecer el ancla temporal.
VAR AnioMax = CALCULATE(MAX('3_0_Ventas_V3'[Año]), ALL('3_0_Ventas_V3'))

// Suaviza la curva aislando la ventana móvil de los 5 años operativos anteriores.
VAR VentasUltimos5Anios = 
    CALCULATE(
        SUM('3_0_Ventas_V3'[Unidades Vehiculares]),
        'Calendario'[Año] >= AnioMax - 5 && 'Calendario'[Año] < AnioMax
    )

RETURN
DIVIDE(VentasUltimos5Anios, 5, 0)

1.5 Estacionalidad Promedio Mensual 3 Anios = 
// Ventana móvil de estacionalidad corta. Ideal para detectar tendencias de mercado recientes.
VAR AnioMax = CALCULATE(MAX('3_0_Ventas_V3'[Año]), ALL('3_0_Ventas_V3'))

VAR VentasUltimos3Anios = 
    CALCULATE(
        SUM('3_0_Ventas_V3'[Unidades Vehiculares]),
        'Calendario'[Año] >= AnioMax - 3 && 'Calendario'[Año] < AnioMax
    )

RETURN
DIVIDE(VentasUltimos3Anios, 3, 0)

💡 Racional de Negocio: El mercado automotriz tiene ciclos muy marcados. Desarrollé estas medidas para extraer la curva de demanda natural (baseline), 
   promediando ventanas móviles de 3 y 5 años. Esto permite a la dirección elegir entre un pronóstico reactivo a tendencias recientes 
   (3 años) o un modelo suavizado e histórico (5 años).

📌 Motor de Simulador de Escenarios y Proyecciones

1.2 Pronostico Simulado = 
// Inyección del parámetro What-If (Escenarios) sobre la base estacional estadística.
VAR EstacionalidadBase = [1.1 Estacionalidad Promedio Mensual]
VAR PorcentajeSimulador = [Valor de Simulador Escenario %]

RETURN
EstacionalidadBase * (1 + PorcentajeSimulador)

1.4 Linea de Tiempo Continua = 
// Motor central del Forecast S&OP. Empalma datos reales (Actuals) con proyecciones.
VAR UltimaFechaVentas = CALCULATE(MAX('3_0_Ventas_V3'[Fecha]), ALL('3_0_Ventas_V3'))
VAR FechaGrafica = MAX('Calendario'[Date])

// Captura de los criterios estadísticos y de estrés seleccionados por el usuario.
VAR CriterioSel = SELECTEDVALUE('Filtro Pronostico'[Criterio], "Estacionalidad 5 Años")
VAR Simulador = [Valor de Simulador Escenario %]
VAR MesEnGrafica = MAX('Calendario'[MesNumero])

RETURN
IF(
    FechaGrafica <= UltimaFechaVentas,
    // [ACTUALS]: Lectura del volumen histórico consolidado.
    CALCULATE(SUM('3_0_Ventas_V3'[Unidades Vehiculares])),
    
    // [FORECAST]: Aislamiento del contexto de filtro para proyectar estacionalidad futura.
    VAR CalcEstacionalidad5 = CALCULATE([1.1 Estacionalidad Promedio Mensual], REMOVEFILTERS('Calendario'), 'Calendario'[MesNumero] = MesEnGrafica)
    VAR CalcEstacionalidad3 = CALCULATE([1.5 Estacionalidad Promedio Mensual 3 Anios], REMOVEFILTERS('Calendario'), 'Calendario'[MesNumero] = MesEnGrafica)
    VAR CalcPromedio12 = CALCULATE([1.6 Promedio Ultimos 12 Meses], REMOVEFILTERS('Calendario'))
    
    // [EVALUACIÓN DE ESCENARIOS]: Switch dinámico según el criterio del modelo predictivo.
    RETURN
    SWITCH(CriterioSel,
        "Estacionalidad 5 Años", CalcEstacionalidad5 * (1 + Simulador),
        "Estacionalidad 3 Años", CalcEstacionalidad3 * (1 + Simulador), 
        "Promedio 12 Meses", CalcPromedio12 * (1 + Simulador),    
        CalcEstacionalidad5 * (1 + Simulador)
    )
)

💡 Racional de Negocio: Esta es la medida núcleo de la herramienta de S&OP. Funciona como un motor condicional (IF / SWITCH) que detecta la fecha actual en el modelo: 
   si la fecha está en el pasado, grafica los datos de ventas reales (Actuals); si entra en el futuro, inyecta automáticamente el modelo estadístico seleccionado por el usuario. 
   Además, se integra con un parámetro "What-If" (Simulador), permitiendo al comité directivo estresar el pronóstico (ej. ¿Qué pasa con el inventario si la demanda sube un 15%?).

📌 Puntos de Inflexión del Mercado

1.3 Variacion Estacional MoM = 
// Identificación de puntos de inflexión mensuales (aceleración/contracción natural).
VAR MesActual = MAX('Calendario'[MesNumero])
VAR MesAnterior = IF(MesActual = 1, 12, MesActual - 1)

VAR ValorActual = [1.1 Estacionalidad Promedio Mensual]

// Ruptura del contexto de filtro visual para evaluar el delta contra el periodo t-1.
VAR ValorAnterior = 
    CALCULATE(
        [1.1 Estacionalidad Promedio Mensual],
        REMOVEFILTERS('Calendario'[MesNumero]),
        'Calendario'[MesNumero] = MesAnterior
    )

RETURN
DIVIDE(ValorActual - ValorAnterior, ValorAnterior, 0)

💡 Racional de Negocio: Utilicé la función REMOVEFILTERS para evaluar la aceleración o contracción Month-over-Month (MoM) directa sobre la línea base. 
   Esto le indica al equipo de logística y producción los meses exactos donde inicia la temporada alta de ventas para anticipar el abastecimiento.

🎯 Bloque de Inteligencia Competitiva (Market Share & TAM)
📌 Total Addressable Market (TAM / Rolling Year)

2.1 Rolling Year Ventas (TAM) = 
// Cálculo del Total Addressable Market (TAM) / Moving Annual Total.
VAR UltimaFechaVentas = CALCULATE(MAX('3_0_Ventas_V3'[Fecha]), ALL('3_0_Ventas_V3'))
VAR FechaActualGrafica = MAX('Calendario'[Date])

// Limita el cálculo exclusivamente a datos históricos consolidados (Actuals) para evitar distorsiones en gráficas futuras.
RETURN
IF(
    FechaActualGrafica > UltimaFechaVentas,
    BLANK(), 
    CALCULATE(
        SUM('3_0_Ventas_V3'[Unidades Vehiculares]),
        DATESINPERIOD(
            'Calendario'[Date], 
            FechaActualGrafica, 
            -12, 
            MONTH
        )
    )
)

💡 Racional de Negocio: El análisis mensual crudo tiene demasiado "ruido" estacional. Utilicé la función DATESINPERIOD para calcular el TAM (Mercado Total Direccionable) o "Rolling Year". 
   Esto genera una línea de tendencia limpia que le indica a la dirección el tamaño real anualizado del mercado en cualquier punto del tiempo. 
   Agregué una condición IF para detener el cálculo en el mes actual, manteniendo limpia la visualización.

📌 Aislamiento del Total de Industria

3.1 Ventas Totales Industria = 
// Calcula el volumen total del mercado ignorando las selecciones del usuario.
// Se usa REMOVEFILTERS en las dimensiones de producto para establecer el denominador universal.
CALCULATE(
    SUM('3_0_Ventas_V3'[Unidades Vehiculares]),
    REMOVEFILTERS('Dim_Marca'), 
    REMOVEFILTERS('Dim_Modelo'),
    REMOVEFILTERS('Dim_Segmento'), 
    REMOVEFILTERS('Dim_Tipo')      
)

💡 Racional de Negocio: Para calcular participaciones de mercado relativas, es obligatorio tener un total absoluto estático (el tamaño completo del pastel). 
   Esta medida utiliza REMOVEFILTERS sobre todas las dimensiones de catálogo (Marca, Modelo, Tipo) para forzar a Power BI a calcular el volumen total del país, 
   sin importar qué vehículo seleccione el usuario en los segmentadores.

📌 Desempeño Competitivo: Market Share Actual vs Histórico

3.3 Market Share % Año Anterior = 
// Desplazamiento del cálculo de cuota de mercado al periodo análogo anterior (LY).
CALCULATE(
    [3.2 Market Share %],
    SAMEPERIODLASTYEAR('Calendario'[Date])
)

3.4 Robo de Mercado (Delta MS) = 
// Cuantificación de ganancia o pérdida neta de participación frente a la industria (Absorción competitiva).
[3.2 Market Share %] - [3.3 Market Share % Año Anterior]

💡 Racional de Negocio: Una marca puede estar vendiendo más unidades que el año pasado, pero perdiendo participación de mercado si la industria crece más rápido. 
   Estas medidas calculan el Share % dinámico y lo comparan contra el ciclo anterior. El "Delta" exacto (Robo de Mercado) responde en comité a la pregunta crítica: 
   "¿Estamos creciendo orgánicamente con el mercado, o le estamos robando clientes a la competencia?".

⚙️ Bloque de Alineación S&OP (Producción vs Demanda)
📌 Desplazamiento Nacional y Salidas Consolidadas

4.1 Ventas Origen Nacional = 
// Aisla el volumen de ventas proveniente exclusivamente de manufactura local (Domestic Sales) para balanceo S&OP.
CALCULATE(
    SUM('3_0_Ventas_V3'[Unidades Vehiculares]),
    '3_0_Ventas_V3'[Origen] = "Nacional" 
)

4.2 Salidas Totales Planta = 
// Demanda total consolidada (Mercado Interno + Exportaciones). Base para cruzar contra el ensamble total de producción.
[4.1 Ventas Origen Nacional] + [1.1 Total Exportacion]

💡 Racional de Negocio: Aquí ocurre la conexión entre Inteligencia Comercial y Supply Chain. Para saber si una planta de ensamble está balanceada, 
   no podemos comparar la producción solo contra las ventas totales (ya que muchas ventas son de vehículos importados). Diseñé la medida Ventas 
   Origen Nacional para aislar la demanda doméstica y, al sumarla con exportaciones, obtenemos las Salidas Totales Planta. Este es el volumen real 
   que "jala" inventario de las fábricas en México, vital para el cálculo de requerimientos netos (Net Requirements).


## 🏭 Bloque de Producción y Manufactura (Operaciones)
---

### 📌 Indicadores Base de Ensamble (CY vs LY)
```dax

0.1 Produccion AP = 
// Ancla dinámica al año actual operativo (CY) ignorando filtros externos.
VAR AnioPresente = CALCULATE(YEAR(MAX('2_0_Historico_Produccion_V3'[Fecha])), ALL('2_0_Historico_Produccion_V3'))

RETURN
CALCULATE(
    SUM('2_0_Historico_Produccion_V3'[Unidades Vehiculares]),
    'Calendario'[Año] = AnioPresente
) + 0

0.2 Produccion AA = 
// Desplazamiento dinámico al periodo análogo anterior (LY) para base comparativa de manufactura.
VAR AnioPresente = CALCULATE(YEAR(MAX('2_0_Historico_Produccion_V3'[Fecha])), ALL('2_0_Historico_Produccion_V3'))
VAR AnioAnterior = AnioPresente - 1

RETURN
CALCULATE(
    SUM('2_0_Historico_Produccion_V3'[Unidades Vehiculares]),
    'Calendario'[Año] = AnioAnterior
) + 0

💡 Racional de Negocio: Al igual que en el bloque comercial, estas medidas establecen la base de volumen 
   operativo de manera completamente dinámica ("evergreen"). Esto le permite al equipo de planta medir las unidades ensambladas 
   del año en curso contra el año anterior sin requerir mantenimiento de código en cada cambio de ciclo fiscal.

📌 Variación de Capacidad y Gaps de Producción

0.3 Gap Produccion AP vs AA = 
// Delta absoluto de ensamble YoY. (+0 para estabilizar matrices visuales).
([0.1 Produccion AP] - [0.2 Produccion AA]) + 0

0.4 % Gap Produccion AP vs AA = 
// Variación relativa YoY del volumen de ensamble.
DIVIDE([0.3 Gap Produccion AP vs AA], [0.2 Produccion AA], 0) + 0

💡 Racional de Negocio: Cuantifica la aceleración o contracción del ritmo de manufactura. En reuniones de S&OP, cruzar esta variación 
   porcentual de producción contra el crecimiento porcentual de ventas nos alerta casi de inmediato sobre posibles riesgos de sobreinventario 
   (si producimos a un ritmo mayor del que vendemos) o riesgos de quiebre de stock

📌 Run-Rate de Planta (Ritmo de Manufactura)

0.5 Promedio Mensual Prod AP = 
// Run-rate de manufactura. Excluye meses futuros/en blanco para no subestimar la capacidad real.
VAR Promedio = 
    AVERAGEX(
        FILTER(VALUES('Calendario'[Mes]), [0.1 Produccion AP] > 0),
        [0.1 Produccion AP]
    )
RETURN
COALESCE(Promedio, 0)

💡 Racional de Negocio: Indicador táctico que establece el "Run-Rate" o la velocidad de salida de las líneas de ensamble. 
   Utilizando AVERAGEX anidado con un filtro de meses activos, medimos la capacidad mensual real demostrada, evitando que los meses 
   que aún no ocurren tiren el promedio hacia abajo. Es una métrica vital para planificar turnos y proyectar requerimientos de insumos productivos.

### 📌 Análisis de Tendencias y Benchmarks de Manufactura
```dax

0.6 Promedio Mensual Prod AA = 
// Línea base del run-rate de manufactura del año anterior (LY) aislando meses inactivos.
VAR Promedio = 
    AVERAGEX(
        FILTER(VALUES('Calendario'[Mes]), [0.2 Produccion AA] > 0),
        [0.2 Produccion AA]
    )
RETURN
COALESCE(Promedio, 0)

0.7 Gap Promedios Prod = 
// Delta absoluto del ritmo de ensamble (Run-rate actual vs histórico).
([0.5 Promedio Mensual Prod AP] - [0.6 Promedio Mensual Prod AA]) + 0

0.8 % Gap Promedios Prod = 
// Variación relativa de la aceleración o contracción en la capacidad de planta.
DIVIDE([0.7 Gap Promedios Prod], [0.6 Promedio Mensual Prod AA], 0) + 0

💡 Racional de Negocio: Este conjunto de métricas evalúa la consistencia de los niveles de producción a nivel táctico. Comparar los promedios mensuales 
   (Run-rate) del año actual contra el anterior permite aislar el impacto de variaciones estacionales atípicas, ayudando a determinar si las líneas de ensamble
   han ganado eficiencia y ritmo constante, o si enfrentan cuellos de botella operativos en comparación con su histórico inmediato.

📌 Benchmarks Históricos de Capacidad y Modelado Temporal

0.9 Promedio Historico Anual = 
// Remueve el contexto de fecha actual para determinar el promedio mensual histórico absoluto de producción.
VAR PromHistorico = 
    CALCULATE(
        AVERAGEX(
            FILTER(VALUES('Calendario'[Mes]), CALCULATE(SUM('2_0_Historico_Produccion_V3'[Unidades Vehiculares])) > 0),
            CALCULATE(SUM('2_0_Historico_Produccion_V3'[Unidades Vehiculares]))
        ),
        REMOVEFILTERS('Calendario'[Date])
    )
RETURN
COALESCE(PromHistorico, 0)

1.0 Produccion AA = 
// Inteligencia de tiempo para comparar de forma homogénea el volumen contra el mismo periodo del año anterior (LY).
CALCULATE(
    [1.1 Total Produccion], 
    SAMEPERIODLASTYEAR('Calendario'[Date])
)

💡 Racional de Negocio: La medida Promedio Historico Anual rompe las barreras del tiempo en el reporte (REMOVEFILTERS) para fijar la capacidad media real de la infraestructura
   de manufactura a lo largo de toda la historia registrada, sirviendo como la línea base definitiva de largo plazo. Por su parte, la medida Produccion AA utiliza la función 
   SAMEPERIODLASTYEAR para habilitar análisis dinámicos y comparaciones homogéneas mes a mes o trimestre a trimestre, herramientas fundamentales para evaluar la estabilidad del plan maestro de producción (MPS).

### 📌 Control de Volúmenes y Eficiencia de Abastecimiento
```dax
1.1 Total Produccion = 
// Métrica agregada base para la cuantificación del volumen total de manufactura.
SUM('2_0_Historico_Produccion_V3'[Unidades Vehiculares])

1.2 % Absorcion Nacional = 
// Evalúa la proporción de la producción local que es retenida por la demanda doméstica.
DIVIDE([4.1 Ventas Origen Nacional], [1.1 Total Produccion], 0)

💡 Racional de Negocio: La medida Total Produccion representa el "input" principal del suministro en la planta. Al cruzarlo con la demanda local mediante % Absorcion Nacional, 
   el tablero revela la dependencia que tiene la manufactura del mercado interno frente a las exportaciones. Un porcentaje bajo indica una operación altamente volcada al comercio 
   exterior, lo cual es crítico para medir riesgos ante aranceles o fluctuaciones cambiarias.

📌 Gaps Dinámicos de Volumen de Ensamble

1.3 Gap Produccion = 
// Evaluación del delta absoluto contra el mismo periodo del año anterior (YoY).
VAR ProduccionActual = [1.1 Total Produccion]
VAR ProduccionAnterior = CALCULATE([1.1 Total Produccion], SAMEPERIODLASTYEAR('Calendario'[Date]))
RETURN
ProduccionActual - ProduccionAnterior

1.4 % Gap Produccion = 
// Tasa de crecimiento o contracción relativa del volumen de producción (YoY).
VAR ProduccionAnterior = CALCULATE([1.1 Total Produccion], SAMEPERIODLASTYEAR('Calendario'[Date]))
RETURN
DIVIDE([1.3 Gap Produccion], ProduccionAnterior, 0)

1.5 Promedio Mensual por Año = 
// Capacidad media mensual de procesamiento calculada a través del contexto anual activo.
AVERAGEX(
    VALUES('Calendario'[MesNumero]), 
    [1.1 Total Produccion]
)

💡 Racional de Negocio: Este grupo de medidas utiliza Inteligencia de Tiempo estándar para diagnosticar la salud de la cadena de suministro en comparación con el ciclo previo. 
   Mientras que Gap Produccion identifica desviaciones en volumen bruto, Promedio Mensual por Año actúa como el indicador de estabilidad ("throughput" promedio), permitiendo a 
   la gerencia de operaciones validar si las variaciones mensuales se mantienen dentro de la capacidad de diseño de las líneas de ensamble.

📌 Indicadores Centrales de Balanceo S&OP

1.6 Ratio de Alineacion = 
// Medida de acoplamiento operacional entre salidas comerciales/logísticas y entradas de manufactura.
DIVIDE([4.2 Salidas Totales Planta], [1.1 Total Produccion], 0)

2.1 Balance de Inventario = 
// Cálculo del delta neto de existencias en planta (Inflow vs Outflow).
[1.1 Total Produccion] - [4.2 Salidas Totales Planta]

💡 Racional de Negocio: Estas dos medidas constituyen el núcleo de control del proceso S&OP (Sales and Operations Planning). El Ratio de Alineacion ideal es 1.0 (100%); 
   un ratio menor a 1.0 alerta sobre sobreproducción latente (manufactura corriendo más rápido que los despachos), mientras que un ratio mayor a 1.0 indica que la demanda 
   está vaciando los almacenes (riesgo de quiebre de stock). Por su parte, Balance de Inventario cuantifica el impacto directo en el capital de trabajo, mostrando exactamente 
   cuántas unidades se acumulan o se liberan en el stock regulador de la planta al final de cada periodo.

## 🍃 Bloque de Movilidad Ecológica (EV / HEV / PHEV)
---

### 📌 Volumen Dinámico por Tecnología (CY vs LY)
```dax
0.1 Ventas Eco AP = 
// Anclaje al año actual operativo (CY) ignorando el contexto de filtro temporal externo.
VAR AnioPresente = CALCULATE(YEAR(MAX('1_0_Historico_Ventas_Hibridos_V3'[Fecha])), ALL('1_0_Historico_Ventas_Hibridos_V3'))

// Captura del parámetro seleccionado en el Slicer Desconectado (What-If tecnológico).
VAR CategoriaSel = SELECTEDVALUE('Filtro Eco'[Categoria], "Combinado")

// Evaluación independiente por tipo de propulsión.
VAR SumaElec = CALCULATE(SUM('1_0_Historico_Ventas_Hibridos_V3'[Unidades Electricos]), 'Calendario'[Año] = AnioPresente)
VAR SumaHibr = CALCULATE(SUM('1_0_Historico_Ventas_Hibridos_V3'[Unidades Hibridos]), 'Calendario'[Año] = AnioPresente)
VAR SumaPlug = CALCULATE(SUM('1_0_Historico_Ventas_Hibridos_V3'[Unidades Hibridos Plugin]), 'Calendario'[Año] = AnioPresente)

// Switch dinámico para inyectar la métrica seleccionada al visual.
RETURN
SWITCH(CategoriaSel,
    "Electricos", SumaElec,
    "Hibridos", SumaHibr,
    "Hibridos Plugin", SumaPlug,
    SumaElec + SumaHibr + SumaPlug
) + 0

0.2 Ventas Eco AA = 
// Desplazamiento de la base comparativa un año atrás (LY).
VAR AnioPresente = CALCULATE(YEAR(MAX('1_0_Historico_Ventas_Hibridos_V3'[Fecha])), ALL('1_0_Historico_Ventas_Hibridos_V3'))
VAR AnioAnterior = AnioPresente - 1

VAR CategoriaSel = SELECTEDVALUE('Filtro Eco'[Categoria], "Combinado")

VAR SumaElec = CALCULATE(SUM('1_0_Historico_Ventas_Hibridos_V3'[Unidades Electricos]), 'Calendario'[Año] = AnioAnterior)
VAR SumaHibr = CALCULATE(SUM('1_0_Historico_Ventas_Hibridos_V3'[Unidades Hibridos]), 'Calendario'[Año] = AnioAnterior)
VAR SumaPlug = CALCULATE(SUM('1_0_Historico_Ventas_Hibridos_V3'[Unidades Hibridos Plugin]), 'Calendario'[Año] = AnioAnterior)

RETURN
SWITCH(CategoriaSel,
    "Electricos", SumaElec,
    "Hibridos", SumaHibr,
    "Hibridos Plugin", SumaPlug,
    SumaElec + SumaHibr + SumaPlug
) + 0

💡 Racional de Negocio: Este bloque utiliza un patrón avanzado de "Dynamic Measure Selection" mediante un Slicer desconectado. 
   En lugar de crear gráficas separadas para vehículos Eléctricos, Híbridos o Plug-ins, esta medida lee la selección del usuario (SELECTEDVALUE) 
   y cambia el motor de cálculo interno (SWITCH) al vuelo. Esto optimiza el rendimiento del tablero y reduce drásticamente el espacio visual en pantalla, 
   ofreciendo a la dirección una experiencia interactiva limpia.

📌 Variación YoY de Adopción Ecológica

0.3 Gap Eco Unid = 
// Delta absoluto de absorción de mercado para nuevas tecnologías (YoY).
([0.1 Ventas Eco AP] - [0.2 Ventas Eco AA]) + 0

0.4 % Gap Eco = 
// Tasa de crecimiento relativa de la categoría ecológica seleccionada.
DIVIDE([0.3 Gap Eco Unid], [0.2 Ventas Eco AA], 0) + 0

💡 Racional de Negocio: Permite evaluar la velocidad de transición del mercado hacia tecnologías limpias. Al heredar el contexto dinámico de la medida padre, 
   este Gap se ajusta automáticamente para mostrar si el crecimiento está siendo impulsado por híbridos convencionales o si ya hay una aceleración real en vehículos 100% eléctricos.

📌 Distribución Geoespacial Dinámica

0.5 Ventas Eco Mapa = 
// Captura del parámetro tecnológico.
VAR CategoriaSel = SELECTEDVALUE('Filtro Eco'[Categoria], "Combinado")

// Agregaciones nativas (el contexto de tiempo es heredado del segmentador global de la página).
VAR SumaElec = SUM('1_0_Historico_Ventas_Hibridos_V3'[Unidades Electricos])
VAR SumaHibr = SUM('1_0_Historico_Ventas_Hibridos_V3'[Unidades Hibridos])
VAR SumaPlug = SUM('1_0_Historico_Ventas_Hibridos_V3'[Unidades Hibridos Plugin])

RETURN
SWITCH(CategoriaSel,
    "Electricos", SumaElec,
    "Hibridos", SumaHibr,
    "Hibridos Plugin", SumaPlug,
    SumaElec + SumaHibr + SumaPlug
)

💡 Racional de Negocio: Medida diseñada específicamente para el análisis geoespacial. A diferencia de las métricas KPI (que fuerzan su propio anclaje de tiempo), 
   esta fórmula respeta los filtros de fecha aplicados en la página. Mantiene la lógica del Slicer dinámico para identificar en el mapa qué estados del país tienen 
   la infraestructura o el nivel socioeconómico para absorber la oferta de vehículos electrificados.

## 🚢 Bloque de Exportaciones y Comercio Exterior
---

### 📌 Indicadores Base de Exportación (CY vs LY)
```dax
0.1 Exportaciones AP = 
// Anclaje dinámico al año actual (CY) de la base de comercio exterior.
VAR AnioPresente = CALCULATE(YEAR(MAX('0_0_Historico_Exportaciones_V3'[Fecha])), ALL('0_0_Historico_Exportaciones_V3'))

RETURN
CALCULATE(
    SUM('0_0_Historico_Exportaciones_V3'[Unidades Vehiculares]),
    'Calendario'[Año] = AnioPresente
) + 0

0.2 Exportaciones AA = 
// Desplazamiento dinámico al periodo análogo anterior (LY) para evaluar la demanda internacional.
VAR AnioPresente = CALCULATE(YEAR(MAX('0_0_Historico_Exportaciones_V3'[Fecha])), ALL('0_0_Historico_Exportaciones_V3'))
VAR AnioAnterior = AnioPresente - 1

RETURN
CALCULATE(
    SUM('0_0_Historico_Exportaciones_V3'[Unidades Vehiculares]),
    'Calendario'[Año] = AnioAnterior
) + 0

💡 Racional de Negocio: Establece la línea base del volumen enviado a mercados internacionales. Mantener estas medidas de forma dinámica 
   (sin ataduras a filtros de tiempo externos) garantiza que el análisis de comercio exterior esté siempre actualizado al último ciclo operativo consolidado, 
   facilitando la planeación logística transfronteriza.

📌 Variación Comercial Internacional (Gaps YoY)

0.3 Gap Exp Unid = 
// Delta absoluto YoY del volumen de exportación. (+0 para visuales consistentes).
([0.1 Exportaciones AP] - [0.2 Exportaciones AA]) + 0

0.4 % Gap Exp = 
// Tasa de crecimiento o contracción de la demanda extranjera.
DIVIDE([0.3 Gap Exp Unid], [0.2 Exportaciones AA], 0) + 0

💡 Racional de Negocio: Mide la aceleración o pérdida de terreno en el extranjero. Para una operación automotriz en México, donde gran parte de la producción se destina a exportación, 
   este % de variación es crítico. Una caída en este indicador alerta inmediatamente sobre la necesidad de rebalancear el S&OP para intentar absorber ese excedente de ensamble en el 
   mercado nacional y no saturar los patios de la planta.

📌 Run-Rate de Exportación (Ritmo de Despacho)

0.5 Prom Mensual Exp AP = 
// Velocidad de salida hacia aduanas. Filtra meses sin actividad para evitar sesgos a la baja en la métrica.
VAR Promedio = 
    AVERAGEX(
        FILTER(VALUES('Calendario'[Mes]), [0.1 Exportaciones AP] > 0),
        [0.1 Exportaciones AP]
    )
RETURN
COALESCE(Promedio, 0)

💡 Racional de Negocio: Calcula el "Run-Rate" logístico de exportación. Saber exactamente cuántas unidades deben cruzar la frontera o
   llegar a los puertos en promedio mensual es vital para el área de tráfico y aduanas, permitiendo asegurar con anticipación la capacidad de 
   transporte (madrinas/ferrocarril) y mitigar cuellos de botella en la cadena de suministro de salida.

### 📌 Análisis de Tendencias Logísticas de Exportación
```dax
0.6 Prom Mensual Exp AA = 
// Línea base del run-rate de exportación del año anterior (LY) aislando meses inactivos.
VAR Promedio = 
    AVERAGEX(
        FILTER(VALUES('Calendario'[Mes]), [0.2 Exportaciones AA] > 0),
        [0.2 Exportaciones AA]
    )
RETURN
COALESCE(Promedio, 0)

0.7 Gap Promedios Exp = 
// Delta absoluto del ritmo de despachos internacionales (Run-rate actual vs histórico).
([0.5 Prom Mensual Exp AP] - [0.6 Prom Mensual Exp AA]) + 0

0.8 % Gap Promedios Exp = 
// Variación relativa de la aceleración o contracción en la capacidad de exportación.
DIVIDE([0.7 Gap Promedios Exp], [0.6 Prom Mensual Exp AA], 0) + 0

💡 Racional de Negocio: Estas medidas evalúan la estabilidad de la red logística internacional. Comparar la velocidad de desplazamiento mensual 
   (Run-rate) del año actual contra el anterior permite a la Dirección de Operaciones identificar cuellos de botella en puertos o fronteras. Si el volumen 
   total de exportación sube, pero el gap de promedios baja, indica que los despachos se están concentrando en picos atípicos en lugar de fluir de manera constante.

📌 Volumen Consolidado y Dependencia de Mercado Extranjero

1.1 Total Exportacion = 
// Métrica agregada base para el volumen total de unidades enviadas al extranjero.
SUM('0_0_Historico_Exportaciones_V3'[Unidades Vehiculares])

1.2 % Exportacion = 
// Cuantificación del grado de dependencia de la planta hacia los mercados internacionales.
DIVIDE([1.1 Total Exportacion], [1.1 Total Produccion], 0)

💡 Racional de Negocio: Este es uno de los KPIs estratégicos más importantes para una planta automotriz en México. El % Exportacion revela el balance 
   de riesgo macroeconómico. Un porcentaje superior al 80% indica una operación altamente dependiente de tratados internacionales y vulnerable a aranceles o 
   fluctuaciones logísticas globales, obligando al equipo de S&OP a mantener un stock de seguridad (buffer) alineado a los tiempos de tránsito marítimo o ferroviario.

📌 Variación Comercial Internacional (Gaps YoY)

1.3 Exportaciones AA = 
// Inteligencia de tiempo estandarizada para periodo análogo anterior (LY).
CALCULATE(
    [1.1 Total Exportacion], 
    SAMEPERIODLASTYEAR('Calendario'[Date])
)

1.4 Gap Exportacion Unid = 
// Delta absoluto YoY del volumen despachado al extranjero.
[1.1 Total Exportacion] - [1.3 Exportaciones AA]

1.5 % Gap Exportacion = 
// Tasa de crecimiento o contracción de envíos internacionales.
DIVIDE([1.4 Gap Exportacion Unid], [1.3 Exportaciones AA], 0)

💡 Racional de Negocio: Mide la aceleración o pérdida de terreno en el extranjero. Para una operación automotriz, 
   una caída en este indicador alerta inmediatamente sobre la necesidad de rebalancear el S&OP para intentar absorber ese 
   excedente de ensamble en el mercado nacional y evitar saturación en patios.

📌 Análisis de Tendencias Logísticas y Run-Rate de Exportación

1.6 Promedio Mensual Exp = 
// Capacidad media de despacho mensual en el año en curso.
AVERAGEX(
    VALUES('Calendario'[MesNumero]), 
    [1.1 Total Exportacion]
)

1.7 Promedio Mensual Exp AA = 
// Capacidad media de despacho mensual del año anterior (LY).
AVERAGEX(
    VALUES('Calendario'[MesNumero]), 
    CALCULATE([1.1 Total Exportacion], SAMEPERIODLASTYEAR('Calendario'[Date]))
)

1.8 Gap Promedio Mensual = 
// Desviación absoluta del ritmo logístico (Run-rate).
[1.6 Promedio Mensual Exp] - [1.7 Promedio Mensual Exp AA]

1.9 % Gap Promedio Mensual = 
// Variación relativa en la eficiencia de salida hacia aduanas.
DIVIDE([1.8 Gap Promedio Mensual], [1.7 Promedio Mensual Exp AA], 0)

💡 Racional de Negocio: Al calcular los Gaps a través de promedios mensuales en lugar de totales brutos, logramos aislar el "ruido" de meses atípicamente altos o bajos. 
   Esto nos da la verdadera velocidad de salida (Throughput Logístico) y ayuda a confirmar si estamos enviando inventario al extranjero de manera estable o si nuestra cadena 
   de suministro está sufriendo cuellos de botella en puertos o fronteras.

📅 Bloque Fundacional: Dimensión de Tiempo Inteligente (Calendario)
📌 Generación de Horizonte S&OP Dinámico

Calendario = 
// Captura la última fecha con datos consolidados en la tabla de hechos (Actuals).
VAR UltimaFechaVentas = MAX('3_0_Ventas_V3'[Fecha])

// Expande el horizonte temporal 24 meses hacia el futuro para habilitar el motor de pronósticos S&OP.
VAR FechaFinPronostico = EDATE(UltimaFechaVentas, 24)

// Límite inferior dinámico basado en el origen de los datos históricos.
VAR FechaInicio = DATE(2005, 1, 1) 

// Generación de la dimensión de tiempo con jerarquías analíticas.
RETURN
ADDCOLUMNS (
    CALENDAR (FechaInicio, FechaFinPronostico),
    "Año", YEAR([Date]),
    "Mes", FORMAT([Date], "MMMM"),
    "MesNumero", MONTH([Date]),
    "Trimestre", "T" & FORMAT([Date], "Q"),
    "AñoMes", FORMAT([Date], "YYYYMM")
)

💡 Racional de Negocio: La dimensión de tiempo es la columna vertebral de cualquier modelo S&OP. A diferencia de los calendarios estáticos tradicionales, 
   esta tabla calcula automáticamente el "horizonte de planeación". Al sumar 24 meses exactos (EDATE) a la última fecha real de ventas, garantiza que el simulador 
   de escenarios y los modelos estadísticos de estacionalidad tengan el espacio temporal necesario para proyectar la demanda a mediano plazo (Mid-Term Planning) sin 
   generar fechas innecesarias que saturen el modelo de datos.

🏷️ Bloque de Modelado Relacional y Dimensionamiento (Master Data)
📌 Creación de Dimensión Consolidada de Marcas (Dim_Marca)

Dim_Marca = 
// Consolidación de catálogo maestro mediante la unión de llaves de las tablas de hechos.
FILTER(
    DISTINCT(
        UNION(
            VALUES('3_0_Ventas_V3'[Marca]),
            VALUES('2_0_Historico_Produccion_V3'[Marca]),
            VALUES('0_0_Historico_Exportaciones_V3'[Marca])
        )
    ),
    // Filtro de integridad de datos para eliminar registros corruptos o nulos.
    [Marca] <> "#N/D" && [Marca] <> BLANK()
)

💡 Racional de Negocio: En arquitectura de datos, cuando se manejan múltiples tablas de hechos independientes (Ventas, Producción y Exportaciones), es un error 
   crítico filtrar el reporte usando la columna de una sola de ellas, ya que ocultaría los datos de las otras. Diseñé esta tabla calculada para generar una "Dimensión 
   Puente" única y centralizada bajo las mejores prácticas del Modelo de Estrella (Star Schema). Al aplicar UNION y DISTINCT, aseguramos una relación de uno a varios 
   (1:N) limpia hacia todas las tablas de hechos, garantizando la consistencia de los filtros globales.

📌 Segmentación y Clasificación Operativa de Marcas

Clasificacion Operativa = 
// Evaluación de presencia física en el Fact Table de Manufactura.
VAR Fab = CALCULATE(COUNTROWS('2_0_Historico_Produccion_V3')) > 0
// Evaluación de presencia física en el Fact Table de Mercado Interno.
VAR Ven = CALCULATE(COUNTROWS('3_0_Ventas_V3')) > 0
// Evaluación de presencia física en el Fact Table de Comercio Exterior.
VAR Exp = CALCULATE(COUNTROWS('0_0_Historico_Exportaciones_V3')) > 0

// Construcción dinámica de la etiqueta de perfil corporativo.
VAR TxtFab = IF(Fab, "Fabricante", "")
VAR TxtVen = IF(Ven, IF(Fab, " | Vendedor", "Vendedor"), "")
VAR TxtExp = IF(Exp, IF(Fab || Ven, " | Exportador", "Exportador"), "")

RETURN 
TxtFab & TxtVen & TxtExp

💡 Racional de Negocio: Esta columna calculada añade inteligencia competitiva al catálogo maestro de marcas. En lugar de tratarlas a todas por igual, evalúa dinámicamente 
   el comportamiento transaccional de cada firma en los tres sectores de la cadena. Esto le permite a la Dirección segmentar el mercado de forma automática para responder 
   preguntas estratégicas de S&OP: por ejemplo, aislar y analizar exclusivamente el comportamiento de las marcas que son "Fabricantes | Exportadores" (las que sostienen 
   la infraestructura industrial del país) frente a las que son puramente "Vendedores" (importadoras).

📌 Consolidación de Catálogos Relacionales (Modelos, Segmentos y Tipos)

Dim_Modelo = 
// Consolidación y limpieza del catálogo maestro de modelos vehiculares.
FILTER(
    DISTINCT(
        UNION(
            VALUES('3_0_Ventas_V3'[Modelo]),
            VALUES('2_0_Historico_Produccion_V3'[Modelo]),
            VALUES('0_0_Historico_Exportaciones_V3'[Modelo])
        )
    ),
    // Exclusión de registros huérfanos o sucios para mantener la integridad referencial.
    [Modelo] <> "#N/D" && [Modelo] <> BLANK()
)

Dim_Segmento = 
// Generación de dimensión puente unificada para cruce de segmentos (ej. SUV, Compacto, Pick-up).
DISTINCT(
    UNION(
        VALUES('3_0_Ventas_V3'[Segmento]),
        VALUES('2_0_Historico_Produccion_V3'[Segmento]),
        VALUES('0_0_Historico_Exportaciones_V3'[Segmento])
    )
)

Dim_Tipo = 
// Generación de dimensión puente unificada para la clasificación de chasis (Pasajeros vs Carga Ligera).
DISTINCT(
    UNION(
        VALUES('3_0_Ventas_V3'[Tipo]),
        VALUES('2_0_Historico_Produccion_V3'[Tipo]),
        VALUES('0_0_Historico_Exportaciones_V3'[Tipo])
    )
)

💡 Racional de Negocio: Estas tablas completan la arquitectura de "Modelo de Estrella" (Star Schema). Al igual que con la tabla de Marcas, 
   extraer los valores únicos de todas las tablas de hechos para crear catálogos centralizados asegura que, cuando un Director seleccione "SUV" 
   en un segmentador, el tablero filtre simultáneamente y con precisión matemática las ventas, la producción y las exportaciones, evitando discrepancias o 
   pérdida de datos en la visualización.

📌 Parámetros de Dinamismo Visual y Simulador de Escenarios (S&OP)

Dimension de Mercado = {
    // Implementación de "Field Parameters" para inyección dinámica de ejes.
    ("Marca", NAMEOF('Dim_Marca'[Marca]), 0),
    ("Segmento", NAMEOF('Dim_Segmento'[Segmento]), 1),
    ("Modelo", NAMEOF('Dim_Modelo'[Modelo]), 2),
    ("Tipo", NAMEOF('Dim_Tipo'[Tipo]), 3)
}

Simulador Escenario % = 
// Generación del arreglo numérico para el motor "What-If" (-50% a +50% en pasos del 5%).
GENERATESERIES(-0.5, 0.5, 0.05)

💡 Racional de Negocio: Aquí se demuestra un dominio avanzado de la interfaz de Power BI (UX/UI Analítica). La Dimension de Mercado utiliza la función de 
   Parámetros de Campo, lo que permite al usuario interactuar con un solo gráfico y cambiar dinámicamente su eje X (ver datos por Marca, luego cambiarlos a 
   Segmento o Modelo con un solo clic), ahorrando un enorme espacio en el lienzo y evitando la saturación visual. 

### 📌 Captura Dinámica de Escenarios (What-If Parameter)
```dax
Simulador Escenario % = 
// Generación del arreglo numérico para el motor "What-If" (-50% a +50% en pasos del 5%).
GENERATESERIES(-0.5, 0.5, 0.05)

Valor de Simulador Escenario % = 
// Captura del valor exacto seleccionado por la dirección en el segmentador visual.
// Si no hay selección activa, el modelo asume 0 (escenario base / sin alteración).
SELECTEDVALUE('Simulador Escenario %'[Simulador Escenario %], 0)

💡 Racional de Negocio: Este par de fórmulas conforma el "cerebro" interactivo del motor de pronósticos en el S&OP. Simulador Escenario % construye la tabla virtual 
   con los porcentajes de estrés (variable independiente), mientras que Valor de Simulador Escenario % actúa como el "oyente" que atrapa la decisión del usuario en el 
   tablero y la inyecta directamente en la medida principal de pronóstico. El valor por defecto de "0" es una regla de negocio crucial: garantiza que, si el comité no 
   toca el simulador de estrés, las proyecciones futuras muestren el comportamiento estacional puro (baseline) sin ninguna alteración artificial.

### 📌 Auditoría y Validación Global del Modelo
```dax
0.0 Validador_Filtros = 
// Suma global de transacciones en las tres tablas de hechos principales del modelo.
CALCULATE(COUNTROWS('3_0_Ventas_V3')) + 
CALCULATE(COUNTROWS('2_0_Historico_Produccion_V3')) + 
CALCULATE(COUNTROWS('0_0_Historico_Exportaciones_V3'))

💡 Racional de Negocio: Esta es una medida técnica de auditoría y control de UI (User Interface) que demuestra un alto nivel de madurez en el desarrollo de tableros. 
   Al sumar el recuento de filas de los tres pilares de datos (Ventas, Producción y Exportación), el modelo evalúa al instante si una combinación de filtros seleccionada 
   por el usuario realmente existe en la operación. Se utiliza estratégicamente para optimizar el rendimiento y limpiar la experiencia visual, ocultando automáticamente 
   en matrices o segmentadores aquellos cruces de datos (ej. una marca específica en un año determinado) que no tienen historial de actividad, evitando pantallas en blanco 
   y confusión directiva.
















