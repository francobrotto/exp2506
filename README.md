# Experiment - 2025 June

I'm using jsPsych to design this simple experiment. The data is stored with Firebase, and I use the export.py script to extract all of the data as a JSON and "flatten" it to a csv. I then use R to analyse the data. This is the first time I'm using this set up, so there is a lot that I'm learning. I will document what I learn here.


> To do list (questionnaire)

V1

+ Store information about participant reloading the page
+ Record browser interactions
+ Integrating with Prolific
+ Make posts full width on mobile

V2

+ Media Preloading
+ Automatic Progress Bar
+ Center and style bigger buttons


> To do list (analysis)

V1

+ Generate data with _Simulation Modes_
+ Clean the csv
+ Write the analysis


> Remember

When I uploaded the main.html for the first time, I got an email warning me that anyone with read access can view _exposed secrets_. I panicked and rotated the key, only to then realise that I wouldn't be able to really hide a key and use it here (or at least I don't know how to do that). After setting up a website restriction I feel like it's okay to have the key exposed.