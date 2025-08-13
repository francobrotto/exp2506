# Experiment - 2025 June

I'm using jsPsych to design this simple experiment. The data is stored with Firebase, and I use the export.py script to extract all of the data as a JSON and "flatten" it to a csv using read_json.R. I then use R to analyse the data. This is the first time I'm using this set up, so there is a lot that I'm learning. I will document what I learn here.

main.html V1

+ Store information about participant reloading the page
+ Record browser interactions
+ Integrating with Prolific - but need to test with Prolific (see https://www.jspsych.org/v8/overview/prolific/)
+ Make posts full width on mobile
+ Split and reorder the questions: guess general, guess friends, your answers, memory
+ Add first page with consent etc.
+ Center and style bigger buttons

main.html V2

+ Revised questionnaire, focused on 3 factors for each of the key indicators.
+ Changed from 2 treatment and 1 control group to a full 2x2x2 design (cause x social support x tactics) + a control group for the climate/environment cause. Some of the groups might hold a little less ecological validity since they are less realist (i.e. there seems to be a natural correlation between social support and tactics, so small and radical are more common than large and radical protests)
+ Right now the media is hosting in a shared Hostinger server. I used stresser.js with k6 so test the server. It seems like it can support around 30-35 simultaneous users, which I can use to limit access in Prolific.

pre-manipulation.html V1

+ This is a little tool based on the main tool, that only loops through all posts and ask three questions about each post, to serve as a "pre-manipulation" check

design.R V1

+ Use D-optimisation to select the fractional factorial design of the experiment
+ Simulate a dataset based on the optimised design
+ Run a power analysis
+ Plot the power for each regression with semPlot

### To do list 

main.html V3

+ I need to run a pilot to check my manipulation. What is actually changing across the groups?
+ Media Preloading (see https://www.jspsych.org/v8/overview/media-preloading/)
+ Automatic Progress Bar

analysis.R V1

+ Generate data with _Simulation Modes_ - alright so apparently that won't work because simulate is very bad with forms
+ Clean the csv
+ Write the analysis


### Running the experiment

+ This version of the experiment is already a shorter version than the one I want to do later on, but I think I can make it even shorter by removing a couple of questions on parts 4 and 5 related to social norms
+ I then need to run a tiny sample to test and time the tool
+ Then I re-do a little power analysis to determine the minimum sample size, and based on the timing from the pilot I can estimate the total cost from Prolific (payment to participants).


> Learning

When I uploaded the main.html for the first time, I got an email warning me that anyone with read access can view _exposed secrets_. I panicked and rotated the key, only to then realise that I wouldn't be able to really hide a key and use it here (or at least I don't know how to do that). After setting up a website restriction I feel like it's okay to have the key exposed.

To set up VS Code to give export.py access to Firebase, I need to get my service account JSON key file from: https://console.cloud.google.com/iam-admin/serviceaccounts (select project, generate and download a JSON key file) and then run the line below in the terminal. If I lose the JSON file, I have to create a new key and delete the old one.

`export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account-key.json"`

Working with JSON is difficult in the beginning. I'm more familiar with R, so decided to wrangle the data there instead of Python.