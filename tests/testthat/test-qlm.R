test_that("qlm works", {
  data(iris)
  iris <- janitor::clean_names(iris)
  iris$large_sepal <- iris$sepal_length > median(iris$sepal_length)
  model <- glm(
    large_sepal ~ sepal_width + petal_length + species, 
    data = iris, 
    family = binomial("logit")
  )
  query <- qlm(model, inverse_link = "1 / (1 + EXP(-{x}))")
  output <- "WITH \neffects AS (\n  SELECT \n      1 * -32.2006 AS intercept,\n      sepal_width * 0.9066 AS sepal_width,\n      petal_length * 5.5194 AS petal_length,\n      CAST(species = 'versicolor' AS INT) * 6.0682 AS is_species_versicolor,\n      CAST(species = 'virginica' AS INT) * 2.9912 AS is_species_virginica\n  FROM iris\n),\nlinear AS (\n  SELECT \n      intercept +\n      sepal_width +\n      petal_length +\n      is_species_versicolor +\n      is_species_virginica\n    AS prediction\n  FROM effects\n)\nSELECT 1 / (1 + EXP(-prediction)) AS prediction\nFROM linear\n"
  testthat::expect_equal(query, output)
})
