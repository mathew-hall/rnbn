context("Test getOccurrences")

test_that("Errors given", {
    if(!file.exists('~/rnbn_test.rdata')) skip('login details not found')
    # login
    load('~/rnbn_test.rdata')
    nbnLogin(username = UN_PWD$username, password = UN_PWD$password)
    expect_error(getOccurrences(tvks="badger", silent=T), 'Error in makenbnurl*') 
    expect_error(getOccurrences(tvks="NBNSYS0000002987", datasets="G3", silent=T), 'Error in makenbnurl*')
    expect_error(getOccurrences(tvks="NBNSYS0000002987", datasets="GA000373", startYear="1992", endYear="1991", silent=T), 'Error in makenbnurl*')
    expect_error(getOccurrences(tvks="NBNSYS0000002987", group="reptile", silent=T), 'Error in getOccurrences*')
    expect_error(getOccurrences(silent=T), 'Error in getOccurrences*')
    expect_error(getOccurrences(polygon = 1, point = 1, silent=T), '*polygon and point cannot be used at the same time*')
})

test_that("Check single TVK search", {
    if(!file.exists('~/rnbn_test.rdata')) skip('login details not found')
    # login
    load('~/rnbn_test.rdata')
    nbnLogin(username = UN_PWD$username, password = UN_PWD$password)
    
    dt <- getOccurrences(tvks="NBNSYS0000002987", datasets="GA000373", 
                         startYear="1990", endYear="1991", acceptTandC=TRUE, silent = TRUE)
    
    expect_that(nrow(dt) > 0, is_true()) 
    expect_that(sum(which(dt$absence == TRUE)), equals(0)) ## no absences
    expect_that(length(unique(dt$taxonVersionKey)), equals(1))
    expect_that(unique(dt$taxonVersionKey), equals('NBNSYS0000002987'))
    expect_that(length(unique(dt$datasetKey)), equals(1))
    expect_that(unique(dt$datasetKey), equals('GA000373'))
    
    rm(dt)
    
})

test_that("Check multi TVK search", {
    if(!file.exists('~/rnbn_test.rdata')) skip('login details not found')
    # login
    load('~/rnbn_test.rdata')
    nbnLogin(username = UN_PWD$username, password = UN_PWD$password)
    
    dt <- getOccurrences(tvks=c("NBNSYS0000002987","NHMSYS0001688296","NHMSYS0000080210"),
                         startYear="1990", endYear="1991", acceptTandC=TRUE, silent = TRUE)
    
    expect_that(nrow(dt) > 0, is_true()) 
    expect_that(sum(which(dt$absence == TRUE)), equals(0)) ## no absences
    expect_that(length(unique(dt$pTaxonVersionKey)), equals(3))
    expect_that(sort(unique(dt$pTaxonVersionKey)), equals(c('NBNSYS0000002987','NHMSYS0000080210','NHMSYS0001688296')))
    
    rm(dt)
    
})

test_that("query uses ptaxonVersionKey if tvks is a data frame (from getTVKQuery)",{
  if(!file.exists('~/rnbn_test.rdata')) skip('login details not found')
  # login
  load('~/rnbn_test.rdata')
  nbnLogin(username = UN_PWD$username, password = UN_PWD$password)
  
  dt <- getOccurrences(tvks="NBNSYS0000002987", datasets="GA000373", 
                       startYear="1990", endYear="1991", acceptTandC=TRUE, silent = TRUE)
  dt2 <- getOccurrences(tvks=data.frame(entityType="taxon", searchMatchTitle="Silene uniflora", ptaxonVersionKey="NBNSYS0000002987"), datasets="GA000373", 
                       startYear="1990", endYear="1991", acceptTandC=TRUE, silent = TRUE)
  expect_that(dt, equals(dt2))
})

test_that("data frames missing pTaxonVersionKey column are rejected",{
  expect_error(getOccurrences(data.frame(a=1:10, b=1:10)), "column missing")
})


test_that("Check group search", {
    if(!file.exists('~/rnbn_test.rdata')) skip('login details not found')
    # login
    load('~/rnbn_test.rdata')
    nbnLogin(username = UN_PWD$username, password = UN_PWD$password)
    
    dt <- getOccurrences(group="quillwort", startYear="1990", endYear="1992",
                         VC="Shetland (Zetland)", acceptTandC=TRUE, silent = TRUE)
    
    expect_that(nrow(dt) > 0, is_true()) 
    expect_that(sum(which(dt$absence == TRUE)), equals(0)) ## no absences
    expect_that(length(unique(dt$pTaxonVersionKey)), equals(2))
    expect_that(sort(unique(dt$pTaxonVersionKey)), equals(c('NBNSYS0000002008','NBNSYS0000002009')))
    
    rm(dt)
})


test_that("Check gridRef only search", {
    if(!file.exists('~/rnbn_test.rdata')) skip('login details not found')
    # login
    load('~/rnbn_test.rdata')
    nbnLogin(username = UN_PWD$username, password = UN_PWD$password)
    
    dt <- getOccurrences(gridRef='SP00',startYear=2008,endYear=2008,acceptTandC=TRUE, silent = TRUE)
    hecs <- unique(do.call(rbind, lapply(dt$location, FUN=gridRef, format='sq10km'))[,3])
    
    expect_that(nrow(dt) > 0, is_true()) 
    expect_that(sum(which(dt$absence == TRUE)), equals(0)) ## no absences
    expect_that(length(hecs), equals(1))
    expect_that(hecs[[1]], equals('SP00'))
    expect_true('providers' %in% names(attributes(dt)))
    expect_is(attr(dt,'providers'), 'data.frame')
    expect_true(ncol(attr(dt,'providers')) >= 7)
    expect_true('Biological Records Centre' %in% attr(dt,'providers')$name)
    
    rm(dt)
})


test_that("Attributes are returned as expected", {    
    if(!file.exists('~/rnbn_test.rdata')) skip('login details not found')
    # login
    load('~/rnbn_test.rdata')
    nbnLogin(username = UN_PWD$username, password = UN_PWD$password)
    
    WCresults <- getOccurrences(tvks = 'NHMSYS0000332741', startYear = 1999,
                                endYear = 1999, attributes = TRUE, acceptTandC = TRUE, silent = TRUE)
    
    expect_true('attributes.Comment' %in% names(WCresults))
    expect_true(length(names(WCresults)[grepl('attributes.',names(WCresults))]) >=3)
    expect_is(WCresults, 'data.frame')
})

test_that("Search by polygon", {
    if(!file.exists('~/rnbn_test.rdata')) skip('login details not found')
    # login
    load('~/rnbn_test.rdata')
    nbnLogin(username = UN_PWD$username, password = UN_PWD$password)
    
    myPolygon <- "POLYGON((-1.1139965057373047 51.61213235467864,-1.1344242095947266 51.6124521493348,-1.152963638305664 51.60936070661524,-1.1521053314208984 51.59688619605445,-1.1438655853271484 51.5896344783868,-1.129617691040039 51.59176745670393,-1.1134815216064453 51.59283390830594,-1.0999202728271484 51.5896344783868,-1.0894489288330078 51.599445349412264,-1.1057567596435547 51.60445660701441,-1.1004352569580078 51.61010693620284,-1.1059284210205078 51.61810148343705,-1.1095333099365234 51.61564997198216,-1.1139965057373047 51.61213235467864))"
    
    polyReturn <- getOccurrences(tvks = 'NHMSYS0000712592',
                                 polygon = myPolygon,
                                 silent = TRUE)
    
    expect_is(polyReturn, 'data.frame')

})

test_that("Search by point and buffer", {
    if(!file.exists('~/rnbn_test.rdata')) skip('login details not found')
    # login
    load('~/rnbn_test.rdata')
    nbnLogin(username = UN_PWD$username, password = UN_PWD$password)
    
    pointReturn <- getOccurrences(tvks = 'NHMSYS0000712592',
                                  point = c(51.600995, -1.122562),
                                  radius = 2000,
                                  silent = TRUE)
    
    expect_is(pointReturn, 'data.frame')
    
})