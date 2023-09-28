#' Create a SQL query to compute predictions from a GLM.
#' 
#' @param model GLM model fit.
#' @param inverse_link Inverse link function string, with parameter "{x}".
#' @returns SQL query string.
#' @export
qlm <- function(model, inverse_link = "{x}", form = NULL) {
  if (is.null(form)) form <- stats::formula(model)
  labs <- labels(stats::terms(form))
  tidy <- broom::tidy(model)
  tidy$old_name <- stringr::str_extract(tidy$term, collapse(labs))
  tidy$old_name[1] <- 1
  tidy$level <- stringr::str_remove(tidy$term, collapse(labs))
  tidy$level[1] <- ""
  tidy$dummy <- tidy$level != ""
  tidy$new_name <- ifelse(
    tidy$dummy,
    paste("is", tidy$old_name, tidy$level, sep = "_"),
    tidy$old_name 
  )
  tidy$new_name[1] <- "intercept"
  tidy$last <- 1:nrow(tidy) == nrow(tidy)
  table_name <- as.character(model$call$data)
  inverse_link <- stringr::str_glue(inverse_link, x = "prediction")
  jinjar::render(
    TEMPLATE, 
    data = tidy, 
    table_name = table_name,
    inverse_link = inverse_link
  )
}

collapse <- function(x) paste(x, collapse = "|")

TEMPLATE <- "WITH 
effects AS (
  SELECT {% for row in data %}
      {% if row.dummy -%}CAST({% endif %}{{row.old_name}}{% if row.dummy %} = '{{row.level}}' AS INT){% endif %} * {{row.estimate}} AS {{row.new_name}}{% if not row.last -%},{% endif -%}  
    {% endfor %}
  FROM {{table_name}}
),
linear AS (
  SELECT {% for row in data %}
      {{row.new_name}}{% if not row.last %} +{% endif -%}
    {% endfor %}
    AS prediction
  FROM effects
)
SELECT {{inverse_link}} AS prediction
FROM linear
"
