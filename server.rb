require "sinatra"
require "pg"
require "pry"

set :bind, '0.0.0.0'  # bind to all interfaces

configure :development do
  set :db_config, { dbname: "movies" }
end

configure :test do
  set :db_config, { dbname: "movies_test" }
end
def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get '/actors' do
  db_connection do |conn|
    @actors = conn.exec("SELECT name,id from actors").to_a
  end
  erb :'actors/index'
end

get '/actors/:id' do

  db_connection do |conn|
    @names_titles_characters = conn.exec(
      "SELECT actors.name,movies.title, cast_members.character,movies.id
      FROM cast_members
      JOIN movies
      ON cast_members.movie_id = movies.id
      JOIN actors
      ON cast_members.actor_id = actors.id"
      );


  end
  erb :'actors/show'
end

get '/movies' do
      db_connection do |conn|

        @movies = conn.exec(
        "SELECT movies.id, movies.title,movies.year,movies.rating,genres.name AS genre,studios.name AS studio
        FROM movies
        LEFT JOIN genres
        ON movies.genre_id = genres.id
        LEFT JOIN studios
        ON movies.studio_id = studios.id"
        );

  end
  erb :'movies/index'
end

  get '/movies/:id' do
        db_connection do |conn|
      @movie = conn.exec(
      'SELECT movies.id, movies.title,movies.year,movies.rating,genres.name AS genre,studios.name AS studio, actors.name AS actor, cast_members.character AS character
      FROM movies
      LEFT JOIN genres
      ON movies.genre_id = genres.id
      LEFT JOIN studios
      ON movies.studio_id = studios.id
      LEFT JOIN cast_members
      ON cast_members.movie_id = movies.id
      LEFT JOIN actors
      ON cast_members.actor_id = actors.id
      WHERE movies.id = ($1)',[params[:id].to_i]
      );
    end
    erb :'movies/show'
end
