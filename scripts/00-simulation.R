#### Preamble ####
# Purpose: Simulate dataset of Covid19 clinics across Toronto
# Author: Christina Wei
# Data: 9 January 2023
# Contact: christina.wei@mail.utoronto.ca
# License: MIT

#### Data Expectations ####
# Number of clinics matching population density in the city
# Expect different types of clinics, like city-run, hospital, pharmacy, pop-ups
# Opening date should be a valid date before today
# columns: clinic_id, district, type, opening_date

#### Workspace setup ####
library(tidyverse)

#### Start simulation ####

## Assumptions

# Fictional district, population, and clinic type
sim_district = c("District1", "District2", "District3", "District4")
sim_population = c(100000, 150000, 20000, 50000)
sim_type = c("City", "Hopsital", "Pharmacy", "Pop-up")

# Probabilities used for sampling
prob_district = sim_population / sum(sim_population)
prob_type = c(0.2, 0.2, 0.5, 0.1)


## Creating simulated data

set.seed(311) #random seed
num_observations = 100

simulated_data = 
  tibble(
    clinic_id = c(1:num_observations),
    district = sample(x = sim_district, 
                      size = num_observations,
                      replace = TRUE,
                      prob = prob_district),
    type = sample(x = sim_type,
                  size = num_observations,
                  replace = TRUE,
                  prob = prob_type),
  )


## Create summary statistics of number of clinics per district and 
## compare it with the number of population in each district

# summarize clinics by district
clinic_per_district = 
  simulated_data |>
    group_by(district) |>
    count() |>
    rename("num_clinics" = "n")

# add population column to the data
clinic_per_district['population'] = sim_population

# compute bps per district
clinic_per_district =
  clinic_per_district |>
    mutate(
      bps_of_population =
        num_clinics / population * 10000
    )


## Create graphs of simulated data

# Bar graph of clinics per district, by type
simulated_data |> 
  ggplot(aes(fill = type, x = district)) +
  geom_bar(position = "dodge")


## Create graph of clinic summary by district

clinic_per_district |>
  ggplot(aes(x = district, y = bps_of_population)) + 
  geom_bar(stat="identity") + 
  theme_minimal()

## Data validation

# 4 districts in the data
length(unique(simulated_data$district)) == 4 

# 4 types of clinics in the data
length(unique(simulated_data$type)) == 4 

# check that each type of clinic is less than 100 
simulated_data |>
  group_by(type) |>
  count() |>
  filter(n > num_observations) |>
  sum() == 0

# check the number of clinics in each district is less than 100 
simulated_data |>
  group_by(district) |>
  count() |>
  filter(n > num_observations) |>
  sum() == 0