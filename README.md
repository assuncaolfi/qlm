
<!-- README.md is generated from README.Rmd. Please edit that file -->

# qlm

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/qlm)](https://CRAN.R-project.org/package=qlm)
<!-- badges: end -->

qlm is a package to create SQL queries to compute predictions from
linear models.

## Installation

Install the development version of qlm:

``` r
devtools::install_github("assuncaolfi/qlm")
```

## Example

Fit a model:

``` r
library(qlm)

data(iris)
iris <- janitor::clean_names(iris)
iris$large_sepal <- iris$sepal_length > median(iris$sepal_length)

model <- glm(
  large_sepal ~ sepal_width + petal_length + species, 
  data = iris, 
  family = binomial("logit")
)
```

Make a predictive query:

``` r
query <- qlm(model, inverse_link = "1 / (1 + EXP(-{x}))")
cat(query)
#> WITH 
#> effects AS (
#>   SELECT 
#>       1 * -32.2006 AS intercept,
#>       sepal_width * 0.9066 AS sepal_width,
#>       petal_length * 5.5194 AS petal_length,
#>       CAST(species = 'versicolor' AS INT) * 6.0682 AS is_species_versicolor,
#>       CAST(species = 'virginica' AS INT) * 2.9912 AS is_species_virginica
#>   FROM iris
#> ),
#> linear AS (
#>   SELECT 
#>       intercept +
#>       sepal_width +
#>       petal_length +
#>       is_species_versicolor +
#>       is_species_virginica
#>     AS prediction
#>   FROM effects
#> )
#> SELECT 1 / (1 + EXP(-prediction)) AS prediction
#> FROM linear
```

Formula interactions and transformations are not supported and should be
precomputed in the data query.
