#
# This is a Shiny web to visualize the results of my project.
#

# Load required libraries
library(shiny)
library(ggplot2)
library(dplyr)
library(rsconnect)
# Load the datast
data <- read.csv("results.csv")

# Define UI
ui <- fluidPage(
  # display the title
  titlePanel("Results Visualization by Task & Training Group"),
  
  # use a sidebar and a main panel
  sidebarLayout(
    # define the sidebar with input controls
    sidebarPanel(
      # select task
      selectInput("task", "Select Task:", choices = unique(data$task)),
      # select group variable
      selectInput("group_variable", "Select Group Variable:", choices = unique(data$group_variable)),
      # select training group
      selectInput("train_group", "Select Train Group:", choices = unique(data$train_group)),
      # update button to update the plot
      actionButton("update", "Update")
    ),
    mainPanel(
      plotOutput("resultPlot")  # Updated to plotOutput
    )
  )
)

# Define Server
server <- function(input, output, session) {
  
# Update training group choices based on selected grouping variable
  observeEvent(input$group_variable, {
    # dynamically update the 'train_group' based on select 'group_variable'
    updateSelectInput(session, "train_group", choices = unique(data$train_group[data$group_variable == input$group_variable]))
  })
  
  
# Filter data based on user input
  filtered_data <- reactive({
    # ensure 'train_group' input is not NULL or invalid
    req(input$train_group)
    # filter the data based on selected task, group variable, and training group.
    data %>% filter(train_group == input$train_group & group_variable == input$group_variable & task == input$task)
  })
  
  
  
# Create Combined Plot
  output$resultPlot <- renderPlot({
    # ensure filtered data exists before proceeding
    req(filtered_data())
    
    plot_data <- filtered_data() %>% 
      # select relevant columns for plotting 
      select(eval_group, calibration_error, roc_auc, train_group)
    # prepare training and test group dataset
    train_data <- plot_data %>% filter(eval_group == train_group)
    test_data <- plot_data %>% filter(eval_group != train_group)
    
#prepare data for arrows connecting training to test points
    arrow_data <- test_data %>%
      mutate(
        # add training group's calibration error.
        train_calibration_error = train_data$calibration_error[1],
        # add training group's AUC
        train_roc_auc = train_data$roc_auc[1]
      ) %>%
      # remove rows with missing values
      filter(!is.na(train_calibration_error) & !is.na(train_roc_auc))
    
# draw plots    
    gg <- ggplot() +
      # plot all points with colors by eval_group
      geom_point(data = plot_data, aes(x = calibration_error, y = roc_auc, color = eval_group), size = 3, alpha = 0.7) +
      # highlight the training group point.
      geom_point(data = train_data, aes(x = calibration_error, y = roc_auc, color = train_group),  size = 4, shape = 21) +
      # add arrows from training to test points.
      geom_segment(data = arrow_data, aes(x = train_calibration_error, y = train_roc_auc, 
                                          xend = calibration_error, yend = roc_auc, color = train_group), 
                   arrow = arrow(length = unit(0.2, "cm"))) +
      # add labels to the plot
      labs(
        title = "Calibration vs Discrimination",
        x = "Calibration Error",
        y = "AUC"
      ) +
      scale_x_continuous(limits = range(plot_data$calibration_error, na.rm = TRUE), expand = c(0.01, 0.01)) +
      scale_y_continuous(limits = range(plot_data$roc_auc, na.rm = TRUE), expand = c(0.01, 0.01))+
      theme(
        axis.text.x = element_text(size = 12, color = "black"),  
        axis.text.y = element_text(size = 12, color = "black")   
      )+
      theme_minimal() +
      theme(
        panel.background = element_rect(fill = "white", color = NA),
        axis.text.x = element_text(size = 12, color = "black"),
        axis.text.y = element_text(size = 12, color = "black")
      ) +
      scale_color_brewer(palette = "Set1")
    
    print(gg)
  })
  
}

# Run the application
shinyApp(ui = ui, server = server)
