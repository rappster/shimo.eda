#' export UI Function
#'
#' @param id [[character]] Module ID
#' @param ns [[function]] Namespace function
#' @param select_title
#' @param select_width
#' @param select_id
#' @param select_button_label
#' @param select_button_class
#' @param select_button_style
#' @param select_button_icon
#' @param select_button_width
#' @param data_title
#' @param data_width
#' @param outer_box
#' @param outer_title
#' @param outer_width
#' @param verbose [[logical]] Tracing infos yes/no
#'
#' @description A shiny Module.
#'
#' @importFrom shiny NS tagList
#' @export
mod_eda_select_ui <- function(
    id = "eda_select",
    ns = function() {},
    # --- Select
    select_title = "Columns",
    select_width = 12,
    select_id = "select_ui",
    select_button_label = "Add select statement",
    select_button_class = "btn-success",
    select_button_style = "color: #fff;",
    select_button_icon = icon('plus'),
    select_button_width = 170,
    # --- Data
    data_title = "Data table",
    data_width = 12,
    # --- Outer
    outer_box = FALSE,
    outer_title = "Select columns",
    outer_width = 12,
    verbose = FALSE
) {
    ns <- NS(id)

    shiny_trace_ns_ui(
        fn_name = "mod_eda_select_ui",
        id_inner = "foo",
        ns = ns,
        verbose = verbose
    )

    # shiny::selectInput("test", label = NULL, choices = letters)

    ui <- tagList(
        fluidRow(
            # column(
            shinydashboardPlus::box(
                title = select_title,
                width = select_width,
                collapsible = TRUE,
                actionButton(
                    ns("add_select"),
                    label = select_button_label,
                    class = select_button_class,
                    style = select_button_style,
                    icon = select_button_icon,
                    width = select_button_width
                ),
                tags$br(),
                tags$br(),
                uiOutput(ns("select_ui"))
            )
        ),
        fluidRow(
            # column(
            shinydashboardPlus::box(
                width = data_width,
                title = data_title,
                collapsible = TRUE,
                DT::DTOutput(ns("select_tbl"))
            )
        ),
        tags$script(src = "shimo.eda.js"),
        tags$script(paste0("shimo_eda_mod_select_js('", ns(''), "')"))
    )

    if (outer_box) {
        fluidRow(
            shinydashboardPlus::box(
                title = tags$b(outer_title),
                width = outer_width,
                collapsible = TRUE,
                ui
            )
        )
    } else {
        ui
    }
}

#' export Server Function
#'
#' @param id [[character]] Module ID
#' @param r_data
#' @param input_id_prefix
#' @param dt_bundle_buttons [[function]] Seet [[dtf::dt_bundle_buttons]]
#' @param dt_bundle_internationalization [[function]] Seet [[dtf::dt_bundle_internationalization]]
#' @param verbose [[logical]] Tracing infos yes/no
#'
#' @export
mod_eda_select_server <- function(
    id = "eda_select",
    r_data,
    input_id_prefix = "select_input",
    dt_bundle_buttons = dtf::dt_bundle_buttons_en,
    dt_bundle_internationalization = dtf::dt_bundle_internationalization_en,
    verbose = FALSE
) {
    shiny::moduleServer(id, function(input, output, session) {
        ns <- session$ns
        # browser()

        # --- Create select UI ----
        input_ids <- get_input_ids(input_id_prefix = input_id_prefix, sort = TRUE)
        input_values <- get_input_values(input_ids = input_ids)

        shiny_trace_ns_server(
            fn_name = "mod_eda_select_server",
            id_inner = input_ids,
            verbose = verbose
        )

        create_select_ui <- create_select_ui(
            r_data = r_data,
            input_ids = input_ids,
            input_values = input_values,
            input_id_prefix = input_id_prefix
        )

        render_select_ui(id = NULL, create_select_ui = create_select_ui)

        # --- Remove select UI ---
        remove_select_ui(id = NULL)

        # --- Render data table ---
        render_select_data_table(
            id = NULL,
            r_data = r_data,
            input_ids = input_ids,
            input_values = input_values,
            dt_bundle_buttons = dt_bundle_buttons,
            dt_bundle_internationalization = dt_bundle_internationalization
        )
    })
}

# Create inputs -----------------------------------------------------------

create_select_ui <- function(
    id = NULL,
    r_data,
    input_ids,
    input_values,
    input_id_prefix = "select_input",
    input_id_button = "add_select"
) {
    shiny::moduleServer(id, function(input, output, session) {
        ns <- session$ns
        input_id_pattern <- "^{input_id_prefix}" %>% stringr::str_glue()

        eventReactive(input[[input_id_button]], {
            # browser()
            # --- Get input IDs and values ---
            input_ids <- input_ids()
            input_values <- input_values()

            # --- Handle existing select inputs ---
            cols <- r_data() %>% names()
            select_existing <- handle_existing_select_inputs(
                cols = cols,
                input_values = input_values
            )

            # --- Handle columns
            cols <- r_data %>% handle_col_values(input_values = input_values)

            # --- Compose UI elements ---
            pos_latest <- length(select_existing) + 1

            input_id <- ns("{input_id_prefix}_{pos_latest}" %>% stringr::str_glue())
            # print(input_id)

            select_new <- div(
                id = input_id,
                div(style = "display:inline-block; vertical-align:top; width:200px;",
                    selectInput(
                        inputId = input_id,
                        label = NULL,
                        choices = cols,
                        width = 200
                    )
                ),
                div(style = "display:inline-block; vertical-align:top; width:40px;",
                    actionButton(
                        inputId = ns("del_{input_id_prefix}_{pos_latest}" %>% stringr::str_glue()),
                        label = NULL,
                        icon = icon("trash-alt"),
                        width = 40,
                        class = "btn-danger delete_btn",
                        title = "Delete"
                    )
                )
            )

            tagList(
                select_existing,
                select_new
            )
        }, ignoreInit = TRUE)
    })
}

# Remove inputs -----------------------------------------------------------

remove_select_ui <- function(
    id = NULL,
    id_input = "ui_to_delete_id"
) {
    shiny::moduleServer(id, function(input, output, session) {
        ns <- session$ns

        observeEvent(input[[id_input]], {
            # browser()
            button_id <- input[[id_input]]

            if (length(button_id) &&
                    button_id != ""
            ) {
                select_id <- button_id %>% derive_input_id_from_button_id(
                    button_prefix = "del_"
                )

                removeUI(
                    selector = "#{select_id}" %>% stringr::str_glue()
                )
                shinyjs::runjs('Shiny.onInputChange("{select_id}", null)' %>%
                        stringr::str_glue())
            }
        }, ignoreInit = TRUE)
    })
}

# Handle existing inputs --------------------------------------------------

handle_existing_select_inputs <- function(
    id = NULL,
    cols,
    input_values = list(),
    input_id_prefix = "select_input"
) {
    shiny::moduleServer(id, function(input, output, session) {
        ns <- session$ns

        if (length(input_values)) {
            input_values %>%
                unname() %>%
                purrr::imap(function(.input, .pos) {
                    input_id <- ns("{input_id_prefix}_{.pos}" %>% stringr::str_glue())
                    div(
                        id = input_id,
                        div(style = "display:inline-block; vertical-align:top; width:200px;",
                            selectInput(
                                inputId = input_id,
                                label = NULL,
                                choices = cols,
                                selected = .input,
                                width = 200
                            )
                        ),
                        div(style = "display:inline-block; vertical-align:top; width:40px;",
                            actionButton(
                                inputId = ns("del_{input_id_prefix}_{.pos}" %>% stringr::str_glue()),
                                label = NULL,
                                icon = icon("trash-alt"),
                                width = 40,
                                class = "btn-danger delete_btn",
                                title = "Delete"
                            )
                        )
                    )
                }) %>%
                purrr::set_names(names(input_values))
        } else {
            NULL
        }
    })
}

# Render UI ---------------------------------------------------------------

render_select_ui <- function(
    id = NULL,
    create_select_ui,
    output_id = "select_ui"
) {
    shiny::moduleServer(id, function(input, output, session) {
        ns <- session$ns

        output[[output_id]] <- renderUI({
            create_select_ui()
        })
    })
}

# Render data table -------------------------------------------------------

#' Title
#'
#' @param id
#' @param r_data
#' @param input_ids
#' @param input_values
#' @param buttons_language
#'
#' @return
#'
#' @examples
render_select_data_table <- function(
    id = NULL,
    r_data,
    input_ids,
    input_values,
    dt_bundle_buttons = dtf::dt_bundle_buttons_en,
    dt_bundle_internationalization = dtf::dt_bundle_internationalization_en
) {
    shiny::moduleServer(id, function(input, output, session) {
        ns <- session$ns

        # output$select_tbl <- DT::renderDT({
        #     data <- r_data()
        #
        #     group_by_ids <- input_ids()
        #     if (length(group_by_ids)) {
        #         cols <- input_values() %>% unname() %>% dplyr::syms()
        #         if (length(cols)) {
        #
        #             # data %>%
        #             #     wrang::wr_freq_table(!!!cols)
        #             data %>%
        #                 dplyr::select(!!!cols)
        #         } else {
        #             data
        #         }
        #     } else {
        #         data
        #     }
        # })

        # Transform
        r_data_2 <- reactive({
            data <- r_data()

            group_by_ids <- input_ids()
            if (length(group_by_ids)) {
                cols <- input_values() %>% unname() %>% dplyr::syms()
                if (length(cols)) {

                    # data %>%
                    #     wrang::wr_freq_table(!!!cols)
                    data %>%
                        dplyr::select(!!!cols)
                } else {
                    data
                }
            } else {
                data
            }
        })

        # Render
        dtf::mod_render_dt_server(
            id = id,
            output_id = "select_tbl",
            data = r_data_2,
            scrollY = 300,
            left = 1,
            .bundles = list(
                dt_bundle_buttons(),
                dt_bundle_internationalization()
            )
        )
    })
}
