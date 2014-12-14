library(stringr)
library(qdap)
library(data.table)
library(dplyr)
load("./data/final_grams.Rda")
most_common <- c("the", "a", "to")
# take in a string of any length and reduce it to a number of words that can be used
# to generate an n-gram prediction
predict.input <- function(string) {
        n <- 1
        if (word_count(string) > 2) {n <- 3}
        else if (word_count(string) == 2) {n <- 2}
        if (n == 1) {words <- string}
        else {words <- word(string, start = -n, end = word_count(string))}
        return(words)
}

# figure out way to look for matches through cases and n - 1 grams
# finds the nth prediction
predict.match <- function(words) {
        words <- paste(words, "$", sep="")
        filter(all_grams, grepl(words, gram)) %>%
                filter(min_rank(desc(freq)) <= 3) %>%
                select(n)
}

swift.output <- function(sentence) {
        gram <- predict.input(sentence)
        n <- predict.match(gram)$n
        if (length(n) == 3) {return(n)}
        else {
                gram <- word(gram, start = -2, end = word_count(gram))
                n <- c(n, predict.match(gram)$n)
        }
        if (length(n) >= 3) {return(n[1:3])}
        else {
                gram <- word(gram, -1)
                n <- c(n, predict.match(gram)$n)
        }
        if (length(n) >= 3) {return(n[1:3])}
        else {
                n <- c(n, most_common[!(most_common %in% n)])
                return(n[1:3])
        }
}