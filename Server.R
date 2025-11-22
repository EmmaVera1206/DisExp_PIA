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


  # ===================== REGRESIÓN NO LINEAL =====================




