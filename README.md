# UTBT MapVote
*A proper MapVote specifically designed for BunnyTrack*
![UTBT_MapVote](https://cdn.discordapp.com/attachments/975106092969377832/991759083696828506/unknown.png)

## Installation
Add to unrealtournament.ini: `ServerPackages=UTBT_MapVote_v10`

Add as Mutator: `UTBT_MapVote_v10.MV_Mutator`
### Setting up the maplist/categories/announcement
See [Requester] in UTBT_MapVote.ini. Place in there the paths to the corresponding files. Make sure to include headers in each file such as:
- maplist file: `[maplist]`.
- categories file: `[categories]`.
- category files themself: `[category_name]` (example: `[BTCup 2021 - Division 1]`)
- announcment file: `[announcement]`
- update file: `[update]`
### Maplist file
For the maplist file, a format of this is expected:
```ini
[maplist]
CTF-BT-Map1*5
CTF-BT-Map2*10
CTF-BT-Map3*1
```
In the example above; Map1 is set with a difficulty rating of 5, Map2 with a 10 and Map3 with a rating of 1.
### Categories file
For the categories file, a format of this is expected:
```ini
[categories]
Easy Maps
Medium Maps
Hard Maps
Most Played Maps
New Maps
BTCup 2021 - Division 1
ClanBase Maps
```
### Categories files
For each category a separate file is expected in this format:
```ini
[BTCup 2021 - Division 1]
CTF-BT-KryptonCB
CTF-BT-RookCB
CTF-BT-BioshockCB
CTF-BT-SolarMoonCB2
CTF-BT-IndifferentV4
CTF-BT-Adeon-Factory
CTF-BT-TheLostJournalCB
```
### Announcement file
For the announcement file, a format of this is expected:
```html
[announcement]
<html>
    <body>
        <center>
            <br>
            <h1>Welcome to UTBT</h1>
            <p><b>Lorem ipsum</b> dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>
            <p>Visit our <a href=\"http://www.UTBT.net\">Discord</a></p>
            <p>Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
        </center>
    </body>
</html>
```
Supported HTML elements are:
-   `<html>`
-   `<body bgcolor=#ffffff link=#ffffff alink=#ffffff>...</body>` (set color for background and links)
-   `<font color=#ffffff bgcolor=#ffffff>...</font>` (set color for text and background)
-   `<center>`
-   `<br>`
-   `<nobr>`
-   `<p>`
-   `<a href=\"...\">My link<a>`
-   `<h1>` (this is the only header, h2 etc. are not available)
-   `<blink>` on/off blinking text
### Update file
For the update file, a format of this is expected:
```ini
[update]
1656259997
```
Update this file each time you make changes to the maplist/categories/announement files, so that the MapVote will request all data again, and will overwrite its cache in case a change in data is found.

## UTBT_MapVote.ini
The server ini is independent of the UTBT_MapVote version you are using. No need to modify headers when updating to a new version.
It consists of 3 headers; Settings, Requester and Cache.
```ini
[Settings]
MapListCacheName=SummerRush
bAllowSpectatorVotes=False
bAddRatingCategories=True
MidGameVotePercent=50
VoteTimeLimit=60
ScoreBoardDelay=10
bSwitchToRandomMapAtFailedMapSwitch=False
bSwitchLevelOnEmptyServer=True
EmptyServerTimeMinutes=2
bSwitchToRandomMap=True
DefaultMap=

[Requester]
HostAddress=
Update_URI=
Announcement_URI=
MapList_URI=
Categories_URI=
MapListCheckUpdateIntervalSeconds=60
LastMapListUpdate=

[Cache]
MD5=
Announcement=
```
### Explainer:

#### [Settings]
- **MapListCacheName:** The name of the cache file stored on clients, holding the mapvote data until a new update appears. For example, a value of "SummerRush" will make a SummerRush.ini file on clients. It's recommended to use different cache file names for servers with different maplists, so that clients can hold multiple maplists at the same time without needing to update/overwrite.
- **bAllowSpectatorVotes:** Should be self explanatory. Option to give spectators the ability to place votes, just like players can.
- **bAddRatingCategories:** This setting will add Difficulty Rating (0-10) categories in the category list. Very useful when every map has a difficulty rating set, making it easy for users to filter or sort the maplist to their preference and skill level.
- **MidGameVotePercent:** This is the amount of percent that the amount of votes in the game need to surpass, to initiate Mid-Game voting; causing a countdown for all players to vote and switch the map.
- **VoteTimeLimit:** When the map has ended, or when Mid-Game voting has initiated; this value is the duration in seconds the countdown would take.
- **ScoreBoardDelay:** Once the map has ended, this is the amount of seconds until the MapVote will pop-up for players that did not vote yet. Starting the VoteTimeLimit once that happens.
- **bSwitchToRandomMapAtFailedMapSwitch:** Bad or missing files (dependencies) for maps can happen. Setting this to false will keep the map running on a failed map switch, and will give players the ability to revote another map. Setting this to true will let the MapVote pick another random map immediately, and switches to this.
- **bSwitchLevelOnEmptyServer:** When there are no players in the server, the mapvote can switch to another map based on the duration of absense of players, see "EmptyServerTimeMinutes" to configure this duration.
- **EmptyServerTimeMinutes:** If "bSwitchLevelOnEmptyServer" is set to true, this setting will set the duration for when to switch to another map, when there is an absense of players for the set amount of minutes.
- **bSwitchToRandomMap:** When voting has ended without any votes, or when there is an absense of players for X minutes; switch to a random map? or switch to the "DefaultMap"?
- **DefaultMap:** The MapVote will switch to this map in the 2 scenario's described above at "bSwitchToRandomMap".
#### [Requester]
- **HostAddress:** Self explanatory; the hostname of where the Requester will look for MapVote data, such as map names, categories, announcement.
- **Update_URI:** The location of the UpdateID/Date. The MapVote will regularly check this to see if it should update.
- **Announcement_URI:** The location of the announcement text, in limited HTML.
- **MapList_URI:** The location of map names.
- **Categories_URI:** The location of Categories.
- **MapListCheckUpdateIntervalSeconds:** This will set the time interval in seconds for the Requester to Re-Request "Update_URI", to keep track of updates.
- **LastMapListUpdate:** This set/modified automatically by the MapVote. Using this value as a UpdateID/Date to compare with the found UpdateID/Date at "Update_URI".
#### [Cache]
- Everything under this header will be used as the name says; as Cache. All the data gathered via the Requester will be stored here server side. Clients who enter the server will automatically download a copy of these contents, saving the Cache client side as well, making the MapVote super quick on opening. Client side Cache will always be validated with the server cache, and in case of difference the client cache will be overwritten with the server cache.
