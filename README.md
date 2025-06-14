# Experiment - 2025 June

I'm using jsPsych to design this simple experiment. The data is stored with Firebase, and I use the export.py script to extract all of the data as a JSON and "flatten" it to a csv. I then use R to analyse the data. This is the first time I'm using this set up, so there is a lot that I'm learning. I will document what I learn here.

V1

+ Store information about participant reloading the page - Done
+ Record browser interactions - Done
+ Integrating with Prolific - Done but need to test with Prolific (see https://www.jspsych.org/v8/overview/prolific/)
+ Make posts full width on mobile - Done
+ Split and reorder the questions: guess general, guess friends, your answers, memory - Done
+ Add first page with consent etc. - Done

### To do list 

Questionnaire V2

+ Media Preloading
+ Automatic Progress Bar
+ Center and style bigger buttons

Analysis V1

+ Generate data with _Simulation Modes_
+ Clean the csv
+ Write the analysis


### Running the experiment

+ This version of the experiment is already a shorter version than the one I want to do later on, but I think I can make it even shorter by removing a couple of questions on parts 4 and 5 related to social norms
+ I then need to run a tiny sample to test and time the tool
+ Then I re-do a little power analysis to determine the minimum sample size, and based on the timing from the pilot I can estimate the total cost from Prolific (payment to participants).


> Learning

When I uploaded the main.html for the first time, I got an email warning me that anyone with read access can view _exposed secrets_. I panicked and rotated the key, only to then realise that I wouldn't be able to really hide a key and use it here (or at least I don't know how to do that). After setting up a website restriction I feel like it's okay to have the key exposed.

I forgot how I set up VS Code to give export.py access to Firebase. 