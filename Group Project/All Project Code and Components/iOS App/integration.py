import os                           # Imports of all needed libraries
import secrets

from flask import Flask
from flask import render_template
from flask import request
from flask import redirect
from flask import g
from flask import flash

from flask_sqlalchemy import SQLAlchemy

# Site Used as Guide: https://www.codementor.io/@garethdwyer/building-a-crud-application-with-flask-and-sqlalchemy-dm3wv7yu2

# To Run Code on Personal Machine (For Team):
# Have Python Installed
# Run on command line (not in Python): pip3 install --user flask sqlalchemy flask-sqlalchemy
        # Installs required libraries
# Run in Python in same directory as integration.py: from integration import db
# Run in Python in same directory as integration.py: db.create_all()
# Run in Python in same directory as integration.py: exit()
        # Creates temporary database for storage DO NOT PUSH THE CREATED FILE TO GITHUB
# Run on command line (not in Python): python integration.py
    # If this does not work you may need to run: python3 integration.py
# In terminal follow link saying: * Running on http://(a series of numbers here)
        # This will take you to the html page where you will first have to hit create account.
        # This is not online, just hosted on your device and run in the browser
# Be sure to kill the program (CTRL+C in terminal) at which point the site will no longer be found

# Side Note: if you are getting "problems" on the db.Column and all of those, it is not an error bur rather an issue with Pylint and VSCode


# Connecting to db
project_dir = os.path.dirname(os.path.abspath(__file__))
database_file = "sqlite:///{}".format(os.path.join(project_dir, "tempinitial.db"))

# Forming app and secret token, finish connecting to database
app = Flask(__name__)
secret = secrets.token_urlsafe(32)

app.secret_key = secret
app.config["SQLALCHEMY_DATABASE_URI"] = database_file


# Define database to add tables too
db = SQLAlchemy(app)


# Definition of the Two tables created and the Columns inside
class Login(db.Model):
    token = db.Column(db.Integer, unique=True, nullable=False, primary_key=True)
    user = db.Column(db.String(80), unique=True, nullable=False, primary_key=False)
    email = db.Column(db.String(80), unique=True, nullable=False, primary_key=False)
    password = db.Column(db.String(80), unique=False, nullable=False, primary_key=False)


class Route(db.Model):
    route_id = db.Column(db.Integer, unique=True, nullable=False, primary_key=True)
    distance = db.Column(db.Float, unique=False, nullable=True, primary_key=False)
    about = db.Column(db.String(500), unique=False, nullable=True, primary_key=False)
    rate = db.Column(db.Integer, unique=False, nullable=False, primary_key=False)
    useradded = db.Column(db.String(80), unique=False, nullable=False, primary_key=False)


# Creation of Global Variables for indexing
def get_idroute():
    g.idroute = Route.query.count() + 1
    return g.idroute

def get_token():
    g.token = Login.query.count() + 1
    return g.token



# Home page when loaded, as well as the Code for adding a route
# Will throw an error to user until account is created
@app.route("/", methods=["GET", "POST"])
def home(): 
    if request.form:
        inputuser = request.form.get("username")
        inputemail = request.form.get("email")
        inputpassword = request.form.get("password")
        found = verify(inputuser, inputemail, inputpassword)
        if found == True:
            newroute = Route(route_id=get_idroute(), distance=request.form.get("distance"), about=request.form.get("routeInfo"), rate=request.form.get("radiob"), useradded=request.form.get("username"))
            db.session.add(newroute)
            db.session.commit()
    return "Success"

def verify(verifyUsername, verifyEmail, verifyPassword):
    find = Login.query.filter_by(user=verifyUsername).first()
    if find == None:
        flash("Username Not Valid")
        return False
    elif find.email != verifyEmail:
        flash("Email not valid")
        return False
    elif find.password != verifyPassword:
        flash("Incorrect Password")
        return False
    else:
        return True



# Redirects when Create Account button is hit
@app.route("/redirectPage", methods=["GET","POST"])
def redirectPage():
    return render_template("tempcreatelogin.html")


# Creates account, throws an arror if Username or Email already exists
# If created sucessfully, redirects to Add Route page
@app.route("/accountCreate", methods=["GET", "POST"])
def newaccount():
    if request.form:
        try:
            addAccount = Login(token=get_token(), user=request.form.get("newUsername"), email=request.form.get("newEmail"), password=request.form.get("newPassword"))
            db.session.add(addAccount)
            db.session.commit()
            return "Success"
        except Exception as e:
            flash("Failed to Create Account")
            print(e)
            return "Failed"


# For Debug
if __name__ == "__main__":
    app.run(debug=True)