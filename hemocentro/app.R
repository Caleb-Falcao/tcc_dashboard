# install.packages("zoo")
# install.packages("shiny")
# install.packages("htmltools")
# install.packages("bslib")
# install.packages("readxl")
# install.packages("forecast")
# install.packages("dygraphs")
# install.packages("shinyWidgets")

################BIBLIOTECAS UTILIZADAS##########################################
#zoo: Reestruturar serie temporal irregular, a partir de modelos genericos
library(zoo)
library(readxl)
library(shiny)
library(shinyWidgets)
library(htmltools)
library(bslib)
library(forecast)
library(dygraphs)

############################ INICIALIZAÇÃO DAS SÉRIES TEMPORAIS ################
dados_total <-
  read_excel("dados_sangue.xlsx", sheet = "total", col_names = FALSE)
mytsTotal <-
  ts(
    dados_total,
    start = c(2014, 1),
    end = c(2022, 12),
    frequency = 12
  )
dados_aferese <-
  read_excel("dados_sangue.xlsx", sheet = "aferese", col_names = FALSE)
mytsaferese <-
  ts(
    dados_aferese,
    start = c(2014, 1),
    end = c(2022, 12),
    frequency = 12
  )

#################################### APLICAÇÃO WEB SHINY #######################

# ALGUNS PARAMETROS SETADOS PARA O BOOTSTRAP
theme <- bs_theme(
  version = 5.0,
  font_scale = 1.2,
  spacer = "2rem",
  bootswatch = "materia"
)

#################### UI SHINY #######################################
ui <- bootstrapPage(
  
  # TEMA SETADO ANTERIORMENTE BOOTSTRAP
  theme = theme,
  
  #TAG HEAD
  tags$head(
    tags$meta(charset = "UTF-8"),
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    tags$link(rel="preconnect", href="https://fonts.googleapis.com"),
    tags$link(rel = "preconnect", type = "text/css", href = "https://fonts.gstatic.com", crossorigin = "anonymous"),
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    tags$link(rel="stylesheet", href="https://fonts.googleapis.com/css2?family=Ubuntu:wght@500&display=swap"),
    tags$link(rel="stylesheet", href="https://fonts.googleapis.com/icon?family=Material+Icons"),
    tags$link(href = "https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css",
      rel = "stylesheet",
      integrity = "sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC",
      crossorigin = "anonymous"
    ),
    tags$title("Hemocentro Dashboard")
  ),
  
  #TEMPLATE HTML
  htmlTemplate(
    
    #RENDERIZAR INDEX.HTML(PARTE ESTATICO)
    "www/index.html",
    
    #MOSTRAR CARDS NO HTML
    cards = uiOutput("cards"),
    
    #INTERVALO DE TEMPO
    intervalo_tempo_total = 
      dateRangeInput(
        "datesSangueTotal",
        "Período Sangue Total",
        start = "2014-01-01",
        end = "2023-12-31",
        min = "2014-01-01",
        max = "2024-12-31",
        format = "dd/mm/yyyy",
        startview = "year",
        language = "pt-BR",separator = "até"
      ),
    intervalo_tempo_aferese = 
      
      dateRangeInput(
           "dates_aferese",
           "Período Sangue Aférese",
           start = "2014-01-01",
           end = "2023-12-31",
           min = "2014-01-01",
           max = "2024-12-31",
           format = "dd/mm/yyyy",
           startview = "year",
           language = "pt-BR",separator = "até"
         )
    ,
    bt_modelo = actionBttn(
      inputId = "res_btn_modelo",
      label = "Recalcular modelo",
      color = "default",
      class = "btn-custom"
    ),
    
    #CHAMADA GRAFICOS SANGUE TOTAL NO HTML
    graficoLinhaTotal = dygraphOutput("graficoLinhaTotal"),
    grafico_barra_total = dygraphOutput("graficoBarraTotal"),
    
    #CHAMADA GRAFICOS SANGUE AFERESE NO HTML
    graficoLinhaAferese = dygraphOutput("graficoLinhaAferese"),
    grafico_barra_aferese = dygraphOutput("graficoBarraAferese")
  )
)

#################################### SERVER ####################################
server <- function(input, output){

  output$cards <- renderUI({
    ############################ DEFINIÇÃO TREINO TESTE ########################
    
    #TOTAL MESES DOAÇÃO DE SANGUE
    TotalMeses = 108
    TotalMesesTreino = ceiling(0.8 * TotalMeses)
    
    #TOTAL MESES PARA PREVISAO
    TotalMesesTeste = TotalMeses - TotalMesesTreino
    treinoSangueTotal = window(mytsTotal,
                               start = c(2014, 1),
                               end = c(2022, 12))
    treinoAfereseTotal = window(mytsaferese,
                                start = c(2014, 1),
                                end = c(2022, 12))
    
    ########################### MAPE MODELOS####################################
    #VARIAVEL TESTAR MAPE
    treinoTesteSangue = window(mytsTotal, start = c(2014,1),end=c(2021,5))#18MESES
    
    #BTN RECALCULAR MAPE
    observeEvent(input$res_btn_modelo,{
      ########################### MAPE MODELOS###################################
      
      #CRIAÇÃO DOS MODELOS    
      
      #MODELO ETS(SUAVIZAÇÃO EXPONENCIAL
      #prevSTLFSangueTotal = stlf(treinoTesteSangue, h = TotalMesesTeste)
      # MODELO ARIMA 
      
      #mdlTreinoSangueTotalArima = auto.arima(treinoTesteSangue, trace=T,stepwise = F, approximation = F)
      #MODELO REGRESSÃO LINEAR
      #mdlTreinoSangueTotalRL = tslm(treinoTesteSangue ~ season + trend, data=treinoTesteSangue)
      
      #QUANTO MENOR O MAPE, MELHOR!
      #mape_Ets = accuracy(treinoTesteSangue, prevSTLFSangueTotal$model$fitted)["Test set", "MAPE"]
      #mape_Arima = accuracy(treinoTesteSangue, mdlTreinoSangueTotalArima$fitted)["Test set", "MAPE"]
      #mapeRL = accuracy(treinoTesteSangue, mdlTreinoSangueTotalRL$fitted.values)["Test set", "MAPE"]
      
      #ENCONTRAR MENOR MAPE
      #melhor_Mape = min(mape_Ets, mape_Arima, mapeRL)
      
      #ARMAZENAR MELHOR MODELO NA VARIAVEL
      #melhorModelo <- ifelse(melhor_Mape == mape_Ets, prevTreinoSangueTotalSTFL,
      #ifelse(melhor_Mape == mape_Arima, mdlTreinoSangueTotalArima,mdlTreinoSangueTotalRL))
    })
    
    ########################## OBTER DATAS USUARIO #############################
    start_date <- as.yearmon(input$datesSangueTotal[1])
    end_date <- as.yearmon(input$datesSangueTotal[2])
    start_date_aferese <- as.yearmon(input$dates_aferese[1])
    end_date_aferese <- as.yearmon(input$dates_aferese[2])
    
    #CONVERTER SERIE TEMPORAL PARA "ZOO", CORRIGIR ERROS
    sangue_total <- as.zoo(mytsTotal)
    aferese <- as.zoo(mytsaferese)
    
    #FILTRAR DADOS INTERVALO SELECIONADO SANGUE TOTAL
    sangueTotalFiltro <-
      window(sangue_total, start = start_date, end = end_date)
    
    #FILTRAR DADOS INTERVALO SELECIONADO SANGUE AFERESE
    afereseFiltro <-
      window(aferese, start = start_date_aferese, end = end_date_aferese)
    ############################### MODELO ETS #################################
    #SANGUE TOTAL ETS
    prevTreinoSangueTotalSTFL = stlf(treinoSangueTotal, h = TotalMesesTeste)
    
    #AFERESE ETS
    prevTreinoSangueAfereseSTFL = stlf(treinoAfereseTotal, h = TotalMesesTeste)
    
    ################################# GRAFICOS #################################
    previsaoTotal <- prevTreinoSangueTotalSTFL$mean
    dados_e_previsao <- cbind(sangueTotalFiltro, previsaoTotal)
    
    #GRAFICO DADOS E PREVISAO SANGUE TOTAL
    dados_e_previsao_filtered <-
      window(dados_e_previsao, start = start_date, end = end_date)
    
    #GRAFICO DADOS E PREVISAO SANGUE AFERESE
    previsao_aferese <- prevTreinoSangueAfereseSTFL$mean
    
    dados_e_previsao_aferese <-
      cbind(afereseFiltro, previsao_aferese)
    
    dados_e_previsao_aferese_filtered <-
      window(dados_e_previsao_aferese,
             start = start_date_aferese,
             end = end_date_aferese)
    # DADOS ESTATISTICOS SANGUE TOTAL
    total <- sum(sangueTotalFiltro)
    media <- as.integer(mean(sangueTotalFiltro))
    mediana <- median(sangueTotalFiltro)
    minimo <- min(sangueTotalFiltro)
    maximo <- max(sangueTotalFiltro)
    
    #VALORES MINIMOS E MAXIMOS
    indice_minimo <- which.min(sangueTotalFiltro)
    indice_maximo <- which.max(sangueTotalFiltro)
    
    # DATAS QUE CORRESPONDE AOS INDICES FILTRADOS
    data_minima <- time(sangueTotalFiltro)[indice_minimo]
    data_maxima <- time(sangueTotalFiltro)[indice_maximo]
    
    # DADOS SANGUE AFERESE
    totalAferese <- sum(afereseFiltro)
    mediaAferese <- as.integer(mean(afereseFiltro))
    medianaAferese <- median(afereseFiltro)
    minimoAferese <- min(afereseFiltro)
    maximoAferese <- max(afereseFiltro)
    
    #VALORES MINIMOS E MAXIMOS
    indice_minimoA <- which.min(afereseFiltro)
    indice_maximoA <- which.max(afereseFiltro)
    
    # DATAS QUE CORRESPONDE AOS INDICES FILTRADOS
    data_minimaA <- time(afereseFiltro)[indice_minimoA]
    data_maximaA <- time(afereseFiltro)[indice_maximoA]
    
    ################### PLOT GRAFICO SANGUE TOTAL ##############################
    output$graficoLinhaTotal <- renderDygraph({
      dygraph(dados_e_previsao_filtered) %>%
        dyAxis("y", label = "Nº de bolsas total") %>%
        dyAxis("x", label = "Tempo") %>%
        dySeries(color = "#9f0000", label = "Bolsas") %>%
        dySeries("previsaoTotal", label = "Previsão") %>%
        dyLegend(show = "follow", width = "0.8em") %>%
        dyOptions(fillGraph = TRUE, fillAlpha = 0.3) %>%
        dyRangeSelector(
          height = 35,
          strokeColor = "#910000",
          fillColor = "#9f0000"
        )
    })
    output$graficoBarraTotal <- renderDygraph({
      dygraph(dados_e_previsao_filtered) %>%
        dyAxis("y", label = "Nº de bolsas total") %>%
        dyAxis("x", label = "Tempo") %>%
        dyLegend(show = "follow") %>%
        dySeries(color = "#9f0000", label = "Bolsas") %>%
        dySeries("previsaoTotal", label = "Previsão") %>%
        dyLegend(show = "follow", width = "0.8em") %>%
        dyRangeSelector(
          height = 35,
          strokeColor = "#910000",
          fillColor = "#9f0000"
        ) %>%
        dyBarChart()
    })
    ##################### PLOT GRAFICO SANGUE AFERESE ##########################
    
    output$graficoLinhaAferese <- renderDygraph({
      dygraph(dados_e_previsao_aferese_filtered) %>%
        dyAxis("y", label = "Nº de bolsas aférese") %>%
        dyAxis("x", label = "Tempo") %>%
        dySeries(color = "#9f0000", label = "Bolsas") %>%
        dySeries("previsao_aferese", label = "Previsão") %>%
        dyLegend(show = "follow", width = "0.8em") %>%
        dyOptions(fillGraph = TRUE, fillAlpha = 0.3) %>%
        dyRangeSelector(
          height = 35,
          strokeColor = "#910000",
          fillColor = "#9f0000"
        )
    })
    output$graficoBarraAferese <- renderDygraph({
      dygraph(dados_e_previsao_aferese_filtered) %>%
        dyAxis("y", label = "Nº de bolsas aférese") %>%
        dyAxis("x", label = "Tempo") %>%
        dySeries(color = "#9f0000", label = "Bolsas") %>%
        dySeries("previsao_aferese", label = "Previsão") %>%
        dyLegend(show = "follow", width = "0.8em") %>%
        dyRangeSelector(
          height = 35,
          strokeColor = "#910000",
          fillColor = "#9f0000"
        ) %>%
        dyBarChart()
    })
    
    ################### RETORNA CARDS COM DADOS ESTATISTICOS####################
    HTML(
      paste(
        '
            <div
        class="row justify-content-center align-items-center p-3 g-5 gradient-cards"
      >
        <div class="col">
          <!--coluna 1-->
          <div class="col">
            <div class="row">
              <div class="card d-flex flex-row-reverse">
                <img src="img/gota_sangue.png" alt="gota de sangue card" />
                <div>
                  <h5 class="card-title">Maximo doado</h5>
                  <p class="card-text">',
        maximo,':',data_maxima,
        '</p>
                </div>
              </div>
            </div>
            <div class="row my-2">
              <div class="card d-flex flex-row-reverse">
                <img src="img/gota_sangue.png" alt="gota de sangue card" />
                <div>
                  <h5 class="card-title">Minimo doado</h5>
                  <p class="card-text">',
        minimo,':',data_minima,
        '</p>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="col">
          <!--coluna 2-->
          <div class="col">
            <div class="row">
              <div class="card d-flex flex-row-reverse">
                <img src="img/gota_sangue.png" alt="gota de sangue card" />
                <div>
                  <h5 class="card-title">Média doação</h5>
                  <p class="card-text">',
        media,
        '</p>
                </div>
              </div>
            </div>
            <div class="row my-2">
              <div class="card d-flex flex-row-reverse">
                <img src="img/gota_sangue.png" alt="gota de sangue card" />
                <div>
                  <h5 class="card-title">Mediana doação</h5>
                  <p class="card-text">',
        mediana,
        '</p>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="col me-5">
          <!--coluna 3-->
          <div class="col">
            <div class="row">
              <div class="card d-flex flex-row-reverse">
                <img src="img/gota_sangue.png" alt="gota de sangue card" />
                <div>
                  <h5 class="card-title">Bolsa Sangue</h5>
                  <p class="card-text">',
        total,
        '</p>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="col ms-3">
          <!--coluna 3-->
          <div class="col">
            <div class="row">
              <div class="card d-flex flex-row-reverse">
                <img src="img/gota_aferese.png" alt="gota de sangue card" />
                <div>
                  <h5 class="card-title">Bolsa Aférese</h5>
                  <p class="card-text">',
        totalAferese,
        '</p>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="col">
          <!--coluna 5-->
          <div class="col">
            <div class="row">
              <div class="card d-flex flex-row-reverse">
                <img src="img/gota_aferese.png" alt="gota de sangue card" />
                <div>
                  <h5 class="card-title">Média doação</h5>
                  <p class="card-text">',
        mediaAferese,
        '</p>
                </div>
              </div>
            </div>
            <div class="row my-2">
              <div class="card d-flex flex-row-reverse">
                <img src="img/gota_aferese.png" alt="gota de sangue card" />
                <div>
                  <h5 class="card-title">Mediana doação</h5>
                  <p class="card-text">',
        medianaAferese,
        '</p>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="col">
          <!--coluna 6-->
          <div class="col">
            <div class="row">
              <div class="card d-flex flex-row-reverse">
                <img src="img/gota_aferese.png" alt="gota de sangue card" />
                <div>
                  <h5 class="card-title">Maximo doado</h5>
                  <p class="card-text">',
        maximoAferese,':',data_maximaA,
        '</p>
                </div>
              </div>
            </div>
          </div>
          <div class="row my-2">
            <div class="card d-flex flex-row-reverse">
              <img src="img/gota_aferese.png" alt="gota de sangue card" />
              <div>
                <h5 class="card-title">Minimo doado</h5>
                <p class="card-text">',
        minimoAferese,':',data_minimaA,
        '</p>
              </div>
            </div>
          </div>
        </div>
      </div>
'
      )
    )
  })
}

##################### CHAMADA DA FUNCAO UI/SERVER SHINY ########################
shinyApp(ui = ui, server = server)
