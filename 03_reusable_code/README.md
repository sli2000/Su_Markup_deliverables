# Markup languages and reproducible programming in statistics

Deliverable 3: Reusable `R` code wrapped in an `R` package or `Shiny` app.

- If `R` package, link the package website and your development repository (on GitHub).
- If `Shiny app`, link the app on a `Shiny` server and your development repository (on GitHub).

See course manual for requirements.  
Link： https://sli2000.shinyapps.io/visualize_results/   

This Shiny app is used to help me visualize the results of my project. The aim of my project is to proof that calibration remain stable for prognostic models and discrimination remain stable for diagnostic models under different environment. Thus I need to build some prognostic and diagnostic models. Calibaration is estimated by calibaration error, discrimination is estimated by AUC value. To better visualize the results I draw plots of those evaluations, The X-axis represents calibration error, Y-axis represents discrimination value. The arrows goes from traing group to test group to show the variation. Until now, there are three tasks: mortality_prognosis, age_diagnosis, gender_diagnosis. There are three group variables that help group hospitals(region, bed size and teaching status). Each group has different subgroups.
