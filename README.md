# @jvlk/rescript-remix

ReScript bindings, modules, and functions for Remix.

Requires ReScript v11.

> This is a work in progress and is not complete

## Installation

```sh
npm install @jvlk/rescript-remix
```
Update `rescript.json` to include it in your dependencies.
```json
"bs-dependencies": [
   "@jvlk/rescript-remix"
],
```
If you want to have `.res` files directly in the `app/routes` directory you will need to set the file extension to `.jsx` in `rescript.json`.

> Note: ReScript does not allow you to have `$` in file names so you will need to create a JavaScript file for routes with params such as `blog/$id.jsx` and import from your generated JavaScript files.

Add ReScript extenstions to Remix's ignored files so it doesn't try and load them in as routes and uses the generated `.jsx` files.
```js
// remix.config.js
export default {
    ignoredRouteFiles: ["**/.*", "**/*.res", "**/*.resi"],
}
```
## `root.js`
You can add types to Remix's links and meta functions
```rescript
@module("./style.css")
external styles: string = "default"

let links: Remix.Links.t = () => [Remix.Links.Href({rel: "stylesheet", href: styles})]

let meta: Remix.Meta.t = () => [
  Remix.Meta.Content({name: "viewport", content: "width=device-width, initial-scale=1"}),
  Remix.Meta.Title({title: "My site"}),
  Remix.Meta.Content({
    name: "description",
    content: "a website",
  }),
  Remix.Meta.Charset({charset: "UTF-8"}),
]

@react.component
let make = () => {
  <html lang="en">
    <head>
      <link rel="icon" href="data:image/x-icon;base64,AA" />
      <Remix.Meta />
      <Remix.Links />
    </head>
    <body>
      <main>
        <Remix.Outlet />
      </main>
      <Remix.Scripts />
      <Remix.LiveReload />
    </body>
  </html>
}

let default = make
```

## Loader
To create a typed [loader](https://remix.run/docs/en/main/route/loader) you can use `Remix.MakeLoader` higher order module (functor). This will create a type for a loader as well as a typed `useLoaderData` hook that has a typed response.

```rescript
// _index.res
module Data = {
  type t = {posts: Posts.t} // type for the data returned by the loader
  type params // route params
  type context = { "NODE_ENV": string, "API_KEY": string } // context passed from the server
}

module Loader = Remix.MakeLoader(Data) // create a Loader module for this route

let loader: Loader.t /** use Loader.t to add typing to the exported loader function */= async ({context}) => {
  let secret = context["API_KEY"]
  let data = await Posts.query(secret)
  Loader.json( // this is Remix's json function typed to Data.t
    {posts: data}, // if this doesn't match Data.t you'll get a type error
    ~jsonOptions={ 
      headers: { // you can add headers to the response
        "Cache-Control": "max-age=300, s-maxage=3600",
      },
    },
  )
}

@react.component
let make = () => {
  let {posts} = Loader.useLoaderData() // the data from the hook is fully typed
  <div>
    {posts
    ->Array.map(post => <Post post />)
    ->React.array}
  </div>
}

let default = make // you have to export make as default for route files
```

## Actions
To create an action you can use `Remix.MakeAction`.

```remix
module ActionData = {
  type t
  type context = Env.context
}

module Action = Remix.MakeAction(ActionData)

let action: Action.t = async ({context, request}) => {
    /** */
    Js.null // actions expect you to return a value or null
}
```