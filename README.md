# CartStatefull

An Elixir based cart manager for an online ordering application.
This is a demo application used for developing elixir skills.
I used many features from Elixir that I thought are appropiate (GenServer, GenStage, Flow)

## Functional specifications

Having this functional requirements:

- Each visitor of the site will have a shopping cart created when he adds first product
- He will be able to add as many products in the cart as needed
- If he does not complete the cart we need to notify him via email at a later time
- When he completes the cart we need to close it and store it for tracking
-

## Techical description

Techical approach will be something like this:

- When the user adds first product we will instantiate the cart
- For performance reasons we will store the cart in memory using GenServer
- From time to time we need to persist the cart in DB for recovery in case application is down
- After a timeout of inactivity we will remove the cart from memory and we will save it in DB
- I used websockes for client-server communication

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `cart_statefull` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:cart_statefull, "~> 0.1.0"}]
end
```
