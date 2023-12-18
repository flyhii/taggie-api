# Taggie Web API

Web API that finds the top 3 most relevant and popular hashtags on Instagram associated with the user-entered hashtag.

## Routes

`GET /`

Status:

- 200: API server running (happy)

### Search for a specific hashtag

`GET /hashtags/{hashtag_name}/]`

Status

- 200: posts returned (happy)
- 404: hashtags or posts not found (sad)
- 500: problems finding or getting hashtags or posts (bad)

### Store related posts for ranking

`POST /hashtags/{hashtag_name}`

Status

- 201: posts stored (happy)
- 404: hashtags or posts not found on Instagram (sad)
- 500: problems storing those posts (bad)