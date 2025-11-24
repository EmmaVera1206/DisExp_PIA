# ui.R
library(shiny)
library(shinythemes)
library(DT)
library(shinyjs)

ui <- navbarPage(
  
  title = "Diseño de Experimentos",
  theme = shinytheme("flatly"),

  # ======= ACTIVAR shinyjs =======
  useShinyjs(),

  # ======= HEADER: CSS personalizado =======
  tags$head(
    tags$style(HTML("
      /* NAVBAR */
      .navbar-default {
        background-color: #2A9689 !important;
        border-color: #357ABD !important;
      }
      .navbar-default .navbar-brand {
        color: #ffffff !important;
        font-size: 22px;
        font-weight: bold;
      }
      .navbar-default .navbar-nav > li > a {
        color: #ffffff !important;
        font-size: 15px;
      }
      .navbar-default .navbar-nav > li > a:hover {
        background-color: #2A9689 !important;
        color: #ffffff !important;
      }

      /* FONDO GENERAL */
      body {
        background-color: #F7FAFC !important;
      }

      /* PANEL / CARDS */
      .well, .panel, .panel-default, .form-control {
        background-color: #FFFFFF !important;
        border-radius: 12px !important;
        border: 1px solid #E2E8F0 !important;
        padding: 15px !important;
        box-shadow: 0 1px 4px rgba(0,0,0,0.08);
      }

      /* TITULOS */
      h1, h2, h3 {
        color: #2A4365 !important;
        font-weight: 600;
      }

      p, ul {
        color: #000000 !important;
        font-weight: 500;
      }

      /* BOTONES */
      .btn {
        background-color: #E1712B !important;
        color: white !important;
        border-radius: 8px !important;
        font-weight: bold !important;
        transition: 0.2s ease;
      }
      .btn:hover {
        background-color: #973C08 !important;
        transform: translateY(-2px);
      }

      /* BOTÓN NARANJA */
      .btn-warning {
        background-color: #F5A623 !important;
        color: white !important;
      }
      .btn-warning:hover {
        background-color: #D98B1C !important;
      }

      /* INPUTS */
      .form-control {
        border-radius: 8px !important;
        border: 1px solid #CBD5E0 !important;
      }
      .form-control:focus {
        border-color: #4A90E2 !important;
        box-shadow: 0 0 4px rgba(74,144,226,0.5) !important;
      }

      /* TABLAS DT */
      table.dataTable {
        border-radius: 8px !important;
        overflow: hidden !important;
      }

      /* TABS ACTIVAS */
      .nav-tabs > li.active > a {
        background-color: #7ED6C1 !important;
        color: white !important;
        border-radius: 10px 10px 0 0 !important;
      }
      .nav-tabs > li > a:hover {
        background-color: #B2EFE0 !important;
      }
    "))
  ),
  # ====================== INICIO ======================
  tabPanel("Inicio",
           fluidPage(
             titlePanel("PIA de Diseño de Experimentos"),
             h4("Se subirán archivos CSV para cada análisis en las pestañas correspondientes."),
             p("Aplicación de los temas vistos en clase usando R:"),
                 tags$ul(
                   tags$li("ANOVA (análisis de varianza)"),
                   tags$li("Prueba de Tukey"),
                   tags$li("Diseños factoriales de dos niveles (unifactorial y bifactorial)"),
                   tags$li("Regresión lineal y no lineal")
			  ),
			column(
                 width = 4,
                 wellPanel(
                   h4("Integrantes del equipo:"),
                   tags$ol(
                     tags$li("Emma Daniela Vera Gordillo 2115127"),
                     tags$li("Osmar Yadir Silva González 2177885"),
                     tags$li("Carlos Dionisio Guía Flores 2109314"),
                     tags$li("Alexa Verónica Arámbula Garza 2096148"),
			   tags$li("Mildred Hatziri Loredo Urdiales 2106410"),
                     tags$li("Victor Manuela Pacheco Martínez 2099730")
                   ),
                   hr(),
                   p(em("Gpo:005 Hora:V3"))
                 )
			
		)
	)
  ),

  # ====================== ANOVA ======================
  tabPanel("ANOVA",
           sidebarLayout(
             sidebarPanel(
               fileInput("anova_file", "Subir archivo CSV", accept = ".csv"),
               uiOutput("anova_var_select"),
               actionButton("run_anova", "Ejecutar ANOVA")
             ),
             mainPanel(
               h3("Resultados ANOVA"),
               verbatimTextOutput("anova_table"),
               plotOutput("anova_plot")
             )
           )
  ),

  # ====================== COMPARACIONES MÚLTIPLES ======================
  tabPanel("Comparaciones múltiples",
           sidebarLayout(
             sidebarPanel(
               fileInput("mc_file", "Subir archivo CSV", accept = ".csv"),
               uiOutput("mc_var_select"),
               selectInput("mc_method", "Método:", 
                           choices = c("Tukey HSD"="tukey")),
               numericInput("mc_alpha","Nivel de significancia:",0.05,0.001,0.2,0.01),
               actionButton("run_mc","Ejecutar comparación")
             ),
             mainPanel(
               verbatimTextOutput("mc_results"),
               plotOutput("mc_plot")
             )
           )
  ),

  # ====================== REGRESIÓN LINEAL ======================
  tabPanel("Regresión lineal",
           sidebarLayout(
             sidebarPanel(
               fileInput("rl_file","Subir CSV", accept=".csv"),
               uiOutput("rl_var_select"),
               actionButton("run_rl","Ajustar modelo")
             ),
             mainPanel(
               verbatimTextOutput("rl_summary"),
               plotOutput("rl_scatter"),
               plotOutput("rl_residuals"),
               plotOutput("rl_qq")
             )
           )
  ),

  # ====================== REGRESIÓN NO LINEAL ======================
  tabPanel("Regresión no lineal",
           sidebarLayout(
             sidebarPanel(
               fileInput("rnl_file","Subir CSV",accept=".csv"),
               uiOutput("rnl_var_select"),
               numericInput("rnl_start_a","Inicial a:",1),
               numericInput("rnl_start_b","Inicial b:",0.1),
               actionButton("run_rnl","Ajustar modelo")
             ),
             mainPanel(
               verbatimTextOutput("rnl_summary"),
               plotOutput("rnl_plot")
             )
           )
  ),

 )