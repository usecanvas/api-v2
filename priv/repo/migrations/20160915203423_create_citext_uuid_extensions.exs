defmodule CanvasAPI.Repo.Migrations.CreateCitextUuidExtensions do
  use Ecto.Migration

   def up do
     execute ~s(CREATE EXTENSION IF NOT EXISTS "uuid-ossp")
     execute ~s(CREATE EXTENSION IF NOT EXISTS "citext")
   end

   def down do
     execute ~s(-- Not Dropping "uuid-ossp" or "citext" extensions)
   end
 end
