# Canvas API

## Authorization

Currently, authentication is done through cookies. Except on endpoints that are
not authenticated, command-line access to Canvas is not easily possible.

## Canvas

A canvas is a JSON-backed collaboratively-edited document.

### Attributes

| Name                | Type            | Example | Description |
| ------------------- | --------------- | ------- | ----------- |
| `blocks`            | `Array<Block>`  | `[]` | The list of blocks that the canvas comprises
| `is_template`       | `boolean`       | `true` | Whether the canvas is a template
| `link_access`       | `string`        | `"none"` | `"none"`, `"read"`, or `"edit"`: Policy for what having the link to this canvas allows
| `native_version`    | `string`        | `"1.0.0"` | The version of the Canvas JSON format this canvas uses
| `slack_channel_ids` | `Array<string>` | `["C39F39FHH"]` | An array of Slack channel IDs this Canvas is linked to
| `type`              | `string`        | `http://sharejs.org/types/JSONv0` | The OT type this canvas uses
| `version`           | `number`        | `108` | The OT version of this canvas
| `edited_at`         | `datetime`      | `"2016-11-14T18:30:47.226471Z"` | The time the canvas contents were last edited
| `inserted_at`       | `datetime`      | `"2016-11-14T18:30:47.226471Z"` | The time the canvas was originally created
| `updated_at`        | `datetime`      | `"2016-11-14T18:30:47.226471Z"` | The time the canvas (not content) was last updated

### Show Canvas

View an individual canvas.

#### Example

Requesting a canvas URL will return a detailed JSON view of the requested
canvas.

##### Request

```curl
curl -v https://pro-api.usecanvas.com/v1/teams/usecanvas/canvases/4IuudUOzvCrVdyPbPjGoQo
```

##### Response

<details>
  <summary>Click to Expand</summary>
```curl
< HTTP/1.1 200 OK
< Content-Type: application/json; charset=utf-8
<
{
  "data": {
    "id": "4IuudUOzvCrVdyPbPjGoQo",
    "attributes": {
      "blocks": [{
        "id": "1qxEceffHwfM9VO0u7ASF5",
        "type": "title",
        "content": "TBTS: The Canvas JSON API",
        "blocks": [],
        "meta": {}
      }, {
        "id": "54X2gfbgZQYIVybOEWK0a9",
        "type": "paragraph",
        "content": "Hello, world!",
        "blocks": [],
        "meta": {}
      }],
      "edited_at": "2016-11-14T19:16:08.020000Z",
      "inserted_at": "2016-11-14T18:30:47.226471Z",
      "is_template": false,
      "link_access": "read",
      "native_version": "1.0.0",
      "slack_channel_ids": [],
      "type": "http://sharejs.org/types/JSONv0",
      "updated_at": "2016-11-15T16:21:04.309667Z",
      "version": 1019
    },
    "relationships": {
      "creator": {
        "data": {
          "id": "8efc6684-8742-431f-ac12-e7e5fb805640",
          "type": "user"
        }
      },
      "pulse_events": {
        "links": {
          "related": "/v1/teams/14c06b28-9e58-4597-bbef-c07170fc2e28/canvases/4IuudUOzvCrVdyPbPjGoQo/pulse-events"
        }
      },
      "team": {
        "data": {
          "id": "14c06b28-9e58-4597-bbef-c07170fc2e28",
          "type": "team"
        },
        "links": {
          "related": "/v1/teams/14c06b28-9e58-4597-bbef-c07170fc2e28"
        }
      }  
    },
    "included": [{
      "attributes": {
        "avatar_url": "https://www.gravatar.com/avatar/a9848171873fd66346195ee42df2c16a",
        "email": "max@usecanvas.com",
        "images": {
          "image_192": "https://avatars.slack-edge.com/2014-08-30/2601551525_192.jpg",
          "image_24": "https://avatars.slack-edge.com/2014-08-30/2601551525_24.jpg",
          "image_32": "https://avatars.slack-edge.com/2014-08-30/2601551525_32.jpg",
          "image_48": "https://avatars.slack-edge.com/2014-08-30/2601551525_48.jpg",
          "image_72": "https://avatars.slack-edge.com/2014-08-30/2601551525_72.jpg"
        },
        "inserted_at": "2016-09-19T18:02:59.064498Z",
        "name": "Max Schoening",
        "slack_id": "U02G9LRV3",
        "updated_at": "2016-09-19T18:02:59.064504Z"
      },
      "id": "8efc6684-8742-431f-ac12-e7e5fb805640",
      "relationships": {
        "canvases": {
          "links": {
            "related": "/v1/teams/14c06b28-9e58-4597-bbef-c07170fc2e28/canvases"
          }
        },
        "team": {
          "data": {
            "id": "14c06b28-9e58-4597-bbef-c07170fc2e28",
            "type": "team"
          },
          "links": {
            "related": "/v1/teams/14c06b28-9e58-4597-bbef-c07170fc2e28"
          }
        }
      },
      "type": "user"
    }]
  }
}
```
</details>

#### Markdown Example

Appending a Markdown extension (for example, ".md" or ".txt) will return the
contents of the canvas, formatted as Markdown.

##### Request

```curl
curl https://pro-api.usecanvas.com/v1/teams/usecanvas/canvases/4IuudUOzvCrVdyPbPjGoQo.md
```

##### Response

```curl
< HTTP/1.1 200 OK
< Content-Type: text/plain; charset=utf-8
<
# TBTS: The Canvas JSON API

Hello, world!
```

## Block

A block is a chunk of content in a canvas.

### Attributes

| Name      | Type             | Example | Description |
| --------- | ---------------- | ------- | ----------- |
| `type`    | `string`         | `"title"` | The type of block this block is
| `meta`    | `map`            | `{ "level": 1 }` | A map of metadata about the block, such as indentation level
| `content` | `string` | `nil` | `"Hello, World"` | The text content of the block
| `blocks`  | `Array<Block>`   | `[]` | Blocks nested inside of this block
