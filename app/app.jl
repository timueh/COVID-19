using Dash, DashHtmlComponents, DashCoreComponents, DataFrames, CSV

function get_data(path_to_file::String, title::String)
    df = DataFrame(CSV.File(path_to_file))
    index, values = names(df)[1], names(df)[2:end]

    data = [ Dict( :x => df[index],
                :y => df[value],
                :type => "scatter",
                :name => value, ) 
                for value in values ]
    layout = Dict("yaxis" => Dict("title" => title,
                    "hoverformat" => ".2f"),
                    "plot_bgcolor"=>"#222222",
                    "paper_bgcolor"=>"#222222",
                "font" => (
                    color="7FDBFF",
                ),
    )

    data, layout
end

data_R_rep = layout_R_rep = data_N_rep = layout_N_rep = data_R_now = layout_R_now = data_N_now = layout_N_now = []

function get_layout()
    global data_R_rep
    global layout_R_rep
    global data_N_rep
    global layout_N_rep
    global data_R_now
    global layout_R_now
    global data_N_now
    global layout_N_now

    run(`curl https://raw.githubusercontent.com/timueh/COVID-19/dash-app/example/results-R-reported.csv --output reported_data_r.csv`)
    run(`curl https://raw.githubusercontent.com/timueh/COVID-19/dash-app/example/results-R-nowcasting.csv --output nowcasting_r.csv`)
    run(`curl https://raw.githubusercontent.com/timueh/COVID-19/dash-app/example/results-N-reported.csv --output reported_data_n.csv`)
    run(`curl https://raw.githubusercontent.com/timueh/COVID-19/dash-app/example/results-N-nowcasting.csv --output nowcasting_n.csv`)

    data_R_rep, layout_R_rep = get_data("reported_data_r.csv", "Reproduction number")
    data_N_rep, layout_N_rep = get_data("reported_data_n.csv", "Number of cases")

    data_R_now, layout_R_now = get_data("nowcasting_r.csv", "Reproduction number")
    data_N_now, layout_N_now = get_data("nowcasting_n.csv", "Number of cases")

    return html_div() do
        dcc_markdown("
        # Covid-19 in Germany
        
        ## Point estimators for the reproduction number `R`
        "),
        # Just like in most countries, the novel SARS-CoV-2 virus affects daily life in Germany.
        # It is not just the numerous deaths it has induced, but the so-called *new-normal* that everybody is still trying to adjust to.

        # Two indicators that often attract media attention are the
        
        # - reproduction number `R` (i.e. the average number of people who get infected by a typical case),
        # - and the total number of cases.

        # The German Robert-Koch-Institut provides daily updates for both.

        # This dashboard compares the two methods used by the Robert Koch Institut to a recently proposed method.
        # The following table explains all methods, and all the different, publicly available data sources, from which you can choose.
        html_table(children = [
                    html_tr(children = [
                        html_th("Method"),
                        html_th("Explanation")
                    ]),
                    html_tr(children = [
                        html_td("RKI Nowcast 4 days"),                     
                        html_td("Estimator long used by Robert Koch Institut; effectively a 4-day moving average."),                 
                        ]),
                    html_tr(children = [
                        html_td("RKI Nowcast 7 days"),
                        html_td("Estimator used by Robert Koch Institut; effectively a 7-day moving average, taking 5 days from the past and one day from the future."),
                        ]),
                    html_tr(children = [
                        html_td("Projected 7 days"),
                        html_td("Acausal estimator that accounts for three days of the past, the current day, and three days of the future; future values are based on the respective values from the previous week."),
                        ]),
        ]
        ),
        html_table(children = [
                    html_tr(children = [
                        html_th("Data source"),
                        html_th("Explanation"),
                    ]),
                    html_tr(children = [
                        html_td("RKI nowcasting cases"),  
                        html_td("Nowcasting data on total number of cases provided by Robert Koch Institut"),  
                        ]),
                    html_tr(children = [
                        html_td("RKI reported cases"),
                        html_td("Full data set of reported cases, curated and updated daily by the Robert Koch Institut"),
                        ]),
        ]
        ),
        html_h1(id = "my-h1"),
        dcc_dropdown(
            id = "data-source",
            options=[
                Dict("label" => "RKI nowcasting cases", "value" => "RKI-nowcasting"),
                Dict("label" => "RKI reported cases", "value" => "RKI-reported"),
            ],
            value="RKI-nowcasting",
        ),
        dcc_graph(
            id = "R-values",
            figure = (
                data = data_R_rep,
                layout = layout_R_rep,
            )
        ),
        dcc_graph(
            id = "N-values",
            figure = (
                data = data_N_rep,
                layout = layout_N_rep,
                )
        )
        
    end

end


app = dash(external_stylesheets = ["https://codepen.io/chriddyp/pen/bWLwgP.css"])


app.layout = get_layout

callback!(app, [Output("R-values", "figure"), Output("N-values", "figure"), Output("my-h1", "children")], Input("data-source", "value")) do input_value
    data_R, layout_R, data_N, layout_N = if input_value == "RKI-reported"
        data_R_rep, layout_R_rep, data_N_rep, layout_N_rep
    else
        data_R_now, layout_R_now, data_N_now, layout_N_now
    end
    R = round(data_R[3][:y][end], digits=2)

    Dict(:data => data_R, :layout => layout_R), Dict(:data => data_N, :layout => layout_N), "R = $R"
end

run_server(app, "0.0.0.0", 8080)