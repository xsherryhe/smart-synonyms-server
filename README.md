# Smart Synonyms Server

## Introduction

This project is the back end for a smart thesaurus which uses "synsets" to form precise conceptual-semantic networks and collections among words. It is built using Ruby on Rails. Lexical and semantic data come from Princeton's [WordNet](https://wordnet.princeton.edu/) database.

On the back end, the project makes use of the Rails framework to adapt an external database to a modern REST API.

This project is currently in progress. See my developer notes below!

## Developer Notes

### Favorite Features

- The app leverages an external academic knowledge base, and provides a modern tech interface for it.
- Randomization is used so that for most words, moderately different sets of synonyms show up on each generation. The Ruby method `Array#sample` offered a very easy way to implement this.

### Challenges

- The WordNet database lacks a RESTful JSON API. However, I was happy to have the opportunity to build my own using Rails!
- It was tricky finding the right data format for the WordNet database for the needs of this app. WordNet exists as a relational database at [SqlUNET](http://sqlunet.sourceforge.net/) in MySQL and SQLite files. Thinking ahead to deployment and knowing I would be using Postgres for production databases, I initially attempted to use the [Sequel](https://github.com/jeremyevans/sequel) gem to migrate WordNet data to a PostgreSQL database. As it turns out, the database would have had millions of rows, which I deemed was too high of a cost for a personal project. Instead, I decided to use [rwordnet](https://github.com/doches/rwordnet), a Ruby gem that interfaces with the WordNet data as raw text files using numerical offsets that point to specific data entries.
- Given my decisions, I was using Rails as a framework for a database-less server. This caused a few bugs when launching the Puma web server using `bin/rails server`, which expects a database config. The [activerecord-nulldb-adapter](https://github.com/nulldb/nulldb) gem did the trick here, effectively setting the database adapter to interact with a "null" database.
- There was minor bug in the rwordnet gem. It specifically involved initializing an origin synset's related synsets using the origin part of speech, rather than the related sysnet's part of speech. I did some research about what to do about a bug in a gem. Through my research, I found out that I could fork the gem, fix the bug in my fork, and point the Gemfile to my forked Git repository.
- There were some functionalities (e.g., getting synonyms and definitions) that were not built into the rwordnet gem, so I extended classes from the rwordnet gem in my own app. I built a strong understanding of the internal workings of the original gem, so that I could select and use the appropriate methods and instance variables for the classes that I extended.
- I knew that I wanted each synonyms query to return 5 related synonym synsets. But what if a particular origin synset had less than 5 related synonym synsets to begin with? I decided to build a function that would implement a "stepwise" breadth-first search over the synonym synsets. On each new step, the synonym synsets of the previous step's synonym synsets would be added to the array of all synonym synsets. The function returned the array of all synonym synsets once the array had reached a certain length (e.g., 5) or once there were no more new synonym synsets to add. Then `Array#sample` would be used to sample exactly 5 items from the array. Very cool adapting some algorithm knowledge to my app here!

### This app was my first time building with...

- [WordNet 3.0 Database from Princeton University](https://wordnet.princeton.edu/)

