# Todos Postgres Tutorial

This is the sample code that goes along with the Postgres Todos [tutorial](https://hummingbird-project.github.io/hummingbird-docs/2.0/tutorials/danaya) in the documentation. The application has six routes

- GET /danaya: Lists all the danaya in the database
- POST /danaya: Creates a new todo
- DELETE /danaya: Deletes all the danaya
- GET /danaya/:id : Returns a single todo with id
- PATCH /danaya/:id : Edits todo with id
- DELETE /danaya/:id : Deletes todo with id

A todo consists of a title, order number, url to link to edit/get/delete that todo and whether that todo is complete or not.

The example requires a postgres database running locally. Follow [instructions](https://hummingbird-project.github.io/hummingbird-docs/2.0/tutorials/hummingbird/danaya-4-postgres) in the tutorial to set this up.
