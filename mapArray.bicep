var varGroceryStore = [
  {
    productName: 'Icecream'
    productPrice: 5
    productCharacteristics: [
      'Vegan'
      'Seasonal'
    ]
  }
  {
    productName: 'Cheese'
    productPrice: 2
    productCharacteristics: [
      'Bio'
    ]
  }
  {
    productName: 'Banana'
    productPrice: 4
    productCharacteristics: [
      'Bio'
    ]
  }
]

output outUsingMap array = map(varGroceryStore, item => item.productName)
output outUsingMapAndStringInterpolation array = map(varGroceryStore, item => 'The price of item ${item.productName} is ${item.productPrice}.')
output outputDiscount array = map(range(0, length(varGroceryStore)), item => {
  productNumber: item
  productName: varGroceryStore[item].productName
  discountedPrice: 'The item ${varGroceryStore[item].productName} is on sale. Sale price: ${(varGroceryStore[item].productPrice / 2)}'
})
