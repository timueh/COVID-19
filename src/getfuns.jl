export get_weights, get_values, get_reference_data

function get_weights(R::Real, past::Day, future::Day, k_gen::Day)
    [ R^(7 / Dates.value(k_gen)) * ones(Dates.value(past)); ones(1 + Dates.value(future)) ]
end

get_weights(R::Real, past::Int, future::Int, k_gen::Int) = get_weights(R, Day(past), Day(future), Day(k_gen))

function get_values(df::DataFrame, present, past::Day, future::Day; column::Symbol = :cases)
    # ToDo: check type of present
    df[ present - past .<= df.days .<= present + future , column]
end

get_values(df::DataFrame, present, past::Int, future::Int; column::Symbol = :cases) = get_values(df, present, Day(past), Day(future); column = column)

function get_reference_data(df::DataFrame; days_col::String, data_col::String, kind::String)
    @assert kind ∈ ( "R", "cases" ) "kind $kind not supported"
    days = df[!, days_col]
    data = df[!, data_col]
    inds = .!ismissing.(data)

    DataFrame( Dict("days" => Vector{Dates.Date}(days[inds]), "$(kind)" => Vector(data[inds]) ) )
end