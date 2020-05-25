export get_weights, get_values, get_reference_data

function get_weights(R::Real, past::Int, future::Int, k_gen::Int)
    [ R^(7 / k_gen) * ones(past); ones(1 + future) ]
end

function get_weights(R::Real, past::Dates.Day, future::Dates.Day, k_gen::Dates.Day)
    [ R^(7 / Dates.value(k_gen)) * ones(Dates.value(past)); ones(1 + Dates.value(future)) ]
end

function get_values(df::DataFrame, present, past::Int, future::Int; column::Symbol = :cases)
    df[ present - past .<= df.days .<= present + future , column]
end

function get_values(df::DataFrame, present, past::Dates.Day, future::Dates.Day; column::Symbol = :cases)
    df[ present - Day(past) .<= df.days .<= present + Day(future) , column]
end

function get_reference_data(df::DataFrame; days_col::String, data_col::String, kind::String)
    @assert kind ∈ ( "R", "cases" ) "kind $kind not supported"
    days = df[!, days_col]
    data = df[!, data_col]
    inds = .!ismissing.(data)

    DataFrame( Dict("days" => Vector{Dates.Date}(days[inds]), "$(kind)" => Vector(data[inds]) ) )
end