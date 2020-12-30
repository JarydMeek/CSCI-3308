#The file that feeds information between swift code, html files, and our database

# My dearest Elena,
#   Here is my list I am making as I go for the items I wish for you to accomplish.
# 1. Fix my login page                                      ??
# 2. make better logout option in navbar (on right?)        yep!!
# 3. no navbar in create account or logon                   seems done
# 4. navbar order- profile, add route, leaderboard          done
# 5. make colors match app? if time, not necessary          pretty much I think
# 6. addroute does not need add account option, no username email or password entry (will already be logged in when used), add date option though, but idk how jaryd did that so
# 
# 
# 
# 
# 
# My to do list
# login function ---------------
# edit add route, no username or anything used, add date ------------------------------ not html edited yet
# logout function
# where to save user token after login----?
# populate profile page.

import os                           # Imports of all needed libraries
import secrets
import hashlib 
from flask import jsonify

from datetime import datetime
from flask import Flask
from flask import render_template
from flask import request
from flask import redirect
from flask import session            #needs to run pip or easy_install Flask-Session
from flask_session import Session
from flask import flash
from sqlalchemy import func

from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import desc


# Site Used as Guide: https://www.codementor.io/@garethdwyer/building-a-crud-application-with-flask-and-sqlalchemy-dm3wv7yu2

# To Run Code on Personal Machine (For Team):
# Have Python Installed
# Run on command line (not in Python): pip3 install --user flask sqlalchemy flask-sqlalchemy
        # Installs required libraries
# Run in Python in same directory as integration.py: from integrationLayer import db
# Run in Python in same directory as integration.py: db.create_all()
# Run in Python in same directory as integration.py: exit()
        # Creates temporary database for storage DO NOT PUSH THE CREATED FILE TO GITHUB
# Run on command line (not in Python): python integrationLayer.py
    # If this does not work you may need to run: python3 integrationLayer.py
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

SESSION_TYPE = 'filesystem'
app.config.from_object(__name__)
Session(app)

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
    date = db.Column(db.DateTime, unique=False, nullable=True, primary_key=False)


def passHash(input):
    salt = "6MgRphZeod2dbGpiRGmhroEmkj66oQVf"

    prepareHash = input + "." + salt
    result = hashlib.sha256(prepareHash.encode()) 

    print(result)
    return str(result.hexdigest())



# Home page when loaded, as well as the Code for adding a route
# Will throw an error to user until account is created
@app.route("/", methods=["GET", "POST"])
def home():
    if request.form:
        inputuser = request.form.get("userin")
        find = Login.query.filter_by(user=inputuser).first()
        if find == None:
            flash("Username Not Valid")
            return render_template("login.html")
        elif find.password != passHash(request.form.get("passin")):
            flash("Incorrect Password")
            return render_template("login.html")
        else:
            session['curid'] = find.token
            return Profile()
    else:
        return render_template("login.html")

#@app.route("/newroute", methods=["GET", "POST"])
#def newroute(): 
#    if request.form:
#        newroute = Route(route_id=get_idroute(), distance=request.form.get("distance"), about=request.form.get("routeInfo"), rate=request.form.get("radiob"), useradded=request.form.get("username"))
#        db.session.add(newroute)
#        db.session.commit()
#    return render_template("addroute.html")


# Redirects when Create Account button OR nav bar link is hit
@app.route("/NewAccount", methods=["GET","POST"])
def NewAccount():
    if request.form:
        try:
            tok = Login.query.count() + 1
            addAccount = Login(token=tok, user=request.form.get("newUsername"), email=request.form.get("newEmail"), password=passHash(request.form.get("newPassword")))
            db.session.add(addAccount)
            db.session.commit()
            return render_template("login.html")
            #return home()
        except Exception as e:
            flash("Failed to Create Account")
            print(e)
            return render_template("addaccount.html")
    else:
        return render_template("addaccount.html")


# Redirects when Enter Data nav bar link is hit
@app.route("/AddRoute", methods=["GET","POST"])
def AddRoute():
    if request.form:
        try:
            useid = session.get('curid')
            date = request.form.get("date")
            processedDate = datetime.strptime(date, '%m/%d/%y')
            currentuser = Login.query.filter_by(token=useid).first()
            use = currentuser.user
            newroute = Route(route_id=Route.query.count() + 1, distance=request.form.get("distance"), about=request.form.get("routeInfo"), rate=request.form.get("radiob"), useradded=use, date = processedDate)
            db.session.add(newroute)
            db.session.commit()
        except Exception as e:
            flash("Could not save route")
            print(e)
    return render_template("addroute.html")

# Redirects when Leaderboard nav bar link is hit
@app.route("/Leaderboard", methods=["GET","POST"])
def Leaderboard():
    top = db.session.query(Route.useradded, func.sum(Route.distance).label('tot')).group_by(Route.useradded).order_by(func.sum(Route.distance).desc()).limit(15)
    return render_template("leaderboard.html", top=top)


# Redirects when Profile nav bar link is hit
@app.route("/Profile", methods=["GET","POST"])
def Profile():
    useid = session.get('curid')
    userinfo = Login.query.filter_by(token=useid).first()
    puser = userinfo.user
    pemail = userinfo.email
    routesran = Route.query.filter_by(useradded=puser)
    return render_template("profile.html", puser = puser, pemail = pemail, routesran = routesran)

@app.route("/Logout", methods=["GET", "POST"])
def Logout():
    session['curid'] = -1
    return home()


# Creates account, throws an arror if Username or Email already exists
# If created sucessfully, redirects to Add Route page
#@app.route("/accountCreate", methods=["GET", "POST"])
#def newaccount():
#    if request.form:
#        try:
#            tok = get_token()
#            addAccount = Login(token=tok, user=request.form.get("newUsername"), email=request.form.get("newEmail"), password=request.form.get("newPassword"))
#            db.session.add(addAccount)
#            db.session.commit()
#            return render_template("addaccount.html")
#        except Exception as e:
#            flash("Failed to Create Account")
#            print(e)
#            return render_template("addaccount.html")




#@app.route("/userRoutes", methods=["GET", "POST"])
#def userRoutes(username):
#    userRouteList = Route.query.filter_by(useradded=username)
#    return render_template("" userRouteList = userRouteList)




#IOS APP ACCESS

@app.route("/mobile/login", methods=["GET", "POST"])
def login():
    if request.form:
        inputuser = request.form.get("username")
        find = Login.query.filter_by(user=inputuser).first()
        if find == None:
            return "-1"
        elif find.password != request.form.get("password"):
            return "-2"
        else:
            print(find.token)
            return str(find.token)
    else:
        return "-1"

@app.route("/mobile/addroute", methods=["GET", "POST"])
def addroute(): 
    if request.form:
        #inputuser = request.form.get("username")
        #inputemail = request.form.get("email")
        #inputpassword = request.form.get("password")
        #found = verify(inputuser, inputemail, inputpassword)
        #if found != -1:
        try:
            date = request.form.get("date")
            processedDate = datetime.strptime(date, '%m/%d/%y %H:%M:%S')
            newroute = Route(route_id=Route.query.count() + 1, distance=request.form.get("distance"), about=request.form.get("routeInfo"), rate=request.form.get("radiob"), useradded=request.form.get("username"), date = processedDate)
            db.session.add(newroute)
            db.session.commit()
            return "True"
        except Exception as e:
            flash("Could not save route")
            print(e)
            return "False"


@app.route("/mobile/accountCreate", methods=["GET", "POST"])
def newaccountmobile():
    if request.form:
        try:
            tok = Login.query.count() + 1
            addAccount = Login(token=tok, user=request.form.get("newUsername"), email=request.form.get("newEmail"), password=request.form.get("newPassword"))
            db.session.add(addAccount)
            db.session.commit()
            return str(tok)
        except Exception as e:
            flash("Failed to Create Account")
            print(e)
            return "-1"

@app.route("/mobile/leaderboard", methods=["GET","POST"])
def mobileLeaderboard():
    top = db.session.query(Route.useradded, func.sum(Route.distance).label('tot')).group_by(Route.useradded).order_by(func.sum(Route.distance).desc()).limit(15)
    all_users = [{'username':user.useradded,'distance':user.tot} for user in top]
    return jsonify(all_users)

@app.route("/mobile/routes", methods=["GET","POST"])
def mobileRoute():
    if request.form:
        userRouteList = Route.query.filter_by(useradded=request.form.get("username"))
        allroutes = [{'route_name':route.about,'distance':route.distance, 'date':route.date} for route in userRouteList]
        return jsonify(allroutes)
    else:
        return jsonify(error='err')


# For Debug
if __name__ == "__main__":
    #app.run(debug= True)
    app.run(host= '0.0.0.0')
