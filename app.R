# app.R -- Buurt Explorer (NL/EN): correlations and maps for Dutch wijken/buurten.
# install.packages(c("shiny","bslib","sf","dplyr","ggplot2","ggiraph","biscale",
#                    "patchwork","arrow","zip","markdown"))
# Needs in the same folder: texts.R, manual_en.md, manual_nl.md and data/ (see 01 and 02 scripts)

suppressPackageStartupMessages({
  library(shiny); library(bslib); library(sf); library(dplyr); library(ggplot2)
  library(ggiraph); library(biscale); library(patchwork); library(arrow); library(zip)
  library(markdown)   # used by includeMarkdown(); loading it here makes the manifest list it
})
source("texts.R", local = TRUE)

DATA_DIR <- "data"
years <- sort(sub("^catalog_(.*)\\.rds$", "\\1", list.files(DATA_DIR, "^catalog_")), decreasing = TRUE)
MANUAL_EN <- includeMarkdown("manual_en.md")
MANUAL_NL <- includeMarkdown("manual_nl.md")

`%||%` <- function(a, b) if (is.null(a)) b else a
blank <- function(s, default = NULL) if (is.null(s) || !nzchar(trimws(s))) default else s
safe  <- function(s) gsub("[^A-Za-z0-9]+", "_", s)
pick  <- function(lg, en, nl) if (lg == "nl") nl else en

# ---- Language helpers: both languages are in the page, CSS shows the active one ----
L <- function(en, nl) tagList(span(class = "t-en", en), span(class = "t-nl", nl))

info_pop <- function(en_title, nl_title, en, nl, placement = "auto") {
  popover(trigger = span(class = "info-i", tabindex = "0", role = "button", "i"),
          tags$strong(L(en_title, nl_title)), tags$p(L(en, nl)), placement = placement)
}
info_txt <- function(title, body, placement = "auto") {
  popover(trigger = span(class = "info-i", tabindex = "0", role = "button", "i"),
          tags$strong(title), tags$p(body), placement = placement)
}
lbl <- function(key) {            # label + (i) from texts.R
  t <- TXT[[key]]
  tagList(L(t$en, t$nl), info_pop(t$en, t$nl, t$ien, t$inl))
}

# ---- Regression formula text: y = a + b x ----
reg_formula <- function(xv, yv) {
  ok <- !is.na(xv) & !is.na(yv)
  if (sum(ok) < 3 || length(unique(xv[ok])) < 2) return(NULL)
  b <- coef(lm(yv[ok] ~ xv[ok]))
  num <- function(v) format(signif(abs(v), 4), scientific = FALSE, trim = TRUE)
  paste0("y = ", if (b[1] < 0) "-" else "", num(b[1]),
         if (b[2] < 0) " - " else " + ", num(b[2]), " \u00d7 x")
}

# ---- Colour help (used by the colour options) ----
COLOURS   <- c(white = "#FFFFFF", black = "#000000", grey = "#808080", red = "#E41A1C", orange = "#FF7F00",
               yellow = "#FFD92F", green = "#4DAF4A", blue = "#377EB8", purple = "#984EA3",
               pink = "#F781BF", brown = "#A65628")
COLOUR_NL <- c(white = "wit", black = "zwart", grey = "grijs", red = "rood", orange = "oranje",
               yellow = "geel", green = "groen", blue = "blauw", purple = "paars", pink = "roze", brown = "bruin")
colour_pop <- function() {
  rows <- lapply(names(COLOURS), function(n) tags$tr(
    tags$td(span(style = sprintf("display:inline-block;width:1.3em;height:1.3em;border:1px solid #999;background:%s;", COLOURS[[n]]))),
    tags$td(n, tags$span(class = "t-nl text-muted", paste0(" (", COLOUR_NL[[n]], ")"))),
    tags$td(tags$code(COLOURS[[n]]))))
  popover(
    trigger = span(class = "info-i", tabindex = "0", role = "button", "i"),
    tags$strong(L("Colours", "Kleuren")),
    tags$p(L("Type an English colour name (for example red) or a colour code such as #2C7FB8 (a # followed by 6 characters). Some common colours:",
             "Typ een Engelse kleurnaam (bijvoorbeeld red) of een kleurcode zoals #2C7FB8 (een # gevolgd door 6 tekens). Enkele veelgebruikte kleuren:")),
    tags$table(class = "table table-sm mb-2", tags$tbody(rows)),
    tags$p(tags$a(href = "https://htmlcolorcodes.com/color-picker/", target = "_blank", rel = "noopener",
                  L("Colour picker (gives you the code)", "Kleurenkiezer (geeft je de code)")),
           tags$br(),
           tags$a(href = "https://en.wikipedia.org/wiki/Web_colors", target = "_blank", rel = "noopener",
                  L("Overview of colour names and codes", "Overzicht van kleurnamen en codes"))),
    placement = "left")
}
lbl_col <- function(key) { t <- TXT[[key]]; tagList(L(t$en, t$nl), colour_pop()) }

# ---- Variable helpers ----
vlab <- function(r, lg) if (lg == "en" && !is.na(r$label_en) && nzchar(r$label_en)) r$label_en else r$label
vlab_vec <- function(ct, lg) {
  if (lg == "en") ifelse(!is.na(ct$label_en) & nzchar(coalesce(ct$label_en, "")), ct$label_en, ct$label) else ct$label
}
ulab <- function(r) if (!is.na(r$unit) && nzchar(r$unit)) paste0(" (", r$unit, ")") else ""

var_info <- function(r, lg) {
  desc <- if (lg == "en" && !is.na(r$description_en)) r$description_en else r$description
  nl_note <- lg == "en" && is.na(r$description_en) && !is.na(desc)
  dt <- DTYPES[[r$dtype]] %||% DTYPES$other
  popover(
    trigger = span(class = "info-i", tabindex = "0", role = "button", "i"),
    tags$strong(vlab(r, lg)),
    tags$p(if (is.na(desc)) pick(lg, "No definition available.", "Geen definitie beschikbaar.") else desc,
           if (nl_note) tags$em(" (definition by CBS/RIVM, in Dutch)")),
    tags$p(tags$b(pick(lg, "Data type: ", "Soort data: ")), dt$name[[lg]], " (", dt$level[[lg]], ")"),
    tags$p(tags$b(pick(lg, "Unit: ", "Eenheid: ")), if (is.na(r$unit) || r$unit == "") "-" else r$unit),
    tags$p(tags$b(pick(lg, "Source: ", "Bron: ")), r$source, " ", r$table),
    placement = "right")
}
var_row <- function(r, lg) {
  tags$div(class = "var-row",
    tags$a(href = "#", class = "var-link",
           onclick = sprintf("Shiny.setInputValue('var_pick','%s',{priority:'event'});return false;", r$id),
           vlab(r, lg), tags$span(class = "text-muted small", paste0(" [", r$source, "]"))),
    var_info(r, lg))
}

src_url <- function(source, table) {
  if (source == "RIVM") sprintf("https://statline.rivm.nl/#/RIVM/nl/dataset/%s/table", table)
  else sprintf("https://opendata.cbs.nl/#/CBS/nl/dataset/%s/table", table)
}

# ---- Script templates for the download ----
TPL_R <- '# Generated by Buurt Explorer on {{date}}
# {{sources}} | year {{year}} | {{city}} | level: {{level}}
# X: {{xlabel}}
# Y: {{ylabel}}
#
# NOTE: neighbouring areas are usually similar (spatial autocorrelation), so
# p-values from the tests below are likely too optimistic. Correlations between
# areas say nothing about individuals (ecological fallacy).
# Check the data types of X and Y first (see README_metadata.txt): Pearson suits
# ratio/interval variables; use Spearman for ordinal or strongly skewed data.

library(readr)
d <- read_csv("data.csv")

cor.test(d${{x}}, d${{y}}, method = "pearson")
cor.test(d${{x}}, d${{y}}, method = "spearman", exact = FALSE)

m <- lm({{y}} ~ {{x}}, data = d)
summary(m)

plot(d${{x}}, d${{y}}, xlab = "{{xlabel}}", ylab = "{{ylabel}}")
abline(m, col = "red")

# Optional: spatial autocorrelation (Moran\'s I)
# library(sf); library(spdep)
# g  <- st_read("areas.gpkg")
# lw <- nb2listw(poly2nb(g, queen = TRUE), style = "W", zero.policy = TRUE)
# moran.test(g${{x}}, lw, zero.policy = TRUE)
# moran.test(g${{y}}, lw, zero.policy = TRUE)
'
TPL_SPSS <- '* Generated by Buurt Explorer on {{date}}.
* {{sources}} | year {{year}} | {{city}} | level: {{level}}.
* X: {{xlabel}}.
* Y: {{ylabel}}.
* Note: spatial autocorrelation makes p-values optimistic; see README_metadata.txt.

GET DATA /TYPE=TXT /FILE=\'data.csv\' /ENCODING=\'UTF8\'
  /DELIMITERS="," /QUALIFIER=\'"\' /ARRANGEMENT=DELIMITED /FIRSTCASE=2
  /VARIABLES=area_code A14 area_name A100 municipality A60 {{x}} F16.6 {{y}} F16.6.
EXECUTE.

CORRELATIONS /VARIABLES={{x}} {{y}} /PRINT=TWOTAIL NOSIG.
NONPAR CORR /VARIABLES={{x}} {{y}} /PRINT=SPEARMAN TWOTAIL NOSIG.
REGRESSION /DEPENDENT {{y}} /METHOD=ENTER {{x}}.
GRAPH /SCATTERPLOT(BIVAR)={{x}} WITH {{y}}.
'
fill <- function(tpl, vals) {
  for (k in names(vals)) tpl <- gsub(paste0("{{", k, "}}"), vals[[k]], tpl, fixed = TRUE)
  tpl
}

# ---- CSS and JavaScript (language switch, info icons, pickers) ----
CSS <- "
body[data-lang='nl'] .t-en {display:none !important}
body:not([data-lang='nl']) .t-nl {display:none !important}
.info-i{display:inline-flex;align-items:center;justify-content:center;width:1.15em;height:1.15em;
  border:1px solid #6c757d;border-radius:50%;font-size:.72em;font-style:italic;font-weight:bold;
  color:#6c757d;cursor:pointer;margin-left:.35em;vertical-align:middle;background:#fff}
.info-i:hover,.info-i:focus{background:#0d6efd;color:#fff;border-color:#0d6efd}
.popover{max-width:380px}
.selectize-control.single .selectize-input:after{display:none}
.var-row{display:flex;justify-content:space-between;gap:.5rem;padding:2px 0;border-bottom:1px solid #eee}
.var-list{overflow-y:auto}
.lang-switch{color:#6c757d;white-space:nowrap}
.lang-switch a{text-decoration:none;padding:0 .25em;color:inherit}
body[data-lang='nl'] .lang-nl, body:not([data-lang='nl']) .lang-en{font-weight:bold;text-decoration:underline}
.plot-tools{display:flex;gap:1.2rem;justify-content:flex-end;font-size:.85rem;color:#6c757d}
"
JS <- "
function setLang(l){
  document.body.setAttribute('data-lang', l);
  if (window.Shiny && Shiny.setInputValue) { Shiny.setInputValue('lang', l, {priority:'event'}); }
  try { localStorage.setItem('lang', l); } catch(e) {}
}
$(document).on('shiny:connected', function(){
  var l = null; try { l = localStorage.getItem('lang'); } catch(e) {}
  if (!l) { l = ((navigator.language || 'en').toLowerCase().indexOf('nl') === 0) ? 'nl' : 'en'; }
  setLang(l);
});
"

lang_switch <- function() tags$span(class = "lang-switch", icon("language"), " ",
  tags$a(href = "#", class = "lang-nl", onclick = "setLang('nl');return false;", "NL"), "|",
  tags$a(href = "#", class = "lang-en", onclick = "setLang('en');return false;", "EN"))

welcome_modal <- function() modalDialog(
  title = L("Welcome to Buurt Explorer", "Welkom bij Buurt Explorer"),
  size = "l", easyClose = FALSE,
  div(class = "mb-3", lang_switch()),
  tags$h5(L("What is this website for?", "Waarvoor is deze website?")),
  tags$p(L("Buurt Explorer lets you quickly compare two things in Dutch neighbourhoods and districts, for example income and health, in a scatter plot and a map. It is meant as inspiration and a starting point for research.",
           "Met Buurt Explorer vergelijk je snel twee dingen in Nederlandse buurten en wijken, bijvoorbeeld inkomen en gezondheid, in een spreidingsdiagram en een kaart. De website is bedoeld als inspiratie en beginpunt voor onderzoek.")),
  div(class = "alert alert-warning",
      tags$strong(L("Disclaimer", "Disclaimer")),
      tags$p(class = "mb-0",
        L("Do not use the plots, maps or numbers from this website as the end result in an academic paper or report. Your work is more credible when you do your own analysis in software that universities and governments recognise (for example R, SPSS or Stata). Use the data and script download to get started, and always check the original CBS and RIVM sources.",
          "Gebruik de grafieken, kaarten of getallen van deze website niet als eindresultaat in een wetenschappelijk artikel of rapport. Je werk is geloofwaardiger als je zelf de analyse doet in software die universiteiten en overheden erkennen (bijvoorbeeld R, SPSS of Stata). Gebruik de download van data en script om te beginnen en controleer altijd de originele bronnen van CBS en RIVM."))),
  footer = tagList(
    actionButton("open_manual", tagList(icon("book"), L("Open the user manual", "Open de handleiding"))),
    modalButton(L("Start", "Start")))
)
manual_modal <- function() modalDialog(
  title = L("User manual", "Handleiding"), size = "xl", easyClose = TRUE,
  div(class = "mb-2", lang_switch()),
  div(class = "t-en", MANUAL_EN), div(class = "t-nl", MANUAL_NL),
  footer = modalButton(L("Close", "Sluiten")))

export_inputs <- function(p) tagList(
  hr(), tags$strong(lbl("export")),
  layout_columns(
    numericInput(paste0(p, "_w"), lbl("ex_w"), 18, 5, 60),
    numericInput(paste0(p, "_h"), lbl("ex_h"), 12, 5, 60)),
  layout_columns(
    numericInput(paste0(p, "_dpi"), lbl("ex_dpi"), 300, 72, 600),
    selectInput(paste0(p, "_fmt"), lbl("ex_fmt"), c("png", "svg", "pdf")))
)

# Bivariate palettes: keep only the names that the installed biscale version accepts
# (newer versions renamed some palettes), and only those that work for 2, 3 and 4 classes.
BI_PALS <- Filter(function(p) all(vapply(2:4, function(d)
    !inherits(try(biscale::bi_pal(p, dim = d, preview = FALSE), silent = TRUE), "try-error"), logical(1))),
  c("DkBlue", "BlueGold", "BlueOr", "BlueYl", "BlueOrange", "BlueYellow", "Bluegill", "BrBG", "BrownBlue",
    "DkCyan", "DkViolet", "GrPink", "PinkGrn", "PurpleGrn", "PurpleOr", "PurpleOrange"))

search_opts <- list(openOnFocus = FALSE, placeholder = "Type to search\u2026 / Typ om te zoeken\u2026")

# ---- UI ----
ui <- page_navbar(
  title = "Buurt Explorer", id = "main", window_title = "Buurt Explorer",
  theme = bs_theme(version = 5),
  header = tagList(tags$style(HTML(CSS)), tags$script(HTML(JS))),

  sidebar = sidebar(
    width = 340,
    selectInput("year", lbl("year"), years),
    selectizeInput("city", lbl("city"), choices = NULL, options = search_opts),
    actionButton("city_map_btn", tagList(icon("map"), L("Choose on map", "Kies op kaart")),
                 class = "btn-outline-primary btn-sm w-100 mb-3"),
    radioButtons("level", lbl("level"),
                 choiceNames = list(L("Buurt (neighbourhood)", "Buurt"), L("Wijk (district)", "Wijk")),
                 choiceValues = c("buurt", "wijk"), inline = TRUE),
    hr(),
    selectizeInput("xvar", lbl("xvar"), choices = NULL, options = search_opts),
    uiOutput("xinfo"),
    actionButton("x_browse", tagList(icon("list"), L("Browse variables", "Bladeren door variabelen")),
                 class = "btn-outline-primary btn-sm w-100 mb-3"),
    selectizeInput("yvar", lbl("yvar"), choices = NULL, options = search_opts),
    uiOutput("yinfo"),
    actionButton("y_browse", tagList(icon("list"), L("Browse variables", "Bladeren door variabelen")),
                 class = "btn-outline-primary btn-sm w-100 mb-3"),
    helpText(textOutput("nobs"))
  ),

  nav_panel(title = lbl("tab_scatter"), value = "scatter", layout_sidebar(
    sidebar = sidebar(position = "right", width = 300, title = lbl("style"),
      textInput("p_title", lbl("p_title"), placeholder = "\u2014"),
      textInput("p_sub", lbl("p_sub"), placeholder = "\u2014"),
      textInput("p_x", lbl("p_x"), placeholder = "(variable name / variabelenaam)"),
      textInput("p_y", lbl("p_y"), placeholder = "(variable name / variabelenaam)"),
      sliderInput("p_size", lbl("p_size"), 8, 28, 13),
      sliderInput("p_tsize", lbl("p_tsize"), 10, 40, 18),
      selectInput("p_family", lbl("p_family"), c("sans", "serif", "mono")),
      selectInput("p_theme", lbl("p_theme"), c("minimal", "bw", "classic", "light")),
      checkboxInput("p_grid", lbl("p_grid"), TRUE),
      checkboxInput("p_line", lbl("p_line"), TRUE),
      checkboxInput("p_formula", lbl("p_formula"), TRUE),
      layout_columns(textInput("p_pcol", lbl_col("p_pcol"), "#2C7FB8"),
                     textInput("p_lcol", lbl_col("p_lcol"), "#D95F0E")),
      sliderInput("p_psize", lbl("p_psize"), 0.5, 6, 2, step = 0.5),
      sliderInput("p_alpha", lbl("p_alpha"), 0.1, 1, 0.7, step = 0.05),
      export_inputs("p"),
      downloadButton("dl_plot", L("Download plot", "Download grafiek"))
    ),
    div(class = "plot-tools",
        tags$span(L("Lasso select", "Lasso-selectie"),
                  info_pop(TXT$lasso_sel$en, TXT$lasso_sel$nl, TXT$lasso_sel$ien, TXT$lasso_sel$inl, "bottom")),
        tags$span(L("Lasso deselect", "Lasso-deselectie"),
                  info_pop(TXT$lasso_desel$en, TXT$lasso_desel$nl, TXT$lasso_desel$ien, TXT$lasso_desel$inl, "bottom"))),
    girafeOutput("scatter", height = "540px"),
    uiOutput("src_links_p")
  )),

  nav_panel(title = lbl("tab_map"), value = "map", layout_sidebar(
    sidebar = sidebar(position = "right", width = 300, title = lbl("style"),
      radioButtons("m_type", lbl("m_type"),
                   choiceNames = list(L("Bivariate (X and Y)", "Bivariaat (X en Y)"),
                                      L("Single variable", "Enkele variabele")),
                   choiceValues = c("bi", "single")),
      conditionalPanel("input.m_type == 'bi'",
        selectInput("m_pal", lbl("m_pal"), BI_PALS),
        radioButtons("m_dim", lbl("m_dim"), c(2, 3, 4), selected = 3, inline = TRUE)),
      conditionalPanel("input.m_type == 'single'",
        radioButtons("m_var", lbl("m_var"), c("X" = "x", "Y" = "y"), inline = TRUE),
        selectInput("m_spal", lbl("m_spal"), c("Blues", "Greens", "Reds", "Purples", "Oranges",
                    "YlOrRd", "YlGnBu", "BuPu")),
        sliderInput("m_k", lbl("m_k"), 3, 7, 5, step = 1)),
      textInput("m_title", lbl("m_title"), placeholder = "\u2014"),
      textInput("m_sub", lbl("m_sub"), placeholder = "\u2014"),
      sliderInput("m_size", lbl("m_size"), 8, 28, 12),
      sliderInput("m_lsize", lbl("m_lsize"), 6, 20, 9),
      sliderInput("m_tsize", lbl("m_tsize"), 10, 40, 18),
      sliderInput("m_bw", lbl("m_bw"), 0, 1, 0.1, step = 0.05),
      textInput("m_bcol", lbl_col("m_bcol"), "#FFFFFF"),
      export_inputs("m"),
      downloadButton("dl_map", L("Download map", "Download kaart"))
    ),
    girafeOutput("map", height = "620px"),
    uiOutput("src_links_m")
  )),

  nav_panel(title = lbl("tab_data"), value = "data", card_body(
    tags$p(L("Downloads a zip with: data.csv (selected variables, area codes and names), areas.gpkg (area shapes, RD New / EPSG:28992), README_metadata.txt (sources, year, variable definitions and data types) and a ready-to-run script.",
             "Downloadt een zip met: data.csv (gekozen variabelen, gebiedscodes en namen), areas.gpkg (vormen van de gebieden, RD New / EPSG:28992), README_metadata.txt (bronnen, jaar, variabeledefinities en soorten data) en een kant-en-klaar script.")),
    selectInput("script_lang", lbl("script_lang"), c("R" = "R", "SPSS" = "SPSS")),
    downloadButton("dl_pack", tagList(L("Download analysis package", "Download analysepakket")))
  )),

  nav_spacer(),
  nav_item(actionLink("open_manual2", tagList(icon("book"), L("Manual", "Handleiding")))),
  nav_item(lang_switch())
)

# ---- Server ----
server <- function(input, output, session) {

  lang <- reactive(if (identical(input$lang, "nl")) "nl" else "en")
  S <- function(en, nl) if (lang() == "nl") nl else en

  showModal(welcome_modal())
  observeEvent(input$open_manual,  showModal(manual_modal()))
  observeEvent(input$open_manual2, showModal(manual_modal()))

  # Translated choices / placeholders that cannot hold HTML
  observeEvent(lang(), {
    updateSelectInput(session, "p_theme", selected = input$p_theme,
      choices = setNames(c("minimal", "bw", "classic", "light"),
                         S(c("minimal", "black-white", "classic", "light"),
                           c("minimaal", "zwart-wit", "klassiek", "licht"))))
  })

  # ---- Data ----
  catalog <- reactive({
    ct <- readRDS(file.path(DATA_DIR, paste0("catalog_", input$year, ".rds")))
    for (cn in c("description", "label_en", "description_en", "theme_en"))
      if (!cn %in% names(ct)) ct[[cn]] <- NA_character_
    if (!"dtype" %in% names(ct)) ct$dtype <- "other"
    ct
  })
  geo      <- reactive(readRDS(file.path(DATA_DIR, sprintf("%s_%s_geo.rds", input$year, input$level))))
  muni_geo <- reactive(readRDS(file.path(DATA_DIR, sprintf("%s_gemeente_geo.rds", input$year))))
  cities   <- reactive(sort(unique(geo()$gemeente)))

  observeEvent(list(catalog(), lang()), {
    ct <- catalog(); lg <- lang()
    ch <- setNames(ct$id, paste0(vlab_vec(ct, lg), " [", ct$source, "]"))
    keep <- function(cur, fallback) if (isTruthy(cur) && cur %in% ct$id) cur else fallback
    updateSelectizeInput(session, "xvar", choices = ch, selected = keep(input$xvar, ct$id[1]))
    updateSelectizeInput(session, "yvar", choices = ch, selected = keep(input$yvar, ct$id[min(2, nrow(ct))]))
  })
  set_city <- function(name)
    updateSelectizeInput(session, "city", choices = cities(), selected = name, server = TRUE)
  observeEvent(geo(), {
    cur <- input$city
    set_city(if (isTruthy(cur) && cur %in% cities()) cur else cities()[1])
  })

  lab <- function(id, lg = lang()) {
    r <- catalog()[catalog()$id == id[1], ][1, ]
    paste0(vlab(r, lg), ulab(r))
  }
  var_status <- function(id) {
    ct <- catalog(); req(id %in% ct$id)
    r <- ct[ct$id == id, ][1, ]; lg <- lang()
    dt <- DTYPES[[r$dtype]] %||% DTYPES$other
    div(class = "small text-muted mb-1", dt$name[[lg]], var_info(r, lg))
  }
  output$xinfo <- renderUI(var_status(input$xvar))
  output$yinfo <- renderUI(var_status(input$yvar))

  dat <- reactive({
    req(input$city, input$xvar, input$yvar)
    validate(need(input$xvar != input$yvar, S("Pick two different variables.", "Kies twee verschillende variabelen.")))
    path <- file.path(DATA_DIR, sprintf("%s_%s.parquet", input$year, input$level))
    v <- read_parquet(path, col_select = c("code", input$xvar, input$yvar))
    geo() |> filter(gemeente == input$city) |> left_join(v, by = "code")
  })
  complete <- reactive({
    d <- dat(); d[!is.na(d[[input$xvar]]) & !is.na(d[[input$yvar]]), ]
  })
  output$nobs <- renderText({
    req(dat())
    S(paste0("n = ", nrow(complete()), " of ", nrow(dat()), " areas have data for both variables."),
      paste0("n = ", nrow(complete()), " van ", nrow(dat()), " gebieden hebben data voor beide variabelen."))
  })

  # ---- Sources (text for images, clickable links under the plots) ----
  src_rows <- reactive({
    ct <- catalog(); unique(ct[ct$id %in% c(input$xvar, input$yvar), c("source", "table")])
  })
  src_text <- reactive({
    r <- src_rows()
    paste(paste0(r$source, " ", r$table, ifelse(r$source == "RIVM", " (statline.rivm.nl)", " (opendata.cbs.nl)")), collapse = " + ")
  })
  src_ui <- function() {
    r <- src_rows(); items <- list()
    for (i in seq_len(nrow(r))) {
      if (i > 1) items <- c(items, list(" + "))
      items <- c(items, list(tags$a(href = src_url(r$source[i], r$table[i]), target = "_blank", rel = "noopener",
                                     paste0(r$source[i], " (", r$table[i], ")"))))
    }
    div(class = "text-end small mt-1", S("Source: ", "Bron: "), do.call(tagList, items))
  }
  output$src_links_p <- renderUI(src_ui())
  output$src_links_m <- renderUI(src_ui())

  tb <- function() opts_toolbar(position = "topright", tooltips = list(   # remove this tooltips list if ggiraph reports an error
    lasso_select = S("Lasso select", "Lasso-selectie"), lasso_deselect = S("Lasso deselect", "Lasso-deselectie"),
    zoom_on = S("Zoom on", "Zoom aan"), zoom_off = S("Zoom off", "Zoom uit"),
    zoom_rect = S("Zoom rectangle", "Zoom rechthoek"), zoom_reset = S("Reset zoom", "Zoom herstellen"),
    saveaspng = S("Download as PNG", "Downloaden als PNG")))

  # ---- Scatter plot ----
  build_scatter <- function(interactive = TRUE) {
    d <- st_drop_geometry(complete()); x <- input$xvar; y <- input$yvar
    validate(need(nrow(d) >= 3, S("Too few areas with data for both variables.", "Te weinig gebieden met data voor beide variabelen.")))
    pt <- if (interactive)
      geom_point_interactive(aes(tooltip = name, data_id = code), colour = input$p_pcol,
                             size = input$p_psize, alpha = input$p_alpha)
    else geom_point(colour = input$p_pcol, size = input$p_psize, alpha = input$p_alpha)
    th <- switch(input$p_theme, minimal = theme_minimal, bw = theme_bw, classic = theme_classic, light = theme_light)
    fml <- if (isTRUE(input$p_formula)) reg_formula(d[[x]], d[[y]]) else NULL
    cap <- paste0(if (!is.null(fml)) paste0(fml, "\n"),
                  "n = ", nrow(d), " | ", input$city, ", ", input$year, "\n", S("Source: ", "Bron: "), src_text())
    p <- ggplot(d, aes(x = .data[[x]], y = .data[[y]])) + pt
    if (input$p_line)
      p <- p + geom_smooth(method = "lm", formula = y ~ x, se = FALSE, colour = input$p_lcol, linewidth = 1)
    p <- p +
      labs(title = blank(input$p_title), subtitle = blank(input$p_sub),
           x = blank(input$p_x, lab(x)), y = blank(input$p_y, lab(y)), caption = cap) +
      th(base_size = input$p_size, base_family = input$p_family) +
      theme(plot.title = element_text(size = input$p_tsize, face = "bold"),
            plot.subtitle = element_text(size = input$p_tsize * 0.7))
    if (!input$p_grid) p <- p + theme(panel.grid = element_blank())
    p
  }
  output$scatter <- renderGirafe(girafe(ggobj = build_scatter(TRUE), width_svg = 8, height_svg = 5.5,
                                        options = list(tb())))

  # ---- Map ----
  build_map <- function(interactive = TRUE) {
    d <- dat(); x <- input$xvar; y <- input$yvar
    ok <- !is.na(d[[x]]) & !is.na(d[[y]])
    validate(need(sum(ok) >= 10, S("Too few areas with data to draw a map.", "Te weinig gebieden met data om een kaart te tekenen.")))
    nd <- S("no data", "geen data")
    fmt <- function(v) ifelse(is.na(v), nd, as.character(round(v, 2)))
    d$tip <- paste0("<b>", htmltools::htmlEscape(d$name), "</b><br/>",
                    htmltools::htmlEscape(lab(x)), ": ", fmt(d[[x]]), "<br/>",
                    htmltools::htmlEscape(lab(y)), ": ", fmt(d[[y]]))
    cap <- paste0("n = ", sum(ok), " / ", nrow(d), " | ", input$city, ", ", input$year, "\n", S("Source: ", "Bron: "), src_text())
    ttl <- labs(title = blank(input$m_title), subtitle = blank(input$m_sub), caption = cap)
    ttheme <- theme(plot.title = element_text(size = input$m_tsize, face = "bold"),
                    plot.subtitle = element_text(size = input$m_tsize * 0.7))
    border <- if (input$m_bw > 0) list(colour = input$m_bcol, linewidth = input$m_bw) else list(colour = NA)
    layer <- function(fillvar, legend) {
      if (interactive)
        do.call(geom_sf_interactive, c(list(mapping = aes(fill = .data[[fillvar]], tooltip = tip, data_id = code),
                                            show.legend = legend), border))
      else do.call(geom_sf, c(list(mapping = aes(fill = .data[[fillvar]]), show.legend = legend), border))
    }
    wrap_txt <- function(s) paste(strwrap(s, width = 16), collapse = "\n")

    if (input$m_type == "bi") {
      dim <- as.numeric(input$m_dim)
      q <- function(v) {
        brk <- unique(quantile(v[ok], seq(0, 1, length.out = dim + 1)))
        findInterval(v, brk, rightmost.closed = TRUE, all.inside = TRUE)
      }
      d$bi_class <- ifelse(ok, paste0(q(d[[x]]), "-", q(d[[y]])), NA)
      m <- ggplot(d) + layer("bi_class", FALSE) +
        bi_scale_fill(pal = input$m_pal, dim = dim, na.value = "grey85") +
        ttl + bi_theme(base_size = input$m_size) + ttheme
      leg <- bi_legend(pal = input$m_pal, dim = dim, size = input$m_lsize,
                       xlab = wrap_txt(paste0(S("Higher ", "Hoger "), lab(x))),
                       ylab = wrap_txt(paste0(S("Higher ", "Hoger "), lab(y))))
      m + leg + plot_layout(widths = c(3, 1.8))
    } else {
      v <- if (input$m_var == "x") x else y
      brk <- unique(quantile(d[[v]], seq(0, 1, length.out = input$m_k + 1), na.rm = TRUE))
      validate(need(length(brk) >= 3, S("Not enough variation to make classes.", "Niet genoeg variatie om klassen te maken.")))
      d$cls <- cut(d[[v]], brk, include.lowest = TRUE, dig.lab = 4)
      ggplot(d) + layer("cls", TRUE) +
        scale_fill_brewer(palette = input$m_spal, na.value = "grey85", name = wrap_txt(lab(v)), na.translate = FALSE) +
        ttl + theme_void(base_size = input$m_size) + ttheme
    }
  }
  output$map <- renderGirafe(girafe(ggobj = build_map(TRUE), width_svg = 10, height_svg = 7,
    options = list(opts_hover(css = "stroke:#000;stroke-width:1.5px;"), opts_selection(type = "none"),
                   opts_zoom(max = 8), tb())))

  # ---- City picker (map of the Netherlands) ----
  muni_n <- reactiveVal(0)
  observeEvent(input$city_map_btn, {
    n <- muni_n() + 1; muni_n(n)
    id <- paste0("muni_map", n)            # a fresh map widget every time the pop-up opens
    output[[id]] <- renderGirafe({
      g <- muni_geo()
      g$sel <- g$gemeente %in% input$city  # %in% also works while no city is set yet
      p <- ggplot(g) +
        geom_sf_interactive(aes(fill = sel, tooltip = gemeente, data_id = gemeente),
                            colour = "white", linewidth = 0.2) +
        scale_fill_manual(values = c(`FALSE` = "#9ecae1", `TRUE` = "#d95f0e"), guide = "none") + theme_void()
      girafe(ggobj = p, width_svg = 7, height_svg = 7.5,
             options = list(opts_hover(css = "fill:#fdae6b;cursor:pointer;"),
                            opts_selection(type = "single", css = "fill:#d95f0e;stroke:black;stroke-width:1.5px;"),
                            opts_zoom(max = 10), tb()))
    })
    observeEvent(input[[paste0(id, "_selected")]], {
      s <- input[[paste0(id, "_selected")]]
      req(length(s) == 1, nzchar(s))
      set_city(s); removeModal()
    })
    showModal(modalDialog(
      title = L("Choose a municipality", "Kies een gemeente"), size = "xl", easyClose = TRUE,
      selectizeInput("muni_search", NULL, width = "100%",
                     choices = c("", sort(unique(muni_geo()$gemeente))), selected = "", options = search_opts),
      tags$p(class = "text-muted small", L("Move your mouse over the map to see names. Click a municipality to choose it. Scroll or use the buttons to zoom.",
                                           "Beweeg je muis over de kaart om namen te zien. Klik op een gemeente om te kiezen. Scroll of gebruik de knoppen om te zoomen.")),
      girafeOutput(id, height = "560px"),
      tags$script(HTML("setTimeout(function(){window.dispatchEvent(new Event('resize'));}, 400);")),
      footer = modalButton(L("Close", "Sluiten"))))
  })
  observeEvent(input$muni_search, { req(nzchar(input$muni_search)); set_city(input$muni_search); removeModal() })

  # ---- Variable browser ----
  target <- reactiveVal("x")
  show_var_modal <- function() showModal(modalDialog(
    title = L("Browse variables", "Bladeren door variabelen"), size = "xl", easyClose = TRUE,
    textInput("var_search", NULL, placeholder = "Search / Zoeken\u2026", width = "100%"),
    radioButtons("var_group", NULL, selected = "theme", inline = TRUE,
                 choiceNames = list(lbl("grp_theme"), lbl("grp_type")), choiceValues = c("theme", "dtype")),
    uiOutput("var_grid"),
    footer = modalButton(L("Close", "Sluiten"))))
  observeEvent(input$x_browse, { target("x"); show_var_modal() })
  observeEvent(input$y_browse, { target("y"); show_var_modal() })

  output$var_grid <- renderUI({
    ct <- catalog(); lg <- lang(); grp <- input$var_group %||% "theme"
    ct$theme_l <- if (lg == "en") ifelse(!is.na(ct$theme_en), ct$theme_en, ct$theme) else ct$theme
    ct$theme_l[is.na(ct$theme_l) | ct$theme_l == ""] <- pick(lg, "Other", "Overig")
    q <- tolower(trimws(input$var_search %||% ""))
    if (nzchar(q)) ct <- ct[grepl(q, tolower(paste(ct$label, coalesce(ct$label_en, ""))), fixed = TRUE), ]
    validate(need(nrow(ct) > 0, pick(lg, "No variables match your search.", "Geen variabelen gevonden.")))
    key <- if (grp == "dtype") ct$dtype else ct$theme_l
    lv  <- if (grp == "dtype") intersect(names(DTYPES), unique(key)) else sort(unique(key))
    cards <- lapply(lv, function(g) {
      rows <- ct[key == g, ]
      if (grp == "dtype") {
        dt <- DTYPES[[g]]
        title <- dt$name[[lg]]; tip <- paste0(dt$level[[lg]], ". ", dt$info[[lg]])
      } else {
        title <- g
        ex <- paste(head(vlab_vec(rows, lg), 3), collapse = "; ")
        tip <- pick(lg, paste0("A theme from CBS/RIVM with ", nrow(rows), " variable(s), for example: ", ex, "."),
                        paste0("Een thema van CBS/RIVM met ", nrow(rows), " variabele(n), bijvoorbeeld: ", ex, "."))
      }
      card(card_header(tags$strong(title), span(class = "text-muted small ms-1", paste0("(", nrow(rows), ")")),
                       info_txt(title, tip)),
           card_body(class = "var-list", fillable = FALSE, max_height = "280px",
                     lapply(seq_len(nrow(rows)), function(i) var_row(rows[i, ], lg))))
    })
    do.call(layout_column_wrap, c(list(width = "300px"), cards))
  })
  observeEvent(input$var_pick, {
    updateSelectizeInput(session, paste0(target(), "var"), selected = input$var_pick)
    removeModal()
  })

  # ---- Downloads: figures ----
  fig_dl <- function(name, fn, p) downloadHandler(
    filename = function() paste0(name, "_", safe(input$city), ".", input[[paste0(p, "_fmt")]]),
    content = function(file) ggsave(file, fn(), width = input[[paste0(p, "_w")]],
                                    height = input[[paste0(p, "_h")]], units = "cm",
                                    dpi = input[[paste0(p, "_dpi")]])
  )
  output$dl_plot <- fig_dl("scatter", function() build_scatter(FALSE), "p")
  output$dl_map  <- fig_dl("map", function() build_map(FALSE), "m")

  # ---- Downloads: data + metadata + script ----
  output$dl_pack <- downloadHandler(
    filename = function() paste0("analysis_", input$year, "_", safe(input$city), ".zip"),
    content = function(file) {
      x <- input$xvar; y <- input$yvar; ct <- catalog(); lg <- lang()
      tmp <- tempfile(); dir.create(tmp)
      cs <- complete(); d <- st_drop_geometry(cs)

      out <- data.frame(area_code = d$code, area_name = d$name, municipality = d$gemeente)
      out[[x]] <- d[[x]]; out[[y]] <- d[[y]]
      write.csv(out, file.path(tmp, "data.csv"), row.names = FALSE, fileEncoding = "UTF-8")
      st_write(cs[c("code", "name", "gemeente", x, y)], file.path(tmp, "areas.gpkg"), quiet = TRUE)

      info <- ct[ct$id %in% c(x, y), ]
      srcs <- paste(unique(paste0(info$source, " table ", info$table)), collapse = "; ")
      vlines <- unlist(lapply(seq_len(nrow(info)), function(i) {
        r <- info[i, ]; dt <- DTYPES[[r$dtype]] %||% DTYPES$other
        c(paste0("  ", r$id, ": ", vlab(r, lg), " [", ifelse(is.na(r$unit), "", r$unit), "]"),
          paste0("     ", pick(lg, "Type: ", "Soort: "), dt$name[[lg]], " (", dt$level[[lg]], ")"),
          paste0("     ", pick(lg, "Definition: ", "Definitie: "),
                 ifelse(is.na(r$description), "-", r$description), " (CBS/RIVM)"),
          paste0("     ", pick(lg, "Source: ", "Bron: "), r$source, " ", r$table, " - ", src_url(r$source, r$table)))
      }))
      writeLines(c(
        "Buurt Explorer - download metadata",
        paste(pick(lg, "Downloaded: ", "Gedownload: "), Sys.Date()),
        paste(pick(lg, "Data build date: ", "Datum data opgebouwd: "), format(max(ct$built))),
        paste(pick(lg, "Year (data and boundaries): ", "Jaar (data en grenzen): "), input$year),
        paste(pick(lg, "Municipality: ", "Gemeente: "), input$city, "| level:", input$level, "| n =", nrow(out)),
        paste(pick(lg, "Sources: ", "Bronnen: "), srcs), "",
        pick(lg, "Variables:", "Variabelen:"), vlines, "",
        pick(lg, "Caveat: neighbouring areas are not independent (spatial autocorrelation) and area-level correlations do not apply to individuals (ecological fallacy). Do not use this site's output as the end result in a paper; do your own analysis.",
                 "Let op: aangrenzende gebieden zijn niet onafhankelijk (ruimtelijke autocorrelatie) en correlaties tussen gebieden gelden niet voor individuen (ecologische denkfout). Gebruik de uitvoer van deze site niet als eindresultaat in een artikel; doe je eigen analyse.")
      ), file.path(tmp, "README_metadata.txt"))

      vals <- list(date = Sys.Date(), sources = srcs, year = input$year, city = input$city,
                   level = input$level, x = x, y = y, xlabel = lab(x, "en"), ylabel = lab(y, "en"))
      if (input$script_lang == "R") writeLines(fill(TPL_R, vals), file.path(tmp, "analysis.R"))
      else writeLines(fill(TPL_SPSS, vals), file.path(tmp, "analysis.sps"))

      zip::zipr(file, list.files(tmp), root = tmp)
    }
  )
}

shinyApp(ui, server)
