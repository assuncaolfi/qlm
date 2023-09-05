test_that("qlm works", {
  data(iris)
  iris <- janitor::clean_names(iris)
  model <- lm(sepal_length ~ sepal_width + petal_length + species, iris)
  query <- qlm(model)
  output <- "WITH effects AS (\n  SELECT \n      1 * 2.3904 AS intercept,\n      sepal_width * 0.4322 AS sepal_width,\n      petal_length * 0.7756 AS petal_length,\n      CAST(species = 'versicolor' AS INT) * -0.9558 AS is_species_versicolor,\n      CAST(species = 'virginica' AS INT) * -1.3941 AS is_species_virginica\n  FROM iris\n)\nSELECT \n    intercept +\n    sepal_width +\n    petal_length +\n    is_species_versicolor +\n    is_species_virginica\n  AS prediction\nFROM effects\n"
  testthat::expect_equal(query, output)
})
