library(shiny)
library(shinyTree)
library(DT)

library(dplyr)
library(ggplot2)
library(plotly)

library(glue)
library(sqldf)

#source(prepare_data.R) #atable, match, tree
source('fun.R')
# read data
a_table = read.csv('data/a_table.csv')
ap_match = read.csv('data/ap_match.csv')
tre = build_attr_tree(a_table)

total_patients = ap_match$person_id %>% unique() %>% length()
each_matched = sqldf(glue("
      select attribute_id, attribute_group, attribute_name, attribute_value
      , sum(match_int) matched_patients
      from ap_match
      join a_table using (attribute_id)
      group by attribute_id, attribute_group, attribute_name, attribute_value
    "))

shinyServer(function(input, output, session) {
  #log <- c(paste0(Sys.time(), ": Interact with the tree to see the logs here..."))
  
  output$tree <- renderTree({tre})

  output$sel_stid <- renderPrint({
    get_selected_attrs(input$tree)
  })
  
  # there is an bug here: a attr not used in a patient is not always null/false.3
  output$sel_patients <- renderPrint({
    sel = get_selected_attrs(input$tree)
    #sel = c(9,10,11,90)
    attr_or = sqldf(glue("
      select person_id, attribute_group, attribute_name
      , max(match_int) attr_or 
      from ap_match 
      join a_table using (attribute_id)
      where attribute_id in ({paste(sel, collapse=',')})
      group by person_id, attribute_group, attribute_name"))
    person_and = sqldf(glue("select person_id
      , min(attr_or) person_and 
      from attr_or 
      group by person_id"))
    glue("{person_and$person_and %>% sum()} in {total_patients}")
  }) 
  
  output$sel_matched = DT::renderDataTable({
    sel = get_selected_attrs(input$tree)
    each_matched %>% filter(attribute_id %in% sel)
   })
  
  # sel = c(49, 72, 82, 86,90, 200)
  output$bar_selected_attrs = renderPlotly({ #renderPlot
    sel = get_selected_attrs(input$tree)
    if (length(sel) ==0) {
      return(ggplot())
    }
    selected_attrs = a_table %>%
      filter(attribute_id %in% sel) %>%
      select('attribute_name') %>%
      unique()
    data = each_matched %>%
      filter(attribute_name %in% selected_attrs$attribute_name)
    plot1(data)
  })
  
})