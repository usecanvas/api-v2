# CanvasAPI

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start Phoenix endpoint with `foreman start`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

## Tasks

### Importing/Updating Templates

A template may be imported using the command line if it is in the ".canvas"
format (meaning that it has a top-level "blocks" key, not "attributes.blocks"
as in JSON API.

```sh
mix canvas_api.import_templates $URL1 $URL2 $URL3
```

Or, for a Heroku app:

```sh
herkou run -a canvas-pro-api-prod \
  mix canvas_api.import_templates $URL1 $URL2 $URL3
```

Note that if the JSON from the URL contains an "ID" key, **the canvas or
template with that ID will be replaced with the new contents**. This allows
for the updating of templates. If you want to create a new template from an
existing canvas, **make sure to strip the ID out of the JSON**.
