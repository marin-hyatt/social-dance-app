# Dance Social Media App

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
This app allows dancers and non-dancers alike to post dance videos of themselves and see other people's dance videos.

### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:** Social
- **Mobile:** Dance videos are often filmed on mobile devices and this app will make it easy to upload videos straight from a phone. Browsing dance videos will be convenient on a phone.
- **Story:** Allows users to share dance videos and explore dance videos from others.
- **Market:** Dancers are the primary market for this app, but non-dancers can make an account just to watch dance videos.
- **Habit:** Users can post videos multiple times per day, but it's also possible to spend a lot of time watching other videos. This app has the potential to be very habit-forming.
- **Scope:** The scope will be very narrow at first (like a bare-bones version of TikTok) but can expand to provide cool features just for dancers, like Spotify API integration.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Users can post a video to their feed
* Users can create a new account
* Users can log in
* Users can follow other users
* Users can see videos from other users in a feed
* Users can search for other users

**Optional Nice-to-have Stories**

* Users can like videos
* Users can comment on videos
* Users can bookmark videos to view later
* Users can view their own profile or the profiles of others, which will have a collection of all dance videos the user has posted
* Users can see what music is playing in the videos (either users will indicate what song is playing when posting a video, or integration with Shazam API?)
* Users can add tags to their videos and search for videos with the same tags
* Users can switch to an explore page with trending videos
* When viewing a dance video, users can navigate to a tutorial screen which will mirror the video, possibly add counts automatically


### 2. Screen Archetypes

* Login Screen
   * User can log in
* Registration Screen
   * User can create a new account
* Feed
    * User can view videos from people that they follow
* Creation
    * User can film a video or upload a video they already have
* Search
    * User can search for other users
    * Could combine with Explore page, also search for tags

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home
* Search User
* Post Video

**Flow Navigation** (Screen to Screen)

* Login Screen
    * => Home
    * => Registration Screen
* Registration Screen
    * => Home
* Feed
    * => None
    * => Could navigate to profile of user who posted the video, tutorial screen
* Creation
    * => Feed
* Search
    * => None
    * => Could navigate to profile of searched user, tutorial screen once video is clicked

## Wireframes
[Add picture of your hand sketched wireframes in this section]
<img src="thumbnail_CamScanner 07-07-2021 11.44.jpg" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
[This section will be completed in Unit 9]
### Models
[Add table of models]
### Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
