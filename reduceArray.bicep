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

var varReceipt = map(varGroceryStore, items => items.productPrice)
output outUsingReduce int = reduce(varReceipt, 0, (currentValue, previousValue) => currentValue + previousValue)

/*
How it works:
   -  First loop: currentValue (5) + previousValue (0)
   -  Second loop: currentValue (2) + previousValue (5)
   -  Third loop and last loop: currentValue (4) + previousValue (7)
   -  Outcome: 11
*/
