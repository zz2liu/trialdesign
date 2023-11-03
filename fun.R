build_attr_tree = function(a_table) {
  res = list()
  for (i in 1:nrow(a_table)) {
    # print(i)
    attr_id = a_table[i, 'attribute_id']
    attr_group = a_table[i, 'attribute_group']
    attr_name = a_table[i, 'attribute_name']
    attr_value = a_table[i, 'attribute_value']
    res[[attr_group]][[attr_name]][[attr_value]] = structure('', stid=attr_id)
  }
  res
}

get_selected_attrs = function(tree) {
  req(tree)
  sel = get_selected(tree, format = "classid")
  tmp = lapply(sel, function(x) {attr(x, 'stid')})
  na.omit(unlist(tmp))
}

plot1 = function(data) {
  g = ggplot(data, aes(x=attribute_value, y=matched_patients))
  g = g + geom_col(fill='forest green', position='dodge', width=.5)
  g = g + 
    facet_wrap(~attribute_group+attribute_name, scales='free', ncol=2, strip.position='top') + #, space='free_x') +
    #facet_grid(~attribute_group+attribute_name, scales='free', space='free_x') + #, ncol=2, strip.position='top') + #, space='free_x') +
    theme(axis.title.x=element_blank(), axis.title.y=element_blank(),
          #axis.text.x=element_text(angle=90),
          panel.spacing=unit(1.5, 'lines'),
          strip.placement = "outside")
  #g
  #g + coord_flip()
  facets = unique(data[,c('attribute_group', 'attribute_name')])
  ggplotly(g+coord_flip(), height=150*(ceiling(nrow(facets)/2)))
}

plot2 = function(data) {
  g = ggplot(data, aes(x=attribute_value, y=matched_patients))
  g = g + geom_col(fill='forest green', position='dodge', width=.5)
  g = g + 
    #facet_wrap(~attribute_group+attribute_name, scales='free', dir='v', ncol=2, strip.position='right') + #, space='free_x') +
    facet_grid(~attribute_group+attribute_name, scales='free', space='free') + #, ncol=2, strip.position='top') + #, space='free_x') +
    theme(axis.title.x=element_blank(), axis.title.y=element_blank(),
          axis.text.x=element_text(angle=90, vjust=0.5, hjust=1),
          panel.spacing=unit(1.5, 'lines'),
          strip.placement = "outside")
  g
}