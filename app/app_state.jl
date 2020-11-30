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

states = ["Baden-Württemberg",
            "Bayern",
            "Berlin",
            "Brandenburg",
            "Bremen",
            "Hamburg",
            "Hessen",
            "Mecklenburg-Vorpommern",
            "Niedersachsen",
            "Nordrhein-Westfalen",
            "Rheinland-Pfalz",
            "Saarland",
            "Sachsen-Anhalt",
            "Sachsen",
            "Schleswig-Holstein",
            "Thüringen"]

dropdown_opts = [ Dict("label"=>state, "value"=>state) for state in states]

files_R  = "../example/results-R-reported-" .* states .* ".csv"
files_N  = "../example/results-N-reported-" .* states .* ".csv"

# R = Dict()
# layout = Dict()
# for (state, file_R) in zip(states, files_R)
#     R[state], layout[state] = get_data(file_R, "R - "*state)
# end

app = dash(external_stylesheets = ["https://codepen.io/chriddyp/pen/bWLwgP.css"])

app.layout = html_div() do
    html_h1(id="header"),
    html_div("Dashboard for reproduction numbers for all German states."),
    dcc_dropdown(
            id = "data-source",
            options= dropdown_opts,
            value="Bayern",
            ),
    dcc_graph(id = "R-values"),
    dcc_graph(id = "N-values")
end

callback!(app, [Output("R-values", "figure"), Output("N-values", "figure"), Output("header", "children")], Input("data-source", "value")) do input_value
    R, l_R = get_data("../example/results-R-reported-"*input_value*".csv", "R - "*input_value)
    R_value = round(R[3][:y][end], digits=2)
    N, l_N = get_data("../example/results-N-reported-"*input_value*".csv", "R - "*input_value)
    Dict(:data=>R, :layout=>l_R), Dict(:data=>N, :layout=>l_N), "R = $R_value"
end

run_server(app, "0.0.0.0", 8080)