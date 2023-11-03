# modify the match table based on the manually modified a_table (with included, default and No Disease)

setwd('/Users/zongzhiliu/git/s4-trial-matching/trialdesign')
library(dplyr)
library(glue)
library(sqldf)


# rebuid ap_match table with included_in_shiny, default, exclusion
a_table = read.csv('data/a_table.csv')
a_table = a_table %>% filter(included_in_shiny==1)
attrs = a_table$attribute_id

# read the prepared match table
df = read.csv ('data/prepared/ap_match.csv')
ap_tmp = df %>% filter(attribute_id %in% attrs)

# add default to ap_match according to a_table
default_match = sqldf ("select person_id, attribute_id, default_match_ifnull
                 from a_table cross join (select distinct person_id from ap_tmp)")
ap_match = sqldf("select person_id, attribute_id
    , coalesce(match_int, default_match_ifnull) match_int
    from default_match 
    left join ap_tmp using (person_id, attribute_id)")

# reverse match if exclusion
sele = ap_match$attribute_id >= 194 #! hard coded
#table(ap_match[sele, 'match_int']) #2583 1s
ap_match[sele, 'match_int'] = abs(ap_match[sele, 'match_int']-1) #swap 0 and 1
#table(ap_match[sele, 'match_int']) #2583 0s
write.csv(ap_match, 'data/ap_match.csv')