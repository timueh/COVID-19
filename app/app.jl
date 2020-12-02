using Dash, DashHtmlComponents, DashCoreComponents, DataFrames, CSV

states = ["Baden-Wuerttemberg",
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
            "Thueringen"]
country = "Germany"
dropdown_opts = [Dict("label"=>state, "value"=>state) for state in [country; states]]

# when running on heroku
download = true
github_url = "https://raw.githubusercontent.com/timueh/COVID-19/master/example/"

# when running locally
# download = false
# github_url = "../example/"


function get_data(path_to_file::String, ylabel::String, title::String)
    df = DataFrame(CSV.File(path_to_file))
    index, values = names(df)[1], names(df)[2:end]

    data = [ Dict( :x => df[index],
                :y => df[value],
                :type => "scatter",
                :name => value, ) 
                for value in values ]
    layout = Dict("yaxis" => Dict("title" => ylabel),
                  "title" => title)

    data, layout
end

function get_R_data_germany()
    file_ger = "results-R-reported-Germany.csv"
    data, layout = get_data(file_ger, "R", "")
    data_proj = data[end]
    data_proj[:name] = "Germany"
    data_proj
end

function download_data(github_url, suffix, states; download=true::Bool)
    values = ["R", "N"]
    for state in states
        for value in values
            for suff in suffix
                file_name = "results-"*value*"-"*suff*"-"*state*".csv"
                url = github_url*file_name
                display(url)
                if download
                    run(`curl $url --output $file_name`)
                else
                    run(`cp $url $file_name`)
                end
            end
        end
    end
end

download_state_data(url; download=true) = download_data(url, ["reported"], states, download=download)
download_germany_data(url; download=true) = download_data(url, ["reported", "nowcasting"], [country], download=download)

download_germany_data(github_url; download=download)
download_state_data(github_url; download=download)

## APP
app = dash(external_stylesheets = ["https://codepen.io/chriddyp/pen/bWLwgP.css"])

app.layout = html_div() do
    dcc_markdown("### Reproduction number `R` for COVID-19 pandemic in Germany"),
    html_h1(id="header"),
    dcc_dropdown(
            id = "location-source",
            options= dropdown_opts,
            value="Germany",
            ),
    dcc_dropdown(id="data-source", value="RKI-reported"),
    dcc_graph(id = "R-values"),
    dcc_graph(id = "N-values"),
    html_table(children = [
                    html_tr(children = [
                        html_th("Method"),
                        html_th("Explanation")
                    ]),
                    html_tr(children = [
                        html_td("RKI Nowcast 4 days"),                     
                        html_td(children = [dcc_markdown("[Estimator long used by Robert Koch Institut (RKI)](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/R-Wert-Erlaeuterung.pdf?__blob=publicationFile); effectively a 4-day moving average.")]),
                        ]),
                    html_tr(children = [
                        html_td("RKI Nowcast 7 days"),
                        html_td(children = [dcc_markdown("[Estimator used by Robert Koch Institut (RKI)](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/R-Wert-Erlaeuterung.pdf?__blob=publicationFile); effectively a 7-day moving average, taking 5 days from the past and one day from the future.")]),
                        ]),
                    html_tr(children = [
                        html_td("Projected 7 days"),
                        html_td(children = [dcc_markdown("[Acausal estimator that accounts for three days of the past, the current day, and three days of the future](https://www.medrxiv.org/content/10.1101/2020.11.27.20238618v1); future values are based on the respective values from the previous week.")]),
                        ]),
        ]
        ),
        html_table(children = [
            html_tr(children = [
                html_th("Data source"),
                html_th("Explanation")
            ]),
            html_tr(children = [
                html_td("RKI Reported cases"),                     
                html_td(children=[dcc_markdown("[Full data set of reported cases](https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0), curated and updated daily by the Robert Koch Institut (RKI)")]),
                ]),
            html_tr(children = [
                html_td("RKI Nowcasting"),
                html_td(children = [dcc_markdown("[Nowcasting data](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/Nowcasting.html;jsessionid=C42873168F44ED8B13EA88FDCEF2DE7A.internet062?nn=13490888) on total number of cases provided by Robert Koch Institut (RKI)")]),
                ]),
            ]
            )
end

callback!(app, [Output("R-values", "figure"), Output("N-values", "figure"), Output("header", "children")], [Input("location-source", "value"), Input("data-source", "value")]) do input_location, input_source

    suffix = "reported"
    if input_location == country && input_source == "RKI-nowcasting"
        suffix = "nowcasting"
    end

    file_R = "results-R-"*suffix*"-"*input_location*".csv"
    file_N = "results-N-"*suffix*"-"*input_location*".csv"

    R, l_R = get_data(file_R, "R", input_location)
    R_value = round(R[3][:y][end], digits=2)
    N, l_N = get_data(file_N, "Cases", "")

    if input_location != country
        # add R values for Germany to compare
        push!(R, get_R_data_germany())
    end

    Dict(:data=>R, :layout=>l_R), Dict(:data=>N, :layout=>l_N), "R = $R_value"
end

callback!(app, Output("data-source", "options"), Input("location-source", "value")) do input_value
    options = [Dict("label" => "Robert Koch Institut (RKI) - reported cases", "value" => "RKI-reported")]
    if input_value == country
        push!(options, Dict("label" => "Robert Koch Institut (RKI) - nowcasting cases", "value" => "RKI-nowcasting"))
    end
    options
end

run_server(app, "0.0.0.0", 8080)