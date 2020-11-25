export compute_R, build_R, build_R_acausal, parameter_search, get_data

function compute_R(data::AbstractVector, windowsize::Int)
    denominator = data[1:end - windowsize]
    numerator = data[1 + windowsize:end]
    compute_R(numerator, denominator)
end

function compute_R(numerator::AbstractVector, denominator::AbstractVector)
    @assert length(numerator) == length(denominator) "inconsistent data lenghts"
    numerator ./ denominator
end

function build_R(df::DataFrame, past::Int, future::Int, k_gen::Int, pop_days::Int=0)
    @assert past >= 0 && future >= 0 "values for past = $past and future = $future must be non-negative"
    @assert k_gen > 0 "invalid value for k_gen ($(k_gen))"

    dates, data = df.days, df.cases

    window = 1 + past + future
    N = rollmean(data, window)
    days_N = dates[1 + past:end - future]

    R = compute_R(N, k_gen)
    days_R = dates[1 + k_gen + past:end - future]

    DataFrame(days = days_N, cases = N), DataFrame(days = days_R, R = R)
end

function build_R_acausal(df::DataFrame, past::Day, future::Day, k_gen::Day)
    df_N_temp, df_R = build_R(df, Dates.value(past), Dates.value(future), Dates.value(k_gen))
    if typeof(df_R.days) == Vector{Int}
       df_R.days = map(x -> Date(2020,2,3) + Day(x), df_R.days) 
    end
    
    df_N_acausal = compute_cases_acausal(df, df_R, past, future, k_gen)
    relevant_days = df_N_acausal.days - k_gen

    num = df_N_acausal.cases
    den = df_N_temp[ first(relevant_days) .<= df_N_temp.days .<= last(relevant_days), :cases]
    R = compute_R(num, den)

    df_N_acausal, DataFrame(days = df_N_acausal.days, R = R)
end

build_R_acausal(df::DataFrame, past::Int, future::Int, k_gen::Int) = build_R_acausal(df, Day(past), Day(future), Day(k_gen))

function compute_cases_acausal(df_cases::DataFrame, df_reproduction::DataFrame, past::Day, future::Day, k_gen::Day)
    @assert typeof(df_reproduction.days) == Vector{Date} "Column `days` of df_cases  needs to have `Date` entries"
    start_date = first(df_reproduction).days - past
    end_date = last(df_reproduction).days + future

    @assert start_date ∈ df_cases.days "missing case numbers from the past (required start date: $(start_date))"
    @assert end_date ∈ df_cases.days "missing case numbers from the future (required end date: $(end_date))"

    N = Vector{Float64}()
    for row in eachrow(df_reproduction)
        day, R = row.days, row.R

        w = get_weights(R, past, future, k_gen)
        cases = get_values(df_cases, day, past, future, column = :cases)

        push!(N, mean(cases .* w))
    end

    DataFrame(days = df_reproduction.days .+ past, cases = N)
end

function get_data(df::DataFrame; days_col::String, data_col::String, kind::String)
    @assert kind ∈ ( "R", "cases" ) "kind $kind not supported"
    index = df[!, days_col]
    data = df[!, data_col]
    inds = .!ismissing.(data)

    DataFrame( Dict("days" => Vector(index[inds]), "$(kind)" => Vector(data[inds]) ) )
end

function parameter_search(df::DataFrame, past::Array{Int64,1}, future::Array{Int64,1}, k_gen:: Array{Int64,1}, data_col::String)
    result_r = DataFrame(NEUH = Float64[], NEUHA= Float64[], Past = Int[], Future = Int[], k_gen=Int[])
    result_n = DataFrame(Method = String[], Case= String[], Past = Int[], Future = Int[], k_gen=Int[])
    df_cases = get_data(df, days_col = "k", data_col = data_col, kind = "cases")
    df_cases.days = map(x -> Date(2020,2,3) + Day(x), df_cases.days)
    r_true = df[!, "true R"]
    for k in k_gen
        for i in past
            if i > k
                break
            end
            for j in future
                if j > k
                    break
                end
                neu_h_N, neu_h_R = build_R(df_cases,i, j,  k)
                error_h = mean(abs.(neu_h_R.R[max(1, 11 - i - j):length(neu_h_R.R)]- r_true[(max(1,11 - i -j)+ k + i):(length(r_true)- j)]))
                neu_ha_N, neu_ha_R = build_R_acausal(df_cases, i, j, k)
                error_ha = mean(abs.(neu_ha_R.R[max(1, 11 - i - j):length(neu_h_R.R)] -r_true[(max(1,11 - i -j)+ k + i):(length(r_true)- j)]))
                push!(result_r, [error_h, error_ha, i, j, k])
            end
        end
    end
    result_r
end