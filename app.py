import os

os.environ["OAUTHLIB_INSECURE_TRANSPORT"] = "1"
os.environ["OAUTHLIB_RELAX_TOKEN_SCOPE"] = "1"

from waitress import serve
from flask import (
    Flask, render_template, request,
    redirect, session, flash,
    send_from_directory, url_for
)

from flask_dance.contrib.google import (
    make_google_blueprint, google
)

from werkzeug.utils import secure_filename
from config import get_db_connection

# CREATE FLASK APP FIRST
app = Flask(__name__)

app.secret_key = "agriculture_secret_key"

UPLOAD_FOLDER = "static/uploads"
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

google_bp = make_google_blueprint(
    client_id="YOUR_CLIENT_ID",
    client_secret="YOUR_CLIENT_SECRET",
    scope=[
        "openid",
        "https://www.googleapis.com/auth/userinfo.email",
        "https://www.googleapis.com/auth/userinfo.profile"
    ]
)

app.register_blueprint(
    google_bp,
    url_prefix="/google_login"
)

app.secret_key = "agriculture_secret_key"
UPLOAD_FOLDER = "static/uploads"
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

# -------------------------
# LOGIN
# -------------------------
@app.route("/", methods=["GET", "POST"])
def login():

    if request.method == "POST":

        username = request.form["username"]
        password = request.form["password"]

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            "SELECT * FROM users WHERE username=%s",
            (username,)
        )

        user = cursor.fetchone()

        if user and user["password"] == password:

            session["user_id"] = user["id"]
            session["fullname"] = user["fullname"]
            session["role"] = user["role"]

            # Activity Log
            cursor.execute(
                """
                INSERT INTO activity_logs
                (user_id, action, description)
                VALUES (%s, %s, %s)
                """,
                (
                    user["id"],
                    "LOGIN",
                    "User Logged In"
                )
            )

            conn.commit()

            cursor.close()
            conn.close()

            return redirect("/dashboard")

        cursor.close()
        conn.close()

        flash("Invalid Username or Password")

    return render_template("login.html")
# -------------------------
# DASHBOARD
# -------------------------
@app.route("/dashboard")
def dashboard():

    if "user_id" not in session:
        return redirect("/")

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT COUNT(*) total FROM documents")
    total_documents = cursor.fetchone()["total"]

    cursor.execute(
        "SELECT COUNT(*) total FROM documents WHERE status='Active'"
    )
    active_documents = cursor.fetchone()["total"]

    cursor.execute(
        "SELECT COUNT(*) total FROM documents WHERE status='Archived'"
    )
    archived_documents = cursor.fetchone()["total"]

    cursor.execute("SELECT COUNT(*) total FROM users")
    total_users = cursor.fetchone()["total"]

    cursor.close()
    conn.close()

    return render_template(
        "dashboard.html",
        total_documents=total_documents,
        active_documents=active_documents,
        archived_documents=archived_documents,
        total_users=total_users
    )
    
@app.route("/users")
def users():

    if "user_id" not in session:
        return redirect("/")

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM users")

    users = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template(
        "users.html",
        users=users
    )
    
@app.route("/activity_logs")
def activity_logs():

    if "user_id" not in session:
        return redirect("/")

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT activity_logs.*,
               users.fullname
        FROM activity_logs
        LEFT JOIN users
        ON activity_logs.user_id = users.id
        ORDER BY activity_logs.id DESC
    """)

    logs = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template(
        "activity_logs.html",
        logs=logs
    )
    
@app.route("/documents")
def documents():

    if "user_id" not in session:
        return redirect("/")

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT documents.*,
               categories.category_name
        FROM documents
        LEFT JOIN categories
        ON documents.category_id = categories.id
        ORDER BY documents.id DESC
    """)
    documents = cursor.fetchall()

    cursor.execute("""
        SELECT *
        FROM categories
        ORDER BY category_name
    """)
    categories = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template(
        "documents.html",
        documents=documents,
        categories=categories
    )
    
@app.route("/upload_document", methods=["POST"])
def upload_document():

    if "user_id" not in session:
        return redirect("/")

    file = request.files["file"]

    if file and file.filename:

        filename = secure_filename(file.filename)

        file.save(
            os.path.join(
                app.config["UPLOAD_FOLDER"],
                filename
            )
        )

        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("""
    INSERT INTO documents
    (
        document_no,
        title,
        category_id,
        filename,
        original_filename,
        status,
        uploaded_by
    )
    VALUES (%s,%s,%s,%s,%s,%s,%s)
""",
(
    request.form["document_no"],
    request.form["title"],
    request.form["category_id"],
    filename,
    file.filename,
    "Active",
    session["user_id"]
))
        
        # Activity Log - Upload Document
    cursor.execute("""
    INSERT INTO activity_logs
    (user_id, action, description)
    VALUES (%s, %s, %s)
""",
(
    session["user_id"],
    "UPLOAD",
    f"Uploaded document: {request.form['title']}"
))
    
    cursor.execute("""
    INSERT INTO activity_logs
    (user_id, action, description)
    VALUES (%s,%s,%s)
""",
(
    session["user_id"],
    "UPLOAD",
    f"Uploaded document: {request.form['title']}"
))

    conn.commit()

    cursor.close()
    conn.close()

    flash("Document uploaded successfully.")

    return redirect("/documents")

@app.route("/download/<int:document_id>")
def download_document(document_id):

    if "user_id" not in session:
        return redirect("/")

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT * FROM documents WHERE id=%s",
        (document_id,)
    )

    document = cursor.fetchone()

    cursor.close()
    conn.close()

    if not document:
        flash("Document not found.")
        return redirect("/documents")

    return send_from_directory(
        app.config["UPLOAD_FOLDER"],
        document["filename"],
        as_attachment=True
    )
    
@app.route("/logout")
def logout():

    if "user_id" in session:

        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO activity_logs
            (user_id, action, description)
            VALUES (%s, %s, %s)
        """,
        (
            session["user_id"],
            "LOGOUT",
            "User Logged Out"
        ))

        conn.commit()

        cursor.close()
        conn.close()

    session.clear()

    return redirect("/")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)