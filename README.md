# Canvas API [![CircleCI][circle_ci_badge]][circle_ci_url] [![Deploy][heroku_button_svg]][heroku_deploy]

This is the Canvas API, which provides an HTTP interface to Canvas resources,
as well as event notifications over WebSockets.

## Dependencies

  - **PostgreSQL**: The API stores data in PostgreSQL.
  - **Redis**: Redis is used for API's worker queue and for event broadcasting.

### Slack OAuth

Canvas uses Slack for OAuth authentication. In order to run API, you will need
to [create a new Slack API app][slack_api_apps]. The client ID and secret for
this app should be set as `SLACK_CLIENT_ID` and `SLACK_CLIENT_SECRET` in the app
environment.

Next, you'll want to set the redirect URLs for your Slack app, which should
be the same as your `REDIRECT_URI` and `ADD_TO_SLACK_REDIRECT_URI` environment
variables.

Also, you'll want to enable events for your Slack app (this should point to
`protocol://host/webhooks/slack` with the `message.channels` subscription.
Once this is enabled, get your verification token from the app credentials
section of the Slack app admin interface and set it as
`SLACK_VERIFICATION_TOKEN`.

Finally, enable a bot user for your Slack app.

### GitHub

Canvas uses GitHub OAuth to unfurl GitHub links in Canvases, as well as to add
events to canvas event pulses when canvases are mentioned in GitHub.

For the OAuth part, simply create a GitHub OAuth application and set the
`GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` environment variables.
The callback URL for the app should look like
`protocol://host/oauth/github/callback`.

Webhooks currently have to be created manually on a per-org basis. Your
webhook's URL should look like
`protocol://host/webhooks/github?team.domain=teamdomain&team.id=teamid` with
an `application/json` content type. The individual events to listen on would be
"Commit comment", "Issue comment", "Issues, "Pull request", "Pull request
review", "Pull request review comment", and "Push".

Make sure and set the webhook secret as `GITHUB_VERIFICATION_TOKEN`.

### Embedly

Canvas uses the Embedly API in order to unfurl links in canvases. Set an Embedly
API key as `EMBEDLY_API_KEY`.

## Running on Heroku

Canvas API should be the first Canvas app deployed. Use the Heroku button in
this README and fill in environment variables appropriately.

## Importing/Updating Templates

A global template may be imported using the command line if it is in the
".canvas" format (meaning that it has a top-level "blocks" key, not
"attributes.blocks" as in JSON API.

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

[circle_ci_badge]: https://circleci.com/gh/usecanvas/pro-api.svg?style=svg&circle-token=3bc227708e24ca576bd7b1db5f61a028e1441f39
[circle_ci_url]: https://circleci.com/gh/usecanvas/pro-api
[heroku_button_svg]: https://www.herokucdn.com/deploy/button.svg
[heroku_deploy]: https://heroku.com/deploy?template=https://github.com/usecanvas/pro-api
[slack_api_apps]: https://api.slack.com/apps
