from flask import Flask, render_template, request, redirect, url_for
from flask import flash, session, send_file
from flask_mysqldb import MySQL
from werkzeug.security import generate_password_hash
from werkzeug.security import check_password_hash
from werkzeug.utils import secure_filename
import os

app = Flask(__name__)

app.secret_key = "dms_secret_key"

# MySQL Configuration
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''
app.config['MYSQL_DB'] = 'dms_db'

mysql = MySQL(app)

UPLOAD_FOLDER = 'static/uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def log_activity(user_id, username, action,
                 document_id=None,
                 document_title=None):

    cur = mysql.connection.cursor()

    cur.execute("""
        INSERT INTO activity_logs
        (user_id,username,action,
         document_id,document_title,
         ip_address)
        VALUES(%s,%s,%s,%s,%s,%s)
    """,(
        user_id,
        username,
        action,
        document_id,
        document_title,
        request.remote_addr
    ))

    mysql.connection.commit()
    
@app.route('/register', methods=['GET','POST'])
def register():

    if request.method == 'POST':

        fullname = request.form['fullname']
        username = request.form['username']
        email = request.form['email']
        password = generate_password_hash(
            request.form['password']
        )

        cur = mysql.connection.cursor()

        cur.execute("""
            INSERT INTO users
            (fullname,username,email,password)
            VALUES(%s,%s,%s,%s)
        """,(fullname,username,email,password))

        mysql.connection.commit()

        flash("Registration Successful")

        return redirect(url_for('login'))

    return render_template('register.html')

@app.route('/', methods=['GET','POST'])
@app.route('/login', methods=['GET','POST'])
def login():

    if request.method == 'POST':

        username = request.form['username']
        password = request.form['password']

        cur = mysql.connection.cursor()

        cur.execute(
            "SELECT * FROM users WHERE username=%s",
            [username]
        )

        user = cur.fetchone()

        if user:

            if check_password_hash(
                user[4],
                password
            ):

                session['user_id'] = user[0]
                session['username'] = user[2]
                session['role'] = user[5]

                log_activity(
                    user[0],
                    user[2],
                    "User Logged In"
                )

                return redirect(url_for('dashboard'))

        flash("Invalid Username or Password")

    return render_template('login.html')

@app.route('/dashboard')
def dashboard():

    cur = mysql.connection.cursor()

    cur.execute(
        "SELECT COUNT(*) FROM documents"
    )
    total_docs = cur.fetchone()[0]

    cur.execute(
        "SELECT COUNT(*) FROM users"
    )
    total_users = cur.fetchone()[0]

    cur.execute("""
        SELECT username,action,activity_time
        FROM activity_logs
        ORDER BY id DESC
        LIMIT 10
    """)

    logs = cur.fetchall()

    return render_template(
        'dashboard.html',
        total_docs=total_docs,
        total_users=total_users,
        logs=logs
    )
    
@app.route('/upload_document', methods=['GET', 'POST'])
def upload_document():

    if 'user_id' not in session:
        return redirect(url_for('login'))

    cur = mysql.connection.cursor()

    if request.method == 'POST':

        title = request.form['title']
        description = request.form['description']
        category_id = request.form['category_id']

        file = request.files['document']

        if file and file.filename != '':

            filename = secure_filename(file.filename)

            filepath = os.path.join(
                app.config['UPLOAD_FOLDER'],
                filename
            )

            file.save(filepath)

            cur.execute("""
                INSERT INTO documents
                (title,description,category_id,
                 file_name,file_path,uploaded_by)
                VALUES(%s,%s,%s,%s,%s,%s)
            """,
            (
                title,
                description,
                category_id,
                filename,
                filepath,
                session['user_id']
            ))

            mysql.connection.commit()

            document_id = cur.lastrowid

            log_activity(
                session['user_id'],
                session['username'],
                "Uploaded Document",
                document_id,
                title
            )

            flash("Document uploaded successfully")

            return redirect(url_for('documents'))

    cur.execute("SELECT * FROM categories")
    categories = cur.fetchall()

    return render_template(
        'upload_document.html',
        categories=categories
    )
    
@app.route('/documents')
def documents():

    if 'user_id' not in session:
        return redirect(url_for('login'))

    cur = mysql.connection.cursor()

    cur.execute("""
        SELECT d.id,
               d.title,
               d.description,
               c.category_name,
               d.file_name,
               d.upload_date
        FROM documents d
        LEFT JOIN categories c
        ON d.category_id = c.id
        ORDER BY d.id DESC
    """)

    documents = cur.fetchall()

    return render_template(
        'documents.html',
        documents=documents
    )
    
@app.route('/download/<int:id>')
def download_document(id):

    if 'user_id' not in session:
        return redirect(url_for('login'))

    cur = mysql.connection.cursor()

    cur.execute("""
        SELECT file_path,title
        FROM documents
        WHERE id=%s
    """, [id])

    document = cur.fetchone()

    if document:

        log_activity(
            session['user_id'],
            session['username'],
            "Downloaded Document",
            id,
            document[1]
        )

        return send_file(
            document[0],
            as_attachment=True
        )

    flash("Document not found")
    return redirect(url_for('documents'))

@app.route('/delete_document/<int:id>')
def delete_document(id):

    if 'user_id' not in session:
        return redirect(url_for('login'))

    if session['role'] != 'admin':
        flash("Access Denied")
        return redirect(url_for('documents'))

    cur = mysql.connection.cursor()

    cur.execute("""
        SELECT title
        FROM documents
        WHERE id=%s
    """, [id])

    doc = cur.fetchone()

    if doc:

        cur.execute(
            "DELETE FROM documents WHERE id=%s",
            [id]
        )

        mysql.connection.commit()

        log_activity(
            session['user_id'],
            session['username'],
            "Deleted Document",
            id,
            doc[0]
        )

    flash("Document deleted")

    return redirect(url_for('documents'))

@app.route('/logout')
def logout():

    if 'user_id' in session:

        log_activity(
            session['user_id'],
            session['username'],
            "User Logged Out"
        )

    session.clear()

    return redirect(url_for('login'))

@app.route('/activity_logs')
def activity_logs():

    if 'user_id' not in session:
        return redirect(url_for('login'))

    cur = mysql.connection.cursor()

    cur.execute("""
        SELECT username,
               action,
               document_title,
               ip_address,
               activity_time
        FROM activity_logs
        ORDER BY id DESC
    """)

    logs = cur.fetchall()

    return render_template(
        'activity_logs.html',
        logs=logs
    )
    
if __name__ == "__main__":
    app.run(debug=True)