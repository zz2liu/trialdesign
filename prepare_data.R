# run once initially
setwd('/Users/zongzhiliu/git/s4-trial-matching/trialdesign')
library(dplyr)
library(glue)
library(sqldf)

# prepare attribute table and attr-patient match matrix
df = read.csv('in/v_attribute_used_20191120_default.csv')
a_table = df %>% filter(included_in_shiny==1)
  # 128

# prepare a master match and attribute from old master file
df = read.csv('in/v_master_sheet_20191120.csv')
ap_raw = unique(df[,c('attribute_id', 'person_id', 'attribute_match')])
# table(ap_raw$attribute_match)
ap_tmp = ap_raw %>% filter(attribute_match %in% c('true', 'false'))
ap_tmp$match_int = ifelse(ap_tmp$attribute_match=='true', 1, 0)

# truncate each other
attrs = intersect(unique(ap_tmp$attribute_id), unique(a_table$attribute_id)) #88
a_table = a_table %>% filter(attribute_id %in% attrs)
ap_tmp = ap_tmp %>% filter(attribute_id %in% attrs)
table(ap_tmp$match_int)


#? apmatch 141563, default_match 141525
# quickfix: set to true if both true and false
ap_match = sqldf("select person_id, attribute_id
                 , max(match_int) match_int
                 from ap_tmp
                 group by person_id, attribute_id")
# # check
# ap_raw %>% filter(attribute_id==90) %>% select('attribute_match') %>% table()
# ap_match %>% filter(attribute_id==90) %>% select('match_int') %>% table()

write.csv(a_table, 'data/prepared/a_table.csv', row.names=F)
write.csv(ap_match, 'data/prepared/ap_match.csv', row.names=F)
