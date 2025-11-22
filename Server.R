# server.R
library(shiny)
library(shinyjs)
library(ggplot2)
library(dplyr)
library(DT)
library(gridExtra)

server <- function(input, output, session){

   # ===================== ANOVA (1 o 2 factores) ===================== 
  an_data <- reactive({ 
    req(input$anova_file) 
    read.csv(input$anova_file$datapath) 
  }) 
 
  # Selección de respuesta y factores 
  output$anova_var_select <- renderUI({ 
    df <- an_data() 
    tagList( 
      selectInput("anova_y",  "Variable respuesta (Y):", names(df)), 
      selectInput("anova_f1", "Factor 1:",              names(df)), 
      selectInput("anova_f2", "Factor 2 (opcional):", 
                  choices = c("Ninguno", names(df)), 
                  selected = "Ninguno") 
    ) 
  }) 
 
  # Tabla ANOVA 
  output$anova_table <- renderPrint({ 
    req(input$run_anova) 
    df <- an_data() 
    req(input$anova_y, input$anova_f1) 
 
    # Definir factores (uno o dos) 
    factors <- c(input$anova_f1) 
    if (!is.null(input$anova_f2) && input$anova_f2 != "Ninguno") { 
      factors <- c(factors, input$anova_f2) 
    } 
    factors <- unique(factors[factors != input$anova_y]) 
 
    if (length(factors) == 0) { 
      cat("Debes elegir al menos un factor distinto de Y.\n") 
      return() 
    } 
 
    # Convertir factores a factor() 
    for (v in factors) { 
      df[[v]] <- factor(df[[v]]) 
    } 
 
    # Fórmula: 1 factor -> Y ~ F1 ; 2 factores -> Y ~ F1 * F2 
    form_str <- if (length(factors) == 1) { 
      paste(input$anova_y, "~", factors[1]) 
    } else { 
      paste(input$anova_y, "~", paste(factors, collapse = " * ")) 
    } 
 
    modelo <- aov(as.formula(form_str), data = df) 
    cat("Modelo ajustado:\n", form_str, "\n\n") 
    print(summary(modelo)) 
  }) 
 
  # Gráfica ANOVA 
  output$anova_plot <- renderPlot({ 
    df <- an_data() 
    req(input$anova_y, input$anova_f1) 
 
    factors <- c(input$anova_f1) 
    if (!is.null(input$anova_f2) && input$anova_f2 != "Ninguno") { 
      factors <- c(factors, input$anova_f2) 
    } 
    factors <- unique(factors[factors != input$anova_y]) 
 
    # 1 factor: boxplot clásico 
    if (length(factors) == 1) { 
      gname <- factors[1] 
      df[[gname]] <- factor(df[[gname]]) 
      ggplot(df, aes_string(x = gname, y = input$anova_y)) + 
        geom_boxplot(fill = "#7ED6C1") + 
        labs(x = gname, y = input$anova_y, 
             title = "Boxplot por niveles del factor") + 
        theme_minimal() 
    } else if (length(factors) == 2) { 
      f1 <- factors[1]; f2 <- factors[2] 
df[[f1]] <- factor(df[[f1]]) 
df[[f2]] <- factor(df[[f2]]) 
medias <- df %>% 
group_by(.data[[f1]], .data[[f2]]) %>% 
summarise(media = mean(.data[[input$anova_y]]), .groups = "drop") 
ggplot(medias, 
aes_string(x = f1, y = "media", 
color = f2, group = f2)) + 
geom_point(size = 3) + 
geom_line() + 
labs(x = f1, y = paste("Media de", input$anova_y), 
color = f2, 
title = "Gráfica de interacción") + 
theme_minimal() 
} 
}) 


  # ===================== COMPARACIONES MÚLTIPLES (Tukey) =====================


  # ===================== REGRESIÓN LINEAL =====================
  rl_df <- reactive({
    req(input$rl_file)
    read.csv(input$rl_file$datapath)
  })

  output$rl_var_select <- renderUI({
    df <- rl_df()
    tagList(
      selectInput("rl_y", "Respuesta (Y):", names(df)),
      selectInput("rl_x", "Predictoras (X):", names(df), multiple = TRUE)
    )
  })

  rl_model <- reactive({
    req(input$run_rl)
    df <- rl_df()
    req(input$rl_y, input$rl_x)
    form_str <- paste(input$rl_y, "~", paste(input$rl_x, collapse = " + "))
    lm(as.formula(form_str), data = df)
  })

  output$rl_summary <- renderPrint({
    modelo <- rl_model()
    cat("Modelo ajustado:\n")
    print(formula(modelo))
    cat("\nResumen del modelo:\n")
    print(summary(modelo))
  })

  # Dispersión + recta ajustada (solo si hay 1 X)
  output$rl_scatter <- renderPlot({
    req(rl_model())
    if (length(input$rl_x) != 1) return(NULL)

    df <- rl_df()
    ggplot(df, aes_string(x = input$rl_x[1], y = input$rl_y)) +
      geom_point(color = "#2A9689") +
      geom_smooth(method = "lm", se = FALSE, color = "#E1712B") +
      labs(title = paste("Modelo lineal:", input$rl_y, "vs", input$rl_x[1])) +
      theme_minimal()
     })

  # Residuos vs ajustados
  output$rl_residuals <- renderPlot({
    modelo <- rl_model()
    df_res <- data.frame(
      ajustados = fitted(modelo),
      residuales = resid(modelo)
    )

    ggplot(df_res, aes(x = ajustados, y = residuales)) +
      geom_point(color = "#2A4365") +
      geom_hline(yintercept = 0, linetype = "dashed") +
      labs(x = "Valores ajustados", y = "Residuos",
           title = "Residuos vs valores ajustados") +
      theme_minimal()
  })

  # Gráfica Q-Q
  output$rl_qq <- renderPlot({
    modelo <- rl_model()
    df_res <- data.frame(residuales = resid(modelo))

    ggplot(df_res, aes(sample = residuales)) +
      stat_qq() +
      stat_qq_line(color = "#E1712B") +
      labs(title = "Gráfica Q-Q de residuos") +
      theme_minimal()
  })



  # ===================== REGRESIÓN NO LINEAL =====================





