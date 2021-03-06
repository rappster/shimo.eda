#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
    shiny::tagList(
        # Leave this function for adding external resources
        golem_add_external_resources(),
        shinydashboardPlus::dashboardPage(
            # title = "Demo",
            skin = "red",
            options = list(
                sidebarExpandOnHover = TRUE
            ),
            header = shinydashboardPlus::dashboardHeader(
                title = "Demo",
                titleWidth = 100,
                fixed = TRUE,

                leftUi = htmltools::tagList(
                )
            ),
            sidebar = shinydashboardPlus::dashboardSidebar(
                id = "sidebar",
                width = 300,
                shinydashboard::sidebarMenu(
                    id = "tabs",

                    # --- Freq table ---
                    shinydashboard::menuItem(
                        "Frequency table",
                        icon = icon("table"),
                        startExpanded = TRUE,
                        shinydashboard::menuSubItem("Separate boxes",
                            tabName = "freq_table", icon = icon("arrow-right")),
                        shinydashboard::menuSubItem("Enclosing box",
                            tabName = "freq_table_outer", icon = icon("arrow-right")),
                        shinydashboard::menuSubItem("Transform function",
                            tabName = "freq_table_trans", icon = icon("arrow-right")),
                        shinydashboard::menuSubItem("Addtional DT bundles",
                            tabName = "freq_table_bundles", icon = icon("arrow-right"))
                    ),
                    shinyjs::hidden(
                        shinydashboard::menuItem("freq_table_hidden",
                            tabName = "freq_table_hidden")
                    ),

                    # --- Select ---
                    shinydashboard::menuItem(
                        "Select",
                        icon = icon("filter"),
                        startExpanded = FALSE,
                        shinydashboard::menuSubItem("Separate boxes",
                            tabName = "select", icon = icon("arrow-right")),
                        shinydashboard::menuSubItem("Enclosing box",
                            tabName = "select_outer", icon = icon("arrow-right"))
                    ),
                    shinyjs::hidden(
                        shinydashboard::menuItem("select_hidden",
                            tabName = "select_hidden", selected = TRUE)
                    ),


                    # --- Table: DT ---
                    shinydashboard::menuItem(
                        "Table: DT",
                        icon = icon("table"),
                        shinydashboard::menuSubItem("No box",
                            tabName = "table_dt", icon = icon("arrow-right")),
                        shinydashboard::menuSubItem("Enclosing box",
                            tabName = "table_dt_box", icon = icon("arrow-right")),
                        shinydashboard::menuSubItem("Enclosing ns",
                            tabName = "table_dt_ns", icon = icon("arrow-right")),
                        shinydashboard::menuSubItem("Custom DT bundles",
                            tabName = "table_dt_bundles", icon = icon("arrow-right")),
                        shinydashboard::menuSubItem("DT with colum filters",
                            tabName = "table_dt_filter", icon = icon("arrow-right"))
                    ),
                    shinyjs::hidden(
                        shinydashboard::menuItem("select_hidden",
                            tabName = "select_hidden", selected = TRUE)
                    )
                )
            ),

            body = shinydashboard::dashboardBody(
                shinyjs::useShinyjs(),
                shinydashboard::tabItems(
                    # --- Freq table ---
                    shinydashboard::tabItem(
                        tabName = "freq_table_hidden",
                        vertical_space(2),
                        h3("Frequency table (click subitem on the left)")
                    ),
                    shinydashboard::tabItem(
                        tabName = "freq_table",
                        vertical_space(2),
                        h3("Frequency table"),
                        mod_eda_freq_table_ui(id = "freq_table", verbose = FALSE)
                    ),
                    shinydashboard::tabItem(
                        tabName = "freq_table_outer",
                        vertical_space(2),
                        h3("Frequency table with outer box"),
                        mod_eda_freq_table_ui(id = "freq_table_outer",
                            outer_box = TRUE, verbose = FALSE)
                    ),
                    shinydashboard::tabItem(
                        tabName = "freq_table_trans",
                        vertical_space(2),
                        h3("Frequency table with transform function"),
                        mod_eda_freq_table_ui(id = "freq_table_trans",
                            outer_box = TRUE, verbose = FALSE)
                    ),
                    shinydashboard::tabItem(
                        tabName = "freq_table_bundles",
                        vertical_space(2),
                        h3("Frequency table with additional DT bundles"),
                        mod_eda_freq_table_ui(id = "freq_table_bundles",
                            outer_box = TRUE, verbose = FALSE)
                    ),

                    # --- Select ---
                    shinydashboard::tabItem(
                        tabName = "select_hidden",
                        vertical_space(2),
                        h3("Select (click subitem on the left)")
                    ),
                    shinydashboard::tabItem(
                        tabName = "select",
                        vertical_space(2),
                        h3("Select"),
                        mod_eda_select_ui(verbose = FALSE)
                    ),
                    shinydashboard::tabItem(
                        tabName = "select_outer",
                        vertical_space(2),
                        h3("Select with outer box"),
                        mod_eda_select_ui(id = "select_outer", outer_box = TRUE, verbose = FALSE)
                    ),

                    # --- Table: dt ---
                    shinydashboard::tabItem(
                        tabName = "table_dt_hidden",
                        vertical_space(2),
                        h3("Table: DT (click subitem on the left)")
                    ),
                    shinydashboard::tabItem(
                        tabName = "table_dt",
                        vertical_space(2),
                        h3("Table: DT"),
                        mod_table_dt_ui(verbose = FALSE)
                    ),
                    shinydashboard::tabItem(
                        tabName = "table_dt_box",
                        vertical_space(2),
                        h3("Table: DT with box"),
                        mod_table_dt_ui(id = "table_dt_box", box = TRUE, verbose = FALSE)
                    ),
                    shinydashboard::tabItem(
                        tabName = "table_dt_ns",
                        vertical_space(2),
                        h3("Table: DT with enclosing 'ns' (EXPERIMENTAL)"),
                        mod_foo_ui(verbose = FALSE)
                    ),
                    shinydashboard::tabItem(
                        tabName = "table_dt_bundles",
                        vertical_space(2),
                        h3("Table: DT with custom DT bundles"),
                        mod_table_dt_ui(id = "table_dt_bundles", box = TRUE, verbose = FALSE)
                    ),
                    shinydashboard::tabItem(
                        tabName = "table_dt_filter",
                        vertical_space(2),
                        h3("Table: DT with column filter"),
                        mod_table_dt_ui(id = "table_dt_filter", box = TRUE, verbose = FALSE)
                    )
                )
            ),
            controlbar = shinydashboardPlus::dashboardControlbar()
        )
    )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "shimo.eda"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
