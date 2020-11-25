export main_reported

function main_reported(fig_name, file_name, days_col, data_col, ylabel_R, ylabel_N, pop_days::Int=0)
    # download full COVID-19 data set from the Robert Koch Institut (RKI)
    # this file is ≈50mb
    run(`curl https://www.arcgis.com/sharing/rest/content/items/f10774f1c63e40168479a1feb6c7ca74/data --output $file_name`)

    # generation-time
    k_gen = 4

    # pre-processing
    df = CSV.File(file_name) |> DataFrame
    # we need to filter out all new cases that are *not* -1
    df_filtered = df[df.NeuerFall .!= -1, :]
    df_temp = by(df_filtered, days_col |> Symbol, :AnzahlFall => sum; sort=true) # `by()` is no longer supported as of DataFrames@0.22
    df_temp[!, days_col] = Date.(df_temp[!, days_col], Dates.DateFormat("yyyy/mm/dd H:M:S"))

    df_cases = get_reference_data(df_temp, days_col = days_col, data_col = data_col, kind = "cases")
    # account for the fact that cases were not reported properly before March 2020
    df_cases = df_cases[df_cases.days .>= Date("2020-03-01"), :]

    # do the math
    N, R = compute_and_plot(df_cases, fig_name, k_gen, ylabel_R, ylabel_N, "reported number of cases", pop_days)

    N, R, df_cases
end

