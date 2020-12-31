import pandas as pd
import subprocess

import dash
import dash_html_components as html
import dash_core_components as dcc
from dash.dependencies import Input, Output

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

dropdown_opts = [{"label":state, "value":state} for state in [country] + states]

download = True
github_url = "https://raw.githubusercontent.com/timueh/COVID-19/master/example/"

def get_data(path_to_file: str, ylabel: str, title: str):
    df = pd.read_csv(path_to_file, index_col="days", parse_dates=["days"], infer_datetime_format=True)
    data = [ {
        "x" : df.index,
        "y" : df[column_name],
        "type":"scatter",
        "name" : column_name
    } for column_name in df.columns]
    layout = {
        "yaxis" : {"title":ylabel},
        "title" : title
    }

    return data, layout

def get_R_data_germany():
    file_ger = "results-R-reported-Germany.csv"
    data, layout = get_data(file_ger, "R", "")
    data_proj = data

    return data_proj


def download_data(github_url, suffix, states, download:bool = True):
    values = ["R", "N"]
    for state in states:
        for value in values:
            for suff in suffix:
                file_name = f"results-{value}-{suff}-{state}.csv"
                url = github_url + file_name
                print(url)
                if download:
                    subprocess.run(["curl", url, "--output", file_name])
                else:
                    subprocess.run(["cp", url, file_name])


def download_state_data(url, download=True):
    download_data(url, ["reported"], states, download=download)

def download_germany_data(url, download=True):
    download_data(url, ["reported", "nowcasting"], [country], download=download)

download_germany_data(github_url, download=download)
download_state_data(github_url, download=download)

app = dash.Dash("COVID-19 Reproduction Number", external_stylesheets = ["https://codepen.io/chriddyp/pen/bWLwgP.css"])
server = app.server

app.layout = html.Div(children=[
    dcc.Markdown("### Reproduction number `R` for COVID-19 pandemic in Germany"),
    html.H1(id="header"),
    dcc.Dropdown(
            id = "location-source",
            options= dropdown_opts,
            value="Germany",
            ),
    dcc.Dropdown(id="data-source", value="RKI-reported"),
    dcc.Graph(id = "R-values"),
    dcc.Graph(id = "N-values"),
    html.Table(children = [
                    html.Tr(children = [
                        html.Th("Method"),
                        html.Th("Explanation")
                    ]),
                    html.Tr(children = [
                        html.Td("RKI Nowcast 4 days"),                     
                        html.Td(children = [dcc.Markdown("[Estimator long used by Robert Koch Institut (RKI)](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/R-Wert-Erlaeuterung.pdf?__blob=publicationFile); effectively a 4-day moving average.")]),
                        ]),
                    html.Tr(children = [
                        html.Td("RKI Nowcast 7 days"),
                        html.Td(children = [dcc.Markdown("[Estimator used by Robert Koch Institut (RKI)](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/R-Wert-Erlaeuterung.pdf?__blob=publicationFile); effectively a 7-day moving average, taking 5 days from the past and one day from the future.")]),
                        ]),
                    html.Tr(children = [
                        html.Td("Projected 7 days"),
                        html.Td(children = [dcc.Markdown("[Acausal estimator that accounts for three days of the past, the current day, and three days of the future](https://www.medrxiv.org/content/10.1101/2020.11.27.20238618v1); future values are based on the respective values from the previous week.")]),
                        ]),
        ]
        ),
        html.Table(children = [
            html.Tr(children = [
                html.Th("Data source"),
                html.Th("Explanation")
            ]),
            html.Tr(children = [
                html.Td("RKI Reported cases"),                     
                html.Td(children=[dcc.Markdown("[Full data set of reported cases](https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0), curated and updated daily by the Robert Koch Institut (RKI)")]),
                ]),
            html.Tr(children = [
                html.Td("RKI Nowcasting"),
                html.Td(children = [dcc.Markdown("[Nowcasting data](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/Nowcasting.html;jsessionid=C42873168F44ED8B13EA88FDCEF2DE7A.internet062?nn=13490888) on total number of cases provided by Robert Koch Institut (RKI)")]),
                ]),
            ]
            ) ])

@app.callback(
    [Output("R-values", "figure"), Output("N-values", "figure"), Output("header", "children")], 
    [Input("location-source", "value"), Input("data-source", "value")]
) 
def knowIdea(input_location, input_source):

    suffix = "reported"
    if input_location == country and input_source == "RKI-nowcasting":
        suffix = "nowcasting"
    

    file_R = f"results-R-{suffix}-{input_location}.csv"
    file_N = f"results-N-{suffix}-{input_location}.csv"

    R, l_R = get_data(file_R, "R", input_location)
    print(R[-1]["y"])
    R_value = round(R[-1]["y"].values[-1], 2)
    N, l_N = get_data(file_N, "Cases", "")

    if input_location != country:
        # add R values for Germany to compare
        R.append(get_R_data_germany())

    return {"data":R, "layout":l_R}, {"data" : N, "layout":l_N}, f"R = {R_value}"

@app.callback(
    Output("data-source", "options"),
    Input("location-source", "value")
)
def update_country(input_value):
    options = [{"label": "Robert Koch Institut (RKI) - reported cases", "value" : "RKI-reported"}]
    if input_value == country:
        options.append({"label": "Robert Koch Institut (RKI) - nowcasting cases", "value" : "RKI-nowcasting"})
    return options
if __name__ == "__main__":
    app.run_server(debug=True)