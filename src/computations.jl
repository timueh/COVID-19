export compute_R, build_R, build_R_acausal

function compute_R(data::AbstractVector, windowsize::Int)
    denominator = data[1:end - windowsize]
    numerator = data[1 + windowsize:end]
    compute_R(numerator, denominator)
end

function compute_R(numerator::AbstractVector, denominator::AbstractVector)
    @assert length(numerator) == length(denominator) "inconsistent data lenghts"
    numerator ./ denominator
end

function build_R(df::DataFrame; past::Int, future::Int, k_gen::Int)
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

function build_R_acausal(df::DataFrame; past::Int, future::Int, k_gen::Int)
    df_N_temp, df_R = build_R(df, past = past, future = future, k_gen = k_gen)
    df_N_acausal = compute_cases_acausal(df, df_R, past = past, future = future, k_gen = k_gen)
    relevant_days = df_N_acausal.days - Day(k_gen)

    num = df_N_acausal.cases
    den = df_N_temp[ first(relevant_days) .<= df_N_temp.days .<= last(relevant_days), :cases]
    R = compute_R(num, den)

    df_N_acausal, DataFrame(days = df_N_acausal.days, R = R)
end

function compute_cases_acausal(df_cases::DataFrame, df_reproduction::DataFrame; past::Int, future::Int, k_gen::Int)
    start_date = first(df_reproduction).days - Day(past)
    end_date = last(df_reproduction).days + Day(future)

    @assert start_date ∈ df_cases.days "missing case numbers from the past (required start date: $(start_date))"
    @assert end_date ∈ df_cases.days "missing case numbers from the future (required end date: $(end_date))"

    N = Vector{Float64}()
    for row in eachrow(df_reproduction)
        day, R = row.days, row.R

        w = get_weights(R, past, future, k_gen)
        cases = get_values(df_cases, day, past, future, column = :cases)

        push!(N, mean(cases .* w))
    end

    DataFrame(days = df_reproduction.days + Dates.Day(past), cases = N)
end