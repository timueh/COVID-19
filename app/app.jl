using Dash, DashHtmlComponents, DashCoreComponents, DataFrames, CSV

function get_data(path_to_file::String, title::String)
    df = DataFrame(CSV.File(path_to_file))
    index, values = names(df)[1], names(df)[2:end]

    data = [ Dict( :x => df[index],
                :y => df[value],
                :type => "scatter",
                :name => value, ) 
                for value in values ]
    layout = Dict("yaxis" => Dict("title" => title))

    data, layout
end

data_R_rep, layout_R_rep = get_data("../example/results-R-reported.csv", "Reproduction number")
data_N_rep, layout_N_rep = get_data("../example/results-N-reported.csv", "Number of cases")

data_R_now, layout_R_now = get_data("../example/results-R-nowcasting.csv", "Reproduction number")
data_N_now, layout_N_now = get_data("../example/results-N-nowcasting.csv", "Number of cases")

app = dash(external_stylesheets = ["https://codepen.io/chriddyp/pen/bWLwgP.css"])

app.layout = html_div() do
    html_div("Some explanation will follow later."),
    html_h1(id = "my-h1"),
    dcc_dropdown(
        id = "data-source",
        options=[
            Dict("label" => "RKI nowcasting cases", "value" => "RKI-nowcasting"),
            Dict("label" => "RKI reported cases", "value" => "RKI-reported"),
        ],
        value="RKI-nowcasting"
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