export main_reported

function main_reported(fig_name, file_name, days_col, data_col, ylabel_R, ylabel_N, aggregation::String="country", pop_days::Int=0)
    aggregation = lowercase(aggregation)
    @assert aggregation ∈ ["county", "state", "country"] "$aggregation is not a valid aggregation level."
    # download full COVID-19 data set from the Robert Koch Institut (RKI)
    # this file is ≈50mb

    if !isfile(file_name)
        run(`curl https://www.arcgis.com/sharing/rest/content/items/f10774f1c63e40168479a1feb6c7ca74/data --output $file_name`)
    end

    # generation-time
    k_gen = 4

    # pre-processing
    df = CSV.File(file_name) |> DataFrame

    df_filter = filter_to_relevant_cases(df)

    # aggregate accordingly
    if aggregation == "country"
        df_temp = aggregate_Germany(df_filter, days_col)
    elseif aggregation == "state"
    elseif aggregation == "county"
        throw(error("Not yet supported."))
    end

    # standardize column names
    df_cases = get_reference_data(df_temp, days_col = days_col, data_col = data_col, kind = "cases")

    # account for the fact that cases were not reported properly before March 2020
    df_cases = df_cases[df_cases.days .>= Date("2020-03-01"), :]

    # do the math
    N, R = compute_and_plot(df_cases, fig_name, k_gen, ylabel_R, ylabel_N, "reported number of cases", pop_days)

    # return values
    N, R, df_cases, df_filter
end

function filter_to_relevant_cases(df::DataFrame)
    # we need to filter out all new cases that are *not* -1
    df_filtered = df[df.NeuerFall .!= -1, :]
end

function aggregate_Germany(df_filtered, days_col)
    df = by(df_filtered, days_col |> Symbol, :AnzahlFall => sum; sort=true) # `by()` is no longer supported as of DataFrames@0.22
    convert_date_column(df, days_col)
end

function convert_date_column(df::DataFrame, days_col)
    df[!, days_col] = Date.(df[!, days_col], Dates.DateFormat("yyyy/mm/dd H:M:S"))
    df
end

