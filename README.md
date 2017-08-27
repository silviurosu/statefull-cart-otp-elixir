# CartStatefull

An Elixir OTP based cart manager for an online ordering application. When we have a new user we create a new cart. Cart will be kept in memory for a specific timeout in case the user does no action in the cart. Each action done by user refreshes the timeout.


All the external methods are in CartStatefull module:

## Functionality already implemented

- create a new cart
- terminate cart by uuid
- get all uuids for active carts
- get all the cart content (buyer, items)
- add item to cart
- remove item from cart
- add buyer to cart

## This to do

- persist carts from time to time to recover in case of failure
