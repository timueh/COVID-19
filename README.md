# Covid-19 in Germany &ndash; Point estimators for `R`

![Reproduction numbers](example/reproduction-numbers-reported.png)

In the wake of the current pandemic, the reproduction number `R` takes on an important role.
It is defined as the average number of people who get infected by a typical case.
Ideally, we'd like to see `R` drop below 1 so that a pandemic (eventually) fades out.

We compare different point estimators for `R` with respect to their effectiveness in representing historical data.
Specifically, we compare an acausal point estimator that accurately accounts for weekly periodicities to the point estimator that has long been used by the Robert Koch Institut (4-day moving average), and a point estimator that the Robert Koch Institut started using recently (7-day moving average).

The code is based on the [this preprint (in German)](https://www.researchgate.net/profile/Ralf_Mikut/publication/341447502_Schatzung_einer_zeitabhangigen_Reproduktionszahl_R_fur_Daten_mit_einer_wochentlichen_Periodizitat_am_Beispiel_von_SARS-CoV-2-Infektionen_und_COVID-19/links/5ec190ee92851c11a870291a/Schaetzung-einer-zeitabhaengigen-Reproduktionszahl-R-fuer-Daten-mit-einer-woechentlichen-Periodizitaet-am-Beispiel-von-SARS-CoV-2-Infektionen-und-COVID-19.pdf).

The following plot shows three different point estimators, namely:

| Name | Description |
| --- | --- |
| `RKI Nowcast 4 days` | Estimator long used by Robert Koch Institut; effectively a 4-day moving average. |
| `RKI Nowcast 7 days` | Estimator used by Robert Koch Institut; effectively a 7-day moving average, taking 5 days from the past and one day from the future. |
| `Projected 7 days` | Acausal estimator that accounts for three days of the past, the current day, and three days of the future; future values are based on the respective values from the previous week. | 

## Installation

The code was tested with `Julia 1.5.2`.
You can [add the code to your local machine as an unregistered package](https://julialang.github.io/Pkg.jl/v1/managing-packages/#Adding-unregistered-packages-1) called `ReproductionNumbers`.
Simply switch to the package manager, and add the package locally.
```julia
julia> ]
(@v1.5) pkg> add https://github.com/timueh/COVID-19
julia> using ReproductionNumbers
```

## Getting started

After having installed the package, you can check out the examples in the designated folder.

## Results for reported cases

__The following plots are generated upon calling [`example/reported.jl`](example/reported.jl)__

The data for the reported cases comes from the [daily updated figures](https://www.arcgis.com/sharing/rest/content/items/f10774f1c63e40168479a1feb6c7ca74/data) from the Robert Koch Institut.

The curves for the reproduction number `R` look as follows

![Reproduction numbers](example/reproduction-numbers-reported.png)

The curves for the actual reported cases look as follows
![Reported cases](example/cases-reported.png)

## Results for nowcasted cases

*Unfortunately, the nowcasting data is not accessible via an API, and automated downloads are blocked at some point by a captcha. That's why the nowcasting data may not be up to date.*

__The following plots are generated upon calling [`example/nowcasting.jl`](example/nowcasting.jl)__

The data for the nowcasted cases comes from the [daily updated figures](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/Nowcasting_Zahlen.xlsx\?__blob\=publicationFile) from the Robert Koch Institut.

The curves for the reproduction number `R` for the reported cases look as follows

![Reproduction numbers](example/reproduction-numbers-nowcasting.png)

The curves for the actual reported cases look as follows
![Reported cases](example/cases-nowcasting.png)


## Dashboard

[Dashboard for Point estimators for reproduction number `R`.](https://r-estimator-dashboard.herokuapp.com/)

*Based on publicly available data from the German Robert Koch Institut.*