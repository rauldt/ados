tablist <- function(x,...) {
 x %>%
  group_by(...) %>%
  summarize(`_freq` = n()) %>%
  arrange(...) %>%
  as.data.frame() %>%
  pandoc.table(t = ., style = "simple", split.table = Inf, multi.line = TRUE)
}

list_examples <- function(x, egs = 5, columns = "", pseudoID = "pseudoid") {
 mylist <- as.data.frame(x[,columns])
 cases <- unique(mylist[[pseudoID]])[1:egs]
 pander::pandoc.table(mylist[mylist[[pseudo_mrid]] %in% cases,], style = "multiline", split.table = Inf)
}