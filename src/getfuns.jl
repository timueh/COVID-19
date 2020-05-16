export get_raw_number, get_dates, get_weights, get_values

function get_raw_number(df::DataFrame, column_name::String = "Punktschätzer der Anzahl Neuerkrankungen (ohne Glättung)")
    Vector{Int64}(df[!, column_name])
end

function get_dates(df::DataFrame, column_name::String = "Datum des Erkrankungsbeginns")
    df[!, column_name]
end

function get_weights(R::Real, past::Int, future::Int, k_gen::Int)
    [ R^(7 / k_gen) * ones(past); ones(1 + future) ]
end

function get_values(df::DataFrame, present::DateTime, past::Int, future::Int; column::Symbol = :cases)
    df[ present - Day(past) .<= df.days .<= present + Day(future) , column]
end