export main_reported, filter_to_relevant_cases, check_and_correct_missing_days, are_days_missing

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

    # aggregate by country, state, or county
    if aggregation == "country"
        df_temp = aggregate_Germany(df_filter, days_col)
    elseif aggregation == "state"
        df_temp = aggregate_state(df_filter, days_col)
    elseif aggregation == "county"
        throw(error("Not yet supported."))
    end
    # convert date column
    df_temp = convert_date_column(df_temp, days_col)
    # standardize column
    df_cases = get_reference_data(df_temp, days_col = days_col, data_col = data_col, kind = "cases")
    # account for the fact that cases were not reported properly before March 2020
    df_cases = filter_to_relevant_days(df_cases, Date("2020-03-01"))
    # check for missing days
    df_cases = check_and_correct_missing_days(df_cases, kind="cases")
    # do the math
    N, R = compute_and_plot(df_cases, fig_name, k_gen, ylabel_R, ylabel_N, "reported number of cases", pop_days)
    # return values
    N, R, df_cases
end

function filter_to_relevant_days(df::DataFrame, day::Date)
    df[df.days .>= day, :]
end

function filter_to_relevant_days(d::Dict, day::Date)
    dd = deepcopy(d)
    for (name, df) in dd
        dd[name] = filter_to_relevant_days(df, day)
    end
    dd
end

function filter_to_relevant_cases(df::DataFrame)
    # we need to filter out all new cases that are *not* -1
    df_filtered = df[df.NeuerFall .!= -1, :]
end

function aggregate_Germany(df_filtered, days_col)
    df = by(df_filtered, days_col |> Symbol, :AnzahlFall => sum; sort=true) # `by()` is no longer supported as of DataFrames@0.22
    Dict("Germany"=>df)
end

function aggregate_state(df_filtered, days_col)
    gdf = groupby(df_filtered, :Bundesland)
    cases_dict = Dict{String, DataFrame}()

    umlaute = Dict("ä"=>"ae", "ö"=>"oe", "ü"=>"ue", "ß"=>"ss")
    for (i, df_state) in enumerate(gdf)
        # get name of current state
        state_name = unique(gdf[i].Bundesland) |> first
        for (key, val) in umlaute
            state_name = replace(state_name, key=>val)
        end
        # aggregate state data by days
        gdf_state = groupby(df_state, days_col)
        # sum over the number of cases & sort
        cases = combine(gdf_state, :AnzahlFall => sum) |> sort
        cases_dict[state_name] = cases
    end
    cases_dict
end

function convert_date_column(df::DataFrame, days_col)
    df[!, days_col] = Date.(df[!, days_col], Dates.DateFormat("yyyy/mm/dd H:M:S"))
    df
end

function convert_date_column(df::Dict, days_col)
    for (key, value) in df
        df[key] = convert_date_column(value, days_col)
    end
    df
end

function check_and_correct_missing_days(df::DataFrame; name::String="", kind::String)
    d_start, d_end = first(df.days), last(df.days)
    if are_days_missing(df.days, d_start, d_end)
        display("Filling non-existing values for $name.")
        d_ref = d_start:Day(1):d_end
        y_ref = fill_non_existing_entries(d_ref, df.days, df.cases)
        return DataFrame(Dict("days" => d_ref, "$kind" => y_ref))
    end
    return df
end

function check_and_correct_missing_days(d::Dict; kind::String)
    for (key, value) in d
        d[key] = check_and_correct_missing_days(value, name=key, kind=kind)
    end
    d
end

function are_days_missing(days::Vector{Date}, start_day::Date, end_day::Date)
    days_ref = start_day:Day(1):end_day
    days_ref != days
end
