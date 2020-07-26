# Overview

Kashup is a red, tomatoey, distributed, in-memory key/value store, with configurable event streaming and element expiration.

## Kashup

Kashup works by assigning a key/pid pair to an interim table, which allows a pid to be retrieved with a key.  During a `Kashup.get/1` call, Kashup uses the provided key to retrieve the pid for the GenServer that was spawned on key/value pair creation, and assigned to manage the state of the value for said key.

This design naturally enables a cluster of BEAM nodes to operate on a single cache, using the same semantics as if the nodes were only a single BEAM instance communicating with itself.

## Configuration

Kashup can be configured to stream cache operation events and enforce expiration times on key/value pairs.

Enabling Kashup configuration features requires a `:kashup` block in your application's config file. The following few sections describe the available configuration fields.

### Event Streaming

To enable event streaming, add a the following field to the `:kashup` config block:

```
config :kashup,
  events: true
```

The event handler that Kashup currently ships with emits event messages to the running node's console. There are plans for a future release to provide an event handler behavior allowing custom event handling solutions.

### Element Expiration

To enable expiration, provide an integer representing the number of seconds a key/value pair should be valid for to an `:expiration` block.

For example, valid for one day:

```elixir
config :kashup,
  expiration: 60 * 60 * 24
```

For those who prefer to be explicit, `:infinity` can be provided to indicate persistant elements.

## Basic Demo

> The events have been separated out from the IEx output for readability

config.exs
```elixir
config :kashup,
  events: :true
  expiration: 5
```

Unix shell
```bash
$ iex --sname node@host -S mix run
```

IEx
```elixir
iex(node@host)1> Kashup.put(:request, %{url: "app.com"})
:ok
iex(node@host)2> Kashup.get(:request)
{:ok, %{url: "app.com"}}
iex(node@host)3> Kashup.get(:request)
{:error, :not_found}
iex(node@host)4> Kashup.delete(:request)
:ok
```

Event Stream
```elixir
[KASHUP] event: :started, pid: #PID<0.266.0>, time: 2020-07-26 02:51:39.257257Z
[KASHUP] event: {:put, [key: :request, value: %{url: "app.com"}], :create}, pid: #PID<0.266.0>, time: 2020-07-26 02:51:50.363260Z
[KASHUP] event: {:get, [key: :request]}, pid: #PID<0.266.0>, time: 2020-07-26 02:51:54.389043Z
[KASHUP] event: {:expired, [pid: #PID<0.271.0>, value: %{url: "app.com"}]}, pid: #PID<0.266.0>, time: 2020-07-26 02:51:55.389990Z
[KASHUP] event: {:get, [key: :request]}, pid: #PID<0.266.0>, time: 2020-07-26 02:52:02.821462Z
[KASHUP] event: {:delete, [key: :request]}, pid: #PID<0.266.0>, time: 2020-07-26 02:52:10.813540Z
```
