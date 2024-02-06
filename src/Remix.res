module Scripts = {
  /** 
   This component renders the client runtime of your app. You should render it inside the `<body>` of your HTML, usually in app/root.tsx.
  ```rescript
    // app/root.res
    @react.component
    let make = () {
      <html>
        <head />
        <body>
          <Remix.Scripts />
        </body>
      </html>
    }

    let default = make
  ```
   If you don't render the `<Scripts/>` component, your app will still work like a traditional web app without JavaScript, relying solely on HTML and browser behaviors.
   https://remix.run/docs/en/main/components/scripts 
   */
  @module("@remix-run/react")
  @react.component
  external make: unit => React.element = "Scripts"
}

module Links = {
  /** 
   The `<Links/>` component renders all of the `<link>` tags created by your route module links export. You should render it inside the `<head>` of your HTML, usually in app/root.tsx.
   
   ```rescript
  // app/root.res
  @react.component
  let make = () => {
      <html>
        <head>
          <Remix.Links />
        </head>
        <body></body>
      </html>
  }
  
  let default = make
   ```
   https://remix.run/docs/en/main/components/links 
   */
  @module("@remix-run/react")
  @react.component
  external make: unit => React.element = "Links"

  type link = | @unboxed Href({rel: string, href: string})
  // for links export
  type t = unit => array<link>
}

module LiveReload = {
  @module("@remix-run/react") @react.component
  external make: unit => React.element = "LiveReload"
}

module Meta = {
  @module("@remix-run/react") @react.component
  external make: unit => React.element = "Meta"

  type meta =
    | @unboxed Content({name: string, content: string})
    | @unboxed Title({title: string})
    | @unboxed Charset({charset: string})

  type t = unit => array<meta>
}

module Outlet = {
  @module("@remix-run/react") @react.component
  external make: unit => React.element = "Outlet"
}

module Headers = {
  type actionHeaders
  type errorHeaders
  type loaderHeaders<'a> = {..} as 'a
  type parentHeaders

  //  {...loaderHeaders, "Cache-Control": string}
  type headers<'a> = {..} as 'a

  type headersArgs<'a> = {actionHeaders?: actionHeaders, loaderHeaders?: loaderHeaders<'a>}

  type t<'a> = headersArgs<'a> => option<headers<'a>>
}

module Loader = {
  open Webapi
  type request = Fetch.Request.t
  type loaderArgs<'p, 'c> = {context: 'c, request: request, params: 'p}
  type t<'a, 'p, 'c> = loaderArgs<'p, 'c> => promise<'a>
}

module type LoaderData = {
  type t
  type params
  type context
}

module MakeLoader = (Data: LoaderData) => {
  type t = Loader.t<Data.t, Data.params, Data.context>

  type headers<'a> = Headers.loaderHeaders<'a>
  type jsonOptions<'a> = {headers: headers<'a>}

  @module("@remix-run/react")
  external json: (Data.t, ~jsonOptions: jsonOptions<'a>=?) => 'b = "json"

  @module("@remix-run/react")
  external useLoaderData: unit => Data.t = "useLoaderData"
}

@module("@remix-run/react")
external redirect: string => exn = "redirect"

module type ActionData = {
  type t
  type context
}

module MakeAction = (Data: ActionData) => {
  type actionArgs = {context: Data.context, request: Webapi.Fetch.Request.t}
  type t = actionArgs => promise<Js.Nullable.t<Data.t>>
}
