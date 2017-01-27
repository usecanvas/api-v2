# CanvasAPI [![CircleCI](https://circleci.com/gh/usecanvas/pro-api.svg?style=svg&circle-token=3bc227708e24ca576bd7b1db5f61a028e1441f39)](https://circleci.com/gh/usecanvas/pro-api) [![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/usecanvas/pro-api/tree/master)

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start Phoenix endpoint with `foreman start -f Procfile.dev`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

## Documentation

- [Internal documentation](https://usecanvas.github.io/pro-api)
- [API documentation](https://github.com/usecanvas/pro-api/blob/master/api.md)

## Tasks

### Personal Access Tokens

To create a personal access token for an umbrella account, provide the domain
and email address of a Slack user tied to that account, or the personal domain
tied to the account:

```sh
mix canvas_api.access_token usecanvas user@example.com
```

Or:


```sh
mix canvas_api.access_token "~personal"
```

Then, use token auth:

```sh
curl https://pro-api.usecanvas.com/v1/teams \
  -H "Authorization: Bearer $token"
```

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
