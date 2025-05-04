import cherrypy
import pymysql

# Database connection function
def get_db_connection():
    conn = pymysql.connect(
        host='localhost',
        user='root',
        password='Kelsey2003!',  # Update with your password
        database='my_blog_db',
        cursorclass=pymysql.cursors.DictCursor  # Return rows as dictionaries
    )
    return conn

class BlogPlatform:

    @cherrypy.expose
    def index(self):
        return """
        <h1>Welcome to the Blog Platform</h1>
        <ul>
          <li><a href="/create_post">Create a New Post</a></li>
          <li><a href="/search">Search Posts</a></li>
        </ul>
        """

    @cherrypy.expose
    def create_post(self, title=None, content=None):
        if cherrypy.request.method == 'POST':
            user_id = cherrypy.session.get('user_id', None)
            if not user_id:
                raise cherrypy.HTTPRedirect('/login')

            connection = get_db_connection()
            with connection.cursor() as cursor:
                cursor.execute(
                    "INSERT INTO BlogPosts (user_id, title, content) VALUES (%s, %s, %s)",
                    (user_id, title, content)
                )
                connection.commit()
            connection.close()

            return "Post created successfully! <a href='/'>Go back to homepage</a>"

        return """
        <h2>Create a New Post</h2>
        <form method="POST" action="/create_post">
            <input type="text" name="title" placeholder="Title" required>
            <textarea name="content" placeholder="Content" required></textarea>
            <button type="submit">Create Post</button>
        </form>
        """

    @cherrypy.expose
    def search(self, search_term=None):
        if search_term:
            connection = get_db_connection()
            with connection.cursor() as cursor:
                cursor.execute(
                    "SELECT post_id, title, content FROM BlogPosts WHERE MATCH (title, content) AGAINST (%s IN NATURAL LANGUAGE MODE)",
                    (search_term,)
                )
                posts = cursor.fetchall()
            connection.close()

            if not posts:
                return f"No posts found for '{search_term}'. <a href='/search'>Try another search</a>."

            post_list = "<ul>"
            for post in posts:
                post_list += f"<li><a href='/view_post?post_id={post['post_id']}'>{post['title']}</a>: {post['content'][:100]}...</li>"
            post_list += "</ul>"

            return f"<h2>Search Results for '{search_term}'</h2>{post_list}<a href='/'>Back to homepage</a>"

        return """
        <h2>Search Posts</h2>
        <form method="GET" action="/search">
            <input type="text" name="search_term" placeholder="Enter keywords" required>
            <button type="submit">Search</button>
        </form>
        """

    @cherrypy.expose
    def view_post(self, post_id):
        connection = get_db_connection()
        with connection.cursor() as cursor:
            cursor.execute("SELECT title, content, created_at FROM BlogPosts WHERE post_id = %s", (post_id,))
            post = cursor.fetchone()

            if not post:
                return "Post not found. <a href='/'>Back to homepage</a>"

            cursor.execute("SELECT content, created_at FROM Comments WHERE post_id = %s ORDER BY created_at DESC", (post_id,))
            comments = cursor.fetchall()
        connection.close()

        comment_list = "<ul>"
        for comment in comments:
            comment_list += f"<li>{comment['content']} - {comment['created_at']}</li>"
        comment_list += "</ul>"

        return f"""
        <h2>{post['title']}</h2>
        <p>{post['content']}</p>
        <p>Published on {post['created_at']}</p>
        <h3>Comments</h3>
        {comment_list}
        <form method="POST" action="/add_comment">
            <textarea name="content" placeholder="Add a comment"></textarea>
            <input type="hidden" name="post_id" value="{post_id}">
            <button type="submit">Add Comment</button>
        </form>
        <a href='/'>Back to homepage</a>
        """

    @cherrypy.expose
    def add_comment(self, post_id, content):
        user_id = cherrypy.session.get('user_id', None)
        if not user_id:
            raise cherrypy.HTTPRedirect('/login')

        connection = get_db_connection()
        with connection.cursor() as cursor:
            cursor.execute(
                "INSERT INTO Comments (post_id, user_id, content) VALUES (%s, %s, %s)",
                (post_id, user_id, content)
            )
            connection.commit()
        connection.close()

        raise cherrypy.HTTPRedirect(f"/view_post?post_id={post_id}")

if __name__ == '__main__':
    cherrypy.quickstart(BlogPlatform(), '/', {
        '/': {
            'tools.sessions.on': True
        }
    })
