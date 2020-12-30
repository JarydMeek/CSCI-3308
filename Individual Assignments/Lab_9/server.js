/***********************
  Load Components!

  Express      - A Node.js Framework
  Body-Parser  - A tool to help use parse the data in a post request
  Pg-Promise   - A database tool to help use connect to our PostgreSQL database
***********************/
var express = require('express'); //Ensure our express framework has been added
var app = express();
var bodyParser = require('body-parser'); //Ensure our body-parser tool has been added
app.use(bodyParser.json());              // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies

//Create Database Connection
var pgp = require('pg-promise')();

/**********************
  Database Connection information
  host: This defines the ip address of the server hosting our database.  We'll be using localhost and run our database on our local machine (i.e. can't be access via the Internet)
  port: This defines what port we can expect to communicate to our database.  We'll use 5432 to talk with PostgreSQL
  database: This is the name of our specific database.  From our previous lab, we created the football_db database, which holds our football data tables
  user: This should be left as postgres, the default user account created when PostgreSQL was installed
  password: This the password for accessing the database.  You'll need to set a password USING THE PSQL TERMINAL THIS IS NOT A PASSWORD FOR POSTGRES USER ACCOUNT IN LINUX!
**********************/
const dbConfig = {
	host: 'localhost',
	port: 5432,
	database: 'football_db',
	user: 'postgres',
	password: 'Password'
};

var db = pgp(dbConfig);

// set the view engine to ejs
app.set('view engine', 'ejs');
app.use(express.static(__dirname + '/'));//This line is necessary for us to use relative paths and access our resources directory



/*********************************
 Below we'll add the get & post requests which will handle:
   - Database access
   - Parse parameters from get (URL) and post (data package)
   - Render Views - This will decide where the user will go after the get/post request has been processed

 Web Page Requests:

  Login Page:        Provided For your (can ignore this page)
  Registration Page: Provided For your (can ignore this page)
  Home Page:
  		/home - get request (no parameters) 
  				This route will make a single query to the favorite_colors table to retrieve all of the rows of colors
  				This data will be passed to the home view (pages/home)

  		/home/pick_color - post request (color_message)
  				This route will be used for reading in a post request from the user which provides the color message for the default color.
  				We'll be "hard-coding" this to only work with the Default Color Button, which will pass in a color of #FFFFFF (white).
  				The parameter, color_message, will tell us what message to display for our default color selection.
  				This route will then render the home page's view (pages/home)

  		/home/pick_color - get request (color)
  				This route will read in a get request which provides the color (in hex) that the user has selected from the home page.
  				Next, it will need to handle multiple postgres queries which will:
  					1. Retrieve all of the color options from the favorite_colors table (same as /home)
  					2. Retrieve the specific color message for the chosen color
  				The results for these combined queries will then be passed to the home view (pages/home)

  		/team_stats - get request (no parameters)
  			This route will require no parameters.  It will require 3 postgres queries which will:
  				1. Retrieve all of the football games in the Fall 2018 Season
  				2. Count the number of winning games in the Fall 2018 Season
  				3. Count the number of lossing games in the Fall 2018 Season
  			The three query results will then be passed onto the team_stats view (pages/team_stats).
  			The team_stats view will display all fo the football games for the season, show who won each game, 
  			and show the total number of wins/losses for the season.

  		/player_info - get request (no parameters)
  			This route will handle a single query to the football_players table which will retrieve the id & name for all of the football players.
  			Next it will pass this result to the player_info view (pages/player_info), which will use the ids & names to populate the select tag for a form 
************************************/

// login page 
app.get('/', function(req, res) {
	res.render('pages/login',{
		local_css:"signin.css", 
		my_title:"Login Page"
	});
});

// registration page 
app.get('/register', function(req, res) {
	res.render('pages/register',{
		my_title:"Registration Page"
	});
});

/*Add your other get/post request handlers below here: */

/* PART 3 */
app.get('/home', function(req, res) {
	var query = 'select * from favorite_colors;';
	db.any(query)
        .then(function (rows) {
            res.render('pages/home',{
				my_title: "Home Page",
				data: rows,
				color: '',
				color_msg: ''
			})

        })
        .catch(function (err) {
            console.log('error', err);
            res.render('pages/home', {
                my_title: 'Home Page',
                data: '',
                color: '',
                color_msg: ''
            })
        })
});

app.get('/home/pick_color', function(req, res) {
	var color_choice = req.query.color_selection; // Investigate why the parameter is named "color_selection"
	var color_options = 'SELECT * FROM favorite_colors;';// Write a SQL query to retrieve the colors from the database
	var color_message = 'SELECT color_msg FROM favorite_colors WHERE hex_value = \'' + color_choice + '\';' ;// Write a SQL query to retrieve the color message for the selected color
	
	db.task('get-everything', task => {
        return task.batch([
            task.any(color_options),
            task.any(color_message)
        ]);
    })
    .then(info => {
    	res.render('pages/home',{
				my_title: "Home Page",
				data: info[0],// Return the color options
				color: color_choice,// Return the color choice
				color_msg: info[1][0].color_msg// Return the color message
			})
    })
    .catch(err => {
            console.log('error', err);
            res.render('pages/home', {
                my_title: 'Home Page',
                data: '',
                color: '',
                color_msg: ''
            })
    });

});
	
	app.post('/home/pick_color', function(req, res) {
		var color_hex = req.body.color_hex;
		var color_name = req.body.color_name;
		var color_message = req.body.color_message;
		var insert_statement = 'INSERT INTO favorite_colors VALUES (\''+color_hex+ '\', \'' +color_name+'\', \'' + color_message +'\');';// Write a SQL statement to insert a color into the favorite_colors table
		var color_select = 'SELECT * FROM favorite_colors;';// Write a SQL statement to retrieve all of the colors in the favorite_colors table
		db.task('get-everything', task => {
			return task.batch([
				task.any(insert_statement),
				task.any(color_select)
			]);
		})
		.then(info => {
			res.render('pages/home',{
				my_title: "Home Page",
				data: info[1],// Return the color options
				color: color_hex,// Return the color choice
				color_msg: color_message // Return the color message
			})
		})
		.catch(err => {
				console.log('error', err);
				res.render('pages/home', {
					my_title: 'Home Page',
					data: '',
					color: '',
					color_msg: ''
				})
		});
	});




	/* PART 5 */
	var wins = 0;
	var losses = 0;

	function determineWinner(data) {
		wins = 0;
		losses = 0;
		var winners = [];
			data.forEach(function(item){					
				if (item.home_score > item.visitor_score) {
					winners.push("CU Boulder");
					wins++;
				} else {
					winners.push(item.visitor_name);
					losses++;
				}
			})
		return winners;
	}

	app.get('/team_stats', function(req, res) {
		var getAllData = 'SELECT * FROM football_games ORDER BY game_date;';
		var getBetterDate = 'SELECT to_char(game_date, \'Mon dd, YYYY\') AS date FROM football_games;'
		db.task('get-everything', task => {
			return task.batch([
				task.any(getAllData),
				task.any(getBetterDate)
			]);
		})
		.then(data => {
			res.render('pages/team_stats',{
					my_title: "Season Stats",
					data: data[0],//Return all the information
					betterDate: data[1],
					winner: determineWinner(data[0]),
					wins: wins,
					losses: losses
				})
		})
		.catch(err => {
			// display error message in case an error
				console.log('error', err);
				res.render('pages/team_stats',{
					my_title: "Season Stats",
					data: '',
					betterDate: '',
					winner: '',
					wins: '',
					losses: ''
				})
		});
	});




/* PART 6 */
app.get('/player_info', function(req, res) {
	var getAllData = 'SELECT * FROM football_players;';
	db.task('get-everything', task => {
		return task.batch([
			task.any(getAllData),
		]);
	})
	.then(data => {
		res.render('pages/player_info',{
				my_title: "Season Stats",
				data: data[0]//Return all the information
			})
	})
	.catch(err => {
		// display error message in case an error
			console.log('error', err);
			res.render('pages/player_info',{
				my_title: "Season Stats",
				data: ''
			})
	});
});



app.get('/player_info/post', function(req, res) {
	var choice = req.query.player_choice -1;
	var getAllData = 'SELECT * FROM football_players;';
	var getGamesPlayed = 'SELECT COUNT(*) FROM football_games WHERE (SELECT id FROM football_players WHERE id = \'' + (choice+1) + '\') = ANY(players);';
	db.task('get-everything', task => {
		return task.batch([
			task.any(getAllData),
			task.any(getGamesPlayed)
		]);
	})
	.then(data => {
		res.render('pages/player_info',{
				my_title: "Season Stats",
				data: data[0],//Return all the information
				year: data[0][choice].year,
				major: data[0][choice].major,
				games_played: data[1][0].count,
				passing_yards: data[0][choice].passing_yards,
				rushing_yards: data[0][choice].rushing_yards,
				receiving_yards: data[0][choice].receiving_yards,
				avg_passing: Math.round(data[0][choice].passing_yards/data[1][0].count),
				avg_rushing: Math.round(data[0][choice].rushing_yards/data[1][0].count),
				avg_receiving: Math.round(data[0][choice].receiving_yards/data[1][0].count),
				img: data[0][choice].img_src
			})
		})
	.catch(err => {
		// display error message in case an error
			console.log('error', err);
			res.render('pages/player_info',{
				my_title: "Season Stats",
				data: ''
			})
	});
});

app.listen(3000);
console.log('3000 is the magic port');
