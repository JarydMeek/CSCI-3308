#testing open read write close functionality - not done yet. Tested using an sqqlite3 func w solely one table.

import click
from flask import current_app, g
from flask.cli import with_appcontext


def raccdb():
    if 'db' not in g:
        g.db = sqlite3.connect(
            current_app.config['DATABASE'],
            detect_types=sqlite3.PARSE_DECLTYPES
        )
        g.db.row_factory = sqlite3.Row

    return g.db


def caccdb(e=None):
    db = g.pop('db', None)

    if db is not None:
        db.close()


def reading():
    names = [g.db.row_factory[0] for row_factory in cursor.row_factory]
    print(f"listing rows {names}")

def writing():
    rowappend  = 'INSERT testing into rowtesting'
    cur = g.db.cursor()
    cur.execute(sql, rowappend)
    g.db.commit()

def main():
    database = r"C:\sqlite\db\pythonsqlite.db"

    # create a database connection
    g.db = raccdb(database)
    with g.db:
        # create a new project
        project = writing('sqllitetesting');
        project_id = create_project(conn, project)

        # tasks
        task_1 = ('testing, testing')
        task_2 = ('1, 2')

        # create tasks
        writing(g.db, task_1)
        writing(g.db, task_2)