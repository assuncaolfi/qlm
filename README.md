
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
model <- lm(sepal_length ~ sepal_width + petal_length + species, iris)
```

Make a predictive query:

``` r
query <- qlm(model)
cat(query)
#> WITH effects AS (
#>   SELECT 
#>       1 * 2.3904 AS intercept,
#>       sepal_width * 0.4322 AS sepal_width,
#>       petal_length * 0.7756 AS petal_length,
#>       CAST(species = 'versicolor' AS INT) * -0.9558 AS is_species_versicolor,
#>       CAST(species = 'virginica' AS INT) * -1.3941 AS is_species_virginica
#>   FROM iris
#> )
#> SELECT 
#>     intercept +
#>     sepal_width +
#>     petal_length +
#>     is_species_versicolor +
#>     is_species_virginica
#>   AS prediction
#> FROM effects
```

Formula interactions and transformations are not supported and should be
precomputed in the data query.
