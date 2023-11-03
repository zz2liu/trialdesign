library(shiny)
library(shinyTree)
library(DT)
library(plotly)

shinyUI(
  pageWithSidebar(
    # Application title
    headerPanel("Clinical Trial Eligibility Design"),
    
    sidebarPanel(
      shinyTree("tree", checkbox = TRUE, search=TRUE, themeIcons=FALSE, themeDots=T, theme='proton'),
      hr(),
      helpText(HTML('Attribute Tree: search or expand to get started.<br>
            Tree levels: attribute group, attribute name, attribute value.<br>
            The logic in third level (value) is <code>OR</code>, the logic in upper levels is <code>AND</code>.<br>')),
      hr(),
      a(href="a_table.csv", "Download the attribute table", download=NA, target="_blank")
    ),
    mainPanel(
      "Elegible Patients:\n",
      verbatimTextOutput("sel_patients"),
      hr(),
      "Matched patients for selected attribute values:",
      DT::dataTableOutput("sel_matched"),
      hr(),
      "Matched patients for selected Attribute Names:",
      #plotOutput('bar_selected_attrs')
      plotlyOutput('bar_selected_attrs')
  ))
)